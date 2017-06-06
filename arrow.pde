class Arrow {

  float intensity;

  PVector position;

  float value;

  String name; 

  Direction dir;

  Arrow(Direction direction, String arrowName) {

    name = arrowName;

    dir = direction;
  }

  void draw() {

    if (dir == Direction.DOWN) {

      int posDOWNy = 60; 

      arrow(width/2, posDOWNy, width/2, posDOWNy + 40);
    }

    if (dir == Direction.UP) {

      arrow(width/2, height-60, width/2, height-100);
    }

    if (dir == Direction.LEFT) {

      arrow(40 + 25, height/2, 80+ 25, height/2);
    }

    if (dir == Direction.RIGHT) {
      
      int rightOffset = 60;

      arrow(width-rightOffset, height/2, width-rightOffset-40, height/2);
    }    

    legendBox();
  }

  void arrow(int x1, int y1, int x2, int y2) {

    pushStyle();
    strokeWeight(intensity);
    line(x1, y1, x2, y2);
    pushMatrix();
    translate(x2, y2);
    float a = atan2(x1-x2, y2-y1);
    rotate(a);
    line(0, 0, -10, -10);
    line(0, 0, 10, -10);
    popMatrix();
    popStyle();
  }

  void legendBox() {

    int boxWidth = 100;

    if (dir == Direction.DOWN) {

      pushStyle();

      rect(width/2 - boxWidth / 2, 0 + 20, boxWidth, 30);


      fill(0);

      int fontX = 25;
      int fontY = 20;

      text(name, width/2 - boxWidth / 2 + fontX, 0 + 20 + fontY);

      popStyle();
    }

    if (dir == Direction.UP) {
      
      pushStyle();
      
      rect(width/2 - boxWidth / 2, height-50, boxWidth, 30);

      fill(0);

      int fontX = 25;
      int fontY = 20;
      
      

      text(name, 10+ width/2 - boxWidth / 2+ fontX, height-50+ fontY);

      popStyle();
    }

    if (dir == Direction.LEFT) {
      
      int boxHeight = 100;
      
      pushStyle();
      
      rect(20,height/2-boxHeight + boxHeight/2, 30, boxHeight);

      fill(0);

      int fontX = 25;
      int fontY = 20;

      //text(name, width/2 - boxWidth / 2+ fontX, height-50+ fontY);
      
      int lengthOfLabel = name.length();
      
      textAlign(CENTER, CENTER);
      
      for(int i=0;i<lengthOfLabel;i++){
        
        text(name.charAt(i),20 + 15,30 + height/2-boxHeight/2 + (i*15));
      }
      
      popStyle();      
    }

    if (dir == Direction.RIGHT) {
      
      int boxHeight = 100;
      
      pushStyle();
      
      rect(width-50,height/2-boxHeight + boxHeight/2, 30, boxHeight);

      fill(0);

      int fontX = 25;
      int fontY = 20;

      int lengthOfLabel = name.length();
      
      textAlign(CENTER, CENTER);
      
      for(int i=0;i<lengthOfLabel;i++){
        
        text(name.charAt(i),width-35,30 + height/2-boxHeight/2 + (i*15));
      }

      popStyle();        
    }
  }
}