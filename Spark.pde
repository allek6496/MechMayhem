 class Spark {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  int r;
  int g;
  int b;
  float mass;

  Spark(PVector positionTemp,int rTemp,int gTemp,int bTemp) 
  {
    
    float angle=random(0,TWO_PI);
    velocity=PVector.fromAngle(angle);
    acceleration=new PVector(0,0);
    position = positionTemp;
    r=rTemp;
    g=gTemp;
    b=bTemp;
    lifespan = 50;
    mass=1;
  }

  void run(float t) 
  {
    
    update(t);
    display();
  }
  
  void addforceGravity()
  {
    
    PVector graForce=new PVector(0,0.01);
    acceleration.add(PVector.div(graForce,mass));
  }
  
 
  void addforce(float t)
  {
    
    float Strength=noise(position.x,position.y,t);
    float Angle=Strength*TWO_PI;
    PVector Force=PVector.fromAngle(Angle);
    Force.mult(Strength*0.01);
    acceleration.add( PVector.div(Force,mass));
  }

  void update(float t) 
  {
    
    acceleration.mult(0);
    // addforceGravity(); // 2d so gravity doesn't make sense
    addforce(t);
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 2.0;
  }
  
  void display() 
  {
    
    noStroke();
    fill(r,g,b,lifespan);
    ellipse(position.x,position.y,5,5);
  }
  
  boolean isDead() 
  {
    
    if (lifespan < 0.0) 
    {
    
      return true;
    }
    else 
    {
    
      return false;
    }
  }
} 
