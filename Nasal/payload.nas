################################################################################
#Payload switcher

#note : this code does not handle multiple ejection racks nor intends to.

# Uses :
# submodel-helper.nas
# stores.nas

var drag_index_prop = "/fdm/jsbsim/aero/drag-index";
var drag_index = 0;

# Load codes

var Empty = 0;
var Fuel_tank = 1;
var smoke_generator = 2;
var Sniper_pod = 3;
var ALQ_131 = 4;
var AIM_120A = 5;
var AIM_9L = 6;
var AIM_7M = 7;
var number_of_load_codes = 8;

var LAU_127 = 1;
var LAU_115 = 2;

var is_rail_adapter = [false, true, false];

var left_tip = 0;
var outer_left = 1;
var inner_left = 2;
var center = 3;
var inner_right = 4;
var outer_right = 5;
var right_tip = 6;

var number_of_stations = right_tip + 1;

var fuel_tank_offset = 2; #fuel tanks can only be on stations 2,3,4

var is_jettisonable = [];
setsize (is_jettisonable, number_of_load_codes);
is_jettisonable [Empty] = false;
is_jettisonable [Fuel_tank] = true;
is_jettisonable [smoke_generator] = true;
is_jettisonable [Sniper_pod] = true;
is_jettisonable [ALQ_131] = true;
is_jettisonable [AIM_120A] = true;
is_jettisonable [AIM_9L] = true;
is_jettisonable [AIM_7M] = true;

var adapters = [];
setsize (adapters, 5);

var adapter_needed = [];
setsize (adapter_needed, number_of_load_codes);
adapter_needed [Empty] = Empty;
adapter_needed [Fuel_tank] = Empty;
adapter_needed [smoke_generator] = Empty;
adapter_needed [Sniper_pod] = Empty;
adapter_needed [ALQ_131] = Empty;
adapter_needed [AIM_120A] = LAU_127;
adapter_needed [AIM_9L] = LAU_127;
adapter_needed [AIM_7M] = LAU_115;

var adapter_names = [{type : LAU_127,
                      names_per_station : ["",
                                           "LAU-127-ol",
                                           "LAU-127-il",
                                           "",
                                           "LAU-127-ir",
                                           "LAU-127-or",
                                           ""]},
                     {type : LAU_115,
                      names_per_station : ["",
                                           "LAU-115-ol",
                                           "LAU-115-il",
                                           "",
                                           "LAU-115-ir",
                                           "LAU-115-or",
                                           ""]}];
                                           
var is_adapter_station = [false, true, true, false, true, true, false];                                           

var adapter_physics = [{weight : 0, drag_index : 0},
                       {weight : 87, drag_index : 1},#LAU_127
                       {weight : 120, drag_index : 3}];#LAU_115

#properties
var drop_tank_qty_props = ["",
                            "",
                            "/consumables/fuel/tank[3]/level-lbs",
                            "/consumables/fuel/tank[2]/level-lbs",
                            "/consumables/fuel/tank[4]/level-lbs",
                            "",
                            ""];
                            
var needs_braces_props = ["",
						   "/f-20/stores/outer-left-needs-braces",
						   "/f-20/stores/inner-left-needs-braces",
						   "",
						   "/f-20/stores/inner-right-needs-braces",
						   "/f-20/stores/outer-right-needs-braces",
						   ""];

var full_tank_quantities = [0, 0, 1995.0, 2085.0, 1995.0, 0, 0];


var weight_props = ["/fdm/jsbsim/inertia/pointmass-weight-lbs[0]",
			         "/fdm/jsbsim/inertia/pointmass-weight-lbs[1]",
			         "/fdm/jsbsim/inertia/pointmass-weight-lbs[2]",
			         "/fdm/jsbsim/inertia/pointmass-weight-lbs[3]",
			         "/fdm/jsbsim/inertia/pointmass-weight-lbs[4]",
			         "/fdm/jsbsim/inertia/pointmass-weight-lbs[5]",
			         "/fdm/jsbsim/inertia/pointmass-weight-lbs[6]"];

#state variables


var drag_indices = [0,  #empty
					 18, #Fuel Tank
					 1,  #Smoke generator
					 15, #Sniper pod
					 20, #ALQ-131
					 12, #AIM-120
					 9,  #AIM-9L
					 14];#AIM-7M

var pylon_drag_index = 14;

var payload_weights = [ #pounds
					   0,  #empty
					   0, #Fuel Tank Managed by capacity
					   200,  #Smoke generator "smokewinder"
					   446, #Sniper pod
					   600, #ALQ-131
					   335,  #AIM-120
					   191,   #AIM-9L
					   510  #AIM-7
                      ];

var outboard_pylon_weight = 128; #pounds
var inboard_pylon_weight = 122; #pounds
var centerline_pylon_weight = 170; #pounds

var current_payload = [Empty, Empty, Empty, Empty, Empty, Empty, Empty];
var previous_payload = [Empty, Empty, Empty, Empty, Empty, Empty, Empty];
var adapter_stations = [1,2,4,5];

var left_smoking = false;
var right_smoking = false;

#-------------------------------------------------------------------------------
var removeSmoke = func (station)
{
  if (station == left_tip) 
  {
   setprop ("/f-20/stores/left-smoke-installed", false);
   left_smoking = false;
   setprop ("/f-20/stores/smoke/smoke-l", left_smoking);
  }
  else 
  {
   setprop ("/f-20/stores/right-smoke-installed", false);
   right_smoking = false;
   setprop ("/f-20/stores/smoke/smoke-r", right_smoking);
  }
}

#-------------------------------------------------------------------------------
var mountSmoke = func (station)
{
  if (station == left_tip) setprop ("/f-20/stores/left-smoke-installed", true);
  else setprop ("/f-20/stores/right-smoke-installed", true);  
}

#-------------------------------------------------------------------------------
var get_adapter_name = func (station, adapter_type_searched)
{
 
   foreach (var adapter_type; adapter_names)
   {
     if (adapter_type.type == adapter_type_searched)
      return adapter_type.names_per_station[station];      
   }
   
}

#-------------------------------------------------------------------------------
var adapterNeedsBraces = func (adapter_type)
{
 
 if (adapter_type == LAU_127) return false;
 return true;
 
}

#-------------------------------------------------------------------------------
var setPayload = func (station_name, payload_name)
{

  current_payload [station_name] = payload_name;

}

#-------------------------------------------------------------------------------
# Note : an assumption is that this function can only be called on the ground
# if you want to change the payload in flight you might as well fiddle with the
# adequate properties

var executePayloadChange = func ()
{
  var station = 0;
  var adapter = Empty;

  drag_index = 0;

  #start by putting the actual payload
  forindex (station; current_payload)
  {

    drag_index = drag_index + drag_indices[current_payload[station]];

    setprop (weight_props [station],
              payload_weights [current_payload[station]]);

    if (current_payload[station] == Fuel_tank)
    {
      if (previous_payload [station] != Fuel_tank) #then fill the tank
       {
         setprop (drop_tank_qty_props [station],full_tank_quantities [station]);
       }
    }
    else #empty the tank and remove it
    {
      setprop (drop_tank_qty_props [station], 0);
    }
  }

  # Place pylons if needed, always symmetrical

  #outer
    if ((current_payload [outer_left] != Empty)
        or
        (current_payload [outer_right] != Empty))
      {
        attachSubmodel ("outer_pylons");
        drag_index = drag_index + 2*pylon_drag_index;
        setprop (weight_props [outer_left],
				  getprop (weight_props[outer_left]) + outboard_pylon_weight);
        setprop (weight_props [outer_right],
				  getprop (weight_props[outer_right]) + outboard_pylon_weight);
      }
      else
      {
        removeSubmodel ("outer_pylons");
      }

   #inner
    if ((current_payload [inner_left] != Empty)
        or
        (current_payload [inner_right] != Empty))
      {
        attachSubmodel ("inner_pylons");
        drag_index = drag_index + 2*pylon_drag_index;
        setprop (weight_props [inner_left],
				  getprop (weight_props[inner_left]) + inboard_pylon_weight);
        setprop (weight_props [inner_right],
				  getprop (weight_props[inner_right]) + inboard_pylon_weight);
      }
      else
      {
        removeSubmodel ("inner_pylons");
      }

   #center
    if (current_payload [center] != Empty)
      {
        attachSubmodel ("center_pylon");
        drag_index = drag_index + pylon_drag_index;
        setprop (weight_props [center],
				  getprop (weight_props[center]) + centerline_pylon_weight);
      }
      else
      {
        removeSubmodel ("center_pylon");
      }

    #handle the launcher rails
    foreach (station; adapter_stations)
    {     
     adapter = adapter_needed [previous_payload[station]];
     if (adapter != Empty) removeSubmodel (get_adapter_name (station, adapter));
     adapter = adapter_needed [current_payload[station]];
     setprop (needs_braces_props[station], adapterNeedsBraces(adapter)); 
       
     if (adapter != Empty)
       {
         attachSubmodel (get_adapter_name (station, adapter));
         drag_index = drag_index + adapter_physics [adapter].drag_index;
         setprop (weight_props [station],
				  getprop (weight_props[station]) 
				  + adapter_physics [adapter].weight);			   
       }
      else
       {
         forindex (var i; adapter_names)
         removeSubmodel (adapter_names[i].names_per_station [station]);
       }
    }

    #handle center station speed brake limiter
    if (current_payload[center] != Empty)
				updateCenterStationSpeedBrakesLimit (true);
    else
				updateCenterStationSpeedBrakesLimit (false);

	#house keeping
	 forindex (station; current_payload)
	 {
	  if (previous_payload[station] == smoke_generator) removeSmoke (station);
	  else removeSubmodel (getIdent (station, previous_payload));		 
	   
	  if (current_payload[station] != smoke_generator)
	                        attachSubmodel(getIdent (station, current_payload));
	  else mountSmoke (station);
	  
	  previous_payload[station] = current_payload[station];
	  
	 }
	 
    setprop (drag_index_prop, drag_index);
}

#-------------------------------------------------------------------------------
var toggleSelectiveJettison = func (station_number)
{
  if (selective_jettison_station_enabled [station_number])
                selective_jettison_station_enabled [station_number] = false;
  else
			    selective_jettison_station_enabled [station_number] = true;
}
