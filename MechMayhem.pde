Robot robot;

void setup() {
    size(600,600);
    robot = new Robot(0, 200, 200, 0);
}

void draw() {
    background(100);

    stroke(255);
    
    textAlign(LEFT,TOP);
    text("LOL",0,0);

    robot.update();
}