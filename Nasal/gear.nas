
var gear_commanded_down_prop ="/controls/gear/gear-down";
var gear_handle_position_prop = "/controls/gear/gear-handle-pos";
var nose_gear_on_prop = "/gear/lights/nose-gear-on";
var nose_gear_intensity_prop = "/gear/lights/nose-gear-intensity";
var left_gear_on_prop = "/gear/lights/left-gear-on";
var left_gear_intensity_prop = "/gear/lights/left-gear-intensity";
var right_gear_on_prop = "/gear/lights/right-gear-on";
var right_gear_intensity_prop = "/gear/lights/right-gear-intensity";
var handle_transit_time = 1.0; #seconds

var hiked_switch_prop = "/gear/hiking/switch";
var hiked_prop = "/gear/hiking/hiked";
var hiked = false;
var hiked_switch = false;

var hiking_actuator = Actuator.new (0.0, #lower stroke position
									1.0, #higher stroke position
									0.3, # equivalent displacement of the actuator
									2.0, #min full stroke time
									3000, #nominal pressure
								 	hiked_prop);
hiking_actuator.connectToCircuit (utility_circuit);


# Landing gear handle animation 
# -----------------------------
var handle_down = 1;
var handle_up = 0;
var handle_command = handle_down;
var handle_position = handle_down;
var gear_transit = handle_down;


var right_gear_light = Light.new (DC_Essential,
								  right_gear_intensity_prop,
                                  0.5,
                                  24);

var left_gear_light = Light.new (DC_Essential,
								  left_gear_intensity_prop,
                                  0.5,
                                  24);     
                                  
var nose_gear_light = Light.new (DC_Essential,
								  nose_gear_intensity_prop,
                                  0.5,
                                  24);                                                                 

#*******************************************************************************
var toggleGear = func
{
   if (!WOW)
   {
     if (handle_command == handle_down)
      {
        handle_command = handle_up;
        HUD_page.hideLandingSymbology();
      }
      else
      {
        handle_command = handle_down;
        HUD_page.showLandingSymbology();
      }
      setprop (gear_commanded_down_prop,handle_command);
      interpolate (gear_handle_position_prop, handle_command, handle_transit_time);
   }
   gear_command = handle_command;
}



#*******************************************************************************
var updateGearIndicators = func (delta_t)
{
   if (getprop ("/gear/gear/position-norm") > 0.98) nose_gear_light.switchOn();
   else nose_gear_light.switchOff();
   if (nose_gear_light.intensity > 0) setprop (nose_gear_on_prop, 1);
   else setprop (nose_gear_on_prop, 0);
   
   if (getprop ("/gear/gear[1]/position-norm") > 0.98) left_gear_light.switchOn();
   else left_gear_light.switchOff();
   if (left_gear_light.intensity > 0) setprop (left_gear_on_prop, 1);
   else setprop (left_gear_on_prop, 0);   
   
   if (getprop ("/gear/gear[2]/position-norm") > 0.98) right_gear_light.switchOn();
   else right_gear_light.switchOff();
   if (right_gear_light.intensity > 0) setprop (right_gear_on_prop, 1);
   else setprop (right_gear_on_prop, 0);   
   
   if (hiked)
   {
     if (!WOW) 
     { 
      hiked = false;
      hiking_actuator.setTarget (hiked);
     }
   }  
}


#*******************************************************************************
var toggleHike = func
{
  hiked_switch = !hiked_switch;
  setprop (hiked_switch_prop, hiked_switch);
  if (WOW and hiked_switch) hiked = true;
  else  hiked = false;
  hiking_actuator.setTarget (hiked);
  
}
