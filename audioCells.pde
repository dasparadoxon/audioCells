// AUDIO CELLS

// DISPLAYS STEP-BY-STEP ENERGY TRANSFER LAYERS 
// AND USES AUDIO INPUT TO FEED THE ENERGIE INTO LAYERS DEPENDING ON FREQUENCIES

// WEBZIS 
// https://stackoverflow.com/questions/11867545/change-text-color-based-on-brightness-of-the-covered-background-area

import processing.sound.*;
import controlP5.*;


ControlP5 cp5;

SoundFile sample;
FFT fft;
AudioDevice device;
LowPass lowPass;

// Define how many FFT bands we want
int bands = 8;

public enum Direction {

  LEFT, RIGHT, UP, DOWN
}

int time;
int timeStep;
int wait = 4;
int waitStep = wait;

ArrayList<Layer> layers = new ArrayList<Layer>();

int squareCellSize = 5;

int spacing = 120;

int cellWidth = spacing/2;
int cellHeight = spacing/2;

public int cellGridWidth = squareCellSize;
public int cellGridHeight = squareCellSize;  

Arrow[] inputArrows = new Arrow[4];

Cell[][] cells;

Layer highFrequenciesLayer = new Layer("Höhen", Direction.DOWN);
Layer midFrequenciesLayerLeft = new Layer("MittenLinks", Direction.LEFT);
Layer bottomFrequenciesLayer = new Layer("Bässe", Direction.UP);
Layer midFrequenciesLayerRight = new Layer("MittenRechts", Direction.RIGHT);

void guiSetup() {

  cp5 = new ControlP5(this);

  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("toggleHeights")
    .setPosition(width/2 +120 / 2, 5 + 20)
    .setSize(50, 20)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    ;

  cp5.addToggle("toggleBasses")
    .setPosition(width/2 +120 / 2, height - 65 + 20)
    .setSize(50, 20)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    ;     

  cp5.addToggle("toggleLeft")
    .setPosition(20 + 3, height/2 +60)
    .setSize(24, 12)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    ;        

  cp5.addToggle("toggleRight")
    .setPosition(width - 47, height/2 +60)
    .setSize(24, 12)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    ;      

  cp5.addToggle("showNumericValues")
    .setPosition(10, 10)
    .setCaptionLabel("mesh setup")
    .setSize(24, 12)
    .setValue(true)
    .setMode(ControlP5.SWITCH)
    ;       

  cp5.getController("showNumericValues").getCaptionLabel().setColor(color(255, 255, 255) );

  cp5.addTextlabel("numericValuesLabel")
    .setText("Show values")
    .setPosition(40, 10)
    .setColorValue(0xffffffff)
    .setFont(createFont("Georgia", 20));
}

void toggleHeights(boolean theFlag) {


  if (theFlag==true) {
    highFrequenciesLayer.active = true;
  } else {
    highFrequenciesLayer.active = false;
  }
  println("High Frequency Status :  "+highFrequenciesLayer.active);
}

void toggleBasses(boolean theFlag) {


  if (theFlag==true) {
    bottomFrequenciesLayer.active = true;
  } else {
    bottomFrequenciesLayer.active = false;
  }
  println("bottomFrequenciesLayer Frequency Status :  "+highFrequenciesLayer.active);
}

void toggleLeft(boolean theFlag) {


  if (theFlag==true) {
    midFrequenciesLayerLeft.active = true;
  } else {
    midFrequenciesLayerLeft.active = false;
  }
  println("midFrequenciesLayerLeft Frequency Status :  "+highFrequenciesLayer.active);
}

void toggleRight(boolean theFlag) {


  if (theFlag==true) {
    midFrequenciesLayerRight.active = true;
  } else {
    midFrequenciesLayerRight.active = false;
  }
  println("midFrequenciesLayerRight Frequency Status :  "+highFrequenciesLayer.active);
}

void setup() {

  guiSetup();

  inputArrows[0] = new Arrow(Direction.DOWN, "HEIGHTS", highFrequenciesLayer);
  inputArrows[1] = new Arrow(Direction.UP, "BASS", bottomFrequenciesLayer);
  inputArrows[2] = new Arrow(Direction.LEFT, "MIDS", midFrequenciesLayerLeft);
  inputArrows[3] = new Arrow(Direction.RIGHT, "MIDS", midFrequenciesLayerRight);

  time = millis();//store the current time
  timeStep = millis();//store the current time

  size(800, 800);

  frameRate(60);

  // AUDIO 

  device = new AudioDevice(this, 44000, bands);

  lowPass = new LowPass(this);

  initAudio();

  // Cells & Layers

  initializeCells();

  layers.add(midFrequenciesLayerRight);
  layers.add(highFrequenciesLayer);
  layers.add(bottomFrequenciesLayer);
  layers.add(midFrequenciesLayerLeft);

  mergeLayersIntoMainCells();
}

void initAudio() {

  sample = new SoundFile(this, "beat1.mp3");
  sample.play();
  sample.amp(0.5);

  lowPass.process(sample, 800);

  // Create and patch the FFT analyzer
  fft = new FFT(this, bands);
  fft.input(sample);
}

void draw() {

  pushStyle();

  background(255);

  inputArrows[0].draw();
  inputArrows[1].draw();
  inputArrows[2].draw();
  inputArrows[3].draw();

  fft.analyze();

  drawLittleSpektrum();

  if (millis() - time >= wait) {

    time = millis();//also update the stored time



    float energyFromBass = fft.spectrum[0];

    float scaledEnergyFromBass = map(energyFromBass, 0, 1, 0, 255);

    bottomFrequenciesLayer.applyForceToCell(2, 4, scaledEnergyFromBass);
    bottomFrequenciesLayer.applyForceToCell(1, 4, scaledEnergyFromBass / 2);
    bottomFrequenciesLayer.applyForceToCell(3, 4, scaledEnergyFromBass / 2);
    bottomFrequenciesLayer.applyForceToCell(0, 4, scaledEnergyFromBass / 4);
    bottomFrequenciesLayer.applyForceToCell(4, 4, scaledEnergyFromBass / 4);

    scaledEnergyFromBass = map(energyFromBass, 0, 1, 0, 50);

    inputArrows[1].intensity = scaledEnergyFromBass;

    // HIGHS

    float energyFromHeights = fft.spectrum[5];

    float scaledEnergyFromHeights = map(energyFromHeights, 0, 1, 0, 255);

    highFrequenciesLayer.applyForceToCell(0, 0, scaledEnergyFromHeights/ 4);
    highFrequenciesLayer.applyForceToCell(1, 0, scaledEnergyFromHeights / 2);
    highFrequenciesLayer.applyForceToCell(2, 0, scaledEnergyFromHeights );
    highFrequenciesLayer.applyForceToCell(3, 0, scaledEnergyFromHeights / 2);
    highFrequenciesLayer.applyForceToCell(4, 0, scaledEnergyFromHeights / 4);

    scaledEnergyFromHeights = map(energyFromHeights, 0, 1, 0, 50);

    inputArrows[0].intensity = scaledEnergyFromHeights;    

    // MIDS

    float energyFromMids = fft.spectrum[3];

    float scaledEnergyFromMids = map(energyFromMids, 0, 1, 0, 255);

    midFrequenciesLayerLeft.applyForceToCell(0, 2, scaledEnergyFromHeights);
    midFrequenciesLayerLeft.applyForceToCell(0, 1, scaledEnergyFromHeights / 2);
    midFrequenciesLayerLeft.applyForceToCell(0, 3, scaledEnergyFromHeights / 2);
    midFrequenciesLayerLeft.applyForceToCell(0, 0, scaledEnergyFromHeights / 4);
    midFrequenciesLayerLeft.applyForceToCell(0, 4, scaledEnergyFromHeights / 4);   

    scaledEnergyFromHeights = map(energyFromMids, 0, 1, 0, 50);

    inputArrows[2].intensity = scaledEnergyFromHeights;   

    // RIGHT

    energyFromMids = fft.spectrum[3];

    scaledEnergyFromMids = map(energyFromMids, 0, 1, 0, 255);

    midFrequenciesLayerRight.applyForceToCell(4, 2, scaledEnergyFromHeights);
    midFrequenciesLayerRight.applyForceToCell(4, 1, scaledEnergyFromHeights / 2);
    midFrequenciesLayerRight.applyForceToCell(4, 3, scaledEnergyFromHeights / 2);
    midFrequenciesLayerRight.applyForceToCell(4, 0, scaledEnergyFromHeights / 4);
    midFrequenciesLayerRight.applyForceToCell(4, 4, scaledEnergyFromHeights / 4); 

    scaledEnergyFromHeights = map(energyFromMids, 0, 1, 0, 50);

    inputArrows[3].intensity = scaledEnergyFromHeights;
  }  

  if (millis() - timeStep >= waitStep) {

    timeStep = millis();//also update the stored time

    step();
  }

  drawLayers();

  popStyle();
}

void drawLittleSpektrum() {

  int r_width = 160 / bands;

  // Create a smoothing vector
  float[] sum = new float[bands];

  // Declare a scaling factor
  int scale=5;

  // Create a smoothing factor
  float smooth_factor = 0.6;  

  pushStyle();

  background(255, 255, 255);
  
  fill(255,255,255);
  
  rect(10,height-100,160,80);
  
  fill(255, 0, 150);
  
  noStroke();
  

  for (int i = 0; i < bands; i++) {

    // smooth the FFT data by smoothing factor
    //sum[i] += (fft.spectrum[i] - sum[i]) * smooth_factor;
    
   //println(fft.spectrum[i]);
   
   float spe = fft.spectrum[i];
    
    float heightOfBars = map(spe*4,0,1,0,40);
    
    println(heightOfBars);

    // draw the rects with a scale factor
    rect( 10 + i*r_width, height-20, r_width,  -heightOfBars);
  }

  popStyle();
}


void keyPressed() {

  step();
}

void initializeCells() {

  cells = new Cell[cellGridHeight][cellGridWidth];

  for (int y=0; y<5; y++)
    for (int x=0; x<5; x++) {

      Cell newCell = new Cell();

      newCell.x = x;
      newCell.y = y;

      newCell.value = 0f;

      cells[y][x] = newCell;
    }
}

void step() {

  runLayers();

  mergeLayersIntoMainCells();
}

void runLayers() {

  for (Layer layer : layers) {

    //println("Running layer :"+layer.name);

    layer.step();
  }
}

void mergeLayersIntoMainCells() {

  initializeCells();

  for (Layer layer : layers) {

    for (int y=0; y<5; y++)
      for (int x=0; x<5; x++) {

        //println("Mergin Layer :"+layer.name+" of Cell ("+x+"/"+y+") with value : "+layer.cells[y][x].value);

        cells[y][x].value += layer.cells[y][x].value;
      }
  }
}


void drawLayers() {

  pushMatrix();

  translate(width/2 - (squareCellSize*spacing/2) + (spacing/2), height/2- (squareCellSize*spacing/2)+ (spacing/2));

  rect(-45, -45, squareCellSize*spacing - 30, squareCellSize*spacing - 25);

  for (int y=0; y<5; y++)
    for (int x=0; x<5; x++) {

      pushStyle();

      float colorValue = map(cells[y][x].value, 0, 3, 0, 127 + 55);

      colorValue += 127 - 55;

      fill(colorValue, 127, 127);

      float size = map(cells[y][x].value, 0, 3, 2, cellWidth/4);

      ellipse(x*spacing, y*spacing, size, size);

      popStyle();

      // Text Value

      pushStyle();

      String s = String.format("%.2f", cells[y][x].value);

      float textColor = 255;

      if (getContrastYIQ(colorValue, colorValue, colorValue) == "black")
        textColor = 0;

      fill(textColor, textColor, textColor);

      int  valuePosOffset = -5;

      //text(s, x*spacing - valuePosOffset - 15, y*spacing - valuePosOffset);

      popStyle();
    }

  popMatrix();
}

String getContrastYIQ(float r, float g, float b) {

  float yiq = ((r*299)+(g*587)+(b*114))/1000;

  if (yiq >= 128)
    return "black";

  return "white";
}  