// I feel like this should be multiple classes given how differently they all operate but this will work for now
class Weapon {
  int type; // 0 - saw blade, 1 - laser, 2 - hammer
  Robot robot;
  float size; // size of the weapon -- also (diameter) of the circle dealing damage for hammer and saw
  float damage; // how much damage the weapon does
  int level;

  PVector attachPoint;

  Weapon(int type, int level, Robot robot) {
    this.type = type;
    this.level = level;
    this.robot = robot;

    this.size = robot.length()-10;
  }

  Weapon(int type, int level, PVector attachPoint, Robot robot) {
    this(type, level, robot);
    this.attachPoint = attachPoint;
  }

  void update(Robot opponent){ // updates the weapon
    // offset to the bot again (since this is called after the bot draws itself)
    pushMatrix();
    translate(robot.pos.x, robot.pos.y);
    rotate(-1*robot.rotation - PI/2);
    if (round*2 % 2 == 1 && robot.player) scale(pauseScale);

    draw();
    
    popMatrix();
    
    if (opponent != null) checkCollision(opponent);
  }

  void draw() { return; }

  void checkCollision(Robot opponent) { return; }

  // gets the screen position of the weapon's base, only really used for laser but it's generalizable so it's here instead
  PVector getPos() {
    PVector pos = new PVector(attachPoint.x, attachPoint.y);
    pos.rotate(-1*robot.rotation - PI/2);
    pos.add(robot.pos);
    return pos;
  }

  // attempts to deal damage to the opponent
  void dealDamage(Robot opponent, float damage, PVector loc) {
    // enemy is invincible during jump
    if (opponent.powerFrames >= 0 && opponent.size == 0) {
      return;

    // this robot deals extra damage
    } else if (robot.powerFrames >= 0 && robot.size == 2) {
      opponent.dealDamage(damage*2, loc);

    // enemy takes 1/2 damage
    } else if (opponent.powerFrames >= 0 && opponent.size == 2) {
      opponent.dealDamage(damage/2.0, loc);

    // we take 1/2 damage lmao  
    } else if (opponent.powerFrames >= 0 && opponent.size == 1) {
      PVector position = new PVector(robot.pos.x, robot.pos.y);
      position.add(PVector.sub(opponent.pos, robot.pos).div(2));
      robot.dealDamage(damage/2.0, position);
    
    // no relavent powerups
    } else {
      opponent.dealDamage(damage, loc);
    }

    // when it's getting damage in increase aggression
    if (!robot.player) {
      robot.aggressiveness = min(1, robot.aggressiveness + 0.03);
    }
  }
}

class Laser extends Weapon {
  float turnSpeed = 0.2;
  int fireRate = 25;

  float angle; // 0 is straight ahead, varies in [-PI/2, PI/2]
  float angleCenter; // 0 straight ahead, only different for back laser, where this is equal to PI
  int cooldown;

  ArrayList<Pulse> pulses;

  class Pulse {
    int len = 10;
    PVector pos;
    PVector vel;
    float speed = 20;
    boolean reflected = false; // has it been reflected by spinning move
  
    Pulse(float x, float y, float angle) { // for angle, 0 is right and increases counterclockwise
      this.pos = new PVector(x, y);
      this.vel = PVector.fromAngle(angle).mult(speed);
    }

    void update() {
      // move
      pos.add(vel);

      // draw
      stroke(200, 0, 50);
      strokeWeight(5);

      // find the position of the trailing point
      PVector trail = new PVector(vel.x, vel.y);
      trail.setMag(len);
      trail.mult(-1);
      trail.add(pos);

      if (trail.x < 0 || trail.x > width || trail.y < 0 || trail.y > height) pulses.remove(this);

      line(pos.x, pos.y, trail.x, trail.y);

      noStroke();
    }

    // checks if this laser has hit an opponent
    boolean colliding(Robot opponent) {
      // reflect if it's a spinning bot
      if (opponent.size == 1 && opponent.powerFrames >= 0) {
        // this is a very naive approach because I can't be bothered to find the exact collision point and where it should go etc, this should look alright

        // if it's inside the bot
        if (pos.dist(opponent.pos) < opponent.radius()) {
          // first project the velocity onto a vector to the center of opponent 
          PVector laserToBot = PVector.sub(opponent.pos, pos);

          laserToBot.mult(PVector.dot(laserToBot, vel) / pow(laserToBot.mag(), 2)); // laserToBot is now the projection of velocity towards the bot

          // subtract double the velocity towards the bot, to basically reflect it away
          vel.sub(laserToBot.mult(2));
        }

        reflected = true;

        return false;

      // if it has been reflected, manually damage our robot 
      } else if (reflected && pos.dist(robot.pos) < robot.radius()) {
        dealDamage(robot, damage, pos);
        pulses.remove(this);
        return false;

      // if there's no special case, just return if they've collided with opponent
      } else return pos.dist(opponent.pos) < opponent.radius();
    }
  } 

  Laser(Robot robot) {
    super(1, 0, new PVector(0, robot.length()/3), robot);
    this.damage = 10;
    this.angle = 0;
    this.angleCenter = 0;
    this.pulses = new ArrayList<Pulse>();
    this.cooldown = fireRate;
  }

  Laser(int level, int i, Robot robot) {
    this(robot);

    // if it's upgraded, position based off of level
    if (level > 0) {
      switch (i) {
        case 1:
          attachPoint = new PVector(-1*robot.length()/4, robot.length()/3);
          break;
        case 2:
          attachPoint = new PVector(robot.length()/4, robot.length()/3);
          break;
        case 3:
          attachPoint = new PVector(0, -1*robot.length()/3);
          angleCenter = PI;
          break;
      }
    }
  }

  void checkCollision(Robot opponent) {
    // this still runs if the robot is dead, the only thing updated are the laser pulses

    // position of the laser
    PVector pos = getPos();

    // ===== TURN THE LASER
    boolean onTarget = false; // whether or not the laser is poitning at the enemy
    float d = robot.headToAng(PVector.sub(opponent.pos, pos).heading());

    d -= robot.rotation;
    d *= -1;

    // TODO: I think there's a bug here involving multiple rotations that causes the laser to get stuck
    // turn towards the enemy iff you're not already close enough and alive lol
    if (abs(d-angle) > turnSpeed && robot.hp > 0) {
      // positive increases the turn, negative decreases.
      float dMod = 1;

      // turn the other way 
      if (angle > d) dMod *= -1;

      // if it's more than a half rotation away, the above calculation will be backwards from the fastest direction (must go through the 0-TWO_PI transiton)
      if (abs(d-angle) > PI) dMod *= -1;

      // turn the robot by the modifier, and keep it bound to TWO_PI radians
      angle += dMod * turnSpeed;

      // bind the angle to prevent shooting backwards (from where it's pointed towards)
      if (angle < angleCenter - 2*PI/3) angle = angleCenter - 2*PI/3;
      else if (angle > angleCenter + 2*PI/3) angle = angleCenter + 2*PI/3;
    } else {
      onTarget = true;
    }

    // ===== SHOOT THE LASER
    if (cooldown <= 0 && onTarget && robot.hp > 0) {
      cooldown = fireRate;

      pulses.add(new Pulse(pos.x, pos.y, angle - robot.rotation));

    } else cooldown--;

    // ===== UPDATE THE PULSES
    for (int i = pulses.size()-1; i >= 0; i--) {
      Pulse pulse = pulses.get(i);
      pulse.update();
      
      // if it's colliding and they're not invincible
      if (pulse.colliding(opponent) && !(opponent.powerFrames >= 0 && opponent.size == 0)) {
        dealDamage(opponent, damage, pulse.pos);
        pulses.remove(pulse);
      }
    }

  }

  // the laser is a bit ugly but oh well
  void draw() {
    // if it's died, move the laser in a random direction 
    if (robot.hp <= 0) {
      attachPoint.mult(1 + 0.03*(robot.deathAnimLength - robot.deathFrames)/robot.deathAnimLength);

      angle += 0.12*(robot.deathAnimLength - robot.deathFrames)/robot.deathAnimLength;
    }

    noStroke();
    pushMatrix();
    translate(attachPoint.x, attachPoint.y);

    rotate(angle);

    fill(200);
    rectMode(CENTER);
    rect(0, 6, 10, 20);
        
    fill(0);
    circle(0, 0, 8);
    popMatrix();
  }
}

class Hammer extends Weapon {
  float anim; // how far through the animation is it 0 -> 1 -> 0 ...
  float animDir; // 1 => descending, -1 => raising
  float length;

  Hammer(Robot robot) {
    super (2, 0, new PVector(0, 0), robot);
    this.damage = 20;
    this.anim = 0;
    this.animDir = 1;
    this.length = size;
  }

  Hammer(int level, Robot robot) {
    this(robot);

    if (level >= 1) animDir = 2; // 2x pound speed
    if (level == 2) {
      size *= 1.5;
      length *= 1.2;
    }
  }

  void checkCollision(Robot opponent) {
    // it can't collide with the enemy if the hammer hasn't fully descended (into madness)
    if (anim != 1 || robot.hp <= 0) return;
    
    PVector point = new PVector(0, armLength());
    point.rotate(-1*robot.rotation - PI/2);
    point.add(robot.pos); // now centered on hammer

    if (point.dist(opponent.pos) < size/4 + opponent.radius()) {
      dealDamage(opponent, damage, point);
    }
  }

  void draw() {
    if (robot.hp <= 0) {
      attachPoint.add(0, 3*(robot.deathAnimLength - robot.deathFrames)/robot.deathAnimLength);

      // angle += 0.15*(robot.deathAnimLength - robot.deathFrames)/robot.deathAnimLength;
    }

    anim += 0.1*animDir*(robot.deathAnimLength - robot.deathFrames)/float(robot.deathAnimLength);
    if (anim >= 1) { 
      if (robot.hp > 0 || (robot.hp < 0 && robot.deathFrames < 15)) animDir *= -1; // don't raise the hammer after death, but still able to drop it
      anim = 1;
    } else if (anim <= 0) {
      animDir *= -1;
      anim = 0;
    }

    pushMatrix();

    translate(attachPoint.x, attachPoint.y); // this is only used for deathAnim

    strokeWeight(10);
    stroke(0);
    line(0, 0, 0, armLength());
    noStroke();

    if (anim >= 0.9 && robot.hp > 0) fill(70, 50, 30);
    else fill(0);
    rectMode(CENTER);
    rect(0, armLength(), size/1.5, size/2.5);
    popMatrix();
  }

  int armLength() {
    return int(length * cos(-PI + anim*PI) * 1.5); 
  }
}

class Sawblade extends Weapon {
  float lv0Damage = 0.6;
  float lv1Damage = 1;

  float bladeAngle;
  float rotation;
  float length;

  Sawblade(Robot robot) {
    super(0, 0, new PVector(0, 10), robot);
    this.damage = lv0Damage;
    this.rotation = 0;
    this.bladeAngle = 0;
    length = size;
  }

  // at level 2, +1 sawblade, so i in {1, 2} tells whether it's first (left) or second (right)
  Sawblade(int level, int i, Robot robot) {
    super(0, level, new PVector(0, 10), robot);
    this.rotation = 0;

    if (level == 2) {
      this.damage = lv1Damage;
      this.length = size + level*10;
      // front left
      if (i == 1) {
        this.bladeAngle = -1*PI/7;
      } else {
        this.bladeAngle = PI/7;
      }
    } else {
      this.damage = lv0Damage;
      this.length = size;
      this.bladeAngle = 0;

      if (level == 1) this.damage = lv1Damage;
    }
  }

  void checkCollision(Robot opponent) {
    if (robot.hp <= 0) return;

    PVector point = new PVector(0, robot.length()-10); // point of the saw blade
    point.rotate(-1*robot.rotation - PI/2);
    point.add(robot.pos); // point is now centered on the sawblade
    
    if (point.dist(opponent.pos) < size/1.25 + opponent.radius()) {
      point.add(PVector.sub(opponent.pos, point).setMag(size/2.5)); // point is now on the leading edge of the blade
      dealDamage(opponent, damage, point);
    }
  }

  // draw weapon and progress animation
  void draw() {
    if (robot.hp <= 0) {
      if (bladeAngle != 0) {
        attachPoint.add(0.5*bladeAngle/abs(bladeAngle)*(robot.deathAnimLength - robot.deathFrames)/robot.deathAnimLength, 
                        3*(robot.deathAnimLength - robot.deathFrames)/robot.deathAnimLength);

        bladeAngle += bladeAngle/abs(bladeAngle) * (0.1*(robot.deathAnimLength - robot.deathFrames)/robot.deathAnimLength);
      } else {
        attachPoint.add(0, 3);

        bladeAngle += 0.1;
      }
    }
    
    pushMatrix();
    translate(attachPoint.x, attachPoint.y);
    rotate(bladeAngle);

    fill(200);
    noStroke();
    rectMode(CORNERS);
    rect(-7-robot.size, 0, 7+robot.size, length);

    // circle to cover the bare ends
    if (level == 2) {
      fill(50);
      circle(0, 0, 30);
    }

    translate(0, length-10);


    rotate(rotation);

    if (level > 0) {
      fill(75);
      circle(0, 0, size/2);

      stroke(25);
      strokeWeight(4);
      line(-size/4, 0, size/4, 0);
      line(0, -size/4, 0, size/4);
      noStroke();

    }

    shapeMode(CENTER);
    if (level == 1) shape(sawblade, 0, 0, size*1.2, size*1.2);
    else shape(sawblade, 0, 0, size, size); // shape(shape, x, y, width, height)

    rotation += 0.3 * (robot.deathAnimLength - robot.deathFrames)/robot.deathAnimLength;
    popMatrix();
  }
}