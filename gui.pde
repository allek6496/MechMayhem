/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

synchronized public void drawDuringGameWindow(PApplet appc, GWinData data) { //_CODE_:duringGameWindow:769630:
  appc.background(230);
  //appc.background(guiBackground); // has to have the same size as application
  // IDEA: maybe have bunch of "theme" photos that every GUI has?
} //_CODE_:duringGameWindow:769630:


public void powerButtonClicked(GButton source, GEvent event) { //_CODE_:powerButton:594449:
  powerUsed = true;
} //_CODE_:powerButton:594449:

public void agroSliderChanged(GCustomSlider source, GEvent event) { //_CODE_:aggroSlider:296709:
  aggressiveness = aggroSlider.getValueF();
} //_CODE_:aggroSlider:296709:

synchronized public void drawpreGameWindow(PApplet appc, GWinData data) { //_CODE_:preGameWindow:325301:
  appc.background(230);
} //_CODE_:preGameWindow:325301:

public void chassisChosen(GDropList source, GEvent event) { //_CODE_:chassisChoice:730452:
  if (chassisChoice.getSelectedIndex() == 1) // if the user picks a small chassis.
    chassis = 0;
  else if (chassisChoice.getSelectedIndex() == 2)
    chassis = 1;
  else if (chassisChoice.getSelectedIndex() == 3)
    chassis = 2;
} //_CODE_:chassisChoice:730452:

public void weaponChosen(GDropList source, GEvent event) { //_CODE_:weaponChoice:239023:
  if (weaponChoice.getSelectedIndex() == 1) // if the user picks a small chassis.
    weapon = 0;
  else if (weaponChoice.getSelectedIndex() == 2)
    weapon = 1;
  else if (weaponChoice.getSelectedIndex() == 3)
    weapon = 2;
} //_CODE_:weaponChoice:239023:

public void movementChosen(GDropList source, GEvent event) { //_CODE_:movementChoice:257625:
  if (movementChoice.getSelectedIndex() == 1) // if the user picks a small chassis.
    movement = 0;
  else if (movementChoice.getSelectedIndex() == 2)
    movement = 1;
  else if (movementChoice.getSelectedIndex() == 3)
    movement = 2;
} //_CODE_:movementChoice:257625:

public void startButtonClicked(GButton source, GEvent event) { //_CODE_:startButton:442583:
  start = true;
} //_CODE_:startButton:442583:

synchronized public void drawpostGameWindow(PApplet appc, GWinData data) { //_CODE_:postGameWindow:595249:
  appc.background(230);
} //_CODE_:postGameWindow:595249:

public void upgradeChosen(GDropList source, GEvent event) { //_CODE_:upgradeChoice:315672:
  println("chosen");

  if (upgradeChoice.getSelectedText().equals("Chassis")) {
    playerBot.upgradeChassis();

    if (selectedUpgrade.equals("Weapon")) 
      playerBot.unUpgradeWeapon();
    else if (selectedUpgrade.equals("Movement"))
      playerBot.unUpgradeMovement();
  }

  else if (upgradeChoice.getSelectedText().equals("Weapon")) {
    playerBot.upgradeWeapon();
    
    if (selectedUpgrade.equals("Chassis")) 
      playerBot.unUpgradeChassis();
    else if (selectedUpgrade.equals("Movement"))
      playerBot.unUpgradeMovement();
    }

  else if (upgradeChoice.getSelectedText().equals("Movement")) {
    playerBot.upgradeMovement();

    if (selectedUpgrade.equals("Chassis")) 
      playerBot.unUpgradeChassis();
    else if (selectedUpgrade.equals("Weapon"))
      playerBot.unUpgradeWeapon();
  }

  selectedUpgrade = upgradeChoice.getSelectedText();
} //_CODE_:upgradeChoice:315672:

public void nextRoundButtonClicked(GButton source, GEvent event) { //_CODE_:nextRoundButton:347340:
  start = true;
  selectedUpgrade = "";
} //_CODE_:nextRoundButton:347340:

public void duringGameKeyHandler(PApplet appc, GWinData data, KeyEvent keyEvent) {
  if (round > 0 && floor(round) == ceil(round)) {
    char key = keyEvent.getKey();

    if (key == 'a') {
      aggressiveness = 0;
      aggroSlider.setValue(0);
    } if (key == 's') {
      aggressiveness = 0.5;
      aggroSlider.setValue(0.5);
    } if (key == 'd') {
      aggressiveness = 1;
      aggroSlider.setValue(1);
    }

    if (key == ' ') {
      // powerUsed = true;
      if (keyEvent.getAction() == keyEvent.PRESS) powerUsed = true;
      else if (keyEvent.getAction() == keyEvent.RELEASE) powerUsed = false;
    }
  }
}

public void beforeGameKeyHandler(PApplet appc, GWinData data, KeyEvent keyEvent) {
  if (keyEvent.getKey() == ' ' && keyEvent.getAction() == keyEvent.PRESS && round == 0.5) {
    start = true;
  }
}

public void afterGameKeyHandler(PApplet appc, GWinData data, KeyEvent keyEvent) {
  if (keyEvent.getKey() == ' ' && keyEvent.getAction() == keyEvent.PRESS  && round > 1 && round * 2 % 2 == 1) {
    start = true;
  }
}

// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  G4P.setDisplayFont("Century Gothic", 12, 12);
  surface.setTitle("Sketch Window");
  duringGameWindow = GWindow.getWindow(this, "Window title", 0, 0, 420, 200, JAVA2D);
  duringGameWindow.noLoop();
  duringGameWindow.setActionOnClose(G4P.KEEP_OPEN);
  duringGameWindow.addDrawHandler(this, "drawDuringGameWindow");
  duringGameWindow.addKeyHandler(this, "duringGameKeyHandler");
  powerButton = new GButton(duringGameWindow, 160, 140, 80, 30);
  powerButton.setText("POWER");
  powerButton.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  powerButton.addEventHandler(this, "powerButtonClicked");
  aggroLabel = new GLabel(duringGameWindow, 10, 30, 110, 30);
  aggroLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  aggroLabel.setText("Aggressiveness");
  aggroLabel.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  aggroLabel.setOpaque(false);
  aggroSlider = new GCustomSlider(duringGameWindow, 152, 12, 240, 60, "grey_blue");
  aggroSlider.setShowLimits(true);
  aggroSlider.setLimits(0.5, 0.0, 1.0);
  aggroSlider.setNbrTicks(11);
  aggroSlider.setStickToTicks(true);
  aggroSlider.setShowTicks(true);
  aggroSlider.setNumberFormat(G4P.DECIMAL, 2);
  aggroSlider.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  aggroSlider.setOpaque(false);
  aggroSlider.addEventHandler(this, "agroSliderChanged");
  label1 = new GLabel(duringGameWindow, 150, 80, 30, 20);
  label1.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label1.setText("A");
  label1.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  label1.setOpaque(false);
  label2 = new GLabel(duringGameWindow, 260, 80, 30, 20);
  label2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label2.setText("S");
  label2.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  label2.setOpaque(false);
  label3 = new GLabel(duringGameWindow, 370, 80, 30, 20);
  label3.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label3.setText("D");
  label3.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  label3.setOpaque(false);
  label4 = new GLabel(duringGameWindow, 10, 80, 80, 20);
  label4.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label4.setText("Key");
  label4.setOpaque(false);
  preGameWindow = GWindow.getWindow(this, "Customize your bot", 0, 0, 560, 200, JAVA2D);
  preGameWindow.noLoop();
  preGameWindow.setActionOnClose(G4P.KEEP_OPEN);
  preGameWindow.addDrawHandler(this, "drawpreGameWindow");
  preGameWindow.addKeyHandler(this, "beforeGameKeyHandler");
  chassisChoice = new GDropList(preGameWindow, 10, 20, 160, 150, 4, 10);
  chassisChoice.setItems(loadStrings("list_730452"), 0);
  chassisChoice.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  chassisChoice.addEventHandler(this, "chassisChosen");
  togGroup1 = new GToggleGroup();
  weaponChoice = new GDropList(preGameWindow, 200, 20, 160, 150, 4, 10);
  weaponChoice.setItems(loadStrings("list_239023"), 0);
  weaponChoice.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  weaponChoice.addEventHandler(this, "weaponChosen");
  movementChoice = new GDropList(preGameWindow, 390, 20, 160, 150, 4, 10);
  movementChoice.setItems(loadStrings("list_257625"), 0);
  movementChoice.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  movementChoice.addEventHandler(this, "movementChosen");
  startButton = new GButton(preGameWindow, 230, 120, 90, 40);
  startButton.setText("START");
  startButton.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  startButton.addEventHandler(this, "startButtonClicked");
  postGameWindow = GWindow.getWindow(this, "Upgrade", 0, 0, 240, 150, JAVA2D);
  postGameWindow.noLoop();
  postGameWindow.setActionOnClose(G4P.KEEP_OPEN);
  postGameWindow.addDrawHandler(this, "drawpostGameWindow");
  postGameWindow.addDrawHandler(this, "afterGameKeyHandler");
  upgradeChoice = new GDropList(postGameWindow, 44, 11, 141, 130, 4, 10);
  upgradeChoice.setItems(loadStrings("list_315672"), 0);
  upgradeChoice.setLocalColorScheme(GCScheme.RED_SCHEME);
  upgradeChoice.addEventHandler(this, "upgradeChosen");
  nextRoundButton = new GButton(postGameWindow, 60, 100, 100, 30);
  nextRoundButton.setText("Next Round");
  nextRoundButton.setLocalColorScheme(GCScheme.RED_SCHEME);
  nextRoundButton.addEventHandler(this, "nextRoundButtonClicked");
  duringGameWindow.loop();
  preGameWindow.loop();
  postGameWindow.loop();
}

// Variable declarations 
// autogenerated do not edit
GWindow duringGameWindow;
GButton powerButton; 
GLabel aggroLabel; 
GCustomSlider aggroSlider; 
GLabel label1; 
GLabel label2; 
GLabel label3; 
GLabel label4; 
GWindow preGameWindow;
GDropList chassisChoice; 
GToggleGroup togGroup1; 
GDropList weaponChoice; 
GDropList movementChoice; 
GButton startButton; 
GWindow postGameWindow;
GDropList upgradeChoice; 
GButton nextRoundButton; 
