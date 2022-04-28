class SparkExplosion 
{
    
  ArrayList<Spark> sparks;
  PVector origin;
  int r;
  int g;
  int b;
  int createTime;

 SparkExplosion(PVector position, int num) 
  {
    
    origin = position;
    createTime=(int)(random(30,50));
    sparks = new ArrayList<Spark>();
    r=(int)(random(175, 225));
    g= r + (int)(random(-120, 25));
    b=0;

    for (int i = 0; i < num; i++) {
        addParticle();
    }
  }

  void addParticle() 
  {
    
    sparks.add(new Spark(new PVector(origin.x,origin.y),r,g,b));
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
    createTime--;
  }
}