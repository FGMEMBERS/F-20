#F-20 speed brakes

var speed_brakes_prop = "/controls/flight/speedbrake";
var speed_brakes_switch_prop = "/f-20/speedbrakes-switch";
var speed_brakes_pos = 0.0;
var speed_brakes_target = 0.0;
var limit_45_deg = 1;
var limit_35_deg = 35/45;
var speed_brakes_limit = limit_45_deg;


var speed_brake_actuator = JSBactuator.new (0.0, #lower stroke position
											1.0, #higher stroke position
											0.5, # equivalent displacement of the actuator
											0.8, #min full stroke time
											3000, #nominal pressure
											"/fdm/jsbsim/fcs/speed-brake-rate",
											"/fdm/jsbsim/fcs/speedbrake-no-pressure",
											"/fdm/jsbsim/fcs/speedbrake-pos-norm");
speed_brake_actuator.connectToCircuit (utility_circuit);			

#-------------------------------------------------------------------------------
var extendSpeedBrakes = func 
{
  
   speed_brakes_target = speed_brakes_target + 0.1;
   if (speed_brakes_target > speed_brakes_limit) 
				speed_brakes_target = speed_brakes_limit;   
   setprop (speed_brakes_prop,speed_brakes_target);
   interpolate (speed_brakes_switch_prop, -1, 0.2);
   settimer (func {interpolate (speed_brakes_switch_prop, 0, 0.2);}, 0.2);
}

#-------------------------------------------------------------------------------
var retractSpeedBrakes = func
{

  speed_brakes_target = speed_brakes_target - 0.1;  
  if (speed_brakes_target < 0.0) speed_brakes_target = 0.0;
  setprop (speed_brakes_prop,speed_brakes_target);
   interpolate (speed_brakes_switch_prop, 1, 0.2);
   settimer (func {interpolate (speed_brakes_switch_prop, 0, 0.2);}, 0.2);
}

#-------------------------------------------------------------------------------
var updateSpeedBrakes = func (delta_t)
{
  #TODO : take into account hydraulics (blow back and rate)
  
  
}

#-------------------------------------------------------------------------------
var updateCenterStationSpeedBrakesLimit = func (center_station_is_present)
{  
   if (center_station_is_present) speed_brakes_limit = limit_35_deg;
   else speed_brakes_limit = limit_45_deg;
}

