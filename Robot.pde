class Robot {
    // ----- Global settings
    int wallOffset = 30; // how many pixels before each bot starts turning away from the wall (larger turns sooner)
    float wallTurnFactor = 2; // how strongly it turns away from the wall

    // ----- Local variables
    int size; // 0-small 1-medium 2-large
    float hp; 
    float speed;
    float turnSpeed;

    int powerFrames; // how many frames the power-up has been occuring for, -1 for inactive
    boolean powerExhausted;

    float sizeFactor; // relative how much to scale the robot by, used for the jump power-up
    PVector targetPos;

    int wallBuffer;

    PVector pos; // center of the robot
    float rotation; // in radians, 0 == pointing right

    boolean player;
    float aggressiveness; // 0 == defensive, 1 == aggressive, aggressiveness only gives chance to change aggression
    int status; // 0 == defensive, 1 == neutral, 2 == aggressive

    MovementPart mP;
    Weapon weapon;

    // TODO: build part/spark classes
    ArrayList<SparkExplosion> sparks;
    // ArrayList<Part> parts;

    Robot(int size, int weaponType, int movementType, float aggressiveness, int x, int y, float rotation, boolean player) {
        this.pos = new PVector(x,y);

        this.rotation = rotation; 
        this.aggressiveness = aggressiveness;
        this.size = size;
        this.player = player;

        this.status = 1;

        this.powerFrames = -1;
        this.powerExhausted = false;
        this.sizeFactor = 1;

        this.hp = maxHP(); // bigger ==> more health

        this.wallBuffer = wallOffset + length();

        // store all the spark explosions made so far
        sparks = new ArrayList<SparkExplosion>();

        mP = new MovementPart(0, this); // creates a tread for this bot TODO: multiple types
        
        // make the appropriate weapon
        switch (weaponType) {
            case 0: weapon = new Sawblade(this); break;
            case 1: weapon = new Laser(this); break;
            case 2: weapon = new Hammer(this); break;
        }

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
    }

    void update(Robot opponent) {
        // TODO: some kind of check if it's player controlled or not
        if (!player && hp <= maxHP()/2.0 && !powerExhausted) {
            println("Powerup");
            powerExhausted = true;

            powerFrames = 0; // signal aiMove that the power has been activated
        }
        else if (player && powerUsed && !powerExhausted){
            powerExhausted = true;

            powerFrames = 0; 
        }

        // run ai and other stuff
        aiMove(opponent);

        // draw the bot
        pushMatrix();
    
        // make the bot's center 0,0 and rotate so up is forward
        translate(pos.x,pos.y);
        rotate(-1*rotation + PI/2);
        // scale(sizeFactor);

        drawBody();

        //TODO: draw weapons and movement parts
        // could possibly add another translate to position them properly based off size, perhaps a set number of pixels from the edge
        
        mP.draw();
        
        popMatrix();
    }

    // act off of semi-intelligent decision making
    void aiMove(Robot opponent) {
        // control the aggression
        if (!player) {
            // TODO: make this based off of what loadout it has, laser likes around 0.5, sawblade likes around 0.9, hammer idk. maybe some size/mP influence as well
            if (aggressiveness <= 0.9) aggressiveness += 0.003;
        }

        // if we have an opponent, and we aren't currenlty performing a small or medium powerup
        if (opponent != null && !(powerFrames >= 0 && size < 2)) { 
            PVector oPos = opponent.pos;

            // =========== CHANGE THE STATUS
            if (random(1) < 0.1) {
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
            if (dist > 0 && (size <= opponent.size || (opponent.powerFrames >= 0 && opponent.size == 1))) {
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
        if (powerFrames >= 0) {
            float seconds;

            switch (size) {
                // jump to the furthest corner -> 3 seconds
                case 0:
                    seconds = 0.5;
                    
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
                    } else if (powerFrames >= frameRate * seconds) powerFrames = -2; // becomes -1 (signaling no power) after following increment

                    powerFrames++; 
                    
                    sizeFactor = 1 + sin(powerFrames * PI/(seconds*frameRate))*1.5; // get larger then back to normal over 3 seconds


                    // move at a constant rate towards the target position
                    pos.x += (targetPos.x - pos.x) / (seconds*frameRate - powerFrames);
                    pos.y += (targetPos.y - pos.y) / (seconds*frameRate - powerFrames);

                    rotation += 0.2;

                    break;

                // spin in a circle at wall turn factor
                // TODO: experiment with increasing attack rate for the duration
                case 1:
                    seconds = 3;

                    if (powerFrames >= frameRate * seconds) powerFrames = -1;
                    else powerFrames++;

                    rotation += turnSpeed*wallTurnFactor;
                    break;

                // all relavent logic handled elsewhere
                case 2:
                    // don't assume the player wants to go in for the kill, but the ai definitely does
                    if (!player) aggressiveness = 1;

                    seconds = 6;

                    if (powerFrames >= frameRate * seconds) powerFrames = -1;
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

    // draws only the chassis
    void drawBody() {
        rectMode(CENTER);
        noStroke();
        
        // small-blue, medium-green large-red
        if (size==0) fill(0,0,255);
        if (size==1) fill(10,220,20);
        if (size==2) fill(255, 0, 0);

        square(0,0, length());

        // TODO: lightning bolt graphic or something like that
        if (powerFrames >= 0) {
            fill(200, 200, 0);
            square(0, 0, length()/2);
        }
    }

    void drawEffects(Robot opponent) {
        weapon.update(opponent);

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
        sparks.add(new SparkExplosion(loc, int(random(6*sqrt(damage), 8*sqrt(damage)))));

        // TODO: spawn parts (based off of rolling amount of damage dealt)
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
        return 75*(2+size);
    }
}
