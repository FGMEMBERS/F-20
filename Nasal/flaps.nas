#flap system
var le_angle_prop = "/fdm/jsbsim/fcs/le-flap-pos-deg";
var te_angle_prop = "/fdm/jsbsim/fcs/te-flap-pos-deg";

#throttle switch
var auto_flaps = 0;
var fixed_flaps = 1;
var forced_up = 2;
var throttle_switch_prop = "/controls/flight/flaps-switch";
var throttle_switch = auto_flaps;

# main lever
var emergency_up = 2;
var thumb_switch = 1;
var full = 0;
var flaps_lever_prop = "/controls/flight/flaps-lever";
var flaps_lever = thumb_switch;

# flap indicator
var ind_off = 0;
var ind_full = 1;
var ind_auto = 2;
var ind_fxd = 3;
var ind_up = 4;
var flaps_indicator_prop = "/controls/flight/flaps-indicator";
var flaps_indicator = ind_off;

#current_position 
var flaps_up = 0;
var flaps_1_4 = 1;
var flaps_1_2 = 2;
var flaps_3_4 = 3;
var flaps_down = 4;
var current_flaps = flaps_up;

var le_flap_positions = [0,0,12,18,24];
var te_flap_positions = [0,8,8,16,20];
var previous_alpha = 0.0;
var alpha_increasing = previous_alpha < Alpha;
var previous_altitude = 0.0;
var altitude_increasing = previous_altitude < altitude_ft; 

var leading_edge_target = 0.0;
var trailing_edge_target = 0.0;
var current_leading_edge_pos = 0.0;
var current_trailing_edge_pos = 0.0;
var leading_edge_rate = 10; #degrees per second
var trailing_edge_rate = 10; #degrees per second
var max_flap_rate = 10;

var left_actuator = GenericLoad.new  (AC_1,
										5000,#watts
										115);#volts
										
var right_actuator = GenericLoad.new  (AC_2,
										5000, #watts
										115); #volts
										
var flaps_controller = GenericLoad.new  (DC_Essential,
										  60, #watts
										  28);#volts 																		

#-----------------------------------------------------------------------
var flapsSwitchBackward = func 
{
   throttle_switch = throttle_switch - 1;
   if (throttle_switch < auto_flaps) throttle_switch = auto_flaps;
   setprop(throttle_switch_prop, throttle_switch);
}

#-----------------------------------------------------------------------
var flapsSwitchForward = func 
{
   throttle_switch = throttle_switch + 1;
   if (throttle_switch > forced_up) throttle_switch = forced_up;
   setprop (throttle_switch_prop, throttle_switch);
}

#-----------------------------------------------------------------------
var flapsLeverUp = func 
{
   flaps_lever = flaps_lever - 1;
   if (flaps_lever < full) flaps_lever = full;
   setprop (flaps_lever_prop, flaps_lever);
}

#-----------------------------------------------------------------------
var flapsLeverDown = func 
{
   flaps_lever = flaps_lever + 1;
   if (flaps_lever > emergency_up) flaps_lever = emergency_up;
   setprop (flaps_lever_prop, flaps_lever);
}

#-----------------------------------------------------------------------
var updateFlaps = func 
{
  alpha_increasing = previous_alpha < Alpha;
  altitude_increasing = previous_altitude < altitude_ft; 
 
   #--------------------------------------------------------------------
   # Control
    
  #automatic schedules
  if (flaps_lever == thumb_switch) 
  {
   if (flaps_controller.fed) 
      {
		if (throttle_switch == auto_flaps)
		{
		  if (gear_command == gear_down) 
			current_flaps = flaps_down;
		  else
		   {
			if (alpha_increasing)
			{
			 if (IAS > 550 or mach > 0.95) current_flaps = flaps_up;                                            
			 else if (IAS > 330)
			 {
			   if (Alpha > 4.2) current_flaps = flaps_1_2;
			   else if (current_flaps != flaps_1_2) current_flaps = flaps_up;
			 }
			 else if (IAS > 200)
			 {
			   if (Alpha > 8.5) current_flaps = flaps_3_4;
			   else if (Alpha > 4.2 and current_flaps != flaps_3_4) 
				 current_flaps = flaps_1_2;
			   else if (current_flaps != flaps_1_2) current_flaps = flaps_up;
			 }
			 else
			 {
			   if (Alpha > 8.5) current_flaps = flaps_down;
			   else if (Alpha > 4.2 and current_flaps != flaps_down) 
				   current_flaps = flaps_3_4;
			   else if (current_flaps != flaps_3_4) current_flaps = flaps_up;
			 }
			}
			else #Alpha decreasing
			{
			 if (IAS > 550 or mach > 0.95) current_flaps = flaps_up;                                            
			 else if (IAS > 330)
			 {
			   if (Alpha >1.2 and current_flaps != flaps_up) 
				   current_flaps = flaps_1_2;
			   else current_flaps = flaps_up;
			 }
			 else if (IAS > 200)
			 {
			   if (Alpha > 6.9 and current_flaps != flaps_1_2) 
					current_flaps = flaps_3_4;
			   else if (Alpha > 1.2 and current_flaps != flaps_up) 
					current_flaps = flaps_1_2;
			   else current_flaps = flaps_up;
			 }
			 else
			 {
			   if (Alpha > 6.9 and current_flaps != flaps_3_4) 
				  current_flaps = flaps_down;
			   else if (Alpha > 1.2 and current_flaps != flaps_up) 
				  current_flaps = flaps_3_4;
			   else current_flaps = flaps_up;
			 }
			}     
		  } #end gear check
       }#end controller is fed
    }#end auto_flaps
    
    else if (throttle_switch == fixed_flaps)
    {
        if (altitude_increasing)
        {
         if (IAS > 550 or mach > 0.95) current_flaps = flaps_up;                                            
         else
         {
           if (altitude_ft > 25000) current_flaps = flaps_1_2;
           else current_flaps = flaps_1_4;           
         }
        }
        else #altitude decreasing
        {
         if (IAS > 550 or mach > 0.95) current_flaps = flaps_up; 
         else
         {
           if (altitude_ft > 23000) current_flaps = flaps_1_2;
           else current_flaps = flaps_1_4;    
         }
        }          
    }#end fixed_flaps
    else #assume up
    {
     current_flaps = flaps_up;
    }#end_up
    
  }
  else if (flaps_lever == emergency_up)
  {
    current_flaps = flaps_up;
  }
  else #assume full
  {
   current_flaps = flaps_down; 
  }
  
   #--------------------------------------------------------------------
   # Motion
  
   leading_edge_target = le_flap_positions[current_flaps];
   trailing_edge_target = te_flap_positions[current_flaps];
      
   if (left_actuator.fed and right_actuator.fed) 
   {
     leading_edge_rate = max_flap_rate;
     trailing_edge_rate = max_flap_rate;
   }   
   else if (left_actuator.fed or right_actuator.fed) 
   {
     leading_edge_rate = max_flap_rate / 2;
     trailing_edge_rate = max_flap_rate / 2;
   }
   else 
   {
     leading_edge_rate = 0;
     trailing_edge_rate = 0;   
   }
 
   if (current_leading_edge_pos < leading_edge_target)
   {
     current_leading_edge_pos = current_leading_edge_pos + leading_edge_rate * deltaT;
     if (current_leading_edge_pos > leading_edge_target)  current_leading_edge_pos = leading_edge_target;
   }
   else
   {
     current_leading_edge_pos = current_leading_edge_pos - leading_edge_rate * deltaT;
     if (current_leading_edge_pos < leading_edge_target)  current_leading_edge_pos = leading_edge_target;   
   }
   
   if (current_trailing_edge_pos < trailing_edge_target)
   {
     left_actuator.switchOn();
     right_actuator.switchOn();   
     current_trailing_edge_pos = current_trailing_edge_pos + trailing_edge_rate * deltaT;
     if (current_trailing_edge_pos > trailing_edge_target)  current_trailing_edge_pos = trailing_edge_target;
   }
   else if (current_trailing_edge_pos > trailing_edge_target)
   {
     left_actuator.switchOn();
     right_actuator.switchOn();
     current_trailing_edge_pos = current_trailing_edge_pos - trailing_edge_rate * deltaT;
     if (current_trailing_edge_pos < trailing_edge_target)  current_trailing_edge_pos = trailing_edge_target;   
   }
   else 
   {
     left_actuator.switchOff();
     right_actuator.switchOff();   
   }
      
   setprop (le_angle_prop, current_leading_edge_pos);
   setprop (te_angle_prop, current_trailing_edge_pos);  
   
   #--------------------------------------------------------------------
   # Display
   
   if (!flaps_controller.fed) setprop (flaps_indicator_prop,ind_off);
   else 
   {   
	   if (flaps_lever == thumb_switch)
	   {
		if (throttle_switch == auto_flaps)
		{
		  if (gear_command == gear_down) 
			setprop (flaps_indicator_prop, ind_full);
		  else
			setprop (flaps_indicator_prop, ind_auto);        
		}
		else if (throttle_switch == forced_up)    
		  setprop (flaps_indicator_prop, ind_up);
		else if (throttle_switch == fixed_flaps)
		  setprop (flaps_indicator_prop, ind_fxd);    
	   } 
	   else if (flaps_lever == emergency_up)
		setprop (flaps_indicator_prop, ind_up);
	   else if (flaps_lever == full)
		setprop (flaps_indicator_prop, ind_full);
   } 
   
   previous_alpha = Alpha;
   previous_altitude = altitude_ft;
}
