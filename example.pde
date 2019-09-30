class Example {
  public Frame frame;
  public Layer layer;

  public Example(Frame frame, Layer layer) {
    this.frame = frame;
    this.layer = layer;
  }
}

Example example01() throws Exception {
  PImage img = loadImage("ali.jpg");
  WeaveConfig config = new WeaveConfig(3000, 0, 35, color(color(0, 0, 0), 25));

  // crop to square
  int min_length = img.width < img.height ? img.width : img.height;
  img = img.get(0, 0, min_length, min_length);

  // setup frame
  frame = new CircleFrame(min_length/2, 256); // new SquareFrame(min_length, 256);

  // scale it down... because bigger the frame, bigger number of threads required...
  int cropped_size = 640;
  if (cropped_size < min_length) {
    min_length = cropped_size;
    img.resize(min_length, min_length);
  }

  // setup layer
  Layer layer = new MonochromeLayer(frame, img, config);

  return new Example(frame, layer);
}

Example example02() throws Exception {
  PImage img = loadImage("Lenna.jpg");
  PImage[] imgs = {
    loadImage("Lenna_Black.jpg"),
    loadImage("Lenna_Blue.jpg"),
    loadImage("Lenna_Yellow.jpg"),
    loadImage("Lenna_Red.jpg"),
  };
  WeaveConfig[] configs = {
    new WeaveConfig(2000, 0, 35, color(color(0, 0, 0), 25)),
    new WeaveConfig(2000, 0, 35, color(color(13, 22, 189), 25)),
    new WeaveConfig(1500, 0, 35, color(color(242, 229, 78), 25)),
    new WeaveConfig(3000, 0, 35, color(color(181, 2, 2), 25)),
  };

  // crop to square
  int min_length = img.width < img.height ? img.width : img.height;
  img = img.get(0, 0, min_length, min_length);

  // setup frame
  frame = new CircleFrame(min_length/2, 256); // new SquareFrame(min_length, 256);

  // scale it down... because bigger the frame, bigger number of threads required...
  int cropped_size = 640;
  if (cropped_size < min_length) {
    min_length = cropped_size;
    img.resize(min_length, min_length);
  }

  // setup layer
  Layer layer = new MultipleImageLayer(frame, img, imgs, configs);

  return new Example(frame, layer);
}

Example example03() throws Exception {
  PImage img = loadImage("Lenna.jpg");
  WeaveConfig[] configs = {
    new WeaveConfig(2000, 0, 35, color(color(0, 0, 0), 25)),
    new WeaveConfig(2000, 0, 35, color(color(13, 22, 189), 25)),
    new WeaveConfig(1500, 0, 35, color(color(242, 229, 78), 25)),
    new WeaveConfig(3000, 0, 35, color(color(181, 2, 2), 25)),
  };

  // crop to square
  int min_length = img.width < img.height ? img.width : img.height;
  img = img.get(0, 0, min_length, min_length);

  // scale it down... because bigger the frame, bigger number of threads required...
  int cropped_size = 640;
  if (cropped_size < min_length) {
    min_length = cropped_size;
    img.resize(min_length, min_length);
  }

  // setup frame
  frame = new CircleFrame(min_length/2, 256); // new SquareFrame(min_length, 256);

  // setup layer
  Layer layer = createColorLayer(frame, img, configs);

  return new Example(frame, layer);
}
