/* Pixelizer is a script that transforms a cloud of weighted latitude-longitude points 
 * into a discrete, pixelized aggregation data set.  Input is a TSV file
 * of weighted lat-lon and output is a JSON.
 *
 *      ---------------> + U-Axis 
 *     |
 *     |
 *     |
 *     |
 *     |
 *     |
 *   + V-Axis
 * 
 * Ira Winder (jiw@mit.edu)
 * Mike Winder (mhwinder@gmail.com)
 * Write Date: January, 2015
 * 
 */
 
/* Graphics Architecture:
 * 
 * projector  <-  main  <-  table  <-  (p)opulation, (h)eatmap, (s)tores(s), (l)ines, (c)ursor, input
 *                 ^
 *                 |
 *               screen <-  (i)nfo <-  minimap, legendH, legendP
 */

// Library needed for ComponentAdapter()
import java.awt.event.*;

// 0 = Denver
// 1 = San Jose
int modeIndex = 0;

// 0 = random
// 1 = rows
// 2 = clear
int randomType = 2;

int projectorWidth = 1920;
int projectorHeight = 1200;
int projectorOffset = 1842;

int screenWidth = 1500;
int screenHeight = 1000;

// Set this to true to display the main menu upon start
boolean showMainMenu = true;
boolean showFrameRate = false;

boolean showStores = true;
boolean showDeliveryData = false;
boolean showPopulationData = true;
boolean showBasemap = true;

boolean showInputData = true;
boolean showFacilities = false;
boolean showMarket = false;
boolean showObstacles = false;
boolean showForm = true;

boolean showOutputData = false;
boolean showCost = true;
boolean showAllocation = false;
boolean showVehicle = false;

// Class that holds a button menu
Menu mainMenu, hideMenu;

void setup() {
  size(screenWidth, screenHeight, P3D);
  
  // Frame Options
  
      // Window may be resized after initialized
      frame.setResizable(true);
      
      // Recalculates relative positions of canvas items if screen is resized
      frame.addComponentListener(new ComponentAdapter() { 
         public void componentResized(ComponentEvent e) { 
           if(e.getSource()==frame) { 
             flagResize = true;
           } 
         } 
       }
       );
  
  // Functions run only once during setup
  
      // Graphics Objects for Data Layers
      initDataGraphics();
    
      // Initial Projection-Mapping Canvas
      initializeProjection2D();
   
      // Allows application to receive information from Colortizer via UDP
      initUDP();
      
      // Sets up Lego Piece Data Information
      setupPieces();
      
      // Initialize Input Packages for CTL Data
      dataForCTL = new ClientPackage(CTL_ADDRESS, CTL_PORT, CTL_SCALE);
      dataFromCTL = new OutputPackage(CTL_SCALE);
  
  // Functions called during setup, but also called again at other points
    
      // Resets the scale, resolution and extents of analysis area
      resetGridParameters();
      
      // Reads point data from TSV file, converts to JSON, prints to JSON, and reads in from JSON
      reloadData(gridU, gridV, modeIndex);
      
      // Initializes Pieces with Random Placement
      fauxPieces(randomType, tablePieceInput, IDMax);
      
      // Renders Minimap
      reRenderMiniMap(miniMap);
      
      // Refreshes the graphics available in all of the canvases
      reRender();
  
      // Loads and formats menu items
      loadMenu(tableWidth, tableHeight);
}

void draw() {
  
  if (flagResize) {
    initScreenOffsets();
    loadMenu(screenWidth, screenHeight);
    flagResize = false;
  }
  
  // Decode pieces only if there is a change in Colortizer input
  if (changeDetected) {
    decodePieces();
    sendCTLData();
    renderDynamicTableLayers(input);
    changeDetected = false;
  }
  
  if (outputReady) {
    renderOutputTableLayers(output);
    outputReady = false;
  }
  
  background(background);
  
  // Render Table Surface Graphic
  renderTable();
  image(table, tablex_0, tabley_0, tablex_1, tabley_1); 

  // Renders everything else drawn to Screen
  renderScreen();
  image(screen, 0, 0);
  
  // Exports table Graphic to Projector
  projector = get(tablex_0, tabley_0, tablex_1, tabley_1);
}
  
