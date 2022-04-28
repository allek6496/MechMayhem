/*
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
  int shapeIndex = 0;
  int robotLength;

  Robot robot;
  
  MovementPart(int t, Robot robot){
    this.type = t;
    this.size = robot.size;
    this.robot = robot;
    this.robotLength = robot.length();
  }
  
  void animateMovement(){ 
    switch (type){
      case 0:  // if Tread
        PShape[] shapes = {tread1, tread2, tread3, tread4, tread5, tread6, tread7};
        shapeMode(CENTER);
        animate(shapes, 1, 1, 1); 
        
      case 1:  // if Wheel
        break;
      
      case 2:  // if Leg
        break;
    }
  }
  
  void updateShape(int shapeInterval, PShape[] shapes){ // updates the shape of the MovementPart every shapeInterval. 
     if (frameCount % shapeInterval == 0){ // if it is time to update the frame, draw the next shape.
      shape(shapes[(shapeIndex) % shapes.length], robotLength/2, 0, 4*(size+1), robotLength); // shape(shape, x, y, width, height)
      shape(shapes[(shapeIndex) % shapes.length], -robotLength/2, 0, 4*(size+1), robotLength);
      shapeIndex = (shapeIndex + 1) % shapes.length;
     }
     else{ // otherwise, keep drawing the current shape.
      shape(shapes[shapeIndex], robotLength/2, 0, 4*(size+1), robotLength); 
      shape(shapes[shapeIndex], -robotLength/2, 0, 4*(size+1), robotLength);
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
} // CLASS
