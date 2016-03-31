String LOCAL_FRIENDLY_NAME = "CTLMIRROR";

// A Class that handles and sends a matrix of data formatted for the scale of the reciever
class ClientPackage {
  
  String packageString;
  int VOID_VALUE = 0;
  
  String clientAddress;
  int clientPort;
  float clientScale;
  int chunks;
  
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
  
  void sendChunks(String packageName, int[][] input, float localScale, int chunkRowCount) {
    int[][] inputSubset = new int[input.length][chunkRowCount];
    
    for (int i=0; i<input[0].length/chunkRowCount; i++) {
      for (int u=0; u<inputSubset.length; u++) {
        for (int v=0; v<inputSubset[0].length; v++) {
          // breaks if last chunk is not a complete chunk
          if ( i*chunkRowCount + v >= input[0].length ) break;
          
          inputSubset[u][v] = input[u][v+i*chunkRowCount];
        }
      }
      
      // Sends Data Chunk String
      clearPackage();
      addToPackage(packageName, inputSubset, localScale);
      sendPackage();
      
    }
  }
  
  void addToPackage( String packageName, int[][] input, float localScale) {
    
    // tag to denote that tag comes from colortizer
    packageString += LOCAL_FRIENDLY_NAME;
    packageString += "\n" ;
    
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
  
  void savePackage(String fileName) {
    saveStrings(fileName, split(packageString, "\n"));
  }
  
  void sendPackage() {
    if (viaUDP) {
      udp.send( packageString, clientAddress, clientPort );
      println("Package sent from CTLMirror to Pixelizer");
      //println(packageString);
      clearPackage();
    }
  }
}
