Robot robot1;
Robot robot2;
PShape tread1, tread2, tread3, tread4, tread5, tread6, tread7;
PShape sawblade;

void setup() {
  loadShapes();
  frameRate(45);
  size(600,600);
  
  /**
  First three numbers:
  0        | 1      | 2
  Small    | Medium | Large
  Sawblade | Laser  | Hammer
  Tread    | Wheel  | Leg

  4th number: default aggression
  5th and 6th numbers: starting x and y

  7th number: starting rotation 0 -> TWO_PI

  Last boolean: Player? true => use setAgression() and usePower() to control, false => autonomous
   */
  robot1 = new Robot(2, 0, 2, 0.9, 200, 200, 0, false);
  robot2 = new Robot(0, 1, 1, 0.3, 400, 400, 0, false);
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
    println("R1: ", robot1.hp, "\tR2: ", robot2.hp);
    println("A1: ", round(robot1.aggressiveness*100)/100.0, "\tA2: ", round(robot2.aggressiveness*100)/100.0);
    println();
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
