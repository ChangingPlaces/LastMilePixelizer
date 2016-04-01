// Arrays that holds ID information of rectilinear tile arrangement.
int tablePieceInput[][][] = new int[displayU/4][displayV/4][2];
int rotationMod = 0;

// Input Piece Types
ArrayList<Integer[][]> inputData;
ArrayList<Integer[][]> inputForm;

// Form Codes:
// 0 = void/no brick
// 1 = tan brick
// 2 = blue brick
// 3 = red brick
// 4 = black brick
// 5 = green brick

void setupPieces() {
  
  inputData = new ArrayList<Integer[][]>();
  inputForm = new ArrayList<Integer[][]>();
  
  // 0: IMN
  Integer[][] data_0 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 1, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_0 = {
    { 0, 0, 0, 0 },
    { 1, 1, 1, 1 },
    { 1, 1, 1, 1 },
    { 0, 0, 0, 0 } };
  inputData.add(data_0);
  inputForm.add(form_0);
  
  // 1: Small Store
  Integer[][] data_1 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 3, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_1 = {
    { 0, 0, 0, 0 },
    { 0, 1, 1, 0 },
    { 0, 2, 2, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_1);
  inputForm.add(form_1);
  
  // 2: Large Store
  Integer[][] data_2 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 2, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_2 = {
    { 0, 0, 0, 0 },
    { 1, 1, 1, 1 },
    { 2, 2, 2, 2 },
    { 0, 0, 0, 0 } };
  inputData.add(data_2);
  inputForm.add(form_2);
  
  // 3: Spoke
  Integer[][] data_3 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 4, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_3 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 2, 2, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_3);
  inputForm.add(form_3);
  
  // 4: Small Locker
  Integer[][] data_4 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 5, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_4 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 3, 0, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_4);
  inputForm.add(form_4);
  
  // 5: Large Locker
  Integer[][] data_5 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 6, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_5 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 3, 3, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_5);
  inputForm.add(form_5);
  
  // 6: Remote
  Integer[][] data_6 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 7, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_6 = {
    { 0, 0, 0, 0 },
    { 3, 3, 3, 3 },
    { 3, 3, 3, 3 },
    { 0, 0, 0, 0 } };
  inputData.add(data_6);
  inputForm.add(form_6);
  
  // 7: No Definition
  Integer[][] data_7 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_7 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_7);
  inputForm.add(form_7);
  
  // 8: Market Freeze
  Integer[][] data_8 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 9, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_8 = {
    { 4, 4, 4, 4 },
    { 4, 4, 4, 4 },
    { 4, 4, 4, 4 },
    { 4, 4, 4, 4 } };
  inputData.add(data_8);
  inputForm.add(form_8);
  
  // 9: Market Bomb
  Integer[][] data_9 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 10, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_9 = {
    { 0, 0, 0, 0 },
    { 0, 5, 5, 0 },
    { 0, 5, 5, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_9);
  inputForm.add(form_9);
  
  // 10: No Definition
  Integer[][] data_10 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_10 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_10);
  inputForm.add(form_10);
  
  // 11: No Definition
  Integer[][] data_11 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_11 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_11);
  inputForm.add(form_11);

  // 12: No Definition
  Integer[][] data_12 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_12 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_12);
  inputForm.add(form_12);
  
  // 13: No Definition
  Integer[][] data_13 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_13 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_13);
  inputForm.add(form_13);
  
  // 14: No Definition
  Integer[][] data_14 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_14 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_14);
  inputForm.add(form_14);
  
  // 15: No Definition
  Integer[][] data_15 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  Integer[][] form_15 = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 } };
  inputData.add(data_15);
  inputForm.add(form_15);
}

void decodePieces() {
  
  clearInputData();
  
  for (int i=0; i<tablePieceInput.length; i++) {
    for (int j=0; j<tablePieceInput[0].length; j++) {
      int ID = tablePieceInput[i][j][0];
      if (ID >= 0 && ID <= IDMax) {
        
        // Rotation Parameters
        int rotation = (tablePieceInput[i][j][1] + rotationMod)%4;
        int X =0;
        int Y =0;
        
        // Update "Form" Layer
        Integer[][] form = inputForm.get(ID);
        for (int u=0; u<form.length; u++) {
          for (int v=0; v<form[0].length; v++) {
            
            if (rotation == 0) {
              X = 4*i + u;
              Y = 4*j + v;
            } else if (rotation == 1) {
              X = 4*i + v;
              Y = 4*j + (3-u);
            } else if (rotation == 2) {
              X = 4*i + (3-u);
              Y = 4*j + (3-v);
            } else if (rotation == 3) {
              X = 4*i + (3-v);
              Y = 4*j + u;
            }
          
            this.form[gridPanU+X][gridPanV+Y] = form[v][u];
          }
        }
        
        // Update Facility, Market, and Obstacle Layers
        Integer[][] data = inputData.get(ID);
        for (int u=0; u<data.length; u++) {
          for (int v=0; v<data[0].length; v++) {
            
            if (rotation == 0) {
              X = 4*i + u;
              Y = 4*j + v;
            } else if (rotation == 1) {
              X = 4*i + v;
              Y = 4*j + (3-u);
            } else if (rotation == 2) {
              X = 4*i + (3-u);
              Y = 4*j + (3-v);
            } else if (rotation == 3) {
              X = 4*i + (3-v);
              Y = 4*j + u;
            }
        
            if (ID >= 0 && ID <= 6) {
              this.facilities[gridPanU+X][gridPanV+Y] = data[v][u];
            } else if (ID ==8 || ID == 9) {
              this.market[gridPanU+X][gridPanV+Y] = data[v][u];
            } 
          }
        }
      }
    }
  }
}

void clearInputData() {
  for (int u=0; u<gridU; u++) {
    for (int v=0; v<gridV; v++) {
      this.form[u][v] = 0;
      this.facilities[u][v] = 0;
      this.market[u][v] = 0;
    }
  }
}

void fauxPieces(int code, int[][][] pieces, int maxID) {
  if (code == 2 ) {
    
    // Sets all grids to have "no object" (-1) with no rotation (0)
    for (int i=0; i<pieces.length; i++) {
      for (int j=0; j<pieces[0].length; j++) {
        pieces[i][j][0] = -1;
        pieces[i][j][1] = 0;
      }
    }
  } else if (code == 1 ) {
    
    // Sets grids to be alternating one of each N piece types (0-N) with no rotation (0)
    for (int i=0; i<pieces.length; i++) {
      for (int j=0; j<pieces[0].length; j++) {
        pieces[i][j][0] = i  % maxID+1;
        pieces[i][j][1] = 0;
      }
    }
  } else if (code == 0 ) {
    
    // Sets grids to be random piece types (0-N) with random rotation (0-3)
    for (int i=0; i<pieces.length; i++) {
      for (int j=0; j<pieces[0].length; j++) {
        if (random(0, 1) > 0.95) {
          pieces[i][j][0] = int(random(-1.99, maxID+1));
          pieces[i][j][1] = int(random(0, 4));
        } else { // 95% of pieces are blank
          pieces[i][j][0] = -1;
          pieces[i][j][1] = 0;
        }
      }
    }
  }
  
  decodePieces();
}
  
