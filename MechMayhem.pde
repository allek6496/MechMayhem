import g4p_controls.*;
//import java.awt.Frame;
//import processing.awt.PSurfaceAWT;
//import processing.awt.PSurfaceAWT.SmoothCanvas;

float pauseScale = 4;

Robot playerBot;
Robot robot1;
PShape tread1, tread2, tread3, tread4, tread5, tread6, tread7;
PShape sawblade;
float aggressiveness;
boolean powerUsed;
PImage guiBackground;
float round;
boolean start; 

//Player Bot's Variables
int chassis; 
int weapon;
int movement;

void setup() {
  fullScreen();
  //size(600,600);
  frameRate(45);
  createGUI();
  loadShapes();
  
  /**
  First three numbers:
  0        | 1      | 2
  Small    | Medium | Large
  Sawblade | Laser  | Hammer
  Tread    | Wheel  | Leg

  4th number: default aggression
  5th and 6th numbers: starting x and y

  7th number: starting rotation 0 -> TWO_PI

  Last boolean: Player? true => use setAgression(float) and usePower() to control, false => autonomous
   */
  
 // chassis = 
  aggressiveness = aggroSlider.getValueF(); // initializing aggressiveness from the initial value of the aggressive slider.
  
  playerBot = new Robot(chassis, weapon, movement, aggressiveness, width/2, height/2, PI/2, true); // the chassis, weapon, and movement are 0 initially
  robot1 = new Robot(0, 2, 0, 0.3, 400, 400, 3*PI/4, false);
  
  preGameWindow.setVisible(true);
  duringGameWindow.setVisible(false);
  postGameWindow.setVisible(false);
  
}

void draw() {
  background(100);

  stroke(255);
  
  textAlign(LEFT,TOP);
  text("LOL",0,0);

  if (round == 0){
    preGameWindow.setVisible(true);

    playerBot.update(null);

    if (playerBot.size != chassis) playerBot.setChassis(chassis);
    if (playerBot.weaponType != weapon) playerBot.setWeapon(weapon);
    if (playerBot.movementType != movement) playerBot.setMovement(movement);

    if (start){ // if the user presses the start button, proceed to round 1.
      round++;      
      
    preGameWindow.setVisible(false);

      //reset(preGameWindow);
    }
  }
  
  else if (round == 1){
    duringGameWindow.setVisible(true);

    playerBot.aggressiveness = aggressiveness;

    playerBot.update(robot1);
    robot1.update(playerBot);

    playerBot.drawEffects(robot1);
    robot1.drawEffects(playerBot);

    println("R1: ", playerBot.hp, "\tR2: ", robot1.hp);
    println("A1: ", round(playerBot.aggressiveness*100)/100.0, "\tA2: ", round(robot1.aggressiveness*100)/100.0);
    println();

    // looks good :)
    if (robot1.hp == 0 && playerBot.hp != 0){
      round += 0.5; // go to the upgrade bot gui.
      println("Win");
      duringGameWindow.setVisible(false);
    }
    else if (playerBot.hp == 0)
      round = -1; // go to the defeat screen. (even if both die at the same frame, gotta survive it)
  }
  else if (round == 1.5){
    postGameWindow.setVisible(true);
    playerBot.aggressiveness = 0.5;
    playerBot.pos.x = width/2;
    playerBot.pos.y = height/2;
    playerBot.rotation = PI/2;    
    playerBot.update(null);

    if (start){ // if the user presses the next round button, proceed to round 2.
      round += 0.5;


      postGameWindow.setVisible(false);
      //reset(postGameWindow);
    }
  }
  
  else if (round == -1){
    println("DEFEAT SCREEN");
  }
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
  guiBackground = loadImage("guiBackground.jpg");
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
  guiBackground = loadImage("guiBackground.jpg");
}

void reset(GWindow... windows){ // ... neccessary? No. Purpose: to reset the stats and position and rotation of the playerbot while popping up appropriate windows.
  for (GWindow window : windows)
    window.setVisible(false);
   
  // reset playerbot.
  playerBot.pos = new PVector(200, 200);
  playerBot.rotation = 7*PI/4;
  start = false;
  powerUsed = false;
}

//PSurface initSurface() { // implemented this feature so that the windows did not have an annoying top bar. Does not work as it throws an Illegal Exception. 
//  PSurface pSurface = super.initSurface();
//  PSurfaceAWT awtSurface = (PSurfaceAWT) surface;
//  SmoothCanvas smoothCanvas = (SmoothCanvas) awtSurface.getNative();
//  Frame frame = smoothCanvas.getFrame();
//  frame.setUndecorated(true);
//  return pSurface;
//}
