/* TO DO
 *
 * Fix Exclusive Veronoi Zones even when store cannot serve
 * Make Store Order Capacity more "balanced"
 *
 */

import java.util.*;

ArrayList<Facility> facilitiesList = new ArrayList<Facility>();
DeliveryMatrix deliveryMatrix = new DeliveryMatrix();

float demandSupplied;
float sumTotalCost;
int HISTOGRAM_DIVISIONS = 30;
float[] histogram = new float[HISTOGRAM_DIVISIONS];
float histogramMax;
float[] performanceDashboard = new float[21]; //Tracks twenty metrics
String[] performanceDashboardLabels = new String[21]; //Tracks up to twenty metrics

void updateOutput() {
  initHistogram();
  clearOutputData();
  clearPerformanceDashboard();

  // 1. Calculate All Delivery Costs. Currently distance.
  // 2. Sort All Delivery Costs
  // 3. Allocate Deliveries until each facility (a) runs out of supply or (b) runs out of demand
  calcDeliveryCost();
  assignDeliveries();

  aggregate();
  histogramMax = histogramMax();
}


//Initialize the dashboard
void initDashboard(){

  performanceDashboardLabels[0]= "Demand - Delivery"; //Delivery demand
  performanceDashboardLabels[1]= "Demand - Pickup"; //Delivery demand
  performanceDashboardLabels[2]= "$ Demand - Delivery"; //Delivery demand
  performanceDashboardLabels[3]= "$ Demand - Pickup"; //Delivery demand
  performanceDashboardLabels[4]= "Deliveries"; //satisfied demand
  performanceDashboardLabels[5]= "Pickups"; //satisfied demand
  performanceDashboardLabels[6]= "Delivery $"; //satisfied demand
  performanceDashboardLabels[7]= "Pickup $"; //satisfied demand
  performanceDashboardLabels[8]= "Variable Cost - Delivery"; // Total Variable Cost per order delivery
  performanceDashboardLabels[9]= "Variable Cost - Pickup"; // Total Variable Cost per order pickup
  performanceDashboardLabels[10]= "Total Fixed Cost($)"; // Total Fixed Cost
  performanceDashboardLabels[11]= "# of Hub Stores"; // Total Hub stores
  performanceDashboardLabels[12]= "# of Spoke Stores"; // Total Spoke stores
  performanceDashboardLabels[13]= "# of In Market Nodes"; // Total Number of IMN
  performanceDashboardLabels[14]= "# of Lockers"; // Total Number of Lockers
  performanceDashboardLabels[15]= "# of Remotes"; // Total Number of Remotes
  performanceDashboardLabels[16]= "Orders Hub Stores"; // Total Hub stores
  performanceDashboardLabels[17]= "Orders Spoke Stores"; // Total Spoke stores
  performanceDashboardLabels[18]= "Orders In Market Nodes"; // Total Number of IMN
  performanceDashboardLabels[19]= "Orders Lockers"; // Total Number of Lockers
  performanceDashboardLabels[20]= "Orders Remotes"; // Total Number of Remotes

  //Store the total market demand
  performanceDashboard[0] =0.0;
  performanceDashboard[1] =0.0;
  performanceDashboard[2] =0.0;
  performanceDashboard[3] =0.0;
  popMode.equals("POP10");
  for (int u=0; u<gridU; u++) {
    for (int v=0; v<gridV; v++) {
      //TODO: Add real computations later
      performanceDashboard[0] += dailyDemand(pop[u][v]);
      performanceDashboard[1] += 0.0; //Update later
      performanceDashboard[2] += 130.0*dailyDemand(pop[u][v]); //Update later
      performanceDashboard[3] += 0.0; //Update later

    }
  }
  clearPerformanceDashboard();

}

//Clears the performanceDashboard
void clearPerformanceDashboard(){
  //Clear all the dynamic metrics
  for (int i=4; i<performanceDashboard.length; i++) {
    performanceDashboard[i]= 0.0;
  }
}

void initHistogram() {
  for (int i=0; i<histogram.length; i++) {
    histogram[i] = 0;
  }
}

void addToHistogram(float cost, float demand) {
  float interval = MAX_DELIVERY_COST_RENDER/histogram.length;
  for (int i=0; i<histogram.length; i++) {
    if (cost > i*interval && cost < (i+1)*interval) {
      histogram[i] += demand;
      break;
    }
  }
}

float histogramMax() {
  float max = Float.NEGATIVE_INFINITY;
  for (int i=0; i<histogram.length; i++) {
    max = max(max, histogram[i]);
  }
  return max;
}

void updateFacilitiesList() {
  facilitiesList.clear();
  for (int u=0; u<gridU; u++) {
    for (int v=0; v<gridV; v++) {
      switch (facilities[u][v] ){
        // Facility(int ID, int u, int v, int maxOrderSize, int maxFleetSize, int maxShifts, boolean delivers, boolean pickup)
        case 1: // IMN
          facilitiesList.add(new Facility(1, u, v, 2000, 10, 2, true,  false));
          performanceDashboard[13]+=1; //Tally IMN
          break;
        case 2: // LARGE HUB STORE
          //facilitiesList.add(new Facility(2, u, v,   200, 10, 2, true,  true));
          facilitiesList.add(new Facility(2, u, v,   800, 10, 2, true,  true));
          performanceDashboard[11]+=1; //Tally  store
          break;
        case 3: // SMALL HUB STORE
          //facilitiesList.add(new Facility(3, u, v,   200, 10, 2, true,  true));
          facilitiesList.add(new Facility(3, u, v,   40, 10, 2, true,  true));
          performanceDashboard[11]+=1; //Tally store
          break;
        case 4: // SPOKE
          facilitiesList.add(new Facility(4, u, v,   40,  0, 2, false, true));
          performanceDashboard[12]+=1; //Tally spoke
          break;
        case 5: // SMALL LOCKER
          facilitiesList.add(new Facility(5, u, v,   10,  0, 3, false, true));
          performanceDashboard[14]+=1; //Tally lockers
          break;
        case 6: // LARGE LOCKER
          facilitiesList.add(new Facility(6, u, v,   20,  0, 3, false, true));
          performanceDashboard[14]+=1; //Tally lockers
          break;
        case 7: // REMOTE
          facilitiesList.add(new Facility(7, u, v,  120,  0, 3, false, true));
          performanceDashboard[15]+=1; //Tally lockers
          break;
      }
    }
  }
}

// Populate a list of all possible delivery assignments
void calcDeliveryCost() {

  // clear list of potential Deliveries
  deliveryMatrix.clearDeliveries();

  // Cycle through each Facility
  for (int i=0; i<facilitiesList.size(); i++) {
    Facility current = facilitiesList.get(i);
    current.clearOrders();

    // Cycle through each pixel
    for (int u=0; u<gridU; u++) {
      for (int v=0; v<gridV; v++) {

        //Add the cost to serve from that facility
        float distance = gridSize*sqrt(sq(u - current.u) + sq(v - current.v)); //  Straight distance in KM
        // float density = dailyDemand(pop[u][v]);
        float currentCost = distance;

        deliveryMatrix.addDelivery(u, v, currentCost, i);

      }
    }
  }

  // Sorts the cells to which one might deliver by cost, lowest to highest
  deliveryMatrix.greedySort();
}

// Greedy algorithm: assign to closest facility based on distance by traversing the matrix
// and checking there is enough capacity
void assignDeliveries() {
  int u, v, facilityIndex;
  float cost, demand;
  float[] resultArray;
  String[] split;

  demandSupplied = 0;

  // Cycle through every possible delivery in the list
  for (int i=0; i<deliveryMatrix.size(); i++) {

    // Assign current values from Info String
    split = split(deliveryMatrix.get(i), ",");
    cost = float(split[0]);
    u = int(split[1]);
    v = int(split[2]);
    demand = dailyDemand(pop[u][v]);
    facilityIndex = int(split[3]);

    // Checks if cell is already Allocated AND if Facility has Capacity
    if (!cellAllocated[u][v] && !facilitiesList.get(facilityIndex).atCapacity) {

      resultArray = computeDeliveryCost(u,v,facilityIndex);
      totalCost[u][v] = resultArray[0];
      deliveryCost[u][v] = resultArray[0]/demand;
      vehicle[u][v] = int(resultArray[1]);
      allocation[u][v] = facilityIndex+1;

      demandSupplied += demand;
      addToHistogram(cost, demand);

      updateDashboard(u,v);

      facilitiesList.get(facilityIndex).addOrders(demand);
      cellAllocated[u][v] = true;
    }
  }
}

//Updates the performance Dashboard with the information stored in pixel u,v
void updateDashboard(int u, int v)
{

  performanceDashboard[4]+= dailyDemand(pop[u][v]);//satisfied delivery demand
  performanceDashboard[5]+= 0.0; //satisfied pickup demand
  performanceDashboard[6]+= 130.0* dailyDemand(pop[u][v]); //satisfied delivery $ demand
  performanceDashboard[7]+= 0.0; //satisfied pickup $ demand
  performanceDashboard[8]+= totalCost[u][v]; // Total Variable Cost per order delivery
  performanceDashboard[9]+= 0.5; // Total Variable Cost per order pickup

  Facility currFacility = facilitiesList.get(allocation[u][v] -1);
  performanceDashboard[10]+=currFacility.fixedCost;

  switch (currFacility.ID){
    // Facility(int ID, int u, int v, int maxOrderSize, int maxFleetSize, int maxShifts, boolean delivers, boolean pickup)
    case 1: // IMN
      performanceDashboard[18]+=dailyDemand(pop[u][v]); //Tally IMN demand
      break;
    case 2: // LARGE HUB STORE
      performanceDashboard[16]+=dailyDemand(pop[u][v]); //Tally  store
      break;
    case 3: // SMALL HUB STORE
      performanceDashboard[16]+=dailyDemand(pop[u][v]);//Tally store
      break;
    case 4: // SPOKE
      performanceDashboard[17]+=dailyDemand(pop[u][v]); //Tally spoke
      break;
    case 5: // SMALL LOCKER
      performanceDashboard[19]+=dailyDemand(pop[u][v]); //Tally lockers
      break;
    case 6: // LARGE LOCKER
      performanceDashboard[19]+=dailyDemand(pop[u][v]); //Tally lockers
      break;
    case 7: // REMOTE
      performanceDashboard[20]+=dailyDemand(pop[u][v]);  //Tally remotes
      break;
    }
}


//Compute the delivery of assigning all the demand from pixel(u,v) to facility facilityIndex
//Returns an array with the cost and the vehicle selected
float[] computeDeliveryCost(int u, int v, int facilityIndex)
{
  float[] resultArray = new float[2];
  float distance = gridSize*sqrt(sq(u - facilitiesList.get(facilityIndex).u) + sq(v - facilitiesList.get(facilityIndex).v)); //  Straight distance in KM

  //TODO: Change these calculations. Simple test
  resultArray[0] = distance * 0.5 + 10;
  resultArray[1] = 1;

  return resultArray;
}

//void checkCapacity() {
//  for (int i=0; i<facilitiesList.size(); i++) {
//    println("#" + i + ", ID = " + facilitiesList.get(i).ID + ", orders = " + facilitiesList.get(i).orders + "/" + facilitiesList.get(i).maxOrderSize + ": " + facilitiesList.get(i).atCapacity);
//  }
//}

void aggregate() {
  sumTotalCost = 0;
  for (int u=0; u<gridU; u++) {
    for (int v=0; v<gridV; v++) {
      if (totalCost[u][v] >= 0) {
        sumTotalCost += totalCost[u][v];
      }
    }
  }
}

int[][] allocationVehicles() {
  int[][] allocation = new int[gridU][gridV];
  return allocation;
}

class Facility {

  int ID;
  int maxOrderSize; // Daily
  int maxFleetSize; // Daily
  int maxShifts;    // Daily
  float fixedCost;
  boolean delivers;
  boolean pickup;
  boolean atCapacity;
  int u, v;
  float orders;


  Facility(int ID, int u, int v, int maxOrderSize, int maxFleetSize, int maxShifts, boolean delivers, boolean pickup) {
    this.ID = ID;
    this.u = u;
    this.v = v;
    this.maxOrderSize = maxOrderSize;
    this.maxFleetSize = maxFleetSize;
    this.maxShifts = maxShifts;
    this.delivers = delivers;
    this.pickup = pickup;
    this.atCapacity = false;
    this.orders = 0;
    this.fixedCost = 0.0;
  }

  void addOrders(float orders) {
    this.orders += orders;
    if (this.orders >= maxOrderSize) atCapacity = true;
  }

  void clearOrders() {
    this.orders = 0;
    atCapacity = false;
  }
}

class DeliveryMatrix {

  ArrayList<String> deliveryInfo;

  DeliveryMatrix() {
    deliveryInfo = new ArrayList<String>();
  }

  //Adds the cost to each facility as a string (trailing zeros), with coordinates
  void addDelivery(int u, int v, float cost, int facilityIndex) {

    String info = "";

    if (cost >= 0 && cost < 10) {
      info += "00000";
    } else if (cost >= 10 && cost < 100) {
      info += "0000";
    } else if (cost >= 100 && cost < 1000) {
      info += "000";
    } else if (cost >= 1000 && cost < 10000) {
      info += "00";
    } else if (cost >= 10000 && cost < 100000) {
      info += "0";
    } else {
      // Do nothing
    }

    info += cost + "," + u + "," + v + "," + facilityIndex;
    deliveryInfo.add(info);
  }

  void clearDeliveries() {
    deliveryInfo.clear();
  }

  void greedySort() {
    Collections.sort(deliveryInfo);
  }

  int size() {
    return deliveryInfo.size();
  }

  String get(int i) {
    return deliveryInfo.get(i);
  }
}
