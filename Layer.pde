abstract class Layer {
  abstract ArrayList<Line> getLines();
  abstract PImage getOriginalImage();
  abstract PImage getWorkingImage();
  abstract public boolean drawNextLine();

  public Layer(Frame frame, PImage img) throws Exception {
    PVector frame_size = frame.getSize();
    if (frame_size.x > img.width || frame_size.y > img.height) {
      throw new Exception("Frame should be smaller or equal to image size.");
    }
  }
}

class MonochromeLayer extends Layer {
  private PImage original_img, working_img;
  private Frame frame;
  private WeaveConfig config;
  
  private ArrayList<Line> lines;
  private int lines_with_less_intensity;
  private int current_index;

  public MonochromeLayer(Frame frame, PImage img, WeaveConfig config) throws Exception {
    super(frame, img);

    this.frame = frame;
    this.config = config;

    PVector frame_size = this.frame.getSize();
    this.original_img = img.copy().get(0, 0, (int)frame_size.x, (int)frame_size.y);

    this.working_img = this.original_img.copy();
    this.working_img.filter(GRAY);

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

  public PImage getWorkingImage() {
    return this.working_img;
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

class MultipleImageLayer extends Layer {
  private PImage original_img;
  private PImage working_img;
  private Frame frame;
  private WeaveConfig[] configs;

  private Layer[] layers;

  public MultipleImageLayer(Frame frame, PImage original_img, PImage[] img, WeaveConfig[] configs) throws Exception {
    super(frame, original_img);

    for (int i = 0; i < img.length; ++i) {
      if (original_img.width != img[i].width || original_img.height != img[i].height) {
        throw new Exception("Images are not the same dimensions.");
      }
    }

    if (img.length != configs.length) {
      throw new Exception("Images and configs should be same quantity.");
    }
    this.frame = frame;
    this.configs = configs;

    PVector frame_size = this.frame.getSize();
    this.original_img = original_img.get(0, 0, (int)frame_size.x, (int)frame_size.y);

    this.layers = new MonochromeLayer[this.configs.length];
    for (int i = 0; i < this.configs.length; ++i) {
      this.layers[i] = new MonochromeLayer(this.frame, img[i], this.configs[i]);
    }

    // set a random image as working image...
    this.working_img = img[0];
  }

  public ArrayList<Line> getLines() {
    ArrayList<Line> lines = new ArrayList();

    for (int i = 0; i < this.configs.length; i++) {
      lines.addAll(this.layers[i].getLines());
    }

    return lines;
  }

  public PImage getOriginalImage() {
    return this.original_img;
  }

  public PImage getWorkingImage() {
    return this.working_img;
  }

  public boolean drawNextLine() {
    for (int i = 0; i < this.configs.length; i++) {
      if (this.layers[i].drawNextLine() == false) {
        return false;
      }
    }

    return true;
  }
}

Layer createColorLayer(Frame frame, PImage img, WeaveConfig[] configs) throws Exception {
  PVector frame_size = frame.getSize();

  PImage original_img = img.copy().get(0, 0, (int)frame_size.x, (int)frame_size.y);

  PImage[] imgs = new PImage[configs.length];

  for (int i = 0; i < configs.length; ++i) {
    imgs[i] = new PImage(img.width, img.height, RGB);
  }

  for (int x = 0; x < img.width; ++x) {
    for (int y = 0; y < img.height; ++y) {
      int i = y*img.width+x;
      color pixel_color = img.pixels[i];
      PVector pixel_color_vect = new PVector(red(pixel_color), green(pixel_color), blue(pixel_color));

      for (int j = 0; j < configs.length; ++j) {
        color draw_color = configs[j].draw_color;
        PVector draw_color_vect = new PVector(red(draw_color), green(draw_color), blue(draw_color));

        float dist = PVector.dist(draw_color_vect, pixel_color_vect);
        dist = color_level(dist); // make dark darker, bright brighter

        imgs[j].pixels[i] = color(dist, dist, dist);
      }
    }
  }

  return new MultipleImageLayer(frame, original_img, imgs, configs);
}

float color_level(float x) {
  return (float)(255*1.0/(1+Math.exp(9-0.05*x)));
}
