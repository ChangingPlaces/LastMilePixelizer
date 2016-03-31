// CTL Web Address
String CTL_ADDRESS = "localhost";
int CTL_PORT = 6252;

// CTL Dimension Constants
float CTL_SCALE = 0.5; //km per pixel unit
int CTL_KM_U = 90;
int CTL_KM_V = 110;
int CTL_GRID_U = int(CTL_KM_U/CTL_SCALE);
int CTL_GRID_V = int(CTL_KM_V/CTL_SCALE);

ClientPackage dataForCTL;
OutputPackage dataFromCTL;

void sendCTLData() {
  dataForCTL.addToPackage("facilities", facilities, gridSize);
  dataForCTL.addToPackage("market", market, gridSize);
  dataForCTL.addToPackage("obstacles", obstacles, gridSize);
  dataForCTL.sendPackage();
}

// A Class that handles and sends a matrix of data formatted for the scale of the reciever
class ClientPackage {
  
  String packageString;
  int VOID_VALUE = 0;
  
  String clientAddress;
  int clientPort;
  float clientScale;
  
  ClientPackage(String address, int port, float scale) {
    packageString = "";
    clientAddress = address;
    clientPort = port;
    clientScale = scale;
  }
  
  // addToPackage() appends a TSV-style matrix to the packageString:
  //
  //  facilities
  //  1  34  101     // ID  U  V
  //  5  104  165
  //  4  76  181
  //  ...
  //  market
  //  9  6  9
  //  10  6  137
  //  9  26  101
  //  ...
  //  obstacles
  //  1  6  9
  //  1  6  137
  //  1  26  101
  //  ... 
  
  void addToPackage( String packageName, int[][] input, float localScale) {
    // Define Package Name
    packageString += packageName;
    packageString += "\n";
    
    int uDisaggregated, vDisaggregated;
    
    // Define Package Data
    for (int u=0; u<input.length; u++) {
      for (int v=0; v<input[0].length; v++) {
        if (input[u][v] != VOID_VALUE) {
          
          // Converts local u,v values to client coordinate system
          uDisaggregated = int(u*localScale/clientScale) + 2;
          vDisaggregated = int(v*localScale/clientScale) + 1;
          
          packageString += input[u][v];
          packageString += "\t";
          packageString += uDisaggregated;
          packageString += "\t";
          packageString += vDisaggregated;
          packageString += "\n";
        }
      }
    }
  }
  
  void clearPackage() {
    packageString = "";
  }
  
  void sendPackage() {
    if (viaUDP) {
      udp.send( packageString, clientAddress, clientPort );
      //println(packageString);
      clearPackage();
    }
  }
}

// A Class that receives and handles a matrix of data from an external client
class OutputPackage {
  
  String packageString;
  int VOID_VALUE = 0;
  
  float clientScale;
  
  OutputPackage(float scale) {
    packageString = "";
    clientScale = scale;
  }
  
  void readPackage( String output, float localScale) {
    this.packageString = output;
  }
  
  void clearPackage() {
    packageString = "";
  }
}
