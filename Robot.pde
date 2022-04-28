class Robot {
    // ----- Global settings
    int wallOffset = 30; // how many pixels before each bot starts turning away from the wall (larger turns sooner)
    float wallTurnFactor = 2; // how strongly it turns away from the wall

    // ----- Local variables
    int size; // 0-small 1-medium 2-large
    int hp; 
    float speed;
    float turnSpeed;

    int wallBuffer;

    PVector pos; // center of the robot
    float rotation; // in radians, 0 == pointing right

    float aggressiveness; // 0 == defensive, 1 == aggressive, aggressiveness only gives chance to change aggression
    int status; // 0 == defensive, 1 == neutral, 2 == aggressive

    MovementPart mP;
    Weapon weapon;

    // TODO: build part/spark classes
    ArrayList<SparkExplosion> sparks;
    // ArrayList<Part> parts;

    Robot(int size, float aggressiveness, int x, int y, float rotation) {
        this.pos = new PVector(x,y);
        this.rotation = rotation; 

        this.aggressiveness = aggressiveness;

        this.size = size;

        this.status = 1;

        this.hp = 100*(1+size); // 100 for small, 200 for medium and 300 for large
        this.speed = 6-size*0.75;
        this.turnSpeed = 0.06*(2-size/3.0);

        this.wallBuffer = wallOffset + length();

        mP = new MovementPart(0, this); // creates a tread appropriate for a large robot.
        weapon = new Sawblade(this);
        sparks = new ArrayList<SparkExplosion>();
    }

    void update(Robot opponent) {
        //TODO: run ai and other stuff
        aiMove(opponent);

        // draw the bot
        pushMatrix();
    
        // make the bot's center 0,0 and rotate so up is forward
        translate(pos.x,pos.y);
        rotate(-1*rotation + PI/2);

        drawBody();

        //TODO: draw weapons and movement parts
        // could possibly add another translate to position them properly based off size, perhaps a set number of pixels from the edge
        
        mP.animateMovement();
        
        popMatrix();
    }

    // move based off of semi-intelligent decision making
    void aiMove(Robot opponent) {
        // react to the opponent        
        if (opponent != null) {
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
            // this is being janky
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
            if (dist > 0 && size <= opponent.size) {
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

        // if there's no opponent just wander
        } else {
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
    private float headToAng(float heading) {
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
    }

    void drawEffects(Robot opponent) {
        weapon.update(opponent);

        for (SparkExplosion spark : sparks) {
            spark.run(frameCount/100.0);
        }
    }

    // Deal damage to the bot at a parcicular location (loc used for spark/part spawning)
    void dealDamage(int damage, PVector loc) {
        // this.hp -= damage;

        sparks.add(new SparkExplosion(loc, int(random(3, 8))));
    }

    int length() {
        return 12*(size+4);
    }

    float radius() {
        return length()*sqrt(2)/2.0;
    }
}
