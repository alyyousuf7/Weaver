abstract class Layer {
  abstract ArrayList<Line> getLines();
  abstract PImage getOriginalImage();
  abstract public boolean drawNextLine();
}

class MonochromeLayer extends Layer {
  private PImage original_img, working_img;
  private Frame frame;
  private WeaveConfig config;
  
  private ArrayList<Line> lines;
  private int lines_with_less_intensity;
  private int current_index;

  public MonochromeLayer(Frame frame, PImage img, WeaveConfig config) {
    this.frame = frame;

    PVector frame_size = this.frame.getSize();

    this.original_img = img.copy().get(0, 0, (int)frame_size.x, (int)frame_size.y);

    this.working_img = this.original_img.copy();
    this.working_img.filter(GRAY);

    this.config = config;

    this.lines = new ArrayList();
    this.lines.add(new Line(0, this.config.draw_color));
    this.current_index = 0;
  }

  public ArrayList<Line> getLines() {
    return this.lines;
  }

  public PImage getOriginalImage() {
    return this.original_img;
  }

  public boolean drawNextLine() {
    if (this.lines.size() > this.config.lines) {
      return true;
    }

    int next_index = this.findNextIndex();
    if (next_index == -1) {
      return true;
    }

    PVector current_point = this.frame.getPoints()[current_index];
    PVector next_point = this.frame.getPoints()[next_index];
    float line_len = PVector.dist(current_point, next_point);

    PVector point = current_point.copy();
    PVector step = PVector.sub(next_point, current_point).div(line_len);

    for (int i = 0; i < line_len; ++i) {
      float c = red(this.working_img.get((int)(point.x), (int)(point.y)));

      c += this.config.remove_intensity;
      if (c > 255) c = 255;

      this.working_img.set((int)(point.x), (int)(point.y), color(c));
      point.add(step);
    }

    this.lines.add(new Line(next_index, this.config.draw_color));
    this.current_index = next_index;
    return false;
  }

  private int findNextIndex() {
    if (this.lines_with_less_intensity >= 10) {
      return -1;
    }

    int best_next_index = this.current_index;
    double max_intensity = 0;

    for (int i = 1 + this.config.jump_lines; i < this.frame.getPoints().length - this.config.jump_lines; ++i) {
      int next_index = (i + this.current_index) % this.frame.getPoints().length;
      if (next_index == this.current_index) {
        continue;
      }

      PVector current_point = this.frame.getPoints()[current_index];
      PVector next_point = this.frame.getPoints()[next_index];
      float line_len = PVector.dist(current_point, next_point);
      
      PVector point = current_point.copy();
      PVector step = PVector.sub(next_point, current_point).div(line_len);

      // find this line's intensity
      double intensity = 0.0;
      for (int j = 0; j < line_len; ++j) {
        intensity += this.working_img.get((int)(point.x), (int)(point.y));
        point.add(step);
      }
      intensity = - intensity / line_len;

      if (intensity > max_intensity) {
        max_intensity = intensity;
        best_next_index = next_index;
      }
    }

    if (max_intensity == 0) {
      this.lines_with_less_intensity += 1;
    } else {
      this.lines_with_less_intensity = 0;
    }

    if (best_next_index == this.current_index) {
      return -1;
    }

    return best_next_index;
  }
}
