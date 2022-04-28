Robot robot1;
Robot robot2;
PShape tread1, tread2, tread3, tread4, tread5, tread6, tread7;
PShape sawblade;

void setup() {
  loadShapesL();
  frameRate(45);
  size(600,600);
  robot1 = new Robot(2, 0, 0.1, 200, 200, 0);
  robot2 = new Robot(2, 1, 0.75, 400, 400, 0);
}

void draw() {
  background(100);

  stroke(255);
  
  textAlign(LEFT,TOP);
  text("LOL",0,0);

    robot1.update(robot2);
    robot2.update(robot1);

    robot1.drawEffects(robot2);
    robot2.drawEffects(robot1);
}

void loadShapesL() {
  tread1  = loadShape("Movement/treads/tread1.svg");
  tread2  = loadShape("Movement/treads/tread2.svg");
  tread3  = loadShape("Movement/treads/tread3.svg");
  tread4  = loadShape("Movement/treads/tread4.svg");
  tread5  = loadShape("Movement/treads/tread5.svg");
  tread6  = loadShape("Movement/treads/tread6.svg");
  tread7  = loadShape("Movement/treads/tread7.svg");
  sawblade = loadShape("Weapon/SawBlade/sawblade1.svg");
}

void loadShapes(){ // loads all shapes for weapon and movementPart Classes
  tread1 = loadShape("Movement\\treads\\tread1.svg");
  tread2 = loadShape("Movement\\treads\\tread2.svg");
  tread3 = loadShape("Movement\\treads\\tread3.svg");
  tread4 = loadShape("Movement\\treads\\tread4.svg");
  tread5 = loadShape("Movement\\treads\\tread5.svg");
  tread6 = loadShape("Movement\\treads\\tread6.svg");
  tread7 = loadShape("Movement\\treads\\tread7.svg");
  sawblade = loadShape("Weapon\\SawBlade\\sawblade1.svg");
}
