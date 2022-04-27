Robot robot;
PShape tread1, tread2;

void setup() {
  loadShapes();
  frameRate(30);
  size(600,600);
  robot = new Robot(2, 0.75, 200, 200, 0);
}

void draw() {
  background(100);

  stroke(255);
  
  textAlign(LEFT,TOP);
  text("LOL",0,0);

    robot.update(null);
}

void loadShapes(){ // loads all shapes for weapon and movementPart Classes
  tread1 = loadShape("Movement\\treads\\tread1.svg");
  tread2 = loadShape("Movement\\treads\\tread2.svg");
}
