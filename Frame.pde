import processing.core.PVector;

abstract class Frame {
  abstract PVector[] getPoints();

  public PShape getFrameShape() {
    PShape frame = createShape();
    frame.setStroke(color(0, 0, 255));

    frame.beginShape(POINTS);

    PVector[] points = this.getPoints();
    for (int i = 0; i < points.length; i++) {
      frame.vertex(points[i].x, points[i].y);
    }

    frame.endShape();
    return frame;
  }

  public PShape[] getLineShapes(ArrayList<Line> lines) {
    PVector size = this.getSize();
    PShape[] shapes = new PShape[lines.size() - 1];

    PVector[] points = this.getPoints();
    for (int i = 1; i < lines.size(); ++i) {
      Line start_line = lines.get(i-1);
      Line end_line = lines.get(i);

      shapes[i-1] = createShape();
      shapes[i-1].beginShape(LINES);
      shapes[i-1].strokeWeight(1);

      // add a line to bottom to fixate the size of the shape...
      shapes[i-1].vertex(0, size.y);
      shapes[i-1].vertex(size.x, size.y);
      shapes[i-1].stroke(end_line.c);

      shapes[i-1].vertex(points[start_line.index].x, points[start_line.index].y);
      shapes[i-1].vertex(points[end_line.index].x, points[end_line.index].y);
      shapes[i-1].endShape();
    }

    return shapes;
  }

  public PVector getSize() {
    float width = 0;
    float height = 0;

    PVector[] points = this.getPoints();
    for (int i = 0; i < points.length; i++) {
      if (width < points[i].x) width = points[i].x;
      if (height < points[i].y) height = points[i].y;
    }

    return new PVector(width, height);
  }
}

class CircleFrame extends Frame {
  private PVector[] points;
  private int radius, count;

  public CircleFrame(int radius, int count) {
    this.radius = radius;
    this.count = count;

    this.points = new PVector[this.count];

    for (int i = 0; i < this.count; ++i) {
      double deg = Math.PI * 2 * i / this.count;

      this.points[i] = new PVector((float)(this.radius + Math.sin(deg) * this.radius), (float)(this.radius - Math.cos(deg) * this.radius));
    }
  }

  public PVector[] getPoints() {
    return this.points;
  }
}

class SquareFrame extends Frame {
  private PVector[] points;
  private int length, count;

  public SquareFrame(int length, int count) {
    this.length = length;
    this.count = count;

    this.points = new PVector[this.count];
    float step = (float)this.length / this.count * 4;

    // Top line
    int offset = 0;
    for (int i = 0; i < this.count / 4; ++i) {
      this.points[offset] = new PVector(i * step, 0);
      offset += 1;
    }

    // Right line
    for (int i = 0; i < this.count / 4; ++i) {
      this.points[offset] = new PVector(this.length, i * step);
      offset += 1;
    }

    // Bottom line
    for (int i = (this.count / 4) - 1; i >= 0; --i) {
      this.points[offset] = new PVector(i * step, this.length);
      offset += 1;
    }

    // Left line
    for (int i = (this.count / 4) - 1; i >= 0; --i) {
      this.points[offset] = new PVector(0, i * step);
      offset += 1;
    }
  }

  public PVector[] getPoints() {
    return this.points;
  }
}
