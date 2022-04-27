/*
Movement
  Wheel
    No animation (mostly hidden)
  Leg (crab style)
    Animation that plays during movement, continuous back and forth on pivot
TODO: Also need to show side view. 
Caution: Only .svg files from Adobe Illustrator or Inkscape work
*/
class MovementPart{
  int type; // Tread, Wheel, Leg. 
  int size;
  int shapeIndex = 0;
  int robotLength;
  
  MovementPart(int t, int s){
    this.type = t;
    this.size = s;
    this.robotLength = 10*(s+1);
  }
  
  void animateMovement(){ 
    switch (type){
      case 0:  // if Tread
        PShape tread1 = loadShape("treads\\tread1.svg");
        PShape tread2 = loadShape("treads\\tread2.svg");
        PShape tread3 = loadShape("treads\\tread3.svg");
        PShape[] shapes = {tread1, tread2, tread3};
        shapeMode(CENTER);
        animate(shapes, 2, 3, 5); 
        
      case 1:  // if Wheel
        break;
      
      case 2:  // if Leg
        break;
    }
  }
  
  void updateShape(int shapeInterval, PShape[] shapes){ // updates the shape of the MovementPart every shapeInterval. 
     if (frameCount % shapeInterval == 0){ // if it is time to update the frame, draw the next shape.
      shape(shapes[(shapeIndex) % shapes.length], robotLength/2, 0, 2*size, robotLength); 
      shape(shapes[(shapeIndex) % shapes.length], -robotLength/2, 0, 2*size, robotLength);
      shapeIndex = (shapeIndex + 1) % 2;
     }
     else{ // otherwise, keep drawing the current shape.
      shape(shapes[shapeIndex], robotLength/2, 0, 2*size, robotLength); 
      shape(shapes[shapeIndex], -robotLength/2, 0, 2*size, robotLength);
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
