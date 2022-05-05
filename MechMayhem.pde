import g4p_controls.*;
import processing.sound.*;

float pauseScale = 4;
int frameR = 45; //45 works best because of frame timings rather than actual time timings

SoundFile buildMusic1;
SoundFile buildMusic2;
SoundFile[] hammerSounds;
SoundFile[] laserSounds;
SoundFile sawIdle;
SoundFile sawActive;
SoundFile megalovania;
SoundFile mantisLords;

boolean firstBuildTrack = false;

Robot playerBot;
Robot robot1;
PShape tread1, tread2, tread3, tread4, tread5, tread6, tread7; // each image is a frame of the animation of treads.
PShape sawblade;
float aggressiveness;
boolean powerUsed;
float round = 0;
int enemyLevel = 0;
String selectedUpgrade = "";
boolean start; 
PImage startScreen;
PImage gameOverScreen;
int counter; // used to make sure certain code only runs once.
boolean mouseActivated = false;

//Player Bot's Variables
int chassis; 
int weapon;
int movement;

void setup() {
  loadAudio(); 
  size(800,800);
  frameRate(frameR);

  createGUI();

  preGameWindow.setVisible(false);
  duringGameWindow.setVisible(false);
  postGameWindow.setVisible(false);
  preGameWindow.setLocation(0, 0);
  duringGameWindow.setLocation(0, 0);
  postGameWindow.setLocation(100, 100);
  
  startScreen = loadImage("startScreen.png");
  gameOverScreen = loadImage("gameOver.png");
  loadShapesL();

  /**
  Parameters of Robot Constructor.
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
  
  aggressiveness = aggroSlider.getValueF(); // initializing aggressiveness from the initial value of the aggressive slider.  
}

void draw() {
  background(100);
  if (round == -1) {
    duringGameWindow.setVisible(false);
    preGameWindow.setVisible(false);
    postGameWindow.setVisible(false);

    image(gameOverScreen, 0, 0);
    if (mouseActivated) {
      mouseActivated = false;
      round = 0.5;

      // yes this is the same code as below, no i don't feel like making a function
      playerBot = new Robot(chassis, weapon, movement, aggressiveness, width/2, height/2, PI/2, true);
      robot1 = randomBot(0);
    }
  }

  if (round == 0) {
    if (!firstBuildTrack && !buildMusic1.isPlaying()) {
      buildMusic1.play();
      firstBuildTrack = true;
    } 
    else if (!buildMusic1.isPlaying() && !buildMusic2.isPlaying()) {
      buildMusic2.loop();
    }

    image(startScreen, 0, 0);

    if (mouseActivated){
      mouseActivated = false;
      round = 0.5;
      
      playerBot = new Robot(chassis, weapon, movement, aggressiveness, width/2, height/2, PI/2, true);
      robot1 = randomBot(0);
    }
  }

  if (round == 0.5){
    if (!buildMusic1.isPlaying() && !buildMusic2.isPlaying()) buildMusic2.loop();
    duringGameWindow.setVisible(false);
    preGameWindow.setVisible(true);
    postGameWindow.setVisible(false);
    
    playerBot.update(null);

    // check for changes in the player's build and update accordingly
    if (playerBot.size != chassis) playerBot.setChassis(chassis, 0);
    if (playerBot.weaponType != weapon) playerBot.setWeapon(weapon, 0);
    if (playerBot.movementType != movement) playerBot.setMovement(movement, 0);

    if (start){ // if the user presses the start button, proceed to round 1.
      println("Starting!");
      round += 0.5;      
      start = false;

      // stop any old music
      buildMusic1.stop();
      buildMusic2.stop();
      firstBuildTrack = false; // allow the music to fully re-start when the upgrade menu or start menu is reached

      mantisLords.loop();
    }
  }
  
  // in game, any round number
  if (round > 0 && round % 1 == 0){
    duringGameWindow.setVisible(true);
    preGameWindow.setVisible(false);
    postGameWindow.setVisible(false);

    // update the aggressiveness from the slider
    playerBot.aggressiveness = aggressiveness;

    playerBot.update(robot1);
    robot1.update(playerBot);

    if (playerBot.hp > 0) playerBot.drawEffects(robot1);
    if (robot1.hp > 0) robot1.drawEffects(playerBot);

    // if you win, but not for a set number of frames
    if (robot1.hp <= 0 && playerBot.hp != 0 && robot1.deathFrames >= robot1.deathAnimLength){
      // stop all sounds
      stopSFX();
      megalovania.stop();
      mantisLords.stop();

      // start buildMusic1
      buildMusic1.play();
      
      round += 0.5; // go to the upgrade bot gui.
      println("Won the match!");

      playerBot.reset();

      boolean weaponUpgradable = playerBot.weaponLevel < 2;
      boolean chassisUpgradable = playerBot.chassisLevel == 0;
      boolean movementUpgradable = playerBot.movementLevel == 0;

      // how many parts can still be upgraded
      int upgradableParts = 0;
      if (weaponUpgradable) upgradableParts++;
      if (chassisUpgradable) upgradableParts++;
      if (movementUpgradable) upgradableParts++;

      // make a list with the first item as "select an upgrade, or no upgrades available"      
      String[] newUpgradeList = new String[upgradableParts+1];
      if (upgradableParts == 0) newUpgradeList[0] = "No Upgrade";
      else newUpgradeList[0] = "Select an Upgrade";

      // what index is the next to upgrade
      int nextUpgrade = 1;

      for (int i = 0; i < upgradableParts; i++) {
        if (weaponUpgradable) {
          newUpgradeList[nextUpgrade] = "Weapon";
          weaponUpgradable = false;
          nextUpgrade++;
        } 
        else if (chassisUpgradable) {
          newUpgradeList[nextUpgrade] = "Chassis";
          chassisUpgradable = false;
          nextUpgrade++;
        } 
        else if (movementUpgradable) {
          newUpgradeList[nextUpgrade] = "Movement";
          movementUpgradable = false;
          nextUpgrade++;
        }
        upgradeChoice.setItems(newUpgradeList, 0);
      }
    }

    // if you die, but not for a set number of frames
    else if (playerBot.hp <= 0 && playerBot.deathFrames >= playerBot.deathAnimLength) {
      // stop all sounds
      stopSFX();
      megalovania.stop();
      mantisLords.stop();
      
      duringGameWindow.setVisible(false);

      round = -1; // go to the defeat screen. (even if both die at the same frame, gotta survive it)
      
      // make a new random enemy
      enemyLevel = 0;
    }
  }
  
  // upgrade menu
  if (round*2 % 2 == 1 && round > 1){
    if (!buildMusic1.isPlaying() && !buildMusic2.isPlaying()) buildMusic2.loop();

    preGameWindow.setVisible(false);
    duringGameWindow.setVisible(false);
    postGameWindow.setVisible(true);

    // show the bot, but don't give it a target
    playerBot.update(null);

    if (start){ // if the user presses the next round button, proceed to round 2.
      round += 0.5;
      buildMusic1.stop();
      buildMusic2.stop();

      if (round >= 3) megalovania.loop();
      else mantisLords.loop(); 

      // reset the selection
      selectedUpgrade = "";


      enemyLevel += 1;
      robot1 = randomBot(enemyLevel);

      start = false;
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
    } 
    else if (upgrade == 1 && robot.weaponLevel <= 1) {
      robot.upgradeWeapon();
    } 
    else if (upgrade == 2 && robot.movementLevel == 0) {
      robot.upgradeMovement();
    } 
    else {
      i--;
    }
  }
  return robot;
}

// audio processed by Kegan, downloaded from pixabay and geoffplaysguitar.bandcamp.com
void loadAudio() {
  buildMusic1 = new SoundFile(this, "Audio/Silver_For_Monsters1.wav");
  buildMusic1.amp(0.6);
  buildMusic2 = new SoundFile(this, "Audio/Silver_For_Monsters2.wav");
  buildMusic2.amp(0.6);

  hammerSounds = new SoundFile[3];
  hammerSounds[0] = new SoundFile(this, "Audio/hammer1.wav");  
  hammerSounds[0].amp(0.8);
  hammerSounds[1] = new SoundFile(this, "Audio/hammer2.wav");
  hammerSounds[1].amp(0.8);
  hammerSounds[2] = new SoundFile(this, "Audio/hammer3.wav");
  hammerSounds[2].amp(0.8);

  laserSounds = new SoundFile[4];
  laserSounds[0] = new SoundFile(this, "Audio/laser1.wav");
  laserSounds[0].amp(1);
  laserSounds[1] = new SoundFile(this, "Audio/laser2.wav");
  laserSounds[1].amp(1);
  laserSounds[2] = new SoundFile(this, "Audio/laser3.wav");
  laserSounds[2].amp(1);
  laserSounds[3] = new SoundFile(this, "Audio/laser4.wav");  
  laserSounds[3].amp(1);

  sawIdle = new SoundFile(this, "Audio/sawIdle.wav");
  sawIdle.amp(0.9);
  sawActive = new SoundFile(this, "Audio/sawActive.wav");
  sawActive.amp(0.8);

  megalovania = new SoundFile(this, "Audio/megalovania.wav");
  megalovania.amp(0.5);

  mantisLords = new SoundFile(this, "Audio/Mantis_Lords.wav");
  mantisLords.amp(0.5);
}

void stopAudioGroup (SoundFile[] group) {
  for (int i = 0; i < group.length; i++) {
    group[i].stop();
  }
}

void stopSFX() {
  stopAudioGroup(hammerSounds);
  stopAudioGroup(laserSounds);
  sawIdle.stop();
  sawActive.stop();
}

void loadShapesL() { // loads all shapes needed for weapon and movementPart Classes (for Linux)
  tread1  = loadShape("Treads/tread1.svg");
  tread2  = loadShape("Treads/tread2.svg");
  tread3  = loadShape("Treads/tread3.svg");
  tread4  = loadShape("Treads/tread4.svg");
  tread5  = loadShape("Treads/tread5.svg");
  tread6  = loadShape("Treads/tread6.svg");
  tread7  = loadShape("Treads/tread7.svg");
  sawblade = loadShape("sawblade.svg");
}

void mouseClicked() {
  mouseActivated = true;
}