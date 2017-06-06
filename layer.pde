

class Layer {

  //ArrayList<Cell> cells = new ArrayList<Cell>();

  public int cellGridWidth = 5;
  public int cellGridHeight = 5;  

  Cell[][] cells = new Cell[cellGridHeight][cellGridWidth];
  Cell[][] nextStepCells = new Cell[cellGridHeight][cellGridWidth];



  Direction direction;

  String name;
  
  boolean active = true;

  boolean debug = true;

  Layer(String nameForLayer, Direction layerDirection) {
    
    

    direction = layerDirection;

    name = nameForLayer;

    //if (debug)
    //  println("Initialising Layer "+name+" with Direction :"+layerDirection.toString());



    for (int y=0; y<5; y++)
      for (int x=0; x<5; x++) {

        Cell newCell = new Cell();

        newCell.x = x;
        newCell.y = y;

        newCell.value = 0f;

        cells[y][x] = newCell;

        newCell = new Cell();

        newCell.x = x;
        newCell.y = y;

        newCell.value = 0f;


        nextStepCells[y][x] = newCell;
      }
  }

  void applyForceToCell(int x, int y, float force) {
    
    if(active)
      cells[y][x].value = force;
  }

  void step() {

    //debugLayer();
    //debugStepAheadLayer();

    for (int y=0; y<cellGridHeight; y++)
      for (int x=0; x<cellGridWidth; x++) {

        int nX, nY;

        nX = x; 
        nY = y;

        if (direction == Direction.UP)
          nY -= 1;

        if (direction == Direction.DOWN)
          nY += 1;

        if (direction == Direction.LEFT)
          nX += 1;

        if (direction == Direction.RIGHT)
          nX -= 1;

        if (checkBoundaries(x, y)) {  



          boolean isZero = false;

          if (cells[y][x].value == 0)
            isZero = true;

          if (!isZero) {  
            
            //println("Moving energy from "+x+"/"+y+" to "+nX+"/"+nY+" with value:"+cells[y][x].value / 2f);

            //debugLayer();
            //debugStepAheadLayer();

            nextStepCells[nY][nX].value = cells[y][x].value / 2f;
          }
        }

        cells[y][x].value = 0;
      }

    for (int y=0; y<cellGridHeight; y++)
      for (int x=0; x<cellGridWidth; x++) {

        cells[y][x].value = nextStepCells[y][x].value;
      }
      
    for (int y=0; y<cellGridHeight; y++)
      for (int x=0; x<cellGridWidth; x++) {

        nextStepCells[y][x].value = 0;
      }      
  }

  boolean checkBoundaries(int x, int y) {

    boolean cellExists = true;

    if (direction == Direction.UP)
      y -= 1;

    if (direction == Direction.DOWN)
      y += 1;

    if (direction == Direction.LEFT)
      x += 1;

    if (direction == Direction.RIGHT)
      x -= 1;            

    if ( x < 0 || x > cellGridWidth - 1 )
      cellExists = false;

    if ( y < 0 || y > cellGridHeight - 1 )
      cellExists = false;     

    //if (cellExists)println("Cell exists !"); 
    //else println("Cell does not exist !");

    return cellExists;
  }

  void debugLayer() {

    println();
    for (int y=0; y<cellGridHeight; y++)
    {
      println();
      for (int x=0; x<cellGridWidth; x++) {

        //print(cells[y][x].value+" : ");


        //println("Mergin Layer :"+name+" of Cell ("+x+"/"+y+") with value : "+layer.cells[y][x].value);
      }
    }
    println(); 
    println();
  }

  void debugStepAheadLayer() {

    println();
    for (int y=0; y<cellGridHeight; y++)
    {
      println();
      for (int x=0; x<cellGridWidth; x++) {

        print(nextStepCells[y][x].value+" : ");


        //println("Mergin Layer :"+name+" of Cell ("+x+"/"+y+") with value : "+layer.cells[y][x].value);
      }
    }
    println(); 
    println();
  }  

}