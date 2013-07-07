/**


  alive,
  drying,
  dead
  
  token.getLivingState();

*/
public class Token{
  
  private Ticker animTicker;
  private Ticker ticker;
  private Ticker deathTicker;
  
  
  // TODO: find better way of doing this?
  // When the token is falling, we need it to be a float
  // so just define it as a float to begin with.
  private int row;
  private int column;
  
  private boolean dying;
  private boolean isLiving;
  
  private boolean colored;
  private int type;
  private boolean doesHaveGem;
  
  private int rowToMoveTo;
  private int colToMoveTo;
  
  private boolean returning;
  private boolean hasArrivedAtDest;
  
  private boolean detached;
  private PVector detachedPos;
  
  // Set this and decrement until we reach zero.
  private float distanceToMove;
  
  private float scaleSize;
  
  private int moveDirection;
  private final float MOVE_SPEED = TOKEN_SIZE * 10.0f; // token size per second
  private final float DROP_SPEED = 10;

  //   
  private boolean isSelected;
  
  public Token(){
    setType(TokenType.NULL);
    
    isSelected = false;
    isLiving = true;
    ticker = new Ticker();
    
    row = 0;
    column = 0;
    
    doesHaveGem = false;
    
    detached = false;
    
    //markedForRemoval = false;
    dying = false;
    colored = true;
    
    detachedPos = new PVector();
    
    // TODO: need to really need to set these?
    rowToMoveTo = 0;
    colToMoveTo = 0;
    moveDirection = 0;
    
    scaleSize = 1.0f;
    
    returning = false;
    hasArrivedAtDest = false;
  }
  
  /**
  */
  //public void moveToRow(int rowToMoveTo){
  //  this.rowToMoveTo = rowToMoveTo;
  //  detached = true;
  //}
  
  public void setRowColumn(int row, int column){
    this.row = row;
    this.column = column;
  }
  
  public int getRow(){
    return row;
  }
  
  public int getColumn(){
    return column;
  }
  
  public int getType(){
    return type;
  }
  
  public void setType(int t){
    type = t;
  }
  
  /*public void unMark(){
    //markedForRemoval = false;
    dying = false;
    animTicker = null;
    colored = true;
  }*/
  
  public void setSelect(boolean select){
    isSelected = select;
  }
  
  /**
   */
  public void swap(Token other){
    int tempRow = row;
    int tempCol = column;
    
    this.setRowColumn(other.row, other.column);
    other.setRowColumn(tempRow, tempCol);    
  }
  
  public void kill(){//markForDeletion(){
    dying = true;
    animTicker = new Ticker();
    //deathTicker = new Ticker();
  }
  
  public boolean isDying(){
    return dying;
  }
  
  public boolean isReturning(){
    return returning;
  }
  
  public void setReturning(boolean r){
    returning = r;
  }
  
  public boolean arrivedAtDest(){
    return hasArrivedAtDest;
  }
  
  public boolean isMoving(){
    return moveDirection != 0;
  }
  
  //
  public void dropIntoCell(){
    row = rowToMoveTo;
    column = colToMoveTo;
    
    board[rowToMoveTo][colToMoveTo] = this;
    
    hasArrivedAtDest = false;
    
    distanceToMove = 0;
    
    moveDirection = 0;
  }
  
  /*
   */
  public void update(){
    ticker.tick();
    
    if(animTicker != null){
      animTicker.tick();
    }
    
    if(detached){
      float amtToMove = MOVE_SPEED * moveDirection * ticker.getDeltaSec();
      
      if(row == rowToMoveTo){
        detachedPos.x += amtToMove;
      }
      else{
        detachedPos.y += amtToMove;
      }
      
      distanceToMove -= abs(amtToMove);
      
      if(distanceToMove <= 0){
        detached = false;
        hasArrivedAtDest = true;
        
        // the token could have been floating down, if it wasn't
        // Don't need to explicitly check if it was in the list, the
        // structure does that for us automatically.
        floatingTokens.remove(this);
      }
    }
    
    if(deathTicker != null){
      deathTicker.tick();
      if(deathTicker.getTotalTime() >= 1.0f){
        isLiving = false;
        //println("dead");
      }
    }
  }
  
  /* Don't use isAlive for variable name because Processing.js gets confused
     with method and variable names that share the same name.
   */
  public boolean isAlive(){
    return isLiving;
  }
  
  public void destroy(){
    //println("destroyed");
    deathTicker = new Ticker();
    //animTicker = new Ticker();
  }
  
  public void addGem(){
    doesHaveGem = true;
  }
  
  public boolean hasGem(){
    return doesHaveGem;
  }
  
  /**
   */
  public void animateTo(int r, int c){
    // TODO: fix, it really isn't detached
    detached = true;
    
    // TODO: fix, why -1??
    // column row swapped here.
    detachedPos = new PVector((column-1) * TOKEN_SIZE + (TOKEN_SIZE/2.0f), (row-1) * TOKEN_SIZE + (TOKEN_SIZE/2.0f));
    
    rowToMoveTo = r;
    colToMoveTo = c;
    
    //
    if(c == column){
      int rowDiff = rowToMoveTo - row;
      distanceToMove = abs(rowDiff) * TOKEN_SIZE;
      moveDirection = rowDiff / abs(rowDiff);
    }else{
      int columnDiff = colToMoveTo - column;
      distanceToMove = abs(columnDiff) * TOKEN_SIZE;
      moveDirection = columnDiff / abs(columnDiff);
    }
  }
  
  /*
   *
   */
  public void draw(){
    
    if(animTicker != null && animTicker.getTotalTime() > 0.05f){
      animTicker.reset();
      //colored = !colored;
    }
    
    pushStyle();
    
    //
    if(type == TokenType.NULL){
      fill(0);
      stroke(255);
      strokeWeight(2);
   //   ellipse(column * BALL_SIZE, row * BALL_SIZE, BALL_SIZE, BALL_SIZE);
    }
    else{
      //if(detached){
       // fill(col);
        
       // ellipse(column * TOKEN_SIZE, row * TOKEN_SIZE, TOKEN_SIZE, TOKEN_SIZE);   
      //}
      
      //else if(colored){
        
        int x = 0, 
        y = 0;
        
        if(detached){
          //println(detachedPos.x);
          x = (int)detachedPos.x;// * TOKEN_SIZE - (TOKEN_SIZE/2);
          y = (int)detachedPos.y;// * TOKEN_SIZE - (TOKEN_SIZE/2);
        }
        else{
          x = column * TOKEN_SIZE - (TOKEN_SIZE/2);
          y = (int) row * TOKEN_SIZE - (TOKEN_SIZE/2);
        }
        
        AssetStore store = AssetStore.Instance(globalApplet);
        
        if(isSelected){
          noFill();
          strokeWeight(2);
          stroke(255);
          rect(x,y,TOKEN_SIZE, TOKEN_SIZE);
        }
        

        
        if(!colored){return;}
        
          if(animTicker != null){
            pushMatrix();
            resetMatrix();
            
            scaleSize += animTicker.getDeltaSec() * 3.0f;
            
            translate(START_X, START_Y);
            translate(x,y);
            translate(TOKEN_SIZE, TOKEN_SIZE);
            
            scale(scaleSize);
            translate(-TOKEN_SIZE/2,-TOKEN_SIZE/2);
            
            // TODO: fix me
            tint(255, 255 - ((scaleSize- 1.0f) * 255));
            

          }
          else{
             pushMatrix();
             resetMatrix();
               translate(TOKEN_SIZE/2, TOKEN_SIZE/2);
               translate(START_X, START_Y);
             translate(x,y);
          }
              // Draw the Token
            switch(type){
              case TokenType.RED:    image(store.get(TokenType.RED),0,0);break;
              case TokenType.GREEN:  image(store.get(TokenType.GREEN),0,0);break;
              case TokenType.BLUE:   image(store.get(TokenType.BLUE),0,0);break;
              case TokenType.YELLOW: image(store.get(TokenType.YELLOW),0,0);break;
              case TokenType.SKULL:  image(store.get(TokenType.SKULL),0,0);break;
              case TokenType.WHITE:  image(store.get(TokenType.WHITE),0,0);break;
              case TokenType.PURPLE: image(store.get(TokenType.PURPLE),0,0);break;
              default: ellipse(column * TOKEN_SIZE, row * TOKEN_SIZE, TOKEN_SIZE, TOKEN_SIZE);break;
            }
      
        // Draw the gem if it has one
     //   if(hasGem()){
      // popMatrix();
    /*
          switch(type){
            case TokenType.RED:    image(store.get(TokenType.RED_GEM),x,y);break;
            case TokenType.GREEN:  image(store.get(TokenType.GREEN_GEM),x,y);break;
            case TokenType.BLUE:   image(store.get(TokenType.BLUE_GEM),x,y);break;
            case TokenType.YELLOW: image(store.get(TokenType.YELLOW_GEM),x,y);break;
            case TokenType.SKULL:  image(store.get(TokenType.SKULL_GEM),x,y);break;
            case TokenType.WHITE:  image(store.get(TokenType.WHITE_GEM),x,y);break;
            case TokenType.PURPLE: image(store.get(TokenType.PURPLE_GEM),x,y);break;
            default: ellipse(column * TOKEN_SIZE, row * TOKEN_SIZE, TOKEN_SIZE, TOKEN_SIZE);break;
          }*/
       // }
        
            //  if(animTicker != null){
        popMatrix();
         //   }
        //if(type == 1){
        //  image(rrr, , );
        //}
        //else{
         // fill(col);
         // ellipse(column * TOKEN_SIZE, row * TOKEN_SIZE, TOKEN_SIZE, TOKEN_SIZE);
        //}
      
      //else{
        //fill(255);
        //ellipse(column * TOKEN_SIZE, row * TOKEN_SIZE, TOKEN_SIZE, TOKEN_SIZE);   
     // }
    }
    
    //ellipse(position.x, position.y, BALL_SIZE, BALL_SIZE);
    popStyle();
  }
  
  /**
   */
  public boolean matchesWith(int other){
    if(type == other){
      return true;
    };
    return false;
  }
}