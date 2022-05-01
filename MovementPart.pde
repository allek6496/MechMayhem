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

  float legRange = PI/3; // how far the legs can rotate

  Legs(Robot robot) {
    super(2, robot);
    
    anim = 0;
    legDir = 1;

    legLength = 10 + size*4;
    legWidth = 4 + size*4;
  }

  Legs(int level, Robot robot) {
    this(robot);

    if (level == 1) {
      legWidth += 2 + size*3;
      legLength += 3  + size*3;
    }
  }

  void draw() {
    // front right
    drawLeg(robot.length()/2, robot.length()/2 - robot.size, 0, -1*PI/2);

    // front left
    drawLeg(-1*robot.length()/2, robot.length()/2 - 2 - robot.size, PI/8, -1*3*PI/2);

    // back right
    drawLeg(robot.length()/2, -1*robot.length()/2 + 2 + robot.size, PI/4, -1*PI/2);

    // back left
    drawLeg(-1*robot.length()/2, -1*robot.length()/2 + 2 + robot.size, 3*PI/8, -1*3*PI/2);

    anim += 0.05*legDir;

    if (anim > 1) {
      legDir = -1;
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

  Wheel(Robot robot) {
    super (1, robot);
    anim = 0;

    wheelWidth = 8 + size*2;
    wheelLength = robot.length()/3;
  }

  Wheel(int level, Robot robot) {
    this(robot);

    if (level == 1) {
      wheelWidth += 2 + size;
      wheelLength += robot.length()/9;
    }
  }

  void draw() {
    fill(25);

    // front left wheel
    drawWheel(-1*robot.length()/2 - wheelWidth/2, robot.length()/4);
    // front right wheel
    drawWheel(robot.length()/2 + wheelWidth/2, robot.length()/4);
    // back left wheel
    drawWheel(-1*robot.length()/2 - wheelWidth/2, -1*robot.length()/4);
    // back right wheel
    drawWheel(robot.length()/2 + wheelWidth/2, -1*robot.length()/4);

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
  int shapeIndex;

  Tread(Robot robot) {
    super (0, robot);
    shapeIndex = 0;
  }

  Tread(int level, Robot robot) {
    this(robot);

    if (level == 1) size += 1;
  }

  void draw() {
    PShape[] shapes = {tread1, tread2, tread3, tread4, tread5, tread6, tread7};
    shapeMode(CENTER);
    animate(shapes, 1, 1, 1); 
  }

  private void updateShape(int shapeInterval, PShape[] shapes){ // updates the shape of the MovementPart every shapeInterval. 
    if (frameCount % shapeInterval == 0){ // if it is time to update the frame, draw the next shape.
      shape(shapes[(shapeIndex) % shapes.length], robot.length()/2, 0, 4*(size+1), robot.length()); // shape(shape, x, y, width, height)
      shape(shapes[(shapeIndex) % shapes.length], -robot.length()/2, 0, 4*(size+1), robot.length());
      shapeIndex = (shapeIndex + 1) % shapes.length;
    }
      else{ // otherwise, keep drawing the current shape.
      shape(shapes[shapeIndex], robot.length()/2, 0, 4*(size+1), robot.length()); 
      shape(shapes[shapeIndex], -robot.length()/2, 0, 4*(size+1), robot.length());
    }
  }

  private void animate(PShape[] shapes, int smallFrameInterval, int midFrameInterval, int largeFrameInterval){ // animates according to the size of the robot and the desired frequency of animation. Makes sure that the small robot moves the fastest and the large robot moves the slowest.
    switch (size){
      case 0: // if small robot
        updateShape(smallFrameInterval, shapes); // change shape every x frames.
        break;

      case 1: // if medium robot
        updateShape(midFrameInterval, shapes);
        break;
        
      case 2: // if large robot
       updateShape(largeFrameInterval, shapes);
       break;
    }
  }
}
