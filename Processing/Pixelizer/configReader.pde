import de.bezier.data.*;  // import library, see menu "Sketch -> Import Library -> ..."

XlsReader reader;         // the xls reader

//Global variables
float T_max = 7; // Maximum service time  h/shift
float k_circuity_global = 1.15F; // Global inter-pixel circuity factor
int tote_vol = 1; // Avg. Volume per tote  totes/tote
float perTote_revenue = 15; // Avg. revenue per tote  USD/tote
float origin_x = 0.0F; //Table origin x-coordinate
float origin_y = 0.0F; //Table origin y-coordinate
float pixel_width = 0.50F; // Pixel width  km
int x_dim = 180; // Table size x-axis  pixels
int y_dim = 220; // Table size y-axis  pixels
int max_facility_num = 50; // Maximum number of facilities

//Vehicles, default values for truck
String vehtype_name = "van"; // vehicle options either truck or van

int capa_vol  = 120;  //physical carrying capacity  totes
float speed_inter  = 24.15F;  //inter-stop avg. Speed  km/h
float speed_linehaul = 56.35F;  //line-haul avg. Speed  km/h
float cost_ops_hour = 0.00F;  //vehicle hourly operational cost  USD/h
float cost_wage_hour = 20.00F;  //driver hourly cost (wage)  USD/h
float cost_ops_km = 0.62F;  //vehicle operational cost per km  USD/km
float cost_delivery = 0.00F;  //fixed cost per delivery  USD/order
float cost_fixed = 60.00F;  //daily vehicle fixed cost  USD/day
float t_perStop = 0.1667F;  //fixed time per delivery  h/order
float t_perToteAtStop = 0.0083F;  //incremental time per tote delivered  h/tote
float t_LoadPerTote = 0.0033F;  //vehicle loading time per tote  h/tote
float t_SetupPerTour = 0.3333F;  //fixed setup time per vehicle trip  h/tour
float detour_factor = 1.40F;  //vehicle-specific detour factor  -
int avail_first = 1;  //available for first tier  1: yes, 0: no
int avail_sec = 1;  //available for second tier  1: yes, 0: no

//facilities , default values for facility type "none"
String facilitytype_name = "none"; // facility options : none,  in-market-node,  small store,  large store,  spoke,  small locker,  large locker,  remote

String delivery_enabled =  "false"; //facility ability to serve delivery demand  boolean
String pickup_enabled = "false";// facility ability to serve pickup demand  boolean
String fulfillment_enabled = "false";// facility ability to fulfill demand of other facilities  boolean
int order_capacity = 0;// maximum order picking capacity  orders
int fleet_size = 0;// maximum fleet size  vehicles
int shift_count = 0;// number of shifts  shifts
float cost_perOrder_delivery = 0.00F;// fulfillment cost per own delivery order  USD/order
float cost_perOrder_pickup = 0.00F;// fulfillment cost per own pickup order  USD/order
float cost_perOrder_fulfillment = 0.00F;// fulfillment cost per order fulfiled for other facility  USD/order
String served_separately = "false";// served outside normal delivery routes  boolean
float add_timeSpent = 0.0000F;// fixed vehicle wait time at this facility if integrated in delivery route  h
int DV_lb = 0;// first-tier allocation variable lower bound  [1,0]
int DV_ub = 0;// first-tier allocation variable upper bound  [1,0]
int SecTier_DV_lb = 0;// second-tier allocation variable lower bound  [1,0]
int SecTier_DV_ub = 0;// second-tier allocation variable upper bound  [1,0]
float max_del_reach = 100.0F;// maximum delivery reach  km
int table_input_code = 0;// Table input code
int fac_type_enabled = 1;// enabled  1: yes, 0: no



void loadConfig()
{
  reader = new XlsReader( this, "data/markets/" + fileName + "/" + "config.xls" );  // open xls file for reading
  reader.firstRow();

  println( reader.getString( 1, 4 ) );    // first value is row, second is cell. both are zero-based

  T_max = reader.getFloat(2,4);
  k_circuity_global = reader.getFloat(3,4);
  tote_vol = reader.getInt(4,4);
  perTote_revenue = reader.getFloat(5,4);
  origin_x = reader.getFloat(6,4);
  origin_y = reader.getFloat(7,4);
  pixel_width = reader.getFloat(8,4);
  x_dim = reader.getInt(9,4);
  y_dim = reader.getInt(10,4);
  max_facility_num = reader.getInt(11,4);

  reader.openSheet(1);            // go to page "vehicles" (at address 1, zero based address)
  reader.firstRow();              // set reader on first row, first cell

  int x = 0;
  if(vehtype_name == "truck"){
      x = 0;
    }
  else if (vehtype_name == "van"){
      x = 1;
    }
  capa_vol = reader.getInt(3,4+x);
  speed_inter = reader.getFloat(4,4+x);
  speed_linehaul = reader.getFloat(5,4+x);
  cost_ops_hour = reader.getFloat(6,4+x);
  cost_wage_hour = reader.getFloat(7,4+x);
  cost_ops_km = reader.getFloat(8,4+x);
  cost_delivery = reader.getFloat(9,4+x);
  cost_fixed = reader.getFloat(10,4+x);
  t_perStop = reader.getFloat(11,4+x);
  t_perToteAtStop = reader.getFloat(12,4+x);
  t_LoadPerTote = reader.getFloat(13,4+x);
  t_SetupPerTour = reader.getFloat(14,4+x);
  detour_factor = reader.getFloat(15,4+x);
  avail_first = reader.getInt(16,4+x);
  avail_sec = reader.getInt(17,4+x);

  //println(avail_sec);
  reader.openSheet(2);            // go to page "facilities" (at address 2, zero based address)
  reader.firstRow();              // set reader on first row, first cell

  int y = 0;
  if(facilitytype_name == "none"){
      y = 0;
    }
  else if (facilitytype_name == "in-market-node"){
      y = 1;
    }
  else if (facilitytype_name == "small store"){
      y = 2;
    }
  else if (facilitytype_name == "large store"){
      y = 3;
    }
  else if (facilitytype_name == "spoke"){
      y = 4;
    }
  else if (facilitytype_name == "small locker"){
      y = 5;
    }
  else if (facilitytype_name == "large locker"){
      y = 6;
    }
  else if (facilitytype_name == "remote"){
      y = 7;
    }

  //delivery_enabled  =  reader.getString(3,4+y);
  //pickup_enabled  =  reader.getString(4,4+y);
  //fulfillment_enabled  =  reader.getString(5,4+y);
  order_capacity  =  reader.getInt(6,4+y);
  fleet_size  =  reader.getInt(7,4+y);
  shift_count  =  reader.getInt(8,4+y);
  cost_perOrder_delivery  =  reader.getFloat(9,4+y);
  cost_perOrder_pickup  =  reader.getFloat(10,4+y);
  cost_perOrder_fulfillment  =  reader.getFloat(11,4+y);
  //served_separately  =  reader.getString(12,4+y);
  add_timeSpent  =  reader.getFloat(13,4+y);
  DV_lb  =  reader.getInt(14,4+y);
  DV_ub  =  reader.getInt(15,4+y);
  SecTier_DV_lb  =  reader.getInt(16,4+y);
  SecTier_DV_ub  =  reader.getInt(17,4+y);
  max_del_reach  =  reader.getFloat(18,4+y);
  table_input_code  =  reader.getInt(19,4+y);
  fac_type_enabled  =  reader.getInt(20,4+y);

}
