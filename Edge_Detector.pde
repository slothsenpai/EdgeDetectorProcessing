/*
  Addison Beall
  This script is largely based off the pixel sorting script from Kim Asendorf (kimasendorf.com | https://github.com/kimasendorf/ASDFPixelSort)
  
  This script has several features which is controlled by the mode value
    0: This will parse out the red value from each pixel and set it to some random value in the range of 0 - 255
    1: This will run an edge detection algorithm, but requires the user to enter a threshold value (lower value - more aggressive classification of an edge; higher value - less aggressive classification of an edge)
        After edge detection is performed, the pixels which are not edges are set to white leaving just the black edges
    2: This will pull out only the red values from an image
    3: This will pull out only the green values from an image
    4: This will pull out only the blue values from an image
    5: This will make everything not a black pixel completely transparent (doesn't work) The intent here was to run this after edge detection, but changing the alpha value doesn't seem to affect the image at all
*/


import java.util.Random;
import java.util.Hashtable;

PImage img;
String imgFileName = "file";
String fileType = "type";

int loops = 1;

Random r = new Random();
int row = 0;
int column = 0;
boolean saved = false;

Hashtable<Integer, Integer> points = new Hashtable<Integer, Integer>();

int mode = 5;

void setup() {
  img = loadImage(imgFileName+"."+fileType);
  
  // use only numbers (not variables) for the size() command, Processing 3
  size(1, 1);
  
  // allow resize and update surface to image dimensions
  surface.setResizable(true);
  surface.setSize(img.width, img.height);
  
  // load image onto surface - scale to the available width,height for display
  image(img, 0, 0, width, height);
}


void draw() {
  
  // load updated image onto surface and scale to fit the display width,height
  img.loadPixels();
  switch(mode){
    case 0:
      randomRed(img.width, img.height);
      break;
    case 1:
      edges(img.width, img.height, 12);
      break;
    case 2:
      filterRed(img.width, img.height);
      break;
    case 3:
      filterGreen(img.width, img.height);
      break;
    case 4:
      filterBlue(img.width, img.height);
      break;
    case 5:
      transparent(img.width, img.height);
      break;
  }
  img.updatePixels();
  
  
  image(img, 0, 0, width, height);
  
  if(!saved && frameCount >= loops) {
    
  // save img
    img.save(imgFileName+"_"+mode+".png");
  
    saved = true;
    println("Saved "+frameCount+" Frame(s)");
    
    // exiting here can interrupt file save, wait for user to trigger exit
    println("Click or press any key to exit...");
  }
  //System.exit(0);
}

void keyPressed() {
  if(saved)
  {
    System.exit(0);
  }
}

void mouseClicked() {
  if(saved)
  {
    System.exit(0);
  }
}

// Set all red values to random ints between 0 - 255
void randomRed(int _width, int _height){
  
  for(int i = 0; i < (_width * _height) - _width; i++){
    int temp = img.pixels[i];
    int rand = r.nextInt(255);
    
    int blue = temp & 0x000000FF;
    temp = temp >> 8;
    int green = temp & 0x0000FF;
    temp = temp >> 8;
    int red = temp & 0x00FF;
    temp = temp & 0xFF00;
    temp = temp >> 8;
    int alpha = temp & 0xFF;
    alpha /= 2;
    red = rand;
    
    temp = alpha;
    temp = temp << 8;
    temp |= red;
    temp = temp << 8;
    temp |= green;
    temp = temp << 8;
    temp |= blue;
    
    img.pixels[i] = temp;
  }
}

// Find all edges and place a black pixel before the edge
// An edge is two pixels whose average difference inRGB value is greater than some threshold argument
// This is a slightly modified version of the Canny edge detection algorithm

void edges(int _width, int _height, int thresh){
  for(int i = 1; i < (_width * _height) - _width; i++){
    int prevy;
    
    int prevx = img.pixels[i-1];
    int curr = img.pixels[i];
    int nextx = img.pixels[i];
    int nexty = img.pixels[(i+width)];
    double prevxAvg, prevyAvg, nextxAvg, nextyAvg, avgxDiff, avgyDiff;
    int threshold = thresh;
    
     
    if(i > width){
      prevy = img.pixels[(i-width)];
      prevyAvg = rgbAverage(prevy);
    } else {
      prevy = 0;
      prevyAvg = 0.0;
    }
    
    if(i % width == 0){
      prevx = 0;
      nextx = 0;
      prevxAvg = 0.0;
      nextxAvg = 0.0;
    } else {
      prevxAvg = rgbAverage(prevx);
      nextxAvg = rgbAverage(nextx);
    }
    
    // parse out each 8-bit value corresponding to RGB values, ignore alpha value which is bits 23 - 31
    
    nextyAvg = rgbAverage(nexty);
    
    avgxDiff = (-0.5 * prevxAvg) + (0.5 * nextxAvg);
    avgyDiff = (-0.5 * prevyAvg) + (0.5 * nextyAvg);
    
    // If we find an edge, set the previous x pixel as a black pixel and add the pixel number to our hashtable of edge points
    if(avgxDiff >= threshold){
      img.pixels[i-1] = 0xFF000000;
      points.put(i-1, 1);
    }
    if(avgyDiff >= threshold && i > width){
      img.pixels[i-width] = 0xFF000000;
      points.put(i-width, 1);
    }
  }
  
  for(int i = 0; i < (_width * _height) - _width; i++){
    if(points.get(i) == null){
      int temp = 0x01;
      temp = temp << 24;
      temp = temp | 0xFFFFFFFF;
      img.pixels[i] = temp;
    }
  }
}

void filterRed(int _width, int _height){
  for(int i = 0; i < (_width * _height) - _width; i++){
    img.pixels[i] = (img.pixels[i] & 0xFFFF0000);
  }
}

void filterGreen(int _width, int _height){
  for(int i = 0; i < (_width * _height) - _width; i++){
    img.pixels[i] = (img.pixels[i] & 0xFF00FF00);
  }
}

void filterBlue(int _width, int _height){
  for(int i = 0; i < (_width * _height) - _width; i++){
    img.pixels[i] = (img.pixels[i] & 0xFF0000FF);
  }
}

void transparent(int _width, int _height){
    for(int i = 0; i < (_width * _height) - _width; i++){
      if(img.pixels[i] != 0xFF000000){
        int temp = img.pixels[i];
    
        int blue = temp & 0x000000FF;
        temp = temp >> 8;
        int green = temp & 0x0000FF;
        temp = temp >> 8;
        int red = temp & 0x00FF;
        temp = temp >> 8;
        int alpha = temp & 0xFF;
        alpha = 0;
        
        temp = alpha;
        temp = temp << 8;
        temp |= red;
        temp = temp << 8;
        temp |= green;
        temp = temp << 8;
        temp |= blue;
        
        img.pixels[i] = temp;
      }
    }
}

int rgbAverage(int rgb){
  int total = 0;
  total += rgb & 0xFF;
  rgb = rgb >> 8;
  total += rgb & 0xFF;
  rgb = rgb >> 8;
  total += rgb & 0xFF;
  total /= 3;
  return total;
}
