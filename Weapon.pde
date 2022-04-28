// I feel like this should be multiple classes given how differently they all operate but this will work for now
class Weapon {
  int type; // 0 - saw blade, 1 - laser, 2 - hammer
  Robot robot;
  float size; // size of the weapon -- also radius of the circle dealing damage for hammer and saw
  int damage; // how much damage the weapon does

  Weapon(int type, Robot robot) {
    this.type = type;
    this.robot = robot;
    this.size = robot.length()-10;
  }

  void update(Robot opponent){ // updates the weapon

    // offset to the bot again (since this is called after the bot draws itself)
    pushMatrix();
    translate(robot.pos.x, robot.pos.y);
    rotate(-1*robot.rotation - PI/2);

    draw();
    
    popMatrix();
    
    checkCollision(opponent);
  }

  void draw() { return; }

  void checkCollision(Robot opponent) { return; }
}

class Sawblade extends Weapon {
  float rotation;

  Sawblade(Robot robot) {
    super(0, robot);
    this.damage = 1;
    this.rotation = 0;
  }

  void checkCollision(Robot opponent) {
    PVector point = new PVector(); // point of the saw blade
    point.add(0, robot.length()-10);
    point.rotate(-1*robot.rotation - PI/2);
    point.add(robot.pos);
    
    if (point.dist(opponent.pos) < size/1.2 + opponent.radius()) {
      // move point to the leading edge of the blade, and pass that as the damage location
      point.add(PVector.sub(opponent.pos, point).setMag(size/2.4));
      opponent.dealDamage(1, point);
    }
  }

  // draw weapon and progress animation
  void draw() {
    fill(200);
    rect(0, robot.length()/2+10, 13 + 2*robot.size, robot.length()-20);
    
    translate(0, robot.length()-10);
    rotate(rotation);
    shape(sawblade, 0, 0, size, size); // shape(shape, x, y, width, height)

    rotation += 0.3;
  }
}