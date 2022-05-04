/*
NO MECHANICAL EFFECTS ARE PRESENT IN THIS FILE, VISUAL ONLY

Movement
  Wheel
    No animation (mostly hidden)
  Leg (crab style)
    Animation that plays during movement, continuous back and forth on pivot
Caution: Only .svg files from Adobe Illustrator or Inkscape work
*/
class MovementPart{
  int type; // Tread, Wheel, Leg. 
  int size;

  Robot robot;
  
  MovementPart(int t, Robot robot){
    this.type = t;
    this.size = robot.size;
    this.robot = robot;
  }

  void draw() {return;}
} // CLASS

class Legs extends MovementPart {
  float anim; // 0 -> 1 as legs move
  int legDir; // 1 or -1 for the increment/decrementing anim
  int legLength;
  int legWidth;

  // death anim variables
  float legOffset;
  float legRotation;

  float legRange = PI/3; // how far the legs can rotate

  Legs(Robot robot) {
    super(2, robot);
    
    anim = 0;
    legDir = 1;

    this.legOffset = 0;
    this.legRotation = 0;

    legLength = 10 + size*4;
    legWidth = 6 + size*4;
  }

  Legs(int level, Robot robot) {
    this(robot);

    if (level == 1) {
      legWidth += 2 + size*3;
      legLength += 3  + size*3;
    }
  }

  void draw() {
    float deathProg = (robot.deathAnimLength - robot.deathFrames)/float(robot.deathAnimLength);
    if (robot.hp <= 0) {
      legRotation += 0.06*deathProg;
      legOffset += 2*deathProg;
    }

    // front left wheel
    pushMatrix();
    translate((robot.length()/2 + legOffset), robot.length()/2 - robot.size*2 -4 + legOffset/3);
    rotate(legRotation);
    drawLeg(0, 0, 0, -1*PI/2);

    popMatrix();

    // front right wheel
    pushMatrix();
    translate(-1*(robot.length()/2 + legOffset), robot.length()/2 - robot.size*2 -4 + legOffset/3);
    rotate(legRotation);
    drawLeg(0, 0, PI/8, -1*3*PI/2);

    popMatrix();

    // back left wheel
    pushMatrix();
    translate((robot.length()/2 + legOffset), -1*robot.length()/2 + robot.size*2 +4 - legOffset/3);
    rotate(-legRotation);
    drawLeg(0, 0, PI/4, -1*PI/2);

    popMatrix();

    // back right wheel
    pushMatrix();
    translate(-1*(robot.length()/2 + legOffset), -1*robot.length()/2 + robot.size*2 +4 - legOffset/3);
    rotate(-legRotation);
    drawLeg(0, 0, 3*PI/8, -1*3*PI/2);
    popMatrix();

    // // front right
    // drawLeg(robot.length()/2, robot.length()/2 - robot.size, 0, -1*PI/2);

    // // front left
    // drawLeg(-1*robot.length()/2, robot.length()/2 - 2 - robot.size, PI/8, -1*3*PI/2);

    // // back right
    // drawLeg(robot.length()/2, -1*robot.length()/2 + 2 + robot.size, PI/4, -1*PI/2);

    // // back left
    // drawLeg(-1*robot.length()/2, -1*robot.length()/2 + 2 + robot.size, 3*PI/8, -1*3*PI/2);

    anim += 0.05*legDir*deathProg;

    if (anim > 1) {
      if (robot.hp > 0 || robot.deathFrames < 15) legDir = -1;
      anim = 1;
    } else if (anim < 0) {
      legDir = 1;
      anim = 0;
    }
  }

  // offset adds to the angle, changing the phase offset from anim
  // angleCenter from 0 to TWO_PI is where the leg's average position points
  private void drawLeg(float x, float y, float offset, float angleCenter) { 
    float theta = (angleCenter + cos(offset + (anim-0.5)*2*PI) * legRange) % TWO_PI;
    
    pushMatrix();
    translate(x, y);
    rotate(theta);

    fill(50);
    noStroke();
    beginShape();

    vertex(-2, 0);
    vertex(2, 0);

    vertex(legWidth/2, legLength/2);

    vertex(2, legLength);
    vertex(-2, legLength);
    
    vertex(-1*legWidth/2, legLength/2);

    endShape(CLOSE);


    // angleCenter will either be PI/2 or 3*PI/2 if it's a parent leg, so if it's 0, must be a child leg
    if (angleCenter != 0) {
      drawLeg(0, legLength, offset - PI/2, 0);
    } 

    popMatrix();
  }
}

class Wheel extends MovementPart {
  float anim; // 0 -> 1 as wheels spin
  int wheelWidth;
  int wheelLength;

  float wheelRotation;
  float wheelOffset;

  Wheel(Robot robot) {
    super (1, robot);
    this.anim = 0;

    this.wheelRotation = 0;
    this.wheelOffset = 0;

    this.wheelWidth = 8 + size*2;
    this.wheelLength = robot.length()/3;
  }

  Wheel(int level, Robot robot) {
    this(robot);

    if (level == 1) {
      wheelWidth += 2 + size;
      wheelLength += robot.length()/9;
    }
  }

  void draw() {
    if (robot.hp <= 0) {
      float deathProg = (robot.deathAnimLength - robot.deathFrames)/float(robot.deathAnimLength);
      wheelRotation += 0.06*deathProg;
      wheelOffset += 2*deathProg;
    }

    fill(25);

    // front left wheel
    pushMatrix();
    rotate(wheelRotation);
    translate(-1*robot.length()/2 - wheelWidth/2 - wheelOffset, robot.length()/4 + wheelOffset/3);
    drawWheel(0, 0);

    popMatrix();

    // front right wheel
    pushMatrix();
    rotate(wheelRotation);
    translate(robot.length()/2 + wheelWidth/2 + wheelOffset, robot.length()/4 + wheelOffset/3);
    drawWheel(0, 0);

    popMatrix();

    // back left wheel
    pushMatrix();
    rotate(-wheelRotation);
    translate(-1*robot.length()/2 - wheelWidth/2  - wheelOffset, -1*robot.length()/4 - wheelOffset/3);
    drawWheel(0, 0);

    popMatrix();

    // back right wheel
    pushMatrix();
    rotate(-wheelRotation);
    translate(robot.length()/2 + wheelWidth/2 + wheelOffset, -1*robot.length()/4 - wheelOffset/3);
    drawWheel(0, 0);
    popMatrix();

    anim = (anim + 0.075) % 1;
  }

  // draws a single wheel at a specific part of the bot (relative to center)
  private void drawWheel(float x, float y) {
    pushMatrix();
    translate(x, y);

    // wheel base
    fill(25);
    noStroke();
    rectMode(CENTER);
    rect(0, 0, wheelWidth, wheelLength);

    // number of lines
    int n = 3;
    for (int i = 0; i < n; i++) {
      float lineY = cos((PI*i/float(n) + anim*PI) % PI) * wheelLength/2;
      stroke(75);
      strokeWeight(2);

      line(-1*wheelWidth/2, lineY, wheelWidth/2, lineY);
    }

    popMatrix();
  }
}

class Tread extends MovementPart {
  PShape[] shapes;
  int shapeIndex;
  float width;

  // these two are used only for death animations
  float rotationL;
  float fallL; // how far should the tread fall from the bot
  float rotationR;
  float fallR;

  Tread(Robot robot) {
    super (0, robot);

    this.shapes = new PShape[] {tread7, tread6, tread5, tread4, tread3, tread2, tread1};
    this.shapeIndex = 0;

    this.width = 4*(robot.size+1);

    this.rotationL = 0;
    this.rotationR = 0;
    this.fallL = 0;
    this.fallR = 0;
  }

  Tread(int level, Robot robot) {
    this(robot);

    if (level == 1) width += 4;
  }

  void draw() {
    shapeMode(CENTER);
    updateShape(1);
  }

  private void updateShape(int shapeInterval){ // updates the shape of the MovementPart every shapeInterval. 
    if (robot.hp <= 0) {
      float deathProg = (robot.deathAnimLength - robot.deathFrames)/float(robot.deathAnimLength);
      fallR += 3*deathProg;
      fallL -= 3*deathProg;

      rotationL += 0.1*deathProg;
      rotationR += 0.1*deathProg;
    }

    if (frameCount % shapeInterval == 0){ // if it is time to update the frame, change the index to the next shape.
      shapeIndex = (shapeIndex + 1) % shapes.length;
    }

    pushMatrix();
    translate(robot.length()/2 + fallR, 0);
    rotate(rotationR);
    drawTread();
    popMatrix();

    pushMatrix();
    translate(-robot.length()/2 + fallL, 0);
    rotate(rotationL);
    drawTread();
    popMatrix();
  }

  private void drawTread() {
    shape(shapes[shapeIndex], 0, 0, width, robot.length());
  }
}
