Robot robot1;
Robot robot2;

void setup() {
  frameRate(60);
  size(600,600);
  robot1 = new Robot(2, 0.75, 200, 200, 0);
  robot2 = new Robot(0, 0.25, 400, 400, 0);
}

void draw() {
  background(100);

  stroke(255);
  
  textAlign(LEFT,TOP);
  text("LOL",0,0);

    robot1.update(robot2);
    robot2.update(robot1);
}
