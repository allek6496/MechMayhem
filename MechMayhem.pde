Robot robot1;
Robot robot2;
PShape tread1, tread2;
PShape sawblade1, sawblade2, sawblade3, sawblade4, sawblade5, sawblade6;

void setup() {
  loadShapes();
  frameRate(30);
  size(600,600, P3D);
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

void loadShapes(){ // loads all shapes for weapon and movementPart Classes
  tread1 = loadShape("Movement\\treads\\tread1.svg");
  tread2 = loadShape("Movement\\treads\\tread2.svg");
  sawblade1 = loadShape("Weapon\\Sawblade\\sawblade1.svg");
  sawblade2 = loadShape("Weapon\\Sawblade\\sawblade2.svg");
  sawblade3 = loadShape("Weapon\\Sawblade\\sawblade3.svg");
  sawblade4 = loadShape("Weapon\\Sawblade\\sawblade4.svg");
  sawblade5 = loadShape("Weapon\\Sawblade\\sawblade5.svg");
  sawblade6 = loadShape("Weapon\\Sawblade\\sawblade6.svg");
}
