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
  void drawWheel(float x, float y) {
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

  void draw() {
    PShape[] shapes = {tread1, tread2, tread3, tread4, tread5, tread6, tread7};
    shapeMode(CENTER);
    animate(shapes, 1, 1, 1); 
  }

  void updateShape(int shapeInterval, PShape[] shapes){ // updates the shape of the MovementPart every shapeInterval. 
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

  void animate(PShape[] shapes, int smallFrameInterval, int midFrameInterval, int largeFrameInterval){ // animates according to the size of the robot and the desired frequency of animation. Makes sure that the small robot moves the fastest and the large robot moves the slowest.
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
