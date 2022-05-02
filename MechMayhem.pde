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
float round = 0.5;
int enemyLevel = 0;
String selectedUpgrade = "";
boolean start; 

//Player Bot's Variables
int chassis; 
int weapon;
int movement;

void setup() {
  // fullScreen();
  size(800,800);
  frameRate(45);
  createGUI();
  loadShapesL();
  
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
  robot1 = randomBot(0);
  
  preGameWindow.setVisible(true);
  duringGameWindow.setVisible(false);
  postGameWindow.setVisible(false);
  
}

void draw() {
  background(100);

  stroke(255);
  
  textAlign(LEFT,TOP);
  text("LOL",0,0);

  if (round == -1) {
    println("Death Screen");
    round = 0.5;
    // TODO: death screen
  }

  if (round == 0) {
    // possible start-menu
  }

  if (round == 0.5){
    preGameWindow.setVisible(true);

    playerBot.update(null);

    if (playerBot.size != chassis) playerBot.setChassis(chassis);
    if (playerBot.weaponType != weapon) playerBot.setWeapon(weapon);
    if (playerBot.movementType != movement) playerBot.setMovement(movement);

    if (start){ // if the user presses the start button, proceed to round 1.
      round += 0.5;      
      start = false;

      preGameWindow.setVisible(false);

    //reset(preGameWindow);
    }
  }
  
  if (round > 0 && round % 1 == 0){
    duringGameWindow.setVisible(true);

    playerBot.aggressiveness = aggressiveness;

    playerBot.update(robot1);
    robot1.update(playerBot);

    if (playerBot.hp > 0) playerBot.drawEffects(robot1);
    if (robot1.hp > 0) robot1.drawEffects(playerBot);

    println("R1: ", playerBot.hp, "\tR2: ", robot1.hp);
    println("A1: ", round(playerBot.aggressiveness*100)/100.0, "\tA2: ", round(robot1.aggressiveness*100)/100.0);
    println();

    // looks good :)
    if (robot1.hp <= 0 && playerBot.hp != 0 && robot1.deathFrames >= robot1.deathAnimLength){
      round += 0.5; // go to the upgrade bot gui.
      println("Win");

      duringGameWindow.setVisible(false);
      postGameWindow.setVisible(true);

      playerBot.reset();
    }
    else if (playerBot.hp <= 0 && playerBot.deathFrames >= playerBot.deathAnimLength) {
      round = -1; // go to the defeat screen. (even if both die at the same frame, gotta survive it)
      playerBot.reset();
    }
  }
  
  if (round == 1.5){
    playerBot.update(null);

    if (start){ // if the user presses the next round button, proceed to round 2.
      // this section is extremely cancer, but just update the list of upgradable parts based off of what's fully upgraded
      boolean weaponUpgradable = playerBot.weaponLevel != 2;
      boolean chassisUpgradable = playerBot.chassisLevel != 1;
      boolean movementUpgradable = playerBot.movementLevel != 1;

      // how many parts can still be upgraded
      int upgradableParts = 0;
      if (weaponUpgradable) upgradableParts++;
      if (chassisUpgradable) upgradableParts++;
      if (movementUpgradable) upgradableParts++;
      
      String[] newUpgradeList = new String[upgradableParts];

      // what index is the next to upgrade
      int nextUpgrade = 0;

      for (int i = 0; i < upgradableParts; i++) {
        if (weaponUpgradable) {
          newUpgradeList[nextUpgrade] = "Weapon";
          weaponUpgradable = false;
          nextUpgrade++;
        } else if (chassisUpgradable) {
          newUpgradeList[nextUpgrade] = "Chassis";
          chassisUpgradable = false;
          nextUpgrade++;
        } else if (movementUpgradable) {
          newUpgradeList[nextUpgrade] = "Movement";
          movementUpgradable = false;
          nextUpgrade++;
        }

        upgradeChoice.setItems(newUpgradeList, 0);
      }

      println("Started");

      round -= 0.5;
      enemyLevel += 1;
      robot1 = randomBot(enemyLevel);

      start = false;

      postGameWindow.setVisible(false);
      //reset(postGameWindow);
    }
  }
}

Robot randomBot(int level) {
  Robot robot = new Robot(int(random(3)), int(random(3)), int(random(3)), 0.3, 400, 400, 3*PI/4, false);

  // there are only 4 upgrades possible, so if level is more than 4, it infinitely loops
  if (level > 2 + 1 + 1) level = 4;

  for (int i = 0; i < level; i++) {
    int upgrade = int(random(3)); // random either 0, 1 or 2

    // upgrade one of the parts, and if the chosen part can't be upgraded, run it again
    if (upgrade == 0 && robot.chassisLevel == 0) {
      robot.upgradeChassis();
    } else if (upgrade == 1 && robot.weaponLevel <= 1) {
      robot.upgradeWeapon();
    } else if (upgrade == 2 && robot.movementLevel == 0) {
      robot.upgradeMovement();
    } else {
      i--;
    }
  }

  return robot;
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
