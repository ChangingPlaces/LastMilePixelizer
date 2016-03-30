// Data Extents Parameters

    // Display Matrix Size (cells rendered to screen)
    int displayV = 22*4; // Height of Lego Table
    int displayU = 18*4; // Width of Lego Table
    int gridPanV, gridPanU; // Integers that describe how much to offset grid pixels when drawing
    int scaler, gridU, gridV;
    
    void resetGridParameters() {
      scaler = int(maxGridSize/gridSize);
      // Total Matrix Size (includes cells beyond extents of screen)
      gridV = displayV*scaler; // Height of Lego Table
      gridU = displayU*scaler; // Width of Lego Table
      // Integers that describe how much to offset grid pixels when drawing
      gridPanV = (gridV-displayV)/2;
      gridPanU = (gridU-displayU)/2;
      resetMousePan();
    }

// Raster Basemap Data based on Google Maps
    
    // Raster Basemap Objects
    PImage wholeMap, basemap;
    String mapColor = "bw";
    
    // Loads one giant map object
    void initializeBaseMap() {
      wholeMap = loadImage("data/" + mapColor + "/" + fileName + "_2000.png");
    }
    
    // Loads subset of wholemap onto basemap
    void loadBasemap() {
      float w = (float)wholeMap.width/gridU;
      float h = (float)wholeMap.height/gridV;
      basemap = wholeMap.get(int(gridPanU*w), int(gridPanV*h), int(displayU*w), int(displayV*h));
      basemap.resize(table.width, table.height);
      loadMiniBaseMap();
    }
    
// Methods for reloading data when changing zoom level, area of analysis, etc
    
    // Set this to false if you know that you don't need to regenerate data every time Software is run
    boolean pixelizeData = true;

    void reloadData(int gridU, int gridV, int index) {
      // determines which dataset to Load
      switch(index) {
        case 0:
          denverMode();
          break;
        case 1:
          sanjoseMode();
          break;
      }
      
      // Processes lat-long data and saves to aggregated JSON grid
      if (pixelizeData) {
        pixelizeData(this.gridU, this.gridV);
      }
      
      // Loads extents of static data
      initStaticData();
      
      // Loads extents of Input data
      initInputData(); 
      
      // Initializes Basemap file
      initializeBaseMap();
      
      // Loads Basemap from subset of file
      loadBasemap();
    }

// Pre-loaded Static Data (geospatial delivery counts, population, etc)

    // 2D matrix that holds grid values
    float heatmap[][], stores[][], pop[][], hu[][];
    // variables to hol minimum and maximum grid values in matrixƒ
    float heatmapMIN, heatmapMAX;
    float storesMIN, storesMAX;
    float popMIN, popMAX;
    float huMIN, huMAX;
    
    //JSON array holding totes
    JSONArray array;
    
    //Table holding Population Counts and Housing Units (created from GridResampler)
    Table popCSV, huCSV;
    
    // Runs once when initializes
    void initStaticData() {
      
      array = loadJSONArray("data/" + fileName + "_" + valueMode + ".json");
      try {
        popCSV = loadTable("data/CSV_POPHU/" + fileName + "_" + popMode + "_" + gridV + "_" + gridU + "_" + int(gridSize*1000) + ".csv");
      }  catch(RuntimeException e) {
        popCSV = new Table();
      }
      
      heatmap = new float[gridU][gridV];
      stores = new float[gridU][gridV];
      pop = new float[gridU][gridV];
      for (int u=0; u<gridU; u++) {
        for (int v=0; v<gridV; v++) {
          heatmap[u][v] = 0;
          stores[u][v] = 0;
          pop[u][v] = 0;
        }
      }
      
      // MIN and MAX set to arbitrarily large and small values
      heatmapMIN = Float.POSITIVE_INFINITY;
      heatmapMAX = Float.NEGATIVE_INFINITY;
      
      // MIN and MAX set to arbitrarily large and small values
      storesMIN = Float.POSITIVE_INFINITY;
      storesMAX = Float.NEGATIVE_INFINITY;
      
      // MIN and MAX set to arbitrarily large and small values
      popMIN = Float.POSITIVE_INFINITY;
      popMAX = Float.NEGATIVE_INFINITY;
      
      JSONObject temp = new JSONObject();
      for (int i=0; i<array.size(); i++) {
        try {
          temp = array.getJSONObject(i);
        } catch(RuntimeException e) {
        }
        heatmap[temp.getInt("u")][temp.getInt("v")] = temp.getInt(valueMode);
        stores[temp.getInt("u")][temp.getInt("v")] = temp.getInt("store");
      }
      
      for (int i=0; i<popCSV.getRowCount(); i++) {
        for (int j=0; j<popCSV.getColumnCount(); j++) {
          pop[j][i] = popCSV.getFloat(popCSV.getRowCount()-1-i, j);
        }
      }
        
      
      for (int u=0; u<gridU; u++) {
        for (int v=0; v<gridV; v++) {
          
          // each cell in the heatmap randomly assigned a vlue between 0 and 178
          // This is a placeholder that should eventually hold real data (i.e. number of totes)
          //heatmap[u][v] = random(0, 178);
          
          if (heatmap[u][v] != 0) { // 0 is usually void, so including it will skew our color gradient
            heatmapMIN = min(heatmapMIN, heatmap[u][v]);
            heatmapMAX = max(heatmapMAX, heatmap[u][v]);
          }
            
          storesMIN = min(storesMIN, stores[u][v]);
          storesMAX = max(storesMAX, stores[u][v]);
          
          if (pop[u][v] != 0) { // 0 is usually void, so including it will skew our color gradient
            popMIN = min(popMIN, pop[u][v]);
            popMAX = max(popMAX, pop[u][v]);
          }
        }
      }
      
    //  // Prints largest and smallest values to console
    //  println("Maximum Value: " + heatmapMAX);
    //  println("Minimum Value: " + heatmapMIN);
      
    }
    
// Initialize Input Data (store locations, lockers, etc)
    
    int[][] facilities, market, obstacles, form;
    
    // Runs once when initializes
    void initInputData() {
      facilities = new int[gridU][gridV];
      market = new int[gridU][gridV];
      obstacles = new int[gridU][gridV];
      form = new int[gridU][gridV];
      for (int u=0; u<gridU; u++) {
        for (int v=0; v<gridV; v++) {
          facilities[u][v] = 0;
          market[u][v] = 0;
          obstacles[u][v] = 0;
          form[u][v] = 0;
        }
      }
      
      fauxData(0, facilities, 7);
      fauxData(0, market, 1);
      fauxData(0, obstacles, 1);
      fauxData(0, form, 0);
    }
    
    void fauxData(int code, int[][] inputs, int maxInput) {

      if (code == 2 ) {
        
        // Sets all grids to have "no object" (-1) with no rotation (0)
        for (int i=0; i<inputs.length; i++) {
          for (int j=0; j<inputs[0].length; j++) {
            inputs[i][j] = -1;
          }
        }
      } else if (code == 1 ) {
        
        // Sets grids to be alternating one of each N piece types (0-N) with no rotation (0)
        for (int i=0; i<inputs.length; i++) {
          for (int j=0; j<inputs[0].length; j++) {
            inputs[i][j] = i  % maxInput+1;
          }
        }
      } else if (code == 0 ) {
        
        // Sets grids to be random piece types (0-N) with random rotation (0-3)
        for (int i=0; i<inputs.length; i++) {
          for (int j=0; j<inputs[0].length; j++) {
            inputs[i][j] = int(random(-1.99, maxInput+1));
          }
        }
      }
      
    }
