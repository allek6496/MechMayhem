class Weapon {
  int type; // 0 - saw blade, 1 - laser, 2 - hammer
  Robot robot;
  int size;
  int weaponIndex = 0;

  Weapon(int type, Robot robot) {
      this.type = type;
      this.robot = robot;
      this.size = robot.size;
  }
  void updateWeapon(int shapeInterval, PShape[] weapons){ // updates the weapon weaponInterval. // making x and y and width and height specific to sawblades
    if (frameCount % shapeInterval == 0){ 
    shape(weapons[(weaponIndex) % weapons.length], 0, -robot.length()/2 - 10, 20*size, 20*size); // shape(shape, x, y, width, height)
    weaponIndex = (weaponIndex + 1) % weapons.length;
   }
   else{ // otherwise, keep drawing the current weapon.
    shape(weapons[weaponIndex], 0, -robot.length()/2 - 10, 20*size, 20*size); 
   }
  }
  
   //void updateWeapon(int shapeInterval, PShape[] weapons){  // problem: rotate doesn't work properly. should put P3D to size(x, y) in setup().
   // if (frameCount % shapeInterval == 0){ 
   // //shape(weapons[0], 0, -robot.length()/2 - 10, 20*size, 20*size); // shape(shape, x, y, width, height)
   // weapons[0].rotateY(PI/3.0);
   // shape(weapons[0], 0, -robot.length()/2 - 10, 20*size, 20*size); // shape(shape, x, y, width, height)
   // //weapons[0].rotate(PI/3.0);
    
   //}
 // }
  void animateWeapon(){ // temporary method.
  PShape[] weapons = {sawblade1, sawblade2, sawblade3, sawblade4, sawblade5, sawblade6};
  shapeMode(CENTER);
  updateWeapon(1, weapons);  // No need for animate method since I do not need to consider the size of the robot and no need for animateWeapon since I don't need to see which weapon it is.
  }
}

class SawBlade extends Weapon {
  SawBlade(Robot robot) {
  super(0, robot);
  //PShape[] weapons = {sawblade1, sawblade2};
  //shapeMode(CENTER);
  //updateWeapon(2, weapons);  // No need for animate method since I do not need to consider the size of the robot and no need for animateWeapon since I don't need to see which weapon it is.
    }
}
