class Robot {
    int size; // 0-small 1-medium 2-large
    int hp; 
    int speed;

    PVector pos; // center of the robot
    float rotation; // in radians, 0 == pointing up

    // TODO: build part/spark classes
    // ArrayList<Spark> sparks;
    // ArrayList<Part> parts;


    Robot(int size, int x, int y, float rotation) {
        this.pos = new PVector(x,y);
        this.rotation = rotation; 

        this.size = size;

        this.hp = 100*(1+size); // 100 for small, 200 for medium and 300 for large
        this.speed = 1+size;
    }

    void update() {
        //TODO: run ai and other stuff
        aiMove();

        // draw the bot
        pushMatrix();
        // make the bot's center 0,0 and rotate so up is forward
        translate(pos.x,pos.y);
        rotate(rotation);

        drawBody();

        //TODO: draw weapons and movement parts
        // could possibly add another translate to position them properly based off size, perhaps a set number of pixels from the edge
        
        MovementPart tread = new MovementPart(0);
        tread.animateMovement(size);
        
        popMatrix();

    }

    // move based off of semi-intelligent decision making
    void aiMove() {
        rotation += random(-0.2,0.2);
        pos.x += cos(rotation-PI/2)*speed;
        pos.y += sin(rotation-PI/2)*speed;
    }

    // draws only the chassis
    void drawBody() {
        rectMode(CENTER);
        noStroke();
        
        // small-blue, medium-green large-black
        if (size==0) fill(0,0,255);
        if (size==1) fill(0,255,0);
        if (size==2) fill(0);

        square(0,0, 10*(size+1));
        // QUESTION: Make 10*(size+1) a global variable? This value will be constantly used in the MovementPart and Weapon Classes to position them.
    }

    

    // Deal damage to the bot at a parcicular location (loc used for spark/part spawning)
    void dealDamage(int damage, PVector loc) {
        this.hp -= damage;

        // TODO: spawn sparks/parts
    }

}
