class SparkExplosion 
{
    
  ArrayList<Spark> sparks;
  ArrayList<Metal> metals;
  ArrayList<Metal> dead;
  PVector origin;
  int r;
  int g;
  int b;
  int createTime;
  color colour;

 SparkExplosion(PVector position, int num, int partNum, color c) 
  {
    origin = position;
    createTime=(int)(random(30,50));
    sparks = new ArrayList<Spark>();
    metals = new ArrayList<Metal>();
    colour = c;
    dead = new ArrayList<Metal>();
    r=(int)(random(175, 225));
    g= r + (int)(random(-120, 25));
    b=0;

    for (int i = 0; i < num; i++) {
        addSpark();
    }

    for (int i = 0; i < partNum; i++) {
      addMetal();
    }
  }

  void addSpark() 
  {
    
    sparks.add(new Spark(new PVector(origin.x,origin.y),r,g,b));
    
  }
    void addMetal() 
  {
   
    metals.add(new Metal(new PVector(origin.x,origin.y),int(red(colour)),int(blue(colour)),int(green(colour))));
  }
  void sq(float x, float y, int r) {
    rectMode(CORNERS);
    rect(x-(r/2),y-(r/2),x+(r/2),y+(r/2));
  }
  
  void run(float t) 
  {
    for (int i = sparks.size()-1; i >= 0; i--) 
    {
    
      Spark p = sparks.get(i);
      p.run(t);
      if (p.isDead()) 
      {
    
        sparks.remove(i);
      }
    }
    for (int i = metals.size()-1; i >= 0; i--) 
    {
    
      Metal p = metals.get(i);
      p.run(t);
      if (p.isDead()) 
      {
        dead.add(p);
        
      }
    }
    createTime--;
    if (dead.size() > 0){
      for (Metal m:dead) {
        metals.remove(m);
        fill(colour);
        sq(m.position.x,m.position.y,5);
      }
    }
  }
  
}
