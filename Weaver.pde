// how many lines to be drawn in every iteration?
int fps = 100;

// pause after every iteration?
boolean stepByStep = false;

boolean paused = true;
boolean done = false;

Frame frame;
Layer layer;

int block_size;

void setup() {
  size(1200, 600);

  block_size = height;

  PImage img = loadImage("ali.jpg");

  // crop to square
  int min_length = img.width < img.height ? img.width : img.height;
  img = img.get(0, 0, min_length, min_length);

  // setup frame
  frame = new CircleFrame(min_length/2, 256);
  // frame = new SquareFrame(min_length, 256);

  // setup weaving layer
  color draw_color = color(color(0, 0, 0), 25);
  layer = new MonochromeLayer(frame, img, new WeaveConfig(3000, 0, 35, draw_color));
}

void drawAll() {
  background(255);

  if (frame == null || layer == null) {
    return;
  }

  translate(0, 0);
  shape(frame.getFrameShape(), 0, 0, block_size, block_size);

  translate(block_size, 0);
  image(layer.getOriginalImage(), 0, 0, block_size, block_size);

  translate(-block_size, 0);
  PShape lines = frame.getLineShape(layer.getLines());
  shape(lines, 0, 0, block_size, block_size);
}

void mouseReleased() {
  // toggle pause
  paused = !paused;
}

void draw() {
  if (done) return;

  if (!paused) {
    for (int i = 0; i < fps; ++i) {
      boolean layerDone = layer.drawNextLine();
      if (layer.drawNextLine()) {
        done = true;
      }
    }
  }

  drawAll();

  if (done) {
    selectOutput("Select a file to write to:", "writeToFile");
  }

  if (stepByStep) {
    paused = true;
  }
}

void writeToFile(File selection) {
  if (selection == null) {
    return;
  }

  PrintWriter file;
  file = createWriter(selection.getAbsolutePath());
  for (Line line : layer.getLines()) {
    file.println(line.index);
  }
  file.flush();
  file.close();
}
