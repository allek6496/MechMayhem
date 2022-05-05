 class Metal {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  int r;
  int g;
  int b;
  float mass;

  Metal(PVector positionTemp,int rTemp,int gTemp,int bTemp) 
  {
    float angle=random(0,TWO_PI);
    velocity=PVector.fromAngle(angle).mult(6);
    acceleration=new PVector(0,0);
    position = positionTemp;
    r=rTemp;
    g=gTemp;
    b=bTemp;
    lifespan = 255;
    mass=1;
  }

  void run(float t) 
  {
    if (!isDead()) update(t);
    display();
  }  
 
  void addforce(float t)
  {
    float angle = random(0, TWO_PI); 
    float strength=noise(position.x, position.y, -1*t);
    PVector Force=PVector.fromAngle(angle);
    Force.mult(strength);
    acceleration.add(PVector.div(Force,mass));
  }

  void update(float t) 
  {
    position.add(velocity);
    lifespan -= 50;
  }
  
  void sq(float x, float y, int r) {
    rectMode(CORNERS);
    rect(x-(r/2),y-(r/2),x+(r/2),y+(r/2));
  }
  void display() 
  {
    noStroke();
    fill(r,g,b);
    sq(position.x,position.y,5);
  }
  
  boolean isDead() 
  {
    if (lifespan < 5.0) 
    {
      return true;
    }
    else 
    {
      return false;
    }
  }
} 
