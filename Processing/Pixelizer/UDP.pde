// Principally, this script ensures that a string is "caught" via UDP and coded into principal inputs of:
// - tablePieceInput[][] or tablePieceInput[][][2] (rotation)
// - UMax, VMax


int portIN = 6152;

import hypermedia.net.*;
UDP udp;  // define the UDP object

boolean busyImporting = false;
boolean viaUDP = true;
boolean changeDetected = false;
boolean outputReady = false;

void initUDP() {
  if (viaUDP) {
    udp = new UDP( this, portIN );
    //udp.log( true );     // <-- printout the connection activity
    udp.listen( true );
  }
}

void ImportData(String inputStr[]) {
  if (inputStr[0].equals("COLORTIZER")) {
    parseColortizerStrings(inputStr);
  } else if (inputStr[0].equals("LAST_MILE_SIM")) {
    parseLastMileSimStrings(inputStr);
  } else if (inputStr[0].equals("CTL")) {
    saveStrings("CTLdata.txt", inputStr);
    parseCTLStrings(inputStr);
  }
  busyImporting = false;
}

void parseLastMileSimStrings(String data[]) {
  
  outputReady = true;
}

void parseCTLStrings(String data[]) {
  
  //println("CTL Strings Recieved by " + LOCAL_FRIENDLY_NAME);
  
  String dataType = "";
  
  for (int i=0 ; i<data.length;i++) {
    
    String[] split = split(data[i], ",");
    
    // Checks Output Data Type
    if (split.length == 1) {
      if (split[0].equals("cost") || split[0].equals("allocation") || split[0].equals("vehicle")) dataType = split[0];
    }
    
    // Checks if row format is compatible with piece recognition.  3 columns for ID, U, V; 4 columns for ID, U, V, rotation
    if (split.length == 3) { 
      
      if (dataType.equals("")) {
        // Do Nothing
        println("No Data Type Specified");
      } else {
        
        //println("CTL Row Processed by " + LOCAL_FRIENDLY_NAME);
        
        //Finds UV values of Lego Grid in CTL units
        int u_local = int(split[0]);
        int v_local = int(split[1]);
        
        // Adds offset assuming CTL grid is centered on same point as local Coordinate system
        // Still in CTL Units
        u_local += int( ((MAX_GRID_SIZE*displayU - CTL_KM_U)/2) / CTL_SCALE);
        v_local += int( ((MAX_GRID_SIZE*displayV - CTL_KM_V)/2) / CTL_SCALE);
        
        // Converts u/v coordinates to local grid.  Results in data being "lost"
        u_local = int( (CTL_SCALE/gridSize)*u_local );
        v_local = int( (CTL_SCALE/gridSize)*v_local );
        
        if (u_local < gridU && v_local < gridV) {
          if (dataType.equals("cost")) {
            float value = float(split[2]);
            cost[u_local][v_local] = value;
          } else if (dataType.equals("allocation")) {
            int value = int(split[2]);
            allocation[u_local][v_local] = value;
          } else if (dataType.equals("vehicle")) {
            int value = int(split[2]);
            vehicle[u_local][v_local] = value;
          } 
        }
      }
    } 
  }
  outputReady = true;
}

void parseColortizerStrings(String data[]) {
  
  for (int i=0 ; i<data.length;i++) {
    
    String[] split = split(data[i], "\t");
    
    // Checks maximum possible ID value
    if (split.length == 2 && split[0].equals("IDMax")) {
      IDMax = int(split[1]);
    }
    
    // Checks if row format is compatible with piece recognition.  3 columns for ID, U, V; 4 columns for ID, U, V, rotation
    if (split.length == 3 || split.length == 4) { 
      
      //Finds UV values of Lego Grid:
      int u_temp = int(split[1]);
      int v_temp = tablePieceInput.length - int(split[2]) - 1;
      
      if (split.length == 3 && !split[0].equals("gridExtents")) { // If 3 columns
          
        // detects if different from previous value
        if ( v_temp < tablePieceInput.length && u_temp < tablePieceInput[0].length ) {
          if ( tablePieceInput[v_temp][u_temp][0] != int(split[0]) ) {
            // Sets ID
            tablePieceInput[v_temp][u_temp][0] = int(split[0]);
            changeDetected = true;
          }
        }
        
      } else if (split.length == 4) {   // If 4 columns
        
        // detects if different from previous value
        if ( v_temp < tablePieceInput.length && u_temp < tablePieceInput[0].length ) {
          if ( tablePieceInput[v_temp][u_temp][0] != int(split[0]) || tablePieceInput[v_temp][u_temp][1] != int(split[3])/90 ) {
            // Sets ID
            tablePieceInput[v_temp][u_temp][0] = int(split[0]); 
            //Identifies rotation vector of piece [WARNING: Colortizer supplies rotation in degrees (0, 90, 180, and 270)]
            tablePieceInput[v_temp][u_temp][1] = int(split[3])/90; 
            changeDetected = true;
          }
        }
      }
    } 
  }
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  // get the "real" message =
  String message = new String( data ); 
  println(message);
  //saveStrings("data.txt", split(message, "\n"));
  String[] split = split(message, "\n");
  
  if (!busyImporting) {
    busyImporting = true;
    ImportData(split);
  }
}

void sendCommand(String command, int port) {
  if (viaUDP) {
    String dataToSend = "";
    dataToSend += command;
    udp.send( dataToSend, "localhost", port );
  }
}

