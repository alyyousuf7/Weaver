// input filename
String imageFilename = "ali.jpg";

// output filename
String outputFilename = "output.txt";

// total number of points around the circle
int points = 256;

// total number of lines to be drawn
int lines = 3000;

// how many points to jump? helpful to save some extra lines to be drawn
int jump = 0;

// how many pixel color should be removed from the original image?
// lower is lighter, range: 0-255
int removeColor = 35;

// how dark a line should be drawn?
// lower is lighter, range: 0-255
int drawAlpha = 35;

// how many lines to be drawn in every iteration?
int fps = 100;

// pause after every iteration?
boolean stepByStep = false;

PImage img;

double [] px = new double[points];
double [] py = new double[points];
double [] lengths = new double[points];

int [] output = new int[lines+1];

boolean paused = true;
double radius = 0;

int linesDrawn = 0;
int currentPos = 0;

int width = 600;
int height = 600;
void setup() {
  size(1200, 600);
  
  img = loadImage(imageFilename);
  img.filter(GRAY);
  
  radius = img.width < img.height ? img.width/2 : img.height/2;
  
  // crop the image to square
  img = img.get((int)((img.width/2)-radius), (int)((img.height/2)-radius), (int)(radius*2), (int)(radius*2));
  
  // draw image for reference
  image(img, width, 0, width, height);
  
  // prepare some data and draw points
  for(int i=0;i<points;++i) {
    double d = Math.PI * 2.0 * (double)i/(double)points;
    px[i] = img.width/2 + Math.sin(d) * radius;
    py[i] = img.height/2 + Math.cos(d) * radius;
    
    double dx = px[i] - px[0];
    double dy = py[i] - py[0];
    lengths[i] = Math.floor( Math.sqrt(dx*dx+dy*dy) );
    
    stroke(color(0, 0, 255)); strokeWeight(3); point((float)(px[i]/(radius*2)*width), (float)(py[i]/(radius*2)*height));
  }

  // record the starting point
  output[linesDrawn] = currentPos;
}

void mouseReleased() {
  // click to pause or resume
  paused = paused ? false : true;  
}

boolean outputWritten = false;
void draw() {
  if (paused) return;

  if (linesDrawn >= lines) {
    if (!outputWritten) {
      PrintWriter file;
      file = createWriter(outputFilename);
      for(int i = 0; i < lines + 1; ++i) {
        file.println(output[i]);
      }
      file.flush();
      file.close();
    }

    return;
  }
  
  strokeWeight(1);
  for(int i = 0; i < fps; ++i) {
    if (linesDrawn >= lines) break;
    
    drawLine();
    linesDrawn++;

    output[linesDrawn] = currentPos;
  }
  image(img, width, 0, width, height);

  // draw progress bar
  strokeWeight(10);
  int barY = 10;
  int barWidth = 100;
  float progress = 1.0 * linesDrawn / lines;
  
  // empty bar
  stroke(color(125, 125, 125));
  line(width - barWidth/2, barY, width + barWidth/2, barY);
  
  // completed bar
  stroke(color(0, 255, 0));
  line(width - barWidth/2, barY, width - barWidth/2 + barWidth*progress, barY);

  if(stepByStep) {
    paused = true;
  }
}

void drawLine() {
  int bestNextPos = currentPos;
  double maxIntensity = 0;
  
  // find the next best position
  for(int i = 1 + jump; i < points - jump; ++i) {
    int nextPoint = (i + currentPos) % points;
    if (nextPoint == currentPos) continue;
    
    double len = lengths[i];
    double dx = px[nextPoint] - px[currentPos];
    double dy = py[nextPoint] - py[currentPos];
    
    // find the intensity of this line
    double intensity = 0;
    for(int j = 0; j < len; ++j) {
      double s = (double)j/len;
      int fx = (int)(px[currentPos] + dx * s);
      int fy = (int)(py[currentPos] + dy * s);
      intensity += img.get(fx, fy);
    }
    intensity = -intensity / len;
    
    // is it the highest? remember it...
    if (intensity > maxIntensity) {
      bestNextPos = nextPoint;
      maxIntensity = intensity;
    }
  }
  
  double dx = px[bestNextPos] - px[currentPos];
  double dy = py[bestNextPos] - py[currentPos];
  double len = bestNextPos > currentPos ? lengths[bestNextPos - currentPos] : lengths[currentPos - bestNextPos];
  
  // subtract some value from original picture on that line
  for(int i = 0; i < len; ++i) {
    double s = (double)i/len;
    int fx = (int) (px[currentPos] + dx * s);
    int fy = (int) (py[currentPos] + dy * s);
    
    float c = red(img.get(fx, fy));
    c += removeColor;
    if (c > 255) c = 255;
    
    img.set(fx, fy, color(c));
  }
  
  // now draw the line
  stroke(0, 0, 0, drawAlpha);
  line((float)(px[currentPos]/(radius*2)*width), (float)(py[currentPos]/(radius*2)*height), (float)(px[bestNextPos]/(radius*2)*width), (float)(py[bestNextPos]/(radius*2)*height));
  
  // set it the current pos
  currentPos = bestNextPos;
}