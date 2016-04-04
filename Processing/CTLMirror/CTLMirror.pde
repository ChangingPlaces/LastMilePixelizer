// This is a simple script that mimics the UDP behavior of CTL's Math Model
// It receives a UDP String and Returns an output String

boolean USE_CTL_SAMPLE_DATA = false;
int SEND_DELAY = 1; // thousanths of a second

int CTL_U = 180;
int CTL_V = 220;
int V_SEND_LIMIT = 2;

float[][] costTotal = new float[CTL_U][CTL_V];
float[][] costPerDelivery = new float[CTL_U][CTL_V];
float[][] allocation = new float[CTL_U][CTL_V];
float[][] vehicle = new float[CTL_U][CTL_V];

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
    
    if (USE_CTL_SAMPLE_DATA) {
//      for (int i=0; i<CTL_OUTPUT.size(); i++) {
//        udp.send( CTL_OUTPUT.getString(i), CLIENT_IP, CLIENT_PORT );
//        if (SEND_DELAY != 0 ) {
//          delay(SEND_DELAY);
//        }
//      }
    } else {
      generateFauxData();
      dataForIra.sendChunks("cost_per_delivery", costPerDelivery, LOCAL_SCALE, V_SEND_LIMIT);
      dataForIra.sendChunks("cost_total", costTotal, LOCAL_SCALE, V_SEND_LIMIT);
      dataForIra.sendChunks("allocation_facilities", allocation, LOCAL_SCALE, V_SEND_LIMIT);
      dataForIra.sendChunks("allocation_vehicles", vehicle, LOCAL_SCALE, V_SEND_LIMIT);
    }
    
    //dataForIra.savePackage("cost.tsv");
    importReady = false;
  }
}

void generateFauxData() {
  for (int u=0; u<CTL_U; u++) {
    for (int v=0; v<CTL_V; v++) {
      costPerDelivery[u][v] = random(0,1);
      costTotal[u][v] = random(0,1);
      allocation[u][v] = float(int(random(-0.99,5)));
      vehicle[u][v] = float(int(random(-0.99,5)));
    }
  }
}
