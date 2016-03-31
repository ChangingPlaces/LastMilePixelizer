// This is a simple script that mimics the UDP behavior of CTL's Math Model
// It receives a UDP String and Returns an output String

int CTL_U = 180;
int CTL_V = 220;
int V_SEND_LIMIT = CTL_V/10;
int[][] cost = new int[CTL_U][CTL_V];

float CLIENT_SCALE = 2.0; //KM PER PIXEL
float LOCAL_SCALE = 0.5;  //KM PER PIXEL

ClientPackage dataForIra;

void setup() {
  initUDP();
  
  dataForIra = new ClientPackage(CLIENT_IP, CLIENT_PORT, CLIENT_SCALE);
}

void draw() {
  if (importReady) {
    println("CTLMirror received input!");
    
    generateFauxData();
    dataForIra.sendChunks("cost", cost, LOCAL_SCALE, V_SEND_LIMIT);
    //dataForIra.savePackage("cost.tsv");
    importReady = false;
  }
}

void generateFauxData() {
  for (int u=0; u<CTL_U; u++) {
    for (int v=0; v<CTL_V; v++) {
      cost[u][v] = int(random(0,10));
    }
  }
}
