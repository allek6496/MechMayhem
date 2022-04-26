Robot robot;

void setup() {
  frameRate(60);
  size(600,600);
  robot = new Robot(2, 200, 200, 0);
}

void draw() {
  background(100);

  stroke(255);
  
  textAlign(LEFT,TOP);
  text("LOL",0,0);

  robot.update();
}
