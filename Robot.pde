class Robot {
    // ----- Global settings
    int wallOffset = 30; // how many pixels before each bot starts turning away from the wall (larger turns sooner)
    float wallTurnFactor = 2; // how strongly it turns away from the wall
    
    int deathAnimLength = 75; // how many frames to keep animating after death

    int partRate = 7; // how many hp before a part is spawned
    // ----- Local variables
    int size; // 0-small 1-medium 2-large
    int weaponType;
    int movementType;
    color colour;

    float hp; 
    float speed;
    float turnSpeed;

    int chassisLevel;
    int weaponLevel;
    int movementLevel;

    int powerFrames; // how many frames the power-up has been occuring for, -1 for inactive
    int powerLength;
    boolean powerExhausted;

    int deathFrames; // how many frames the bot has been dead, used to calculate weapon stuff

    float sizeFactor; // relative how much to scale the robot by, used for the jump power-up
    PVector targetPos;

    int wallBuffer;

    PVector pos; // center of the robot
    float rotation; // in radians, 0 == pointing right

    boolean player;
    float aggressiveness; // 0 == defensive, 1 == aggressive, aggressiveness only gives chance to change aggression
    int status; // 0 == defensive, 1 == neutral, 2 == aggressive

    MovementPart mP;
    ArrayList<Weapon> weapons;

    // TODO: build part class
    ArrayList<SparkExplosion> sparks;
    int partsSpawned;
    // ArrayList<Part> parts;

    Robot(int size, int weaponType, int movementType, float aggressiveness, int x, int y, float rotation, boolean player) {
        this.pos = new PVector(x,y);

        this.rotation = rotation; 
        this.aggressiveness = aggressiveness;
        this.size = size;
        this.weaponType = weaponType;
        this.movementType = movementType;
        this.player = player;

        this.partsSpawned = 0;

        this.status = 1;

        this.powerFrames = -1;
        this.powerExhausted = false;

        this.deathFrames = 0;

        this.sizeFactor = 1;

        this.hp = maxHP(); // bigger ==> more health

        this.wallBuffer = wallOffset + length();

        // store all the spark explosions made so far
        sparks = new ArrayList<SparkExplosion>();

        setChassis(size, 0);

        setWeapon(weaponType, 0);

        setMovement(movementType, 0);
    }

    void update(Robot opponent) {
        // draw the player special in the middle of the screen when building
        if (round*2 % 2 == 1 && player) {

            pushMatrix();
            translate(pos.x, pos.y); // this should be 300, 300
            scale(pauseScale);

            drawBody();
            mP.draw();

            popMatrix();

            drawEffects(opponent);
            return;
        } 

        // if it's died, don't move or update
        if (hp <= 0) {
            if (deathFrames < deathAnimLength) deathFrames++;

            // for an explanation see below
            pushMatrix();

            translate(pos.x, pos.y);
            rotate(-1*rotation + PI/2);
            
            drawBody();
            mP.draw();

            popMatrix();

            // draw weapon below the other bot if it's dead
            drawEffects(opponent);
            return;
        }

        // activate a power
        if (!player && hp <= maxHP()/2.0 && !powerExhausted) {
            powerExhausted = true;

            powerFrames = 0; // signal aiMove that the power has been activated
        }
        else if (player && powerUsed && !powerExhausted){
            powerExhausted = true;

            powerFrames = 0; 
            powerUsed = false;
        }

        // run ai and other stuff
        aiMove(opponent);

        // draw the bot
        pushMatrix();

        // make the bot's center 0,0 and rotate so up is forward
        translate(pos.x,pos.y);
        drawHealth();

        rotate(-1*rotation + PI/2);
        scale(sizeFactor); // only used for the small bot when it jumps

        // draw the chassis and movement parts
        drawBody();        
        mP.draw();
        
        popMatrix();
    }

    // act off of semi-intelligent decision making
    void aiMove(Robot opponent) {
        // control the aggression
        if (!player) {
            if (aggressiveness <= 0.9) aggressiveness += 0.003;
            if (weaponType != 1) aggressiveness += 0.003; // go up faster without laser, cause laser is best at neutral aggression
        }

        // if we have an opponent, and we aren't currenlty performing a small or medium powerup
        if (opponent != null && !(powerFrames >= 0 && size < 2)) { 
            PVector oPos = opponent.pos;

            // =========== CHANGE THE STATUS
            if (random(1) < 0.1 || (player && random(1) < 0.2)) {
                // chance to turn aggressive
                if (random(1) < pow(aggressiveness, 6)) {
                    status = 2;

                // chance to turn defensive 
                } if (random(1) < pow(1-aggressiveness, 6)) {
                    status = 0;

                // chance to turn neutral (smaller chance)
                } if (random(2) < pow(1-abs(aggressiveness-0.5), 6)) status = 1;
            }

            // =========== TURN THE BOT
            // direction to the other bot
            PVector d = PVector.sub(oPos, this.pos);
            float oDir = headToAng(d.heading());

            // if it's aggressive, move towards the enemy
            if (status == 2) {
                turnTo(oDir, 1);

            // if it's neutral, travel perpindicular to the enemy
            } else if (status == 1) {
                // choose whether to travel perpindicular to the right or the left
                if ((rotation < oDir && rotation > oDir - PI) || rotation > oDir + PI) turnTo((oDir + 3*PI/2) % TWO_PI, 1);
                else turnTo((oDir + PI/2) % TWO_PI, 1);
                
            // if it's defensive, run away
            } else if (status == 0) {
                turnTo((oDir + PI) % TWO_PI, 1);
            }

            // =========== AVOID THE WALLS
            // now that it's turned where it would like to go, turn away from the wall, to prevent unnecessary collisions
            PVector wallBounce = new PVector(0, 0); // where should it try and turn to
            
            // move away from the left and right walls
            if (pos.x < wallBuffer) wallBounce.x = 1;
            if (width - wallBuffer < pos.x) wallBounce.x = -1;

            // move away from the top and bottom walls
            if (pos.y < wallBuffer) wallBounce.y = 1;
            if (height - wallBuffer < pos.y) wallBounce.y = -1;

            if (wallBounce.mag() != 0) turnTo(headToAng(wallBounce.heading()), wallTurnFactor);

            // =========== MOVE THE BOT
            pos.x += cos(-1*rotation)*speed;
            pos.y += sin(-1*rotation)*speed;

            // =========== COLLISION CHECK
            // first check for a collision with the other bot
            float dist = radius() + opponent.length()*sqrt(2)/2.0 - pos.dist(oPos);

            // if they're colliding, only move the smaller bot, unless the opponent is spinning, in which case don't move them
            if (dist > 0 && (size <= opponent.size || (opponent.powerFrames >= 0 && opponent.size == 1) || (opponent.hp <= 0))) {
                // if it is overlapping, move it directly away from the other bot equal to the overlap
                PVector offset = PVector.sub(pos, oPos);
                offset.setMag(dist);

                pos.add(offset);
            }

            // wall collision
            if (pos.x < radius()) pos.x = radius();
            if (pos.x > width - radius()) pos.x = width - radius();

            if (pos.y < radius()) pos.y = radius();
            if (pos.y > height - radius()) pos.y = height - radius();

        } 
        
        // if there is an active powerup
        if (opponent != null && powerFrames >= 0) {
            switch (size) {
                // jump to the furthest corner -> 3 seconds
                case 0:                    
                    // if this is the first frame of the power-up, decide where the target corner is
                    if (powerFrames == 0) {
                        // set the target as the opposite quadrant from opponent
                        if (opponent.pos.x <= width/2) {
                            if (opponent.pos.y <= height/2) {
                                targetPos = new PVector(width-wallBuffer, height-wallBuffer);
                            } else {
                                targetPos = new PVector(width-wallBuffer, wallBuffer);
                            }
                        } else {
                            if (opponent.pos.y <= height/2) {
                                targetPos = new PVector(wallBuffer, height-wallBuffer);
                            } else {
                                targetPos = new PVector(wallBuffer, wallBuffer);
                            }
                        }
                    } else if (powerFrames >= powerLength) powerFrames = -2; // becomes -1 (signaling no power) after following increment

                    powerFrames++; 
                    
                    sizeFactor = 1 + sin(powerFrames * PI/(powerLength))*0.6; // get larger then back to normal over 3 seconds


                    // move at a constant rate towards the target position (only if the movement hasn't finished)
                    if (powerFrames > 0 && powerFrames != powerLength) {
                        pos.x += (targetPos.x - pos.x) / (powerLength - powerFrames);
                        pos.y += (targetPos.y - pos.y) / (powerLength - powerFrames);
                    }

                    rotation += 0.2;

                    break;

                // spin in a circle at wall turn factor
                case 1:
                    if (powerFrames >= powerLength) powerFrames = -1;
                    else powerFrames++;

                    rotation += turnSpeed*wallTurnFactor;
                    break;

                // all relavent logic handled elsewhere
                case 2:
                    // don't assume the player wants to go in for the kill, but the ai definitely does
                    if (!player) aggressiveness = 1;

                    if (powerFrames >= powerLength) powerFrames = -1;
                    else powerFrames++;

                    break;
            }
        } 
        
        // if there's no opponent just wander
        if (opponent == null) {
            rotation += random(-0.2,0.2);
            pos.x += cos(-1*rotation + PI/2)*speed;
            pos.y += sin(-1*rotation + PI/2)*speed;
        }
    }

    // turns the robot at turnSpeed towards direction d
    void turnTo(float d, float factor) {
        // don't attempt to turn if it's already close enough (prevents jittering)
        if (abs(d-rotation) > turnSpeed*factor) {
            // positive increases the turn, negative decreases. start at factor to affect how quickly it turns
            float dMod = factor;

            // turn the other way
            if (rotation > d) dMod *= -1;

            // if it's more than a half rotation away, the above calculation will be backwards from the fastest direction
            if (abs(d-rotation) > PI) dMod *= -1;

            // turn the robot by the modifier, and keep it bound to TWO_PI radians
            rotation += dMod * turnSpeed;
            rotation %= TWO_PI;
            if (rotation < 0) rotation += TWO_PI;
        }
    }

    // converts the heading from PVector.heading() to an angle counterclockwise of right
    float headToAng(float heading) {
        if (heading < 0) return heading * -1;
        else return TWO_PI-heading;
    }

    void drawHealth() {
        pushMatrix();
        translate(0, -1*(radius() + 15));

        noStroke();
        rectMode(CENTER);
        fill(150, 15, 0);
        rect(0, 0, sqrt(maxHP())*5, 3);

        fill(255, 50, 0);
        rect(0, 0, sqrt(maxHP())*5 * hp / maxHP(), 3);

        popMatrix();
    }

    // draws only the chassis
    void drawBody() {
        rectMode(CENTER);
        
        noStroke();

        // small-blue, medium-green large-red
        
        
        if (size==0) colour=color(0,0,255);
        if (size==1) colour=color(10,220,20);
        if (size==2) colour=color(255, 0, 0);
        fill(colour);
        square(0,0, length());

        if (powerFrames >= 0) {
            fill(200, 200, 0);
            square(0, 0, length()/2 * (powerLength - powerFrames)/powerLength);
        }

        if (chassisLevel == 1) {
            fill(0, 0);
            stroke(75);
            strokeWeight(5);
            square(0, 0, length()-12);
        }
    }

    synchronized void drawEffects(Robot opponent) {
        for (Weapon weapon : weapons) {
            weapon.update(opponent);
        }

        for (SparkExplosion spark : sparks) {
            spark.run(frameCount/100.0);
        }
    }

    // Deal damage to the bot at a parcicular location (loc used for spark/part spawning)
    void dealDamage(float damage, PVector loc) {
        // lower aggression when taking damage to make it run away and re-position
        if (!player && aggressiveness > 0.25) {
            aggressiveness = max(0, aggressiveness - damage/50);            
        }

        this.hp -= damage;

        // more damage = more sparks
        int partNum = int(maxHP() - hp - partsSpawned*partRate)/partRate;
        partsSpawned += partNum;
        sparks.add(new SparkExplosion(loc, int(random(6*sqrt(damage), 8*sqrt(damage))),partNum,colour));

        // TODO: spawn parts (based off of rolling amount of damage dealt)
    }

    // sets the part to a version of the passed type at a given level
    void setChassis(int size, int level) {
        this.size = size;
        this.chassisLevel = level;
        hp = maxHP();

        float seconds = 0;
        switch(size) {
            case 0:
                seconds = 0.75;
                break;
            case 1:
                seconds = 3;
                break;
            case 2:
                seconds = 4;
                break; 
        }

        powerLength = round(frameR*seconds);

        setWeapon(weaponType, weaponLevel);
        setMovement(movementType, movementLevel);
    }

    void setWeapon(int weaponType, int level) {
        this.weaponType = weaponType;
        // this.weaponLevel = level;

        weapons = new ArrayList<Weapon>();
        // make the appropriate weapon (all fully levelled for testing)
        switch (weaponType) {
            case 0: 
                weapons.add(new Sawblade(this)); 
                break;
            case 1: 
                weapons.add(new Laser(this)); 
                break;
            case 2: 
                weapons.add(new Hammer(this)); 
                break;
        }

        this.weaponLevel = 0;
        if (level >= 1) upgradeWeapon();
        if (level >= 2) upgradeWeapon();
        this.weaponLevel = level;
    }

    void setMovement(int movementType, int level) {
        this.movementType = movementType;

        switch (movementType) {
            case 0: 
                mP = new Tread(this);
                this.speed = 6-size*0.75;
                this.turnSpeed = 0.06*(2-size/3.0);
                break;
            case 1:
                mP = new Wheel(this);
                this.speed = 10-size*0.75;
                this.turnSpeed = 0.04*(2-size/2.0);
                break;
            case 2:
                mP = new Legs(this);
                this.speed = 4-size*0.75;
                this.turnSpeed = 0.1*(2-size/2.0);
                break;
        }

        movementLevel = 0;
        if (level == 1) upgradeMovement();
    }

    // upgrades the specified part to +1 level
    void upgradeChassis() {
        if (chassisLevel == 0) {
            chassisLevel = 1;

            hp = maxHP(); // small +150, medium +300, large +450. why? not a clue, it probably needs balancing lmao
        }
    }

    void upgradeWeapon() {
        if (weaponLevel < 2) {
            weaponLevel++;

            if (weapons.get(0) instanceof Sawblade) {
                switch(weaponLevel) {
                    case 1: 
                        weapons.remove(0);
                        weapons.add(new Sawblade(1, 1, this));
                        break;
                    case 2:
                        weapons.remove(0);
                        weapons.add(new Sawblade(2, 1, this));
                        weapons.add(new Sawblade(2, 2, this));
                        break;
                }
            }

            if (weapons.get(0) instanceof Laser) {
                switch(weaponLevel) {
                    case 1:
                        weapons.remove(0);
                        weapons.add(new Laser(1, 1, this)); 
                        weapons.add(new Laser(1, 2, this));
                        break;
                    case 2:
                        weapons = new ArrayList<Weapon>();
                        weapons.add(new Laser(2, 1, this)); 
                        weapons.add(new Laser(2, 2, this));
                        weapons.add(new Laser(2, 3, this));
                        break;
                }
            }

            if (weapons.get(0) instanceof Hammer) {
                switch(weaponLevel) {
                    case 1:
                        weapons.remove(0);
                        weapons.add(new Hammer(1, this));
                        break;
                    case 2:
                        weapons.remove(0);
                        weapons.add(new Hammer(2, this));
                        break;
                }
            }
        }
    }

    void upgradeMovement() {
        if (movementLevel == 0) {
            movementLevel = 1;

            if (mP instanceof Tread) {
                mP = new Tread(1, this);
                this.speed = 9-size*0.75;
                this.turnSpeed = 0.08*(2-size/3.0);
            }

            if (mP instanceof Wheel) {
                mP = new Wheel(1, this);
                this.speed = 12-size*0.75;
                this.turnSpeed = 0.06*(2-size/2.0);    
            }
            
            if (mP instanceof Legs) {
                mP = new Legs(1, this);
                this.speed = 7-size*0.75;
                this.turnSpeed = 0.12*(2-size/2.0);   
            }
        }

    }

    void unUpgradeChassis() {
        setChassis(size, 0);
    }

    void unUpgradeWeapon() {
        if (weaponLevel == 1) {
            setWeapon(weaponType, 0);
        } else if (weaponLevel == 2) {
            setWeapon(weaponType, 1);
        }
    }

    void unUpgradeMovement() {
        setMovement(movementType, 0);
    }

    void usePower() {
        powerFrames = 0;
    }

    void setAgression(float aggression) {
        this.aggressiveness = aggression;
    }

    void reset() {
        // this doesn't do much
        aggressiveness = 0.5;

        // move it to the center, pointing up
        pos.x = width/2;
        pos.y = height/2;
        rotation = PI/2;  

        // reset the power-up status
        powerExhausted = false;
        powerFrames = -1;

        deathFrames = 0;

        // clear debris
        sparks = new ArrayList<SparkExplosion>();

        // reset combat stuff
        hp = maxHP();
        setWeapon(weaponType, weaponLevel);
        setMovement(movementType, movementLevel);        
    }

    // side length
    int length() {
        return 12*(size+4);
    }

    // hitbox radius (smallest circle containing the corners)
    float radius() {
        return length()*sqrt(2)/2.0;
    }

    float maxHP() {
        return 75*(2+size) + 150*(chassisLevel);
    }
}
