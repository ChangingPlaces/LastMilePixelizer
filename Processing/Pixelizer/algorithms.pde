import java.util.*;

ArrayList<Facility> facilitiesList = new ArrayList<Facility>();

void updateOutput() { 
  clearOutputData();
  
  calcDeliveryCost();
  calcFacilityAllocations();
  //assignDeliveries();
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
  
  for (int i=0; i<facilitiesList.size(); i++) {
    Facility current = facilitiesList.get(i);
    current.clearDeliveries();
    float distance, density, currentCost;
    for (int u=0; u<gridU; u++) {
      for (int v=0; v<gridV; v++) {
        // Cost = A*distance/sqrt(density) + B
        distance = gridSize*sqrt(sq(u - current.u) + sq(v - current.v)); // KM
        density = dailyDemand(pop[u][v]);
        currentCost = distance / sqrt(density);
        if (currentCost < deliveryCost[u][v]) {
          deliveryCost[u][v] = currentCost;
        }
      }
    }
  } 
}

void assignDeliveries() {
  
  for (int u=0; u<gridU; u++) {
    for (int v=0; v<gridV; v++) {
      if (allocation[u][v] > 0) {
        Facility current = facilitiesList.get(allocation[u][v]-1);
        current.addDelivery(u,v,deliveryCost[u][v], dailyDemand(pop[u][v]));
      }
      allocation[u][v] = 0;
    }
  }
  
  for (int i=0; i<facilitiesList.size(); i++) {
    Facility current = facilitiesList.get(i);
    Collections.sort(current.deliveryCost);
    
    // Greedy Algorithm
    float demandMet = 0;
    for (int j=0; j<current.deliveryDemand.size(); j++) {
      demandMet += current.deliveryDemand.get(j);
      if (demandMet <= current.maxOrderSize) {
        totalCost[current.deliveryU.get(j)][current.deliveryV.get(j)] += current.deliveryCost.get(j);
        allocation[current.deliveryU.get(j)][current.deliveryV.get(j)] = i+1;
      } else {
        break;
      }
    }
  }
  
}

void calcFacilityAllocations() {
  for (int i=0; i<facilitiesList.size(); i++) {
    Facility current = facilitiesList.get(i);
    float distanceCurrent, distanceLeast;
    for (int u=0; u<gridU; u++) {
      for (int v=0; v<gridV; v++) {
        
        if (i == 0) {
          allocation[u][v] = i+1;
        } else {
          Facility closest = facilitiesList.get(allocation[u][v]-1);
          // Allocation -> distance
          distanceCurrent = gridSize*sqrt(sq(u - current.u) + sq(v - current.v)); // KM
          distanceLeast = gridSize*sqrt(sq(u - closest.u) + sq(v - closest.v)); // KM
          if (distanceCurrent < distanceLeast) {
            allocation[u][v] = i+1;
          }
        }
        
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
  boolean delivers;
  boolean pickup;
  int u, v;
  ArrayList<Integer> deliveryU, deliveryV;
  ArrayList<Float> deliveryCost, deliveryDemand;
  
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
  }
  
  void addDelivery(int u, int v, float cost, float demand) {
    deliveryU.add(u);
    deliveryV.add(v);
    deliveryCost.add(cost);
    deliveryDemand.add(demand);
  }
  
  void clearDeliveries() {
    deliveryU.clear();
    deliveryV.clear();
    deliveryCost.clear();
    deliveryDemand.clear();
  }
}
