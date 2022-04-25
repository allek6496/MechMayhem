/*
Movement
  Tread
    Possible animation using lines that travel forwards
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
  
  MovementPart(int t, int size){
    this.type = t;
    this.size = size;
  }
  
  void animateMovement(){ 
    if (type == 0){ // if Tread
      PShape tread1;
      PShape tread2;
      tread1 = loadShape("tread1.svg");
      tread2 = loadShape("tread2.svg");
      shapeMode(CENTER);
      
      if (frameCount % 2 == 0){
        shape(tread1, 10*(size+1)/2, 0, 2*size+1, 10*(size+1)); // (shape, x, y, width, height)
        shape(tread1, -10*(size+1)/2, 0, 2*size+1, 10*(size+1));
      }
      else{
        shape(tread2, 10*(size+1)/2, 0, 2*size+1, 10*(size+1));
        shape(tread2, -10*(size+1)/2, 0, 2*size+1, 10*(size+1));
      }
      
    }
    else if (type == 1){ // if Wheel

    }
    
    else if (type == 2){ // if Leg

    }
  }

}
