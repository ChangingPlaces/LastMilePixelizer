// Input Piece Types

ArrayList<Integer[][]> inputDef = new ArrayList<Integer[][]>();

int NPieces = 16;

// Arrays that holds ID information of rectilinear tile arrangement.
int codeArray[][][] = new int[displayU/4][displayV/4][2]; 

void setupInputDef() {
  
  // 0: IMN
  Integer[][] piece_0 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 1, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_0);
  
  // 1: Large Store
  Integer[][] piece_1 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 2, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_1);
  
  // 2: Small Store
  Integer[][] piece_2 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 3, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_2);
  
  // 3: Spoke
  Integer[][] piece_3 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 4, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_3);
  
  // 4: Small Locker
  Integer[][] piece_4 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 5, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_4);
  
  // 5: Large Locker
  Integer[][] piece_5 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 6, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_5);
  
  // 6: Remote
  Integer[][] piece_6 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 7, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_6);
  
  // 7: No Definition
  Integer[][] piece_7 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_7);
  
  // 8: Market Close
  Integer[][] piece_8 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 9, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_8);
  
  // 9: Market Bomb
  Integer[][] piece_9 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 10, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_9);
  
  // 10: No Definition
  Integer[][] piece_10 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_10);
  
  // 11: No Definition
  Integer[][] piece_11 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_11);

  // 12: No Definition
  Integer[][] piece_12 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_12);
  
  // 13: No Definition
  Integer[][] piece_13 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_13);
  
  // 14: No Definition
  Integer[][] piece_14 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_14);
  
  // 15: No Definition
  Integer[][] piece_15 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 }
  };
  inputDef.add(piece_15);
}

void setupCodeArray(int code) {

  if (code == 2 ) {
    
    // Sets all grids to have "no object" (-1) with no rotation (0)
    for (int i=0; i<codeArray.length; i++) {
      for (int j=0; j<codeArray[0].length; j++) {
        codeArray[i][j][0] = -1;
        codeArray[i][j][1] = 0;
      }
    }
  } else if (code == 1 ) {
    
    // Sets grids to be alternating one of each N piece types (0-N) with no rotation (0)
    int testID = 0; // Sets first grid cell to ID = 0
    for (int i=0; i<codeArray.length; i++) {
      for (int j=0; j<codeArray[0].length; j++) {
        codeArray[i][j][0] = i  % NPieces;
        codeArray[i][j][1] = 0;
        testID++;
      }
    }
  } else if (code == 0 ) {
    
    // Sets grids to be random piece types (0-N) with random rotation (0-3)
    int testID = 0; // Sets first grid cell to ID = 0
    for (int i=0; i<codeArray.length; i++) {
      for (int j=0; j<codeArray[0].length; j++) {
        codeArray[i][j][0] = int(random(-1.99, NPieces));
        codeArray[i][j][1] = int(random(0, 4));
        testID++;
      }
    }
  }
  
}
