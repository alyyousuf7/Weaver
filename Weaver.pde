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

  try {
    Example example;

    // if you want a black/white output
    // example = example01();

    // if you want colored output, but have colors separated out yourself
    // example = example02();

    // if you want colored output, and rely on Weaver's algorithm to separate out colors for you
    example = example03();

    frame = example.frame;
    layer = example.layer;
  } catch(Exception e) {
    println(e);
    exit();
  }
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
  PShape[] lines = frame.getLineShapes(layer.getLines());
  for (PShape line : lines) {
    shape(line, 0, 0, block_size, block_size);
  }
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
      if (layerDone) {
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
    file.println(line.index + " ; Color: #" + hex(line.c));
  }
  file.flush();
  file.close();
}
