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
    
    update(t);
    display();
  }  
 
  void addforce(float t)
  {
    
    // float angle=(noise(position.x,position.y,t)-0.25)*4*PI;
    float angle = random(0, TWO_PI); // i had to remove noise from this because it was tending around PI, very little around 0/TWO_PI
    float strength=noise(position.x, position.y, -1*t);
    PVector Force=PVector.fromAngle(angle);
    Force.mult(strength);
    acceleration.add(PVector.div(Force,mass));
  }

  void update(float t) 
  {
    
    acceleration.mult(0);
    // addforceGravity(); // 2d so gravity doesn't make sense
    addforce(t);
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 10;
    r /= 1.02;
    g /= 1.02;
    b /= 1.02;
  }
  
  void display() 
  {
    noStroke();
    fill(r,g,b,sqrt(lifespan/255.0)*255);
    circle(position.x,position.y,2);
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
