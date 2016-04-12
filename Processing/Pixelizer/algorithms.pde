import java.util.*;

ArrayList<Facility> facilitiesList = new ArrayList<Facility>();
float demandSupplied;
float sumTotalCost;
float[] histogram = new float[20];
float histogramMax;

void updateOutput() { 
  initHistogram();
  clearOutputData();
  
  calcDeliveryCost();
  assignDeliveries();
  
  aggregate();
  histogramMax = histogramMax();
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
          break;
        case 2: // SMALL STORE
          facilitiesList.add(new Facility(2, u, v,   40, 10, 2, true,  true));
          break;
        case 3: // LARGE STORE
          facilitiesList.add(new Facility(3, u, v,  200, 10, 2, true,  true));
          break;
        case 4: // SPOKE
          facilitiesList.add(new Facility(4, u, v,   40,  0, 2, false, true));
          break;
        case 5: // SMALL LOCKER
          facilitiesList.add(new Facility(5, u, v,   10,  0, 3, false, true));
          break;
        case 6: // LARGE LOCKER
          facilitiesList.add(new Facility(6, u, v,   20,  0, 3, false, true));
          break;
        case 7: // REMOTE
          facilitiesList.add(new Facility(7, u, v,  120,  0, 3, false, true));
          break;
      }
    }
  }
}

void calcDeliveryCost() {
  
  // Cycle through each Facility
  for (int i=0; i<facilitiesList.size(); i++) {
    Facility current = facilitiesList.get(i);
    current.clearDeliveries();
    
    // Cycle through each pixel
    for (int u=0; u<gridU; u++) {
      for (int v=0; v<gridV; v++) {
        
        // Cost = A*distance/sqrt(density) + B
        float distance = gridSize*sqrt(sq(u - current.u) + sq(v - current.v)); // KM
        float density = dailyDemand(pop[u][v]);
        float currentCost = distance / sqrt(density);
        
        // Assigns a Facility and a Delivery Cost to a cell
        if (currentCost < deliveryCost[u][v]) {
          deliveryCost[u][v] = currentCost;
          allocation[u][v] = i+1;
        }
      }
    }
  } 
}

void assignDeliveries() {
  
  demandSupplied = 0;
  
  // Cycle through every grid cell and adds its information to an ArrayList withing the respective Facility object
  for (int u=0; u<gridU; u++) {
    for (int v=0; v<gridV; v++) {
      if (allocation[u][v] > 0 && dailyDemand(pop[u][v]) >= 1) {
        Facility current = facilitiesList.get(allocation[u][v]-1);
        current.addDelivery(u,v, deliveryCost[u][v], dailyDemand(pop[u][v]));
      }
      // Resets Allocation
      allocation[u][v] = 0;
    }
  }
  
  // Cycles through Each Facility
  for (int i=0; i<facilitiesList.size(); i++) {
    Facility current = facilitiesList.get(i);
    
    // Greedy Algorithm
    
    // Sorts the cells to which one might delivery by cost, lowest to highest
    Collections.sort(current.deliveryInfo);
    
    // Assigns deliveries in a greedy manner until the store has fulfilled its maximum order capacity
    float demandMet = 0;
    for (int j=0; j<current.deliveryInfo.size(); j++) {
      String[] delivery = split(current.deliveryInfo.get(j), ",");
      //Local
      demandMet += int(delivery[1]);
      
      if (demandMet <= current.maxOrderSize) {
        //Global
        demandSupplied += int(delivery[1]);
        addToHistogram(float(delivery[0]), float(delivery[1]));
        //Local
        totalCost[int(delivery[2])][int(delivery[3])] += float(delivery[0])*int(delivery[1]);
        allocation[int(delivery[2])][int(delivery[3])] = i+1;
      } else {
        break;
      }
    }
  }
}

void aggregate() {
  sumTotalCost = 0;
  for (int u=0; u<gridU; u++) {
    for (int v=0; v<gridV; v++) {
      sumTotalCost += totalCost[u][v];
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
  boolean delivers;
  boolean pickup;
  int u, v;
  ArrayList<Integer> deliveryU, deliveryV;
  ArrayList<Float> deliveryCost, deliveryDemand;
  ArrayList<String> deliveryInfo;
  
  Facility(int ID, int u, int v, int maxOrderSize, int maxFleetSize, int maxShifts, boolean delivers, boolean pickup) {
    this.ID = ID;
    this.u = u;
    this.v = v;
    this.maxOrderSize = maxOrderSize;
    this.maxFleetSize = maxFleetSize;
    this.maxShifts = maxShifts;
    this.delivers = delivers;
    this.pickup = pickup;
    
    deliveryU = new ArrayList<Integer>();
    deliveryV = new ArrayList<Integer>();
    deliveryCost = new ArrayList<Float>();
    deliveryDemand = new ArrayList<Float>();
    
    deliveryInfo = new ArrayList<String>();
  }
  
  void addDelivery(int u, int v, float cost, float demand) {
    deliveryU.add(u);
    deliveryV.add(v);
    deliveryCost.add(cost);
    deliveryDemand.add(demand);
    
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
    
    info += cost + "," + demand + "," + u + "," + v;
    deliveryInfo.add(info);
  }
  
  void clearDeliveries() {
    deliveryU.clear();
    deliveryV.clear();
    deliveryCost.clear();
    deliveryDemand.clear();
    
    deliveryInfo.clear();
  }
}
