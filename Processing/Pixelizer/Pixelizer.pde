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

String systemOS;

// Library needed for ComponentAdapter()
import java.awt.event.*;

// 0 = Denver
// 1 = San Jose
// 2 = Seattle
int modeIndex = 2;

// 0 = random
// 1 = rows
// 2 = clear
int randomType = 2;

int projectorWidth = 1920;
int projectorHeight = 1200;
int projectorOffset = 1920;

int screenWidth = 1920;
int screenHeight = 1080;

boolean hideWallyWorld = true;

// Set this to true to display the main menu upon start
boolean showMainMenu = true;
boolean showFrameRate = false;
boolean startup = true;

boolean showStores = false;
boolean showDeliveryData = false;
boolean showPopulationData = true;
boolean showBasemap = true;

boolean showInputData = true;
boolean showFacilities = true;
boolean showMarket = false;
boolean showObstacles = false;
boolean showForm = false;

boolean showOutputData = true;
boolean showDeliveryCost = false;
boolean showTotalCost = false;
boolean showAllocation = true;
boolean showVehicle = false;

//WMT Logo
PImage wmt_logo;

// Class that holds a button menu
Menu mainMenu, hideMenu;

boolean sketchFullScreen() {
  return true;
}

void setup() {
  size(screenWidth, screenHeight, P3D);
  
  logo[0] = loadImage("data/logos/ira.png");
  logo[1] = loadImage("data/logos/mit.png");
  logo[2] = loadImage("data/logos/bgv.png");
  single = loadImage("data/slides/single.png");
  multi = loadImage("data/slides/multi.png");
  high = loadImage("data/slides/high.png");

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

      // Initializes Facility Configurations
      updateFacilitiesList();

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
       
      systemOS = System.getProperty("os.name").substring(0,3);
      println(systemOS);
}

void draw() {

  if (flagResize) {
    initScreenOffsets();
    if (applet != null) applet.reset(); // Resets Projection Graphics
    loadMenu(screenWidth, screenHeight);
    flagResize = false;
  }

  // Decode pieces only if there is a change in Colortizer input
  if (changeDetected) {
    decodePieces();
    if (!enableCTL) {
      updateFacilitiesList();
      updateOutput();
      renderOutputTableLayers(output);
    } else {
      sendCTLData();
    }
    renderDynamicTableLayers(input);
    reRenderMiniMap(miniMap);
    changeDetected = false;
  }

  if (outputReady) {
    renderOutputTableLayers(output);
    outputReady = false;
  }

  background(background);

  // Render Table Surface Graphic
  renderTable();
  image(table, TABLE_IMAGE_OFFSET, STANDARD_MARGIN, TABLE_IMAGE_WIDTH, TABLE_IMAGE_HEIGHT);

  // Renders everything else drawn to Screen
  renderScreen();
  image(screen, 0, 0);

  // Exports table Graphic to Projector
  projector = get(TABLE_IMAGE_OFFSET, STANDARD_MARGIN, TABLE_IMAGE_WIDTH, TABLE_IMAGE_HEIGHT);
  margin = get(TABLE_IMAGE_OFFSET - STANDARD_MARGIN - int(mapRatio*TABLE_IMAGE_HEIGHT) + 10, STANDARD_MARGIN, int(mapRatio*TABLE_IMAGE_HEIGHT) + STANDARD_MARGIN - 10, TABLE_IMAGE_HEIGHT);
  margin.resize(int(mapRatio*TABLE_IMAGE_HEIGHT), margin.height);
  hist = get(TABLE_IMAGE_OFFSET + TABLE_IMAGE_WIDTH, STANDARD_MARGIN, 250, 350);
  hist.resize(margin.width, 350);
  
  // In Lieu of Projection creates the square table on main canvas for testing when on mac
  if (systemOS.equals("Mac") && testProjectorOnMac) {
    background(textColor);
    image(margin, 0, 0);
    image(projector, margin.width, 0);
    image(hist, 0, 370);
  }

//  fill(textColor, 80);
//  text("CTL Optimization = " + enableCTL, 20, 35);
//  text("(Press Spacebar to Toggle)", 20, 50);
//  fill(textColor);
  
//  if (waitingForCTL){
//    if(waiting_blink){
//      fill(wmt_light_green);
//      text("** OPTIMIZING **", 20, 65);
//      fill(textColor);
//      waiting_blink = false;
//    }
//    else{
//      waiting_blink = true;
//    }
//  }
  
  if (showSingle) {
    background(0);
    image(single, width/2 - single.width/2, height/2 - single.height/2);
  } else if(showMulti) {
    background(0);
    image(multi,width/2 - multi.width/2, height/2 - multi.height/2);
  } else if(showHigh) {
    background(0);
    image(high,width/2 - high.width/2, height/2 - high.height/2);
  }
  
  for (int i=0; i<logo.length; i++) {
    image(logo[i], 25, 25 + i*100);
  }
  
  if (!displayProjection2D && startup) {
    // Open Projector by default
    displayProjection2D = true;
    showProjection2D();
    startup = false;
  }

}
