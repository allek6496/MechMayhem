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

  void damage(Robot opponent, PVector loc) {
    opponent.dealDamage(damage, loc);
  }

  void draw() { return; }

  void checkCollision(Robot opponent) { return; }
}

class Hammer extends Weapon {
  float anim; // how far through the animation is it 0 -> 1 -> 0 ...
  float animDir; // 1 => descending, -1 => raising

  Hammer(Robot robot) {
    super (1, robot);
    this.damage = 10;
    this.anim = 0;
    this.animDir = 1;
  }

  void checkCollision(Robot opponent) {
    println(anim);
    // it can't collide with the enemy if the hammer hasn't fully descended (into madness)
    if (anim != 1) return;
    
    PVector point = new PVector(0, armLength());
    point.rotate(-1*robot.rotation - PI/2);
    point.add(robot.pos); // now centered on hammer
    println(point, opponent.pos);
    fill(0, 255, 0, 100);
    circle(point.x, point.y, 10);

    if (point.dist(opponent.pos) < size/4 + opponent.radius()) {
      damage(opponent, point);
      println("Hit");
    }
  }

  void draw() {
    anim += 0.1*animDir;
    if (anim >= 1) {
      animDir = -1;
      anim = 1;
    } else if (anim <= 0) {
      animDir = 1;
      anim = 0;
    }

    strokeWeight(10);
    stroke(0);
    line(0, 0, 0, armLength());
    noStroke();

    fill(0);
    rectMode(CENTER);
    rect(0, armLength(), size/1.5, size/2.5);
  }

  int armLength() {
    return int(size * cos(-PI + anim*PI) * 1.5); 
  }
}

class Sawblade extends Weapon {
  float rotation;

  Sawblade(Robot robot) {
    super(0, robot);
    this.damage = 1;
    this.rotation = 0;
  }

  void checkCollision(Robot opponent) {
    PVector point = new PVector(0, robot.length()-10); // point of the saw blade
    point.rotate(-1*robot.rotation - PI/2);
    point.add(robot.pos); // point is now centered on the sawblade
    
    if (point.dist(opponent.pos) < size/1.25 + opponent.radius()) {
      point.add(PVector.sub(opponent.pos, point).setMag(size/2.5)); // point is now on the leading edge of the blade
      damage(opponent, point);
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