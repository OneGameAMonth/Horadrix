public interface IScreen{
  
  public void draw();
  public void update();
  
  // Mouse methods
  public void mousePressed();
  public void mouseReleased();
  public void mouseDragged();
  public void mouseMoved();
  
  public void keyPressed();
  public void keyReleased();
  
  public String getName();
  
  public boolean isAlive();
}
/*
TODO: add rotation



*/
public class SpriteSheetLoader{

  PImage test;
  HashMap map;
  
  public  void load(String texturePackerMetaFile){
    
    
    
    
    
   /* JSONObject json;
    
    json = loadJSONObject(texturePackerMetaFile);
    
    String imageFilename = json.getJSONObject("meta").getString("image");
   // print(imageFilename); 
    
    PImage texture = loadImage(imageFilename);
    
    JSONArray frames = json.getJSONArray("frames");
    
    map = new HashMap<String, PImage>(frames.size());    
    
    //println(frames.size());
    
    // Iterate over all the sprites in the json file
    for(int i = 0; i < frames.size(); i++){
      
      //
      JSONObject frame = frames.getJSONObject(i);
      
      
      // Regardless of whether the sprite is rotated or not, it's final dimensions
      // can be extracted from sourceSize.
      JSONObject sourceSize = frame.getJSONObject("sourceSize");
      int dstSpriteWidth  = sourceSize.getInt("w");
      int dstSpriteHeight = sourceSize.getInt("h");
      PImage img = createImage(dstSpriteWidth, dstSpriteHeight, ARGB);
      println("Created image: (" + dstSpriteWidth + "," + dstSpriteHeight + ")");
      
      // Pull the actual sprite from the sheet
      JSONObject dimensions = frame.getJSONObject("frame");
      int srcStartX = dimensions.getInt("x");
      int srcStartY = dimensions.getInt("y");
      int srcWidth = dimensions.getInt("w");
      int srcHeight = dimensions.getInt("h");
      
      // This is actually our destination, where we copy the pixels into the image.
      JSONObject spriteSourceSize = frame.getJSONObject("spriteSourceSize");
      int dstStartX = spriteSourceSize.getInt("x");
      int dstStartY = spriteSourceSize.getInt("y");
      int dw = spriteSourceSize.getInt("w");
      int dh = spriteSourceSize.getInt("h");
      
      //println("dw: " + dw);
      //println("dh: " + dh);
      
     // println("dstSpriteWidth: " + dstSpriteWidth);
      //println("dstSpriteHeight: " + dstSpriteHeight);
      
      // If the sprite isn't rotated, our logic is much simpler so we break up the cases.
      if(frame.getBoolean("rotated")){
        println("sprite is rotated");
        
        // Going to copy the pixels starting from the sprite in the sheet
        // upper left corner downwards moving left to right

        // inverted for src
        //int dstWidth = 400;
       // int dstHeight = 324;
        
        // We only need to copy the trimmed part
        int pixelsCopied = 0;
        int pixelsToCopy = srcWidth * srcHeight;
        
        int srcX = srcStartX;
        int srcY = srcStartY;
       
        int dstX = dstStartX;
        int dstY = dh - 1;
        
        //println(dw);
        int srcRotHeight = srcWidth;
        //println(srcRotHeight);

        
        for( ;pixelsCopied < pixelsToCopy; pixelsCopied++, dstX++, srcY++){

          //
         if(srcY == srcRotHeight + srcStartY){
           srcY = srcStartY;
           srcX++;
           
           dstX = dstStartX;
           dstY--;
         }
        // println(dstY*dw+dstX);
         
         color c = texture.pixels[srcY * texture.width + srcX];
           
          //
          img.pixels[dstY * dstSpriteWidth + dstX] = c;
        }
        
        img.updatePixels();
  
        map.put(frame.getString("filename"), img);
      }
      else{
        println("sprite is not rotated");
        // Copy from the sprite sheet to our individual sprite
        // potentially not touching the transparent pixels that border the sprite.
        img.copy(texture, srcStartX, srcStartY, srcWidth, srcHeight, dstStartX, dstStartY, dw, dh);
        map.put(frame.getString("filename"), img);
      }
    }*/
  }
  
  public PImage get(String sprite){
    return (PImage)map.get(sprite);
  }
}
/**
 */
public class ScreenGameplay implements IScreen{
  
  public boolean alive;
    
  Debugger debug;
  int R=0, C=0;
  
  Ticker debugTicker;
  Ticker delayTicker;
  Ticker gemRemovalTicker;
  Ticker levelTimeLeft;
  
  int tokensDestroyed = 0;
  
  boolean isPaused = false;
  
  int gemCounter = 0;
  int gemsRequiredForLevel = 0;
  int currLevel = 1;
  
  boolean waitingForTokensToFall = false;
  
  // User can only be in the process of swapping two tokens
  // at any given time.
  Token swapToken1 = null;
  Token swapToken2 = null;
  
  // As the levels increase, more and more token types are added
  // This makes it a slightly harder to match tokens.
  int numTokenTypesOnBoard = 5;
  
  // 
  int numGemsOnBoard = 2;
  
  //Tuple gems = new Tuple();
  
  // TODO: fix
  // Keep track of the number of gems removed from the board.
  int[] numMatchedGems = new int[100+numTokenTypesOnBoard + 1];
  
  Token currToken1 = null;
  Token currToken2 = null;
  
  //SpriteSheetLoader s = new SpriteSheetLoader();
    
  int score = 0;
  
  /**
  */
  ScreenGameplay(){
    alive = true;
    
  gemsRequiredForLevel = currLevel * 5;
  


  floatingTokens = new ArrayList<Token>();
  dyingTokens = new ArrayList<Token>();

  debugTicker = new Ticker();
  debug = new Debugger();
 
  // lock P for pause
  Keyboard.lockKeys(new int[]{KEY_P});
  
  
  levelTimeLeft = new Ticker();
  //levelTimeLeft.setMinutes(5);
  levelTimeLeft.setTime(0, 10);
  levelTimeLeft.setDirection(-1);
  
  
  resetBoard();
  deselectTokens();
  resetGemMatchCount();
    
  }
  
  public void draw(){
    
    update();
    
    background(103);
    
    // This line is only here to workaround a bug in Processing.js
    // If removed, the board would translate diagonally the canvas.
    resetMatrix();
    
    pushMatrix();
    translate(START_X, START_Y);
    translate(TOKEN_SIZE/2, TOKEN_SIZE/2);
    
    for(int i = 0; i < floatingTokens.size(); i++){
      floatingTokens.get(i).draw();
    }
  
    if(swapToken1 != null){
      swapToken1.draw();
    }
    if(swapToken2 != null){
      swapToken2.draw();
    }
    
    // For demo purposes
    pushStyle();
    fill(103);
    noStroke();
    rect(-TOKEN_SIZE/2, -TOKEN_SIZE/2, 222, 222);
    popStyle();
    
    pushStyle();
    noFill();
    stroke(255, 0, 0);
    rect(C * TOKEN_SIZE - TOKEN_SIZE/2, R * TOKEN_SIZE - TOKEN_SIZE/2, TOKEN_SIZE, TOKEN_SIZE);
    popStyle();
    
    drawBoard();
    
    // Draw the Dying tokens above the board as if they are coming out of it.
    // So when the tokens above fall down, those falling tokens render BEHIND these ones.
    for(int i = 0; i < dyingTokens.size(); i++){
      dyingTokens.get(i).draw();
    }
    
    popMatrix();
    
    debug.draw();
  }
  
  public void update(){
      
    // Once the player meets their quota...
    if(gemCounter >= gemsRequiredForLevel){
      goToNextLevel();    
    }
    
    
    if(waitingForTokensToFall && floatingTokens.size() == 0){
      waitingForTokensToFall = false;
      fillHoles();
    }
    
    isPaused = Keyboard.isKeyDown(KEY_P);

    if(isPaused){
      println("paused");
      return;
    }
    
    debug.clear();
    
    debugTicker.tick();
    levelTimeLeft.tick();
    
    //println(debugTicker.getDeltaSec());
    
    // Update all the tokens that are falling down
    for(int i = 0; i < floatingTokens.size(); i++){
      Token token = floatingTokens.get(i);
      token.update();
      if(token.arrivedAtDest()){
        token.dropIntoCell();
        markTokensForRemoval();
        delayTicker = new Ticker();
        //removeMarkedTokens();
        gemRemovalTicker = new Ticker();
      }
      waitingForTokensToFall = true;
    }
  
  
    // Now, update the two tokens that the user has swapped
    if(swapToken1 != null){
      
      swapToken1.update();
      swapToken2.update();
      
      if(swapToken1.arrivedAtDest() && swapToken1.isReturning() == false && swapToken1.isMoving()){
        //
        // Need to drop into the cells before check if it was indeed a valid swap
        swapToken1.dropIntoCell();
        swapToken2.dropIntoCell();
        
        // If it was not a valid swap, animate it back from where it came.
        if(isValidSwap(swapToken1, swapToken2) == false){
          //println("not a valid swap");
          
          int r1 = swapToken1.getRow();
          int c1 = swapToken1.getColumn();
          
          int r2 = swapToken2.getRow();
          int c2 = swapToken2.getColumn();
          
          swapToken1.animateTo(r2, c2);
          swapToken2.animateTo(r1, c1);
          
          swapToken1.setReturning(true);
          swapToken2.setReturning(true);
        }
        
        // Swap was valid, so get rid of 
        else{
          swapToken1 = swapToken2 = null;
          
         // gemRemovalTicker = new Ticker();
          markTokensForRemoval();
          removeMarkedTokens(true);
          //deselectTokens();
        }
        
        // Was it valid?
        // if( false == isValidSwap(token1, token2)){
          // token1.animateTo( .. );
          // token2.animateTo( ...);
          // token1.setReturning(true);
          // token2.setRetruning(true);
        
        // if it was valid ....
        
      }
      else if(swapToken1.arrivedAtDest() && swapToken1.isReturning()){
        //println("returned");
        swapToken1.dropIntoCell();
        swapToken2.dropIntoCell();
        swapToken1.setReturning(false);
        swapToken2.setReturning(false);
        
        swapToken1 = swapToken2 = null;
      }
    }
    
  
    // Update the tokens that may need to be GC'ed.
    for(int i = 0; i < dyingTokens.size(); i++){
      
      dyingTokens.get(i).update();
      
      if(dyingTokens.get(i).isAlive() == false){
        
        if(dyingTokens.get(i).hasGem()){
          gemCounter++;
          addGemToQueuedToken();
        }
        
        dyingTokens.remove(i);
        tokensDestroyed++;
      }
    }
    
    for(int r = 0; r < BOARD_ROWS; r++){
      for(int c = 0; c < BOARD_COLS; c++){
        board[r][c].update();
      }
    }
    
    if(gemRemovalTicker != null){
      gemRemovalTicker.tick();
    }
    
    if(delayTicker != null){
      delayTicker.tick();
    }
    
    if(gemRemovalTicker != null && gemRemovalTicker.getTotalTime() > 0.5f){
      gemRemovalTicker = null;
      removeMarkedTokens(true);
      delayTicker = new Ticker();
    }
    
    if(delayTicker != null && delayTicker.getTotalTime() > 0.35f){
      dropTokens();
      
      if(validSwapExists() == false){
        //println("no more moves available!");
      }
      
      //if(markTokensForRemoval()){
      //  gemRemovalTicker = new Ticker();
      //}
      
      delayTicker = null;
    }
    
    //pushMatrix();
    resetMatrix();
    //debug.addString("debug time: " + debugTicker.getTotalTime());
    debug.addString("score: " + score);
    debug.addString("Level: " + currLevel);
    debug.addString("destroyed: " + tokensDestroyed);
    //debug.addString("FPS: " + frameRate);
    debug.addString(gemCounter + "/" + gemsRequiredForLevel);
    
    // Add a leading zero if seconds is a single digit
    String secStr = "";
    int seconds = (int)levelTimeLeft.getTotalTime() % 60;
    
    if(seconds <= 9){
      secStr  = Utils.prependStringWithString( "" + seconds, "0", 2);
    }
    else{
      secStr = "" + seconds;
    }
    
    debug.addString( "" + (int)(levelTimeLeft.getTotalTime()/60) + ":" + secStr  );
    
    for(int i = 0; i < numTokenTypesOnBoard; i++){
      //debug.addString("color: " + numMatchedGems[i]);
    }
    //popMatrix();
  }
  
  public boolean isAlive(){
    return alive;
  }
  
  public String getName(){
    return "gameplay";
  }



public int getRowIndex(){
  return (int)map(mouseY,  START_Y , START_Y + BOARD_ROWS * TOKEN_SIZE, 0, BOARD_ROWS);
}

public int getColumnIndex(){
  return (int)map(mouseX,  START_X, START_X + BOARD_COLS * TOKEN_SIZE, 0, BOARD_COLS);
}


/**
 * Tokens that are considrered too far to swap include ones that
 * are across from each other diagonally or have 1 token between them.
 */
public boolean isCloseEnoughForSwap(Token t1, Token t2){
  //
  return abs(t1.getRow() - t2.getRow()) + abs(t1.getColumn() - t2.getColumn()) == 1;
}

//if((abs(t2.getRow() - t1.getRow()) == 1 && (t1.getColumn() == t2.getColumn()) ) ||
  //   (abs(t2.getColumn() - t1.getColumn()) == 1 && (t1.getRow() == t2.getRow()))  ){
  

public void mouseMoved(){
  R = getRowIndex();
  C = getColumnIndex();
}

public void mouseReleased(){
}

/*
 *
 */
public void mousePressed(){
  
  if(isPaused){
    return;
  }
  
  // convert the mouse coords to grid coordinates
  int r = getRowIndex();
  int c = getColumnIndex();
  
  if( r >= BOARD_ROWS || c >= BOARD_COLS || r < 0 || c < 0){
    return;
  }
  
  
  if(currToken1 == null){
    currToken1 = board[r][c];
    currToken1.setSelect(true);
  }
  
  else if(currToken2 == null){
    
    currToken2 = board[r][c];
    // User clicked on a token that's too far to swap with the one already selected
    // In that case, what they are probably doing is starting the 'swap process' over.
    if( isCloseEnoughForSwap(currToken1, currToken2) == false){
    //tooFarToSwap(currToken1,currToken2)){
      currToken1.setSelect(false);
      currToken1 = currToken2;
      currToken1.setSelect(true);  
      currToken2 = null;
    }
    else{
      animateSwapTokens(currToken1, currToken2);
    }
  }
}


/**
 * To swap tokens, players will clic/tap a token then drag to the token
 * they want to swap with.
 */
public void mouseDragged(){
  
  // convert the mouse coords to grid coordinates
  int r = getRowIndex();
  int c = getColumnIndex();
  
  if( r >= BOARD_ROWS || c >= BOARD_COLS || r < 0 || c < 0){
    return;
  }
  
  
  if(currToken1 != null && currToken2 == null){

    //    
    if(c != currToken1.getColumn() || r != currToken1.getRow()){
      currToken2 = board[r][c];
      
      if(isCloseEnoughForSwap(currToken1, currToken2) == false){
         currToken2 = null;
      }
      else{
        animateSwapTokens(currToken1, currToken2);
      }
    }
  }
}

/*
 * 
 */
void animateSwapTokens(Token t1, Token t2){
  
  // We need to cache these so we get get the wrong
  // values when calling animateTo.
  int t1Row = t1.getRow();
  int t1Col = t1.getColumn();
  
  int t2Row = t2.getRow();
  int t2Col = t2.getColumn();
  
  swapToken1 = t1;
  swapToken2 = t2;
  
  // Animate will detach the tokens from the board
  swapToken1.animateTo(t2Row, t2Col);
  swapToken2.animateTo(t1Row, t1Col);
  
  deselectTokens();
}

/**
  Speed: O(n)
  Returns true as soon as it finds a valid swap/move.

  There may be a case in which there are no valid swap/moves left
  in that case the board needs to be reset.
  
*/
boolean validSwapExists(){
  
  // First check any potential matches in the horizontal
  for(int r = START_ROW_INDEX; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS - 1; c++){
      
      Token gem1 = board[r][c];
      Token gem2 = board[r][c + 1];
      
      swapTokens(gem1, gem2);
      
      if(isValidSwap(gem1, gem2)){
        swapTokens(gem1, gem2);
        return true;
      }
      // Swap them back
      else{
        swapTokens(gem1, gem2);
      }
    }
  }
  
  // Check any potential matches in the vertical
  for(int c = 0; c < BOARD_COLS; c++){  
    for(int r = START_ROW_INDEX; r < BOARD_ROWS - 1; r++){
      
      Token gem1 = board[r][c];
      Token gem2 = board[r + 1][c];
      swapTokens(gem1, gem2);
      
      if(isValidSwap(gem1, gem2)){
        swapTokens(gem1, gem2);
        return true;
      }
      else{
        swapTokens(gem1, gem2);
      }
    }
  }
  
  return false;
}

/*
  In rare cases, there may not be any valid moves the user can make.
  we need to detect these cases and reset the board.
*/
boolean noMovesLeft(){
  return false;
}

int getRandomToken(){
  return Utils.getRandomInt(0, numTokenTypesOnBoard-1);
}


/*
  Find any null tokens on the board and replace them with a random token.
  
  This is used at the start of the level when trying to generate a board
  that initially has no matches.
  
  This is also used to populate the tokens above the board that aren't seen.
*/
void fillHoles(){
  for(int r = 0; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      if(board[r][c].getType() == TokenType.NULL){
        board[r][c].setType(getRandomToken());
      }
    }
  }
}

  /**
   1) From bottom to top, search to find first gap
    ) After finding the first gap, set the marker
    ) Find first token, set dst to marker
    ) Increment marker by 1
    ) Find next token
    ) 
    ) For all the tokens above that gap, until very top
     a) detach tokens from board
     b) give them appropriate positions
     c) give them a velocity
     d) give them destination positions
     e)
     f) place tokens in special floating tokens array to keep track of them.
     g) update tokens and allow them to add themselves back in
  */
void dropTokens(){
  
  // From bottom to top, search to find first gap
  // Start at the bottom of the grid, so we can properly iterate to the top
  // copying down the gems
  for(int c = 0; c < BOARD_COLS; c++){
    for(int r = BOARD_ROWS - 1; r >= 0; r--){
      
      // After finding the first gap, set the marker. Once we find a 
      // token, we will tell it to move to this marker position.
      if(board[r][c].getType() == TokenType.NULL){
        int firstEmptyCellIndex = r;
        
        // Find first non-empty cell. We can start immediately above the 
        // empty cell.
        for(int row = firstEmptyCellIndex - 1; row >= 0; row--){
          
          // Found non-empty cell, move 
          if(board[row][c].getType() != TokenType.NULL){
            //println("found non empty cell at: " + row);
            //println("move to: " + firstEmptyCellIndex);
            
            // We need to remove the token from the board because each frame
            // the board is rendered, all the tokens in it get rendered also.
            // And if the tokens are floating down, they shouldn't appear in the board.
            
            //tokenToMove.setRowColumn(firstEmptyCellIndex, c);
            // tokenToMove.moveToRow(firstEmptyCellIndex);
            
            Token tokenToMove = board[row][c];
            tokenToMove.animateTo(firstEmptyCellIndex, c);
            
            floatingTokens.add(tokenToMove);
            waitingForTokensToFall = true;

            // Since that token has just been removed, we'll need to
            // place a 'hole' where it used to be.
            Token nullToken = new Token();
            nullToken.setType(TokenType.NULL);
            nullToken.setRowColumn(row, c);
            board[row][c] = nullToken;
            
            //
            break;
            
            //Gem g = board[row][c];
            //g.moveTo(board[rowMarker][c]);
          }
        }
      }      
    }
  }
  
  /*

  for(int c = BOARD_COLS-1; c >= 0; c--){
    for(int r = BOARD_ROWS-1; r >= 0; r--){
      
      if(board[r][c].getType() == 0){
        
        // Keep moving up until we either find a ball we can copy downwards or
        // we hit the top, in which case we need to generate a random number.
        for(int rr = r - 0; rr >= 0; rr--){
          
          if(rr < 0){
           // board[0][c].setType(Utils.getRandomInt(1, NUM_GEM_TYPES));
            break;
          }
          
          if(rr == 0 && board[rr][c].getType() == 0){
            board[r][c].setType(Utils.getRandomInt(1, numTokenTypesOnBoard));
          }
          
          else if(board[rr][c].getType() != 0){
            swapTokens(board[rr][c], board[r][c]);
            break;
          }
        }
      }
    }
  }*/
}

/**
  Find any 3 matches either going vertically or horizontally and
  remove them from the board.
  
  @returns true if at least 3 gems were marked for removal. This means we found at least one match
  In some cases, this needs to be corrected, for example, when the game starts, there shouldn't be any
  matches.
*/
boolean markTokensForRemoval(){
  
  //
  boolean markedAtLeast3Gems = false;
  
  // Iterate over the entire board, mark gems for removal
  // Once complete, remove all gems
  
  // Mark the matched horizontal gems
  // Add extra column buffer at end of board to fix matches counter?
  for(int r = START_ROW_INDEX; r < BOARD_ROWS; r++){
    
    // use the first column as the thing we want to match against.
    int type = board[r][0].getType();
    
    // start of matched row
    int markerIndex = 0;
    int matches = 1;
      
    for(int c = 1; c < BOARD_COLS; c++){
      
      if(board[r][c].matchesWith(type)){
        matches++;
      }
      // We bank on finding a different gem. Once that happens, we can see if
      // we found enough of the previous gems.
      //
      else if( (board[r][c].matchesWith(type) == false) && matches < 3){
        //else if( (board[r][c].getType() != type) && matches < 3){
        matches = 1;
        markerIndex = c;
        type = board[r][c].getType();
      }
      // We need to also do it at the end of the board 
      else if( (board[r][c].matchesWith(type) == false && matches >= 3) || (c == BOARD_ROWS - 1 && matches >= 3)){
       // else if( (board[r][c].getType() != type && matches >= 3) || (c == BOARD_ROWS - 1 && matches >= 3)){
        markedAtLeast3Gems = true;
                  
        for(int gemC = markerIndex; gemC < markerIndex + matches; gemC++){
          board[r][gemC].kill();//.markForDeletion();
          numMatchedGems[board[r][gemC].getType()]++;
        }
        matches = 1;
        markerIndex = c;
        type = board[r][c].getType();
      }
    }
    
    // TODO: comment
    if(matches >= 3){
      markedAtLeast3Gems = true;
      
      for(int gemC = markerIndex; gemC < markerIndex + matches; gemC++){
        board[r][gemC].kill();//markForDeletion();
        numMatchedGems[board[r][gemC].getType()]++;
      }
    }
  }
  
  
  // Add extra column buffer at end of board to fix matches counter?
  for(int c = 0; c < BOARD_COLS; c++){
    int type = board[START_ROW_INDEX][c].getType();
    int markerIndex = START_ROW_INDEX;
    int matches = 1;
      
    for(int r = START_ROW_INDEX + 1; r < BOARD_ROWS; r++){
      
      if(board[r][c].matchesWith(type)){
      //if(board[r][c].getType() == type){
        matches++;
      }
      // We bank on finding a different gem. Once that happens, we can see if
      // we found enough of the previous gems.
      else if(board[r][c].matchesWith(type) == false && matches < 3){
      //else if(board[r][c].getType() != type && matches < 3){
        matches = 1;
        markerIndex = r;
        type = board[r][c].getType();
      }
      // We need to also do it at the end of the board 
      else if( (board[r][c].matchesWith(type) == false && matches >= 3)){// || (c == BOARD_COLS - 1 && matches > 2)){
      //else if( (board[r][c].getType() != type && matches >= 3)){// || (c == BOARD_COLS - 1 && matches > 2)){
        markedAtLeast3Gems = true;
         //sprintln("marker index: " +markerIndex );
        
        for(int gemR = markerIndex; gemR < markerIndex + matches; gemR++){
          board[gemR][c].kill();//markForDeletion();
          
          // TODO: fix AOOB
          // Num format exception
           numMatchedGems[board[gemR][c].getType()]++;
        }
        matches = 1;
        markerIndex = r;
        type = board[r][c].getType();
      }
    }
    
    if(matches >= 3){
      markedAtLeast3Gems = true;
              
      for(int gemR = markerIndex; gemR < markerIndex + matches; gemR++){
        board[gemR][c].kill();//markForDeletion();
        numMatchedGems[board[gemR][c].getType()]++;
      }
    }
  }

  return markedAtLeast3Gems;
}

/*
  A swap of two gems is only valid if it results in a row or column of 3 or more 
  gems of the same type getting lined up.

  We call this just after the player has swapped gems. We check to see if the swap was valid and if it isn't we swap the gems back.
  
  This is also called when we are trying to determine if there are actually any valid swaps left on the board. If not, the board
  needs to get reset.
*/
public boolean isValidSwap(Token t1, Token t2){
  
  if(isCloseEnoughForSwap(t1, t2)){
          
    if( matchesLeft(t1) + matchesRight(t1) >= 2){
      return true;
    }

    if( matchesLeft(t2) + matchesRight(t2) >= 2){
      return true;
    }
    
    if( matchesDown(t1) + matchesUp(t1) >= 2){
      return true;
    }

    if( matchesDown(t2) + matchesUp(t2) >= 2){
      return true;
    }
  }
  return false;
}

/*
*/
public void deselectTokens(){
  if(currToken1 != null) currToken1.setSelect(false);
  if(currToken2 != null) currToken2.setSelect(false);
  currToken1 = null;
  currToken2 = null;
}

/**
  We can only match up until the visible part of the board
  returns the number of matching types excluding this one.
*/
public int matchesUp(Token token){
  int r = token.getRow();
  int matchesFound = 0;
  int type = token.getType();
  int tokenColumn = token.getColumn();
 
  while(r >= START_ROW_INDEX && board[r][tokenColumn].matchesWith(type)){
  //  while(r >= START_ROW_INDEX && board[r][tokenColumn].getType() == type){
    matchesFound++;
    r--;
  }
  
  return matchesFound == 0 ? 0 : matchesFound -1;  
}

/**
 */
public int matchesRight(Token token){
  int col = token.getColumn();
  int matchesFound = 0;
  int type = token.getType();
  int currRow = token.getRow();
  
  while(col < BOARD_COLS && board[currRow][col].matchesWith(type)){
  //  while(col < BOARD_COLS && board[currRow][col].getType() == type){
    matchesFound++;
    col++;
  }
  
  return matchesFound-1;
}

/*
 * Return how many tokens match this one on its left side
 * Does not include the count of the token itself.
 */
public int matchesLeft(Token token){
  int col = token.getColumn();
  int matchesFound = 0;
  int type = token.getType();
  int tokenRow = token.getRow();
  
  // Watch for going out of bounds
  while(col >= 0 && board[tokenRow][col].matchesWith(type)){
  //  while(col >= 0 && board[tokenRow][col].getType() == type){
    matchesFound++;
    col--;
  }
  
  // matchesFound included the token we started with to
  // keep the code in this funciton short, but we have to
  // only return the number of matched tokens excluding it.
  return matchesFound - 1;
}

/**
*/
public int matchesDown(Token token){
  int row = token.getRow();
  int matchesFound = 0;
  int type = token.getType();
  int tokenColumn = token.getColumn();
  
  while(row < BOARD_ROWS && board[row][tokenColumn].matchesWith(type)){
  //  while(row < BOARD_ROWS && board[row][tokenColumn].getType() == (type)){
    matchesFound++;
    row++;
  }
  
  return matchesFound - 1;
}

/**
*/
public void swapTokens(Token token1, Token token2){
  
  int token1Row = token1.getRow();
  int token1Col = token1.getColumn();

  int token2Row = token2.getRow();
  int token2Col = token2.getColumn();

  // Swap on the board and in the tokens
  board[token1Row][token1Col] = token2;
  board[token2Row][token2Col] = token1;
  
  token2.swap(token1);
}



/*
 */
void resetGemMatchCount(){
  for(int i = 0; i < numTokenTypesOnBoard + 1; i++){
    numMatchedGems[i] = 0;
  }
}

/*
 */
void resetBoard(){
  for(int r = 0; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      Token token = new Token();
      
      token.setType(getRandomToken());
      
      /*int chance = Utils.getRandomInt(0,5);
      if(chance == 0){
        token.addGem();
      }*/
      
      token.setRowColumn(r, c);
      board[r][c] = token;
    }
  }

  int safeCounter = 0;
  
  // Ugly way of making sure there are no immediate matches, but it works for now.
  do{
    markTokensForRemoval();
    removeMarkedTokens(false);
    fillHoles();
    safeCounter++;
  }while(markTokensForRemoval() == true);// && safeCounter < 20 );
  
  for(int i = 0; i < numGemsOnBoard; i++){
    addGemToQueuedToken();
  }  
  
  if(false == validSwapExists()){
    //println("**** no moves remaining ****");
  }
}
  
/*
 */
void drawBoard(){
  
  pushStyle();
  noFill();
  stroke(255);
  strokeWeight(2);
  rect(-TOKEN_SIZE/2, -TOKEN_SIZE/2, BOARD_COLS * TOKEN_SIZE, BOARD_ROWS * TOKEN_SIZE);
  
  rect(-TOKEN_SIZE/2, -TOKEN_SIZE/2 + START_ROW_INDEX * TOKEN_SIZE, BOARD_COLS * TOKEN_SIZE, BOARD_ROWS * TOKEN_SIZE);
  popStyle();
  
  // Draw the invisible part, for debugging
  for(int r = 0; r < START_ROW_INDEX; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      if(board[r][c].isMoving() == false){
        board[r][c].draw();
      }
    }
  }
  
  //image(boardImage, -30, 190);
  
  // Draw the visible part to the player
  for(int r = START_ROW_INDEX; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      board[r][c].draw();
    }
  }
}

  /**
      Select a random token and add a gem to it if it doesn't already have one.
      
      Used when the user clears a gem from board, and we have to 'replace' it.
  */
  private void addGemToQueuedToken(){
    
    boolean added = false;
    
    while(added == false){
      // We can only add the gem to the part of the board the user doesn't see.
      // Don't forget getRandom int is inclusive.
      int r = Utils.getRandomInt(0, START_ROW_INDEX - 1);
      int c = Utils.getRandomInt(0, BOARD_COLS - 1);
      Token token = board[r][c];
      
      if(token.hasGem() == false){
        token.addGem();
        added = true;
      }
    }
  }

/*
 */
void removeMarkedTokens(boolean doDyingAnimation){
  println("removeMarkedTokens");
  
  // Now delete everything marked for deletion
  for(int r = 0; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      
      Token tokenToDestroy = board[r][c];
      
      if(tokenToDestroy.isDying()){//.isMarkedForDeletion()){
        //println("marked for delection...");
        //
        tokenToDestroy.destroy();
        
        if(doDyingAnimation){
          dyingTokens.add(tokenToDestroy);
        }
        
        // Replace the token we removed with a null Token
        Token nullToken = new Token();
        nullToken.setType(TokenType.NULL);
        nullToken.setRowColumn(r, c);
        board[r][c] = nullToken;
                
        delayTicker = new Ticker();
        
        //removedAtLeastOneMatch = true;
      }
      board[r][c].setSelect(false);
    }
  }
}

void keyPressed(){
  println(keyCode);
  Keyboard.setKeyDown(keyCode, true);
}

void keyReleased(){
  Keyboard.setKeyDown(keyCode, false);
}


void goToNextLevel(){
  currLevel++;  
  gemsRequiredForLevel += 5;
  gemCounter = 0;
  levelTimeLeft.setTime(5, 00);

  if(currLevel == 4){
    numTokenTypesOnBoard++;
  }
  
  numGemsOnBoard = currLevel + 1;
  
  resetBoard();
}

}
/**
 */
public class ScreenSplash implements IScreen{

  RetroPanel mainTitlePanel;
  RetroLabel mainTitleLabel;

  Ticker ticker;
  boolean alive;
  
  RetroFont solarWindsFont;
  
  RetroPanel panel;  
  RetroLabel versionLbl;
  
  public ScreenSplash(){
    ticker = new Ticker();
    alive = true;
    solarWindsFont = new RetroFont("data/fonts/solarwinds.png", 7, 8, 1);
    
    mainTitlePanel = new RetroPanel(0, 0, width, height);
    mainTitleLabel = new RetroLabel(solarWindsFont);
    mainTitleLabel.setText("---- H O R A D R I X ----");
    mainTitlePanel.addWidget(mainTitleLabel);
    
    mainTitleLabel.pixelsFromCenter(0,0);
    
    
    panel = new RetroPanel(0, 0, width, height);
    versionLbl = new RetroLabel(solarWindsFont);
    versionLbl.setText("Code & Art: Andor Salga");  
  
    panel.addWidget(versionLbl);
    
    //versionLbl.setJustification(RetroLabel.JUSTIFY_MANUAL);
    versionLbl.setVerticalSpacing(3);
  
    versionLbl.setHorizontalTrimming(true);
    
    //versionLbl.pixelsFromBottomLeft(0, 0);
    
    
    // textSprite = new TextSprite("SOLAR WINDS");
    // textSprite.setKerning(TextSprite.MONOSPACED);
    // textSprite.setKerning(TextSprite.????);
    
    versionLbl.pixelsFromBottomLeft(0, 0);
    //versionLbl.setHorizontalSpacing(0);
    // panel.add(textSprite);
    noSmooth();
  }
  
  /**
  */
  public void draw(){
    background(0);
    panel.draw();
    mainTitlePanel.draw();
  }
  
  public void update(){
    ticker.tick();
    if(ticker.getTotalTime() > 0.25f){
      alive = false;
    }
  }
  
  public String getName(){
    return "splash";
  }

  public boolean isAlive(){
    return alive;
  }
  
  public void keyReleased(){}
  public void keyPressed(){}
  
  public void mousePressed(){}
  public void mouseReleased(){}
  public void mouseDragged(){}
  public void mouseMoved(){}
}
/*
 * Prints text on top of everything for real-time object tracking.
 */
class Debugger{
  private ArrayList strings;
  private PFont font;
  private int fontSize;
  private boolean isOn;
  
  public Debugger(){
    isOn = true;
    strings = new ArrayList();
    fontSize = 15;
    font = createFont("Arial", fontSize);
  }
  
  public void addString(String s){
    if(isOn){
      strings.add(s);
    }
  }
  
  /*
   * Should be called after every frame
   */
  public void clear(){
    strings.clear();
  }
  
  /**
    If the debugger is off, it will ignore calls to addString and draw saving
    some processing time.
  */
  public void toggle(){
    isOn = !isOn;
  }
  
  public void draw(){
    if(isOn){
      int y = 20;
      fill(255);
      for(int i = 0; i < strings.size(); i++, y+=fontSize){
        textFont(font);
        text((String)strings.get(i),0,y);
      }
    }
  }
}
/*
*/
public class RetroFont{
  
  private PImage chars[];
  private PImage trimmedChars[];
  
  private int glyphWidth;
  private int glyphHeight;
  
  /*
    inImage
  */
  private PImage truncateImage(PImage inImage, char ch){
    
    int startX = 0;
    int endX = inImage.width - 1;
    int x, y;

    // Find the starting X coord of the image.
    for(x = inImage.width; x >= 0 ; x--){
      for(y = 0; y < inImage.height; y++){
        
        color testColor = inImage.get(x,y);
        if( alpha(testColor) > 0.0){
          startX = x;
        }
      }
    }

   // Find the ending coord
    for(x = 0; x < inImage.width; x++){
      for(y = 0; y < inImage.height; y++){
        
        color testColor = inImage.get(x,y);
        if( alpha(testColor) > 0.0){
          endX = x;
        }
      }
    }
    
    return inImage.get(startX, 0, endX-startX+1, inImage.height);
  }
  
  
  // Do not instantiate directly
  public RetroFont(String imageFilename, int glyphWidth, int glyphHeight, int borderSize){
    this.glyphWidth = glyphWidth;
    this.glyphHeight = glyphHeight;
    
    PImage fontSheet = loadImage(imageFilename);
    
    chars = new PImage[96];
    trimmedChars = new PImage[96];
    
    int x = 0;
    int y = 0;
    
    //
    //
    for(int currChar = 0; currChar < 96; currChar++){  
      chars[currChar] = fontSheet.get(x, y, glyphWidth, glyphHeight);
      trimmedChars[currChar] = truncateImage(fontSheet.get(x, y, glyphWidth, glyphHeight), (char)currChar);
      
      x += glyphWidth + borderSize;
      if(x >= fontSheet.width){
        x = 0;
        y += glyphHeight + borderSize;
      }
    }
    
    
    // For each character, truncate the x margin
    //for(int currChar = 0; currChar < 96; currChar++){
      //chars[currChar] = truncateImage( chars[currChar] );
    //}
  }
  
  //public static void create(String imageFilename, int charWidth, int charHeight, int borderSize){ 
  //PImage fontSheet = loadImage(imageFilename);
  public PImage getGlyph(char ch){
    int asciiCode = Utils.charCodeAt(ch);
 
    return chars[asciiCode-32];
  }
  
  public PImage getTrimmedGlyph(char ch){
    int asciiCode = Utils.charCodeAt(ch);
    return trimmedChars[asciiCode-32];
  }
  
  public int getGlyphWidth(){
    return glyphWidth;
  }
  
  public int getGlyphHeight(){
    return glyphHeight;
  }
}
/*
 * 
 */
public class RetroLabel extends RetroPanel{
  
  public static final int JUSTIFY_MANUAL = 0; 
  public static final int JUSTIFY_LEFT = 1;
  //public static final int JUSTIFY_RIGHT = 1;

  private final int NEWLINE = 10;
  private boolean dirty;
  private String text;
  private RetroFont font;
  
  //
  private int horizontalSpacing;
  private int verticalSpacing;
  private boolean horizontalTrimming;
  
  private int justification;
  
  public RetroLabel(RetroFont font){
    setFont(font);
    setVerticalSpacing(1);
    setHorizontalSpacing(1);
    //setJustification(JUSTIFY_LEFT);
    setHorizontalTrimming(false);
  }
  
  public void setHorizontalTrimming(boolean horizTrim){
    horizontalTrimming = horizTrim;
  }
  
  /**
  */
  public void setHorizontalSpacing(int spacing){
    horizontalSpacing = spacing;
    dirty = true;
  }
  
  public void setVerticalSpacing(int spacing){
    verticalSpacing = spacing;
    dirty = true;
  }
  
  /*
   * Will immediately calculate the width 
   */
  public void setText(String text){
    this.text = text;
    dirty = true;
    
    int newWidth = 0;
    for(int letter = 0; letter < text.length(); letter++){
    
      PImage glyph = getGlyph(text.charAt(letter)); 
    
      if(glyph != null){
        newWidth += glyph.width + horizontalSpacing;
      }
    }
    
    w = newWidth;
  }
  
  public void setFont(RetroFont font){
    this.font = font;
    dirty = true;
    h = this.font.getGlyphHeight();
  }
  
  /**
  */
  private int getWordWidth(String word){
    return word.length() * font.getGlyphWidth() + (word.length() * horizontalSpacing );
  }
  
  //public void setJustification(int justify){
  //   justification = justify;
  //}
  
  /**
    Draws the text in the label depending on the
    justification of the panel is sits inside
  */
  public void draw(){
    
    // Return if there is nothing to draw
    if(text == null || visible == false){
      return;
    }
    
    if(justification == JUSTIFY_MANUAL){
      int currX = x;
      int lineIndex = 0;
      
      for(int letter = 0; letter < text.length(); letter++){
        if((int)text.charAt(letter) == NEWLINE){
          lineIndex++;
          currX = x;
          continue;
        }
        PImage glyph = getGlyph(text.charAt(letter));
        
        if(glyph != null){
          image(glyph, currX, y + lineIndex * (font.getGlyphHeight() + verticalSpacing));

          currX += glyph.width + horizontalSpacing;
        }
      }
      currX += font.getGlyphWidth();
    }
    else{
    
      // iterate over each word and see if it would fit into the
      // panel. If not, add a line break
      String[] words = text.split(" ");
      int[] firstCharIndex = new int[words.length];
      
      // get indices of fist char of every word
      // for(int word = 0; word < words.length; word++){
      //  firstCharIndex[word] = 
      //}
       firstCharIndex[0] = 0;
      
       int iter = 1;
       for(int letter = 0; letter < text.length(); letter++){
         if(text.charAt(letter) == ' '){
           firstCharIndex[iter] = letter + 1;
           iter++;
         }
       }
       
       int[] wordWidths;
      
      // start drawing at the panel
      int currXPos = x;
      
      int lineIndex = 0;
      
      // Iterate over all the words
      for(int word = 0; word < words.length; word++){
        int wordWidth = getWordWidth(words[word]);
        
        if(justification == JUSTIFY_LEFT){
          if(word != 0 && currXPos + wordWidth + 0 >  parent.getWidth() ){
            lineIndex++;
            currXPos = x;
          }
        }
        
        // Iterate over the letter of each word
        for(int letter = 0; letter < words[word].length(); letter++){
          
          int firstChar = firstCharIndex[word];
          
          //
          if((int)words[word].charAt(letter) == NEWLINE){
            lineIndex++;
            currXPos = x;
            continue;
          }
          
          PImage glyph = getGlyph(words[word].charAt(letter));
          
          if(glyph != null){
            image(glyph, currXPos, lineIndex * (font.getGlyphHeight() + verticalSpacing));
            currXPos += font.getGlyphWidth() + horizontalSpacing;
          }
        }
        currXPos += font.getGlyphWidth();
      }
    }
  }
   
  public PImage getGlyph(char ch){
    if(horizontalTrimming == true){
      return font.getTrimmedGlyph(ch );
    }
    return font.getGlyph( ch);
  }
}
/**
*/
public class RetroPanel extends RetroWidget{

  ArrayList<RetroWidget> children;
  
  public RetroPanel(){
    w = 0;
    h = 0;
    x = 0;
    y = 0;
    removeAllChildren();
  }
  
  public void removeAllChildren(){
    children = new ArrayList<RetroWidget>();
  }

  public void addWidget(RetroWidget widget){
    widget.setParent(this);
    children.add(widget);
  }
  
  public void setWidth(int w){
    this.w = w;
  }

  public int getWidth(){
    return w;
  }
  
  public RetroPanel(int x, int y, int w, int h){
    removeAllChildren();
    this.w = w;
    this.h = h;
    this.x = x;
    this.y = y;
  }
  
  public void pixelsFromTop(int pixels){
    x = width/2 - 60/2;
    //startY = 0;
  }
  
  public void pixelsFromBottomLeft(int bottomPixels, int leftPixels){
    y = parent.y + parent.h - h + bottomPixels;
    x = parent.x + leftPixels;
  }
  
  /**
   */
  public void pixelsFromCenter(int xPixels, int yPixels){
    x = (parent.w/2) - (w/2) + xPixels;
    y = (parent.h/2) - (h/2) + yPixels;
  }
  
  
  public void draw(){
    
    pushStyle();
    noFill();
    stroke(255, 0, 0,32);
    rect(x, y, w, h);
    popStyle();
    
    if(visible == false || children.size() == 0){
      return;
    }
    
    pushMatrix();
    translate(x,y);
    for(int i = 0; i < children.size(); i++){
      children.get(i).draw();
    }
    popMatrix();
  }
}

/*
 */
public abstract class RetroWidget{

  protected RetroWidget parent;
  protected int x, y, w, h;
  
  protected boolean visible = true;
  protected boolean debugDraw = false;
  
  public RetroWidget(){
    x = y = 0;
    w = h = 0;
    visible = true;
  }
  
  public void setVisible(boolean v){
    visible = v;
  }
  
  public boolean getVisible(){
    return visible;
  }
    
  public void setParent(RetroWidget widget){
    parent = widget;
  }
  

  public int getWidth(){
    return w;
  }
  
  public int getHeight(){
    return h;
  }

  public void setPosition(int x, int y){
    this.x = x;
    this.y = y;
  }
  
  public abstract void draw();
}
/*
 * Classes poll keyboard state to get state of keys.
 */
public static class Keyboard{
  
  private static final int NUM_KEYS = 128;
  
  // Locking keys are good for toggling things.
  // After locking a key, when a user presses and releases a key, it will register and
  // being 'down' (even though it has been released). Once the user presses it again,
  // it will register as 'up'.
  private static boolean[] lockableKeys = new boolean[NUM_KEYS];
  
  // Use char since we only need to store 2 states (0, 1)
  private static char[] lockedKeyPresses = new char[NUM_KEYS];
  
  // The key states, true if key is down, false if key is up.
  private static boolean[] keys = new boolean[NUM_KEYS];
  
  /*
   * The specified keys will stay down even after user releases the key.
   * Once they press that key again, only then will the key state be changed to up(false).
   */
  public static void lockKeys(int[] keys){
    for(int k : keys){
      if(isValidKey(k)){
        lockableKeys[k] = true;
      }
    }
  }
  
  /*
   * TODO: if the key was locked and is down, then we unlock it, it needs to 'pop' back up.
   */
  public static void unlockKeys(int[] keys){
    for(int k : keys){
      if(isValidKey(k)){
        lockableKeys[k] = false;
      }
    }
  }
  
  /* This is for the case when we want to start off the game
   * assuming a key is already down.
   */
  public static void setVirtualKeyDown(int key, boolean state){
    setKeyDown(key, true);
    setKeyDown(key, false);
  }
  
  /**
   */
  private static boolean isValidKey(int key){
    return (key > -1 && key < NUM_KEYS);
  }
  
  /*
   * Set the state of a key to either down (true) or up (false)
   */
  public static void setKeyDown(int key, boolean state){
    
    if(isValidKey(key)){
      
      // If the key is lockable, as soon as we tell the class the key is down, we lock it.
      if( lockableKeys[key] ){
          // First time pressed
          if(state == true && lockedKeyPresses[key] == 0){
            lockedKeyPresses[key]++;
            keys[key] = true;
          }
          // First time released
          else if(state == false && lockedKeyPresses[key] == 1){
            lockedKeyPresses[key]++;
          }
          // Second time pressed
          else if(state == true && lockedKeyPresses[key] == 2){
             lockedKeyPresses[key]++;
          }
          // Second time released
          else if (state == false && lockedKeyPresses[key] == 3){
            lockedKeyPresses[key] = 0;
            keys[key] = false;
          }
      }
      else{
        keys[key] = state;
      }
    }
  }
  
  /* 
   * Returns true if the specified key is down.
   */
  public static boolean isKeyDown(int key){
    return keys[key];
  }
}

// These are outside of keyboard simply because I don't want to keep
// typing Keyboard.KEY_* in the main Tetrissing.pde file
final int KEY_BACKSPACE = 8;
final int KEY_TAB       = 9;
final int KEY_ENTER     = 10;

final int KEY_SHIFT     = 16;
final int KEY_CTRL      = 17;
final int KEY_ALT       = 18;

final int KEY_CAPS      = 20;
final int KEY_ESC = 27;

final int KEY_SPACE  = 32;
final int KEY_PGUP   = 33;
final int KEY_PGDN   = 34;
final int KEY_END    = 35;
final int KEY_HOME   = 36;

final int KEY_LEFT   = 37;
final int KEY_UP     = 38;
final int KEY_RIGHT  = 39;
final int KEY_DOWN   = 40;

final int KEY_0 = 48;
final int KEY_1 = 49;
final int KEY_2 = 50;
final int KEY_3 = 51;
final int KEY_4 = 52;
final int KEY_5 = 53;
final int KEY_6 = 54;
final int KEY_7 = 55;
final int KEY_8 = 56;
final int KEY_9 = 57;

final int KEY_A = 65;
final int KEY_B = 66;
final int KEY_C = 67;
final int KEY_D = 68;
final int KEY_E = 69;
final int KEY_F = 70;
final int KEY_G = 71;
final int KEY_H = 72;
final int KEY_I = 73;
final int KEY_J = 74;
final int KEY_K = 75;
final int KEY_L = 76;
final int KEY_M = 77;
final int KEY_N = 78;
final int KEY_O = 79;
final int KEY_P = 80;
final int KEY_Q = 81;
final int KEY_R = 82;
final int KEY_S = 83;
final int KEY_T = 84;
final int KEY_U = 85;
final int KEY_V = 86;
final int KEY_W = 87;
final int KEY_X = 88;
final int KEY_Y = 89;
final int KEY_Z = 90;

// Function keys
final int KEY_F1  = 112;
final int KEY_F2  = 113;
final int KEY_F3  = 114;
final int KEY_F4  = 115;
final int KEY_F5  = 116;
final int KEY_F6  = 117;
final int KEY_F7  = 118;
final int KEY_F8  = 119;
final int KEY_F9  = 120;
final int KEY_F10 = 121;
final int KEY_F12 = 122;

//final int KEY_INSERT = 155;

/**
  * A ticker class to manage animation timing.
  */
public class Ticker{

  private int lastTime;
  private float deltaTime;
  private boolean isPaused;
  private float totalTime;
  private boolean countingUp; 
  
  public Ticker(){
    reset();
  }
  
  public void setDirection(int d){
    countingUp = false;
  }
  
  public void reset(){
    deltaTime = 0f;
    lastTime = -1;
    isPaused = false;
    totalTime = 0f;
    countingUp = true;
  }
  
  //
  public void pause(){
    isPaused = true;
  }
  
  public void resume(){
    if(isPaused == true){
      reset();
    }
  }
  
  public void setTime(int min, int sec){
    
    totalTime = min * 60 + sec;
  }
  
  //public void setMinutes(int min){
  //  totalTime = min * 60;
  //}
  
  public float getTotalTime(){
    return totalTime;
  }
  
  /*
  */
  public float getDeltaSec(){
    if(isPaused){
      return 0;
    }
    return deltaTime;
  }
  
  /*
  * Calculates how many seconds passed since the last call to this method.
  *
  */
  public void tick(){
    if(lastTime == -1){
      lastTime = millis();
    }
    
    int delta = millis() - lastTime;
    lastTime = millis();
    deltaTime = delta/1000f;
    
    if(countingUp){
      totalTime += deltaTime;
    }
    else{
      totalTime -= deltaTime;
    }
  }
}

public static class TokenType{
  
  //public static final int NULL = 0;
  public static final int RED = 0;
  public static final int GREEN = 1;
  public static final int BLUE = 2;
  public static final int WHITE = 3;
  public static final int YELLOW = 4;
  public static final int SKULL = 5;
  public static final int PURPLE = 6;
  
  public static final int RED_GEM = 7;
  public static final int GREEN_GEM = 8;
  public static final int BLUE_GEM = 9;
  public static final int WHITE_GEM = 10;
  public static final int YELLOW_GEM = 11;
  public static final int SKULL_GEM = 12;
  public static final int PURPLE_GEM = 13;
  
  public static final int NULL = 14;
  
  /*public static final int ORANGE = 4;
  public static final int BRONZE = 5;
  public static final int SILVER = 6;
  public static final int GOLD = 7;*/
}


/**
 *  This class contains a gem, which players need to collect
 *  to progress to the next level.
 */
public class GemToken extends Token{

}
/*
 @pjs preload="data/fonts/solarwinds.png";
*/ 
 
/**
  Horadrix
  Andor Salga
  June 2013
*/

import ddf.minim.*;

// The amount of rows that are visible
final int BOARD_COLS = 8;
final int BOARD_ROWS = 16;

// Only need y index
final int START_ROW_INDEX = 8;
// Where on the canvas the tokens start to be rendered.
final int START_X = 100;//200;
final int START_Y = 0;//-20; // 20 - -220
final int TOKEN_SIZE = 28;
final int TOKEN_SPACING = 3;

// For the AssetStore
PApplet globalApplet;

Token[][] board = new Token[BOARD_ROWS][BOARD_COLS];
// When a match is created, the matched tokens are removed from the board array
// and 'float' above the board and drop down until they arrive where they need to go.
// We do this because as they fall, we can't give them a integer position, but need to
// use a float.
ArrayList<Token> floatingTokens;

// Tokens that have been remove from the board, but still need to be rendered for their
// death animation.
ArrayList<Token> dyingTokens;

//ArrayList<Token> dyingTokensOnBoard

  
IScreen currScreen;
  
void setup(){
  size(START_X + TOKEN_SIZE * BOARD_COLS, START_Y + TOKEN_SIZE * BOARD_ROWS);
  globalApplet = this;
  
  currScreen = new ScreenSplash();
}

void update(){
  currScreen.update();
  
  if(currScreen.getName() == "splash" && currScreen.isAlive() == false){
    currScreen = new ScreenGameplay();
  }
}

void draw(){
  update();
  currScreen.draw();
}

public void mousePressed(){
  currScreen.mousePressed();
}

public void mouseReleased(){
  currScreen.mouseReleased();
}

public void mouseDragged(){
  currScreen.mouseDragged();
}

public void mouseMoved(){
  currScreen.mouseMoved();
}

public void keyPressed(){
  currScreen.keyPressed();
}

public void keyReleased(){
  currScreen.keyReleased();
}


public class SoundManager{
  boolean muted = false;
  Minim minim;
  
  
  AudioPlayer failSwap;
  
  public void init(){
  }
  
  public SoundManager(PApplet applet){
    minim = new Minim(applet);
  
    failSwap = minim.loadFile("audio/failSwap.wav");
  }
  
  public void setMute(boolean isMuted){
    muted = isMuted;
  }
  
  public void playFailSwapSound(){
    if(muted){
      return;
    }
    failSwap.play();
    failSwap.rewind();
  }
    
  public void stop(){
    // dropPiece.close();
    // minim.stop();
    // super.stop();
  }
}
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
    
    ///
    ///  There's a huge problem with this. For some reason tick() needs to be
    //  called on update and here as well. Otherwise the delta is 0.
    ///
    if(animTicker != null){
      animTicker.tick();
    }
    
    //if(animTicker != null && animTicker.getTotalTime() > 0.05f){
     // animTicker.reset();
      //colored = !colored;
    //}
    
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
          x = column * TOKEN_SIZE - (TOKEN_SIZE/2);// + (column * TOKEN_SPACING*2);
          y = row * TOKEN_SIZE - (TOKEN_SIZE/2);
        }
        
        AssetStore store = AssetStore.Instance(globalApplet);
        
        if(isSelected){
          noFill();
          strokeWeight(2);
          stroke(255);
          rect(x, y, TOKEN_SIZE, TOKEN_SIZE);
        }
        

        
        //if(!colored){return;}
        
          if(animTicker != null){
            pushMatrix();
            resetMatrix();
            
            scaleSize += animTicker.getDeltaSec() * 15.0f;
            
            // TODO: Fix me
            //println("animTicker ==> " + animTicker.getDeltaSec() * 10.0f);
            
            translate(START_X, START_Y);
            translate(x, y);
            translate(TOKEN_SIZE, TOKEN_SIZE);
            
            scale(scaleSize * 1.0f);
            translate(-TOKEN_SIZE/2,-TOKEN_SIZE/2);
            
            // TODO: fix me
            tint(255, 255 - ((scaleSize- 1.0f) * 255));
          }
          else{
             pushMatrix();
             resetMatrix();
               translate(TOKEN_SIZE/2, TOKEN_SIZE/2);
               translate(START_X, START_Y);
            // translate(x + TOKEN_SPACING, y);
             translate(x, y);
          }
          
          // Debugging
         /* pushStyle();
          noFill();
          stroke(255,50,50);
          rect(0,0, TOKEN_SIZE, TOKEN_SIZE);*/
          
          if(hasGem()){
            pushStyle();
            fill(33, 60, 90, 255);
            noStroke();
            rect(0,0,TOKEN_SIZE, TOKEN_SIZE);
            popStyle();
          }
          
          
            //
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
      popStyle();
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
    //popStyle();
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
public class Tuple{
  private Object first, second;
  
  public Tuple(){
    first = second = null;
  }
  
  public void swap(){
    Object temp = first;
    first = second;
    second = temp;
  }
  
  public Object getFirst(){
    return first;
  }
  
  public Object getSecond(){
    return second;
  }
 
  public void setFirst(Object first){
    this.first = first;
  }
  
  public void setSecond(Object second){
    this.second = second;
  }
  
  public int numObjects(){
    if(isEmpty()){
      return 0;
    }
    if(isFull()){
      return 2;
    }
    return 2;
  }
  
  public boolean isFull(){
    return first != null && second != null;
  }
  
  public boolean isEmpty(){
    return first == null && second == null;
  } 
}
import processing.core.*;

/*
 *  Single location that stores only 1 copy of the assets we require.
 */
public class AssetStore{
    
  private static PApplet app;
  private static AssetStore instance;
  
  private String BASE_IMG_PATH = "data/images/";
  private PImage[] images;
  private String[] imageNames = {  "red.gif","green.gif", "blue.gif", "yellow.gif", "white.gif", "skull.gif", "purple.gif",
                                   //"red_gem.gif", "green_gem.gif", "blue_gem.gif", "yellow_gem.gif", "white_gem.gif", "skull_gem.gif", "purple_gem.gif"};
                                   "red_normal.gif", "green_normal.gif", "blue_normal.gif", "yellow_normal.gif", "white_normal.gif", "skull_normal.gif", "purple_normal.gif"};
  
  /*  
   */
  public PImage get(int asset){
    return images[asset];
  }
  
  //public PImage get(String asset){}
  
  /* As soon as this is contructed, load all the assets
   */
  private AssetStore(){
    
    // TODO: fix me
    int numImages = 14;
    
    images = new PImage[numImages];
    
    for(int i = 0; i < numImages; i++){
      images[i] = app.loadImage(BASE_IMG_PATH + imageNames[i]);
    }
  }
  
  /* Not an ideal way of getting an instance, but not much
   * we can do about it.
   */
  public static AssetStore Instance(PApplet applet){
    if(instance == null){
      app = applet;
      instance = new AssetStore();
    }
    return instance;
  }
}
public interface IScreen{
  
  public void draw();
  public void update();
  
  // Mouse methods
  public void mousePressed();
  public void mouseReleased();
  public void mouseDragged();
  public void mouseMoved();
  
  public void keyPressed();
  public void keyReleased();
  
  public String getName();
  
  public boolean isAlive();
}
/**
 */
public class ScreenSplash implements IScreen{

  RetroPanel mainTitlePanel;
  RetroLabel mainTitleLabel;

  Ticker ticker;
  boolean alive;
  
  RetroFont solarWindsFont;
  
  RetroPanel panel;  
  RetroLabel versionLbl;
  
  public ScreenSplash(){
    ticker = new Ticker();
    alive = true;
    solarWindsFont = new RetroFont("data/fonts/solarwinds.png", 7, 8, 1);
    
    mainTitlePanel = new RetroPanel(0, 0, width, height);
    mainTitleLabel = new RetroLabel(solarWindsFont);
    mainTitleLabel.setText("---- H O R A D R I X ----");
    mainTitlePanel.addWidget(mainTitleLabel);
    
    mainTitleLabel.pixelsFromCenter(0,0);
    
    
    panel = new RetroPanel(0, 0, width, height);
    versionLbl = new RetroLabel(solarWindsFont);
    versionLbl.setText("Code & Art: Andor Salga");  
  
    panel.addWidget(versionLbl);
    
    //versionLbl.setJustification(RetroLabel.JUSTIFY_MANUAL);
    versionLbl.setVerticalSpacing(3);
  
    versionLbl.setHorizontalTrimming(true);
    
    //versionLbl.pixelsFromBottomLeft(0, 0);
    
    
    // textSprite = new TextSprite("SOLAR WINDS");
    // textSprite.setKerning(TextSprite.MONOSPACED);
    // textSprite.setKerning(TextSprite.????);
    
    versionLbl.pixelsFromBottomLeft(0, 0);
    //versionLbl.setHorizontalSpacing(0);
    // panel.add(textSprite);
    noSmooth();
  }
  
  /**
  */
  public void draw(){
    background(0);
    panel.draw();
    mainTitlePanel.draw();
  }
  
  public void update(){
    ticker.tick();
    if(ticker.getTotalTime() > 0.25f){
      alive = false;
    }
  }
  
  public String getName(){
    return "splash";
  }

  public boolean isAlive(){
    return alive;
  }
  
  public void keyReleased(){}
  public void keyPressed(){}
  
  public void mousePressed(){}
  public void mouseReleased(){}
  public void mouseDragged(){}
  public void mouseMoved(){}
}
/*
 * JS Utilities interface
 */
var Utils = {

  /*   
   */
  charCodeAt: function(ch){
    return ch.charCodeAt(0);
  },

  /*
   * 
   */
  getRandomInt: function(minVal, maxVal){
    var scale = Math.random();
    return minVal + Math.floor(scale * (maxVal - minVal + 1));
  },
  
  Lerp: function(a, b, p){
  	return a * (1-p) + (b * p);
  },
  
  /*
  */
  prependStringWithString: function(baseString, prefix, newStrLength){
    var zerosToAdd, i;

    if(newStrLength <= baseString.length()){
      return baseString;
    }
    
    zerosToAdd = newStrLength - baseString.length();
    
    for(i = 0; i < zerosToAdd; i++){
      baseString = prefix + baseString;
    }
    
    return baseString;
  }

}
/**
 */
public class ScreenGameplay implements IScreen{
  
  public boolean alive;
    
  Debugger debug;
  int R=0, C=0;
  
  Ticker debugTicker;
  Ticker delayTicker;
  Ticker gemRemovalTicker;
  Ticker levelTimeLeft;
  
  int tokensDestroyed = 0;
  
  boolean isPaused = false;
  
  int gemCounter = 0;
  int gemsRequiredForLevel = 0;
  int currLevel = 1;
  
  boolean waitingForTokensToFall = false;
  
  // User can only be in the process of swapping two tokens
  // at any given time.
  Token swapToken1 = null;
  Token swapToken2 = null;
  
  // As the levels increase, more and more token types are added
  // This makes it a slightly harder to match tokens.
  int numTokenTypesOnBoard = 5;
  
  // 
  int numGemsOnBoard = 2;
  
  //Tuple gems = new Tuple();
  
  // TODO: fix
  // Keep track of the number of gems removed from the board.
  int[] numMatchedGems = new int[100+numTokenTypesOnBoard + 1];
  
  Token currToken1 = null;
  Token currToken2 = null;
  
  //SpriteSheetLoader s = new SpriteSheetLoader();
    
  int score = 0;
  
  /**
  */
  ScreenGameplay(){
    alive = true;
    
  gemsRequiredForLevel = currLevel * 5;
  


  floatingTokens = new ArrayList<Token>();
  dyingTokens = new ArrayList<Token>();

  debugTicker = new Ticker();
  debug = new Debugger();
 
  // lock P for pause
  Keyboard.lockKeys(new int[]{KEY_P});
  
  
  levelTimeLeft = new Ticker();
  //levelTimeLeft.setMinutes(5);
  levelTimeLeft.setTime(0, 10);
  levelTimeLeft.setDirection(-1);
  
  
  resetBoard();
  deselectTokens();
  resetGemMatchCount();
    
  }
  
  public void draw(){
    
    update();
    
    background(103);
    
    // This line is only here to workaround a bug in Processing.js
    // If removed, the board would translate diagonally the canvas.
    resetMatrix();
    
    pushMatrix();
    translate(START_X, START_Y);
    translate(TOKEN_SIZE/2, TOKEN_SIZE/2);
    
    for(int i = 0; i < floatingTokens.size(); i++){
      floatingTokens.get(i).draw();
    }
  
    if(swapToken1 != null){
      swapToken1.draw();
    }
    if(swapToken2 != null){
      swapToken2.draw();
    }
    
    // For demo purposes
    pushStyle();
    fill(103);
    noStroke();
    rect(-TOKEN_SIZE/2, -TOKEN_SIZE/2, 222, 222);
    popStyle();
    
    pushStyle();
    noFill();
    stroke(255, 0, 0);
    rect(C * TOKEN_SIZE - TOKEN_SIZE/2, R * TOKEN_SIZE - TOKEN_SIZE/2, TOKEN_SIZE, TOKEN_SIZE);
    popStyle();
    
    drawBoard();
    
    // Draw the Dying tokens above the board as if they are coming out of it.
    // So when the tokens above fall down, those falling tokens render BEHIND these ones.
    for(int i = 0; i < dyingTokens.size(); i++){
      dyingTokens.get(i).draw();
    }
    
    popMatrix();
    
    debug.draw();
  }
  
  public void update(){
      
    // Once the player meets their quota...
    if(gemCounter >= gemsRequiredForLevel){
      goToNextLevel();    
    }
    
    
    if(waitingForTokensToFall && floatingTokens.size() == 0){
      waitingForTokensToFall = false;
      fillHoles();
    }
    
    isPaused = Keyboard.isKeyDown(KEY_P);

    if(isPaused){
      println("paused");
      return;
    }
    
    debug.clear();
    
    debugTicker.tick();
    levelTimeLeft.tick();
    
    //println(debugTicker.getDeltaSec());
    
    // Update all the tokens that are falling down
    for(int i = 0; i < floatingTokens.size(); i++){
      Token token = floatingTokens.get(i);
      token.update();
      if(token.arrivedAtDest()){
        token.dropIntoCell();
        markTokensForRemoval();
        delayTicker = new Ticker();
        //removeMarkedTokens();
        gemRemovalTicker = new Ticker();
      }
      waitingForTokensToFall = true;
    }
  
  
    // Now, update the two tokens that the user has swapped
    if(swapToken1 != null){
      
      swapToken1.update();
      swapToken2.update();
      
      if(swapToken1.arrivedAtDest() && swapToken1.isReturning() == false && swapToken1.isMoving()){
        //
        // Need to drop into the cells before check if it was indeed a valid swap
        swapToken1.dropIntoCell();
        swapToken2.dropIntoCell();
        
        // If it was not a valid swap, animate it back from where it came.
        if(isValidSwap(swapToken1, swapToken2) == false){
          //println("not a valid swap");
          
          int r1 = swapToken1.getRow();
          int c1 = swapToken1.getColumn();
          
          int r2 = swapToken2.getRow();
          int c2 = swapToken2.getColumn();
          
          swapToken1.animateTo(r2, c2);
          swapToken2.animateTo(r1, c1);
          
          swapToken1.setReturning(true);
          swapToken2.setReturning(true);
        }
        
        // Swap was valid, so get rid of 
        else{
          swapToken1 = swapToken2 = null;
          
         // gemRemovalTicker = new Ticker();
          markTokensForRemoval();
          removeMarkedTokens(true);
          //deselectTokens();
        }
        
        // Was it valid?
        // if( false == isValidSwap(token1, token2)){
          // token1.animateTo( .. );
          // token2.animateTo( ...);
          // token1.setReturning(true);
          // token2.setRetruning(true);
        
        // if it was valid ....
        
      }
      else if(swapToken1.arrivedAtDest() && swapToken1.isReturning()){
        //println("returned");
        swapToken1.dropIntoCell();
        swapToken2.dropIntoCell();
        swapToken1.setReturning(false);
        swapToken2.setReturning(false);
        
        swapToken1 = swapToken2 = null;
      }
    }
    
  
    // Update the tokens that may need to be GC'ed.
    for(int i = 0; i < dyingTokens.size(); i++){
      
      dyingTokens.get(i).update();
      
      if(dyingTokens.get(i).isAlive() == false){
        
        if(dyingTokens.get(i).hasGem()){
          gemCounter++;
          addGemToQueuedToken();
        }
        
        dyingTokens.remove(i);
        tokensDestroyed++;
      }
    }
    
    for(int r = 0; r < BOARD_ROWS; r++){
      for(int c = 0; c < BOARD_COLS; c++){
        board[r][c].update();
      }
    }
    
    if(gemRemovalTicker != null){
      gemRemovalTicker.tick();
    }
    
    if(delayTicker != null){
      delayTicker.tick();
    }
    
    if(gemRemovalTicker != null && gemRemovalTicker.getTotalTime() > 0.5f){
      gemRemovalTicker = null;
      removeMarkedTokens(true);
      delayTicker = new Ticker();
    }
    
    if(delayTicker != null && delayTicker.getTotalTime() > 0.35f){
      dropTokens();
      
      if(validSwapExists() == false){
        //println("no more moves available!");
      }
      
      //if(markTokensForRemoval()){
      //  gemRemovalTicker = new Ticker();
      //}
      
      delayTicker = null;
    }
    
    //pushMatrix();
    resetMatrix();
    //debug.addString("debug time: " + debugTicker.getTotalTime());
    debug.addString("score: " + score);
    debug.addString("Level: " + currLevel);
    debug.addString("destroyed: " + tokensDestroyed);
    //debug.addString("FPS: " + frameRate);
    debug.addString(gemCounter + "/" + gemsRequiredForLevel);
    
    // Add a leading zero if seconds is a single digit
    String secStr = "";
    int seconds = (int)levelTimeLeft.getTotalTime() % 60;
    
    if(seconds <= 9){
      secStr  = Utils.prependStringWithString( "" + seconds, "0", 2);
    }
    else{
      secStr = "" + seconds;
    }
    
    debug.addString( "" + (int)(levelTimeLeft.getTotalTime()/60) + ":" + secStr  );
    
    for(int i = 0; i < numTokenTypesOnBoard; i++){
      //debug.addString("color: " + numMatchedGems[i]);
    }
    //popMatrix();
  }
  
  public boolean isAlive(){
    return alive;
  }
  
  public String getName(){
    return "gameplay";
  }



public int getRowIndex(){
  return (int)map(mouseY,  START_Y , START_Y + BOARD_ROWS * TOKEN_SIZE, 0, BOARD_ROWS);
}

public int getColumnIndex(){
  return (int)map(mouseX,  START_X, START_X + BOARD_COLS * TOKEN_SIZE, 0, BOARD_COLS);
}


/**
 * Tokens that are considrered too far to swap include ones that
 * are across from each other diagonally or have 1 token between them.
 */
public boolean isCloseEnoughForSwap(Token t1, Token t2){
  //
  return abs(t1.getRow() - t2.getRow()) + abs(t1.getColumn() - t2.getColumn()) == 1;
}

//if((abs(t2.getRow() - t1.getRow()) == 1 && (t1.getColumn() == t2.getColumn()) ) ||
  //   (abs(t2.getColumn() - t1.getColumn()) == 1 && (t1.getRow() == t2.getRow()))  ){
  

public void mouseMoved(){
  R = getRowIndex();
  C = getColumnIndex();
}

public void mouseReleased(){
}

/*
 *
 */
public void mousePressed(){
  
  if(isPaused){
    return;
  }
  
  // convert the mouse coords to grid coordinates
  int r = getRowIndex();
  int c = getColumnIndex();
  
  if( r >= BOARD_ROWS || c >= BOARD_COLS || r < 0 || c < 0){
    return;
  }
  
  
  if(currToken1 == null){
    currToken1 = board[r][c];
    currToken1.setSelect(true);
  }
  
  else if(currToken2 == null){
    
    currToken2 = board[r][c];
    // User clicked on a token that's too far to swap with the one already selected
    // In that case, what they are probably doing is starting the 'swap process' over.
    if( isCloseEnoughForSwap(currToken1, currToken2) == false){
    //tooFarToSwap(currToken1,currToken2)){
      currToken1.setSelect(false);
      currToken1 = currToken2;
      currToken1.setSelect(true);  
      currToken2 = null;
    }
    else{
      animateSwapTokens(currToken1, currToken2);
    }
  }
}


/**
 * To swap tokens, players will clic/tap a token then drag to the token
 * they want to swap with.
 */
public void mouseDragged(){
  
  // convert the mouse coords to grid coordinates
  int r = getRowIndex();
  int c = getColumnIndex();
  
  if( r >= BOARD_ROWS || c >= BOARD_COLS || r < 0 || c < 0){
    return;
  }
  
  
  if(currToken1 != null && currToken2 == null){

    //    
    if(c != currToken1.getColumn() || r != currToken1.getRow()){
      currToken2 = board[r][c];
      
      if(isCloseEnoughForSwap(currToken1, currToken2) == false){
         currToken2 = null;
      }
      else{
        animateSwapTokens(currToken1, currToken2);
      }
    }
  }
}

/*
 * 
 */
void animateSwapTokens(Token t1, Token t2){
  
  // We need to cache these so we get get the wrong
  // values when calling animateTo.
  int t1Row = t1.getRow();
  int t1Col = t1.getColumn();
  
  int t2Row = t2.getRow();
  int t2Col = t2.getColumn();
  
  swapToken1 = t1;
  swapToken2 = t2;
  
  // Animate will detach the tokens from the board
  swapToken1.animateTo(t2Row, t2Col);
  swapToken2.animateTo(t1Row, t1Col);
  
  deselectTokens();
}

/**
  Speed: O(n)
  Returns true as soon as it finds a valid swap/move.

  There may be a case in which there are no valid swap/moves left
  in that case the board needs to be reset.
  
*/
boolean validSwapExists(){
  
  // First check any potential matches in the horizontal
  for(int r = START_ROW_INDEX; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS - 1; c++){
      
      Token gem1 = board[r][c];
      Token gem2 = board[r][c + 1];
      
      swapTokens(gem1, gem2);
      
      if(isValidSwap(gem1, gem2)){
        swapTokens(gem1, gem2);
        return true;
      }
      // Swap them back
      else{
        swapTokens(gem1, gem2);
      }
    }
  }
  
  // Check any potential matches in the vertical
  for(int c = 0; c < BOARD_COLS; c++){  
    for(int r = START_ROW_INDEX; r < BOARD_ROWS - 1; r++){
      
      Token gem1 = board[r][c];
      Token gem2 = board[r + 1][c];
      swapTokens(gem1, gem2);
      
      if(isValidSwap(gem1, gem2)){
        swapTokens(gem1, gem2);
        return true;
      }
      else{
        swapTokens(gem1, gem2);
      }
    }
  }
  
  return false;
}

/*
  In rare cases, there may not be any valid moves the user can make.
  we need to detect these cases and reset the board.
*/
boolean noMovesLeft(){
  return false;
}

int getRandomToken(){
  return Utils.getRandomInt(0, numTokenTypesOnBoard-1);
}


/*
  Find any null tokens on the board and replace them with a random token.
  
  This is used at the start of the level when trying to generate a board
  that initially has no matches.
  
  This is also used to populate the tokens above the board that aren't seen.
*/
void fillHoles(){
  for(int r = 0; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      if(board[r][c].getType() == TokenType.NULL){
        board[r][c].setType(getRandomToken());
      }
    }
  }
}

  /**
   1) From bottom to top, search to find first gap
    ) After finding the first gap, set the marker
    ) Find first token, set dst to marker
    ) Increment marker by 1
    ) Find next token
    ) 
    ) For all the tokens above that gap, until very top
     a) detach tokens from board
     b) give them appropriate positions
     c) give them a velocity
     d) give them destination positions
     e)
     f) place tokens in special floating tokens array to keep track of them.
     g) update tokens and allow them to add themselves back in
  */
void dropTokens(){
  
  // From bottom to top, search to find first gap
  // Start at the bottom of the grid, so we can properly iterate to the top
  // copying down the gems
  for(int c = 0; c < BOARD_COLS; c++){
    for(int r = BOARD_ROWS - 1; r >= 0; r--){
      
      // After finding the first gap, set the marker. Once we find a 
      // token, we will tell it to move to this marker position.
      if(board[r][c].getType() == TokenType.NULL){
        int firstEmptyCellIndex = r;
        
        // Find first non-empty cell. We can start immediately above the 
        // empty cell.
        for(int row = firstEmptyCellIndex - 1; row >= 0; row--){
          
          // Found non-empty cell, move 
          if(board[row][c].getType() != TokenType.NULL){
            //println("found non empty cell at: " + row);
            //println("move to: " + firstEmptyCellIndex);
            
            // We need to remove the token from the board because each frame
            // the board is rendered, all the tokens in it get rendered also.
            // And if the tokens are floating down, they shouldn't appear in the board.
            
            //tokenToMove.setRowColumn(firstEmptyCellIndex, c);
            // tokenToMove.moveToRow(firstEmptyCellIndex);
            
            Token tokenToMove = board[row][c];
            tokenToMove.animateTo(firstEmptyCellIndex, c);
            
            floatingTokens.add(tokenToMove);
            waitingForTokensToFall = true;

            // Since that token has just been removed, we'll need to
            // place a 'hole' where it used to be.
            Token nullToken = new Token();
            nullToken.setType(TokenType.NULL);
            nullToken.setRowColumn(row, c);
            board[row][c] = nullToken;
            
            //
            break;
            
            //Gem g = board[row][c];
            //g.moveTo(board[rowMarker][c]);
          }
        }
      }      
    }
  }
  
  /*

  for(int c = BOARD_COLS-1; c >= 0; c--){
    for(int r = BOARD_ROWS-1; r >= 0; r--){
      
      if(board[r][c].getType() == 0){
        
        // Keep moving up until we either find a ball we can copy downwards or
        // we hit the top, in which case we need to generate a random number.
        for(int rr = r - 0; rr >= 0; rr--){
          
          if(rr < 0){
           // board[0][c].setType(Utils.getRandomInt(1, NUM_GEM_TYPES));
            break;
          }
          
          if(rr == 0 && board[rr][c].getType() == 0){
            board[r][c].setType(Utils.getRandomInt(1, numTokenTypesOnBoard));
          }
          
          else if(board[rr][c].getType() != 0){
            swapTokens(board[rr][c], board[r][c]);
            break;
          }
        }
      }
    }
  }*/
}

/**
  Find any 3 matches either going vertically or horizontally and
  remove them from the board.
  
  @returns true if at least 3 gems were marked for removal. This means we found at least one match
  In some cases, this needs to be corrected, for example, when the game starts, there shouldn't be any
  matches.
*/
boolean markTokensForRemoval(){
  
  //
  boolean markedAtLeast3Gems = false;
  
  // Iterate over the entire board, mark gems for removal
  // Once complete, remove all gems
  
  // Mark the matched horizontal gems
  // Add extra column buffer at end of board to fix matches counter?
  for(int r = START_ROW_INDEX; r < BOARD_ROWS; r++){
    
    // use the first column as the thing we want to match against.
    int type = board[r][0].getType();
    
    // start of matched row
    int markerIndex = 0;
    int matches = 1;
      
    for(int c = 1; c < BOARD_COLS; c++){
      
      if(board[r][c].matchesWith(type)){
        matches++;
      }
      // We bank on finding a different gem. Once that happens, we can see if
      // we found enough of the previous gems.
      //
      else if( (board[r][c].matchesWith(type) == false) && matches < 3){
        //else if( (board[r][c].getType() != type) && matches < 3){
        matches = 1;
        markerIndex = c;
        type = board[r][c].getType();
      }
      // We need to also do it at the end of the board 
      else if( (board[r][c].matchesWith(type) == false && matches >= 3) || (c == BOARD_ROWS - 1 && matches >= 3)){
       // else if( (board[r][c].getType() != type && matches >= 3) || (c == BOARD_ROWS - 1 && matches >= 3)){
        markedAtLeast3Gems = true;
                  
        for(int gemC = markerIndex; gemC < markerIndex + matches; gemC++){
          board[r][gemC].kill();//.markForDeletion();
          numMatchedGems[board[r][gemC].getType()]++;
        }
        matches = 1;
        markerIndex = c;
        type = board[r][c].getType();
      }
    }
    
    // TODO: comment
    if(matches >= 3){
      markedAtLeast3Gems = true;
      
      for(int gemC = markerIndex; gemC < markerIndex + matches; gemC++){
        board[r][gemC].kill();//markForDeletion();
        numMatchedGems[board[r][gemC].getType()]++;
      }
    }
  }
  
  
  // Add extra column buffer at end of board to fix matches counter?
  for(int c = 0; c < BOARD_COLS; c++){
    int type = board[START_ROW_INDEX][c].getType();
    int markerIndex = START_ROW_INDEX;
    int matches = 1;
      
    for(int r = START_ROW_INDEX + 1; r < BOARD_ROWS; r++){
      
      if(board[r][c].matchesWith(type)){
      //if(board[r][c].getType() == type){
        matches++;
      }
      // We bank on finding a different gem. Once that happens, we can see if
      // we found enough of the previous gems.
      else if(board[r][c].matchesWith(type) == false && matches < 3){
      //else if(board[r][c].getType() != type && matches < 3){
        matches = 1;
        markerIndex = r;
        type = board[r][c].getType();
      }
      // We need to also do it at the end of the board 
      else if( (board[r][c].matchesWith(type) == false && matches >= 3)){// || (c == BOARD_COLS - 1 && matches > 2)){
      //else if( (board[r][c].getType() != type && matches >= 3)){// || (c == BOARD_COLS - 1 && matches > 2)){
        markedAtLeast3Gems = true;
         //sprintln("marker index: " +markerIndex );
        
        for(int gemR = markerIndex; gemR < markerIndex + matches; gemR++){
          board[gemR][c].kill();//markForDeletion();
          
          // TODO: fix AOOB
          // Num format exception
           numMatchedGems[board[gemR][c].getType()]++;
        }
        matches = 1;
        markerIndex = r;
        type = board[r][c].getType();
      }
    }
    
    if(matches >= 3){
      markedAtLeast3Gems = true;
              
      for(int gemR = markerIndex; gemR < markerIndex + matches; gemR++){
        board[gemR][c].kill();//markForDeletion();
        numMatchedGems[board[gemR][c].getType()]++;
      }
    }
  }

  return markedAtLeast3Gems;
}

/*
  A swap of two gems is only valid if it results in a row or column of 3 or more 
  gems of the same type getting lined up.

  We call this just after the player has swapped gems. We check to see if the swap was valid and if it isn't we swap the gems back.
  
  This is also called when we are trying to determine if there are actually any valid swaps left on the board. If not, the board
  needs to get reset.
*/
public boolean isValidSwap(Token t1, Token t2){
  
  if(isCloseEnoughForSwap(t1, t2)){
          
    if( matchesLeft(t1) + matchesRight(t1) >= 2){
      return true;
    }

    if( matchesLeft(t2) + matchesRight(t2) >= 2){
      return true;
    }
    
    if( matchesDown(t1) + matchesUp(t1) >= 2){
      return true;
    }

    if( matchesDown(t2) + matchesUp(t2) >= 2){
      return true;
    }
  }
  return false;
}

/*
*/
public void deselectTokens(){
  if(currToken1 != null) currToken1.setSelect(false);
  if(currToken2 != null) currToken2.setSelect(false);
  currToken1 = null;
  currToken2 = null;
}

/**
  We can only match up until the visible part of the board
  returns the number of matching types excluding this one.
*/
public int matchesUp(Token token){
  int r = token.getRow();
  int matchesFound = 0;
  int type = token.getType();
  int tokenColumn = token.getColumn();
 
  while(r >= START_ROW_INDEX && board[r][tokenColumn].matchesWith(type)){
  //  while(r >= START_ROW_INDEX && board[r][tokenColumn].getType() == type){
    matchesFound++;
    r--;
  }
  
  return matchesFound == 0 ? 0 : matchesFound -1;  
}

/**
 */
public int matchesRight(Token token){
  int col = token.getColumn();
  int matchesFound = 0;
  int type = token.getType();
  int currRow = token.getRow();
  
  while(col < BOARD_COLS && board[currRow][col].matchesWith(type)){
  //  while(col < BOARD_COLS && board[currRow][col].getType() == type){
    matchesFound++;
    col++;
  }
  
  return matchesFound-1;
}

/*
 * Return how many tokens match this one on its left side
 * Does not include the count of the token itself.
 */
public int matchesLeft(Token token){
  int col = token.getColumn();
  int matchesFound = 0;
  int type = token.getType();
  int tokenRow = token.getRow();
  
  // Watch for going out of bounds
  while(col >= 0 && board[tokenRow][col].matchesWith(type)){
  //  while(col >= 0 && board[tokenRow][col].getType() == type){
    matchesFound++;
    col--;
  }
  
  // matchesFound included the token we started with to
  // keep the code in this funciton short, but we have to
  // only return the number of matched tokens excluding it.
  return matchesFound - 1;
}

/**
*/
public int matchesDown(Token token){
  int row = token.getRow();
  int matchesFound = 0;
  int type = token.getType();
  int tokenColumn = token.getColumn();
  
  while(row < BOARD_ROWS && board[row][tokenColumn].matchesWith(type)){
  //  while(row < BOARD_ROWS && board[row][tokenColumn].getType() == (type)){
    matchesFound++;
    row++;
  }
  
  return matchesFound - 1;
}

/**
*/
public void swapTokens(Token token1, Token token2){
  
  int token1Row = token1.getRow();
  int token1Col = token1.getColumn();

  int token2Row = token2.getRow();
  int token2Col = token2.getColumn();

  // Swap on the board and in the tokens
  board[token1Row][token1Col] = token2;
  board[token2Row][token2Col] = token1;
  
  token2.swap(token1);
}



/*
 */
void resetGemMatchCount(){
  for(int i = 0; i < numTokenTypesOnBoard + 1; i++){
    numMatchedGems[i] = 0;
  }
}

/*
 */
void resetBoard(){
  for(int r = 0; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      Token token = new Token();
      
      token.setType(getRandomToken());
      
      /*int chance = Utils.getRandomInt(0,5);
      if(chance == 0){
        token.addGem();
      }*/
      
      token.setRowColumn(r, c);
      board[r][c] = token;
    }
  }

  int safeCounter = 0;
  
  // Ugly way of making sure there are no immediate matches, but it works for now.
  do{
    markTokensForRemoval();
    removeMarkedTokens(false);
    fillHoles();
    safeCounter++;
  }while(markTokensForRemoval() == true);// && safeCounter < 20 );
  
  for(int i = 0; i < numGemsOnBoard; i++){
    addGemToQueuedToken();
  }  
  
  if(false == validSwapExists()){
    //println("**** no moves remaining ****");
  }
}
  
/*
 */
void drawBoard(){
  
  pushStyle();
  noFill();
  stroke(255);
  strokeWeight(2);
  rect(-TOKEN_SIZE/2, -TOKEN_SIZE/2, BOARD_COLS * TOKEN_SIZE, BOARD_ROWS * TOKEN_SIZE);
  
  rect(-TOKEN_SIZE/2, -TOKEN_SIZE/2 + START_ROW_INDEX * TOKEN_SIZE, BOARD_COLS * TOKEN_SIZE, BOARD_ROWS * TOKEN_SIZE);
  popStyle();
  
  // Draw the invisible part, for debugging
  for(int r = 0; r < START_ROW_INDEX; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      if(board[r][c].isMoving() == false){
        board[r][c].draw();
      }
    }
  }
  
  //image(boardImage, -30, 190);
  
  // Draw the visible part to the player
  for(int r = START_ROW_INDEX; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      board[r][c].draw();
    }
  }
}

  /**
      Select a random token and add a gem to it if it doesn't already have one.
      
      Used when the user clears a gem from board, and we have to 'replace' it.
  */
  private void addGemToQueuedToken(){
    
    boolean added = false;
    
    while(added == false){
      // We can only add the gem to the part of the board the user doesn't see.
      // Don't forget getRandom int is inclusive.
      int r = Utils.getRandomInt(0, START_ROW_INDEX - 1);
      int c = Utils.getRandomInt(0, BOARD_COLS - 1);
      Token token = board[r][c];
      
      if(token.hasGem() == false){
        token.addGem();
        added = true;
      }
    }
  }

/*
 */
void removeMarkedTokens(boolean doDyingAnimation){
  println("removeMarkedTokens");
  
  // Now delete everything marked for deletion
  for(int r = 0; r < BOARD_ROWS; r++){
    for(int c = 0; c < BOARD_COLS; c++){
      
      Token tokenToDestroy = board[r][c];
      
      if(tokenToDestroy.isDying()){//.isMarkedForDeletion()){
        //println("marked for delection...");
        //
        tokenToDestroy.destroy();
        
        if(doDyingAnimation){
          dyingTokens.add(tokenToDestroy);
        }
        
        // Replace the token we removed with a null Token
        Token nullToken = new Token();
        nullToken.setType(TokenType.NULL);
        nullToken.setRowColumn(r, c);
        board[r][c] = nullToken;
                
        delayTicker = new Ticker();
        
        //removedAtLeastOneMatch = true;
      }
      board[r][c].setSelect(false);
    }
  }
}

void keyPressed(){
  println(keyCode);
  Keyboard.setKeyDown(keyCode, true);
}

void keyReleased(){
  Keyboard.setKeyDown(keyCode, false);
}


void goToNextLevel(){
  currLevel++;  
  gemsRequiredForLevel += 5;
  gemCounter = 0;
  levelTimeLeft.setTime(5, 00);

  if(currLevel == 4){
    numTokenTypesOnBoard++;
  }
  
  numGemsOnBoard = currLevel + 1;
  
  resetBoard();
}

}