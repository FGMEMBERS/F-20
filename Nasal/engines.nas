################################################################################
# Propulsion system including starters

#Properties
#var EngineBurner = props.globals.initNode("engines/engine[0]/augmentation", 0, "DOUBLE");
var GearPos = props.globals.getNode("gear/gear[0]/position-norm", 1);

var glow_factor_burner  = props.globals.getNode("/f-20/glow-factor-burner", 1);
var glow_factor_flame  = props.globals.getNode("/f-20/glow-factor-flame", 1);

var Nozzle = props.globals.getNode ("/f-20/nozzle-pos-norm");
var prop_throttle = "/controls/engines/engine/throttle";

var flame_number = props.globals.getNode ("/f-20/flame-number");

#variables 
var Throttle = 0.0;
var eng_burner = 0;

# Constants
var ThrottleIdle = 0.02;
var Burner_throttle_span = 0.15;
var ThrottleBurner = 1 - Burner_throttle_span;

################################################################################
# Jet Fuel Starter
var JFS_ready_prop = "/f-20/JFS/ready";
var JFS_started_prop = "/f-20/JFS/started";
var JFS_intake_position_prop = "/f-20/JFS/intake-pos";
var JFS_rpm_prop = "/f-20/JFS/rpm";
var JFS_rpm = 0.0;
var JFS_rpm_nominal = 6000;
var JFS_intake_openning_time = 0.5; #seconds
var JFS_intake_position = 0.0; 
var JFS_started = false;
var JFS_ready = false;
var JFS_spinup_time = 5.0; #seconds

#----------------------------------------------------------------------------
var JFSupdate = func {settimer (JFSspin, 0)}

var JFSspin = func 
{
  if (JFS_started)
  {
    #spin up
    JFS_intake_position = JFS_intake_position + 1.0 * deltaT/JFS_intake_openning_time;
    if (JFS_intake_position > 1.0) JFS_intake_position = 1.0;
    setprop (JFS_intake_position_prop, JFS_intake_position);
    JFS_rpm = JFS_rpm + JFS_rpm_nominal * deltaT / JFS_spinup_time;
    if (JFS_rpm >= JFS_rpm_nominal) 
    {
      JFS_rpm = JFS_rpm_nominal;
      JFS_ready = true;
      setprop (JFS_ready_prop, JFS_ready);      
    }
    else JFSupdate();
    setprop (JFS_rpm_prop, JFS_rpm);         
  }
  else
  {
    #spin down
    if (JFS_ready)
    {
     JFS_ready = false;
     setprop (JFS_ready_prop, JFS_ready);       
    }
    JFS_intake_position = JFS_intake_position - 1.0 * deltaT/JFS_intake_openning_time;
    if (JFS_intake_position < 0.0) JFS_intake_position = 0.0;
    setprop (JFS_intake_position_prop, JFS_intake_position);
    JFS_rpm = JFS_rpm - JFS_rpm_nominal * deltaT / JFS_spinup_time;
    if (JFS_rpm <= 0.0) 
    {
      JFS_rpm = 0.0;  
    }
    else JFSupdate();
    setprop (JFS_rpm_prop, JFS_rpm);     
  }

}

#----------------------------------------------------------------------------
var toggleJFS = func
{
  JFS_started = ! JFS_started;
  JFSupdate();
  setprop (JFS_started_prop, JFS_started);
}

#----------------------------------------------------------------------------
var JFStimeout = func
{
  if (JFS_started) 
  {
   JFS_started = false;
   JFSupdate();
   setprop (JFS_started_prop, JFS_started);
  }
}

################################################################################
# Hydrazine cartridge starter

var cartridge_discharging = false;
var cartridge_capacity = 120; #seconds
var cartridge_discharge_prop = "/f-20/cartridge/discharging";
var ground_override = true;
var cartridge_button_depress_prop = "/f-20/cartridge/button";
var cartridge_override_depress_prop = "/f-20/cartridge/override";

if (!is_C_variant)
{
  var cartridge_controller = GenericLoad.new (DC_Essential,1,24);
}

#----------------------------------------------------------------------------
var pushCartridge = func
{
  interpolate (cartridge_button_depress_prop, 1, 0.2);
  settimer (func{interpolate (cartridge_button_depress_prop, 0, 0.2);},0.2);
  if (!start_cart_blowing and cartridge_controller.fed)
  {
       setprop (cartridge_discharge_prop, 1);
       cartridge_discharging = true;
       engine_cranking = true;
       setprop (starter_prop, 1);       
  }
}

#----------------------------------------------------------------------------
var overrideCartridge = func
{
  ground_override = true;
  interpolate (cartridge_override_depress_prop, 1, 0.2);
  settimer (func{interpolate (cartridge_override_depress_prop, 0, 0.2);},0.2);
}

################################################################################
# Engine proper

var display_throttle_prop = "/controls/engines/engine/display-throttle";
var starter_prop = "/controls/engines/engine/starter";
var cutoff_prop = "/controls/engines/engine/cutoff";
var inside_stop_detent = false;
var start_sequence_in_progress = false;

#----------------------------------------------------------------------------
var engineIdleToggle = func
{
  if (Throttle < 0.05)
  {
   if (inside_stop_detent) 
   {    
     interpolate (display_throttle_prop, Throttle,0.5);
     settimer (func {inside_stop_detent = false;},0.5);  
     setprop (cutoff_prop, 0);
   }   
   else
   {
    inside_stop_detent = true;
    interpolate (display_throttle_prop, -0.2, 0.5);
    setprop (cutoff_prop, 1);
   }    
  }  
}

#----------------------------------------------------------------------------
var engine_crank_lever_prop = "/controls/engines/engine/crank-lever-on";
var engine_crank_lever_up = false;
var engine_cranking = false;

#this control only exists in the F-20C
var engineCrankToggle = func
{
  if (engine_cranking)
  {
    setprop (engine_crank_lever_prop, 0);
    setprop (starter_prop, 0);
    setprop (start_control_valve_prop, 0);
    engine_cranking = false;
    engine_crank_lever_up = false;
  }
  else
  {
	  if (JFS_ready or start_cart_blowing)
	  { 
		 setprop (starter_prop, 1);
		 setprop (engine_crank_lever_prop, 1);
		 engine_cranking = true;
		 engine_crank_lever_up = true;
	  }  
	  else 
	  {
		setprop (engine_crank_lever_prop, 1);		
		settimer (func { setprop(engine_crank_lever_prop,0);}, 0.5);
		engine_crank_lever_up = false;
		setprop (start_control_valve_prop, 0);
	  }
   }
}

#----------------------------------------------------------------------------
var fuelCutoff = func
{
  
}

#----------------------------------------------------------------------------
#cycle the flame texture
#----------------------------------------------------------------------------
var current_flame_number = 0;

var updateFlame = func 
{    
   current_flame_number = current_flame_number + 1;        
   if (current_flame_number > 3) current_flame_number = 0;
   flame_number.setValue (current_flame_number);  
 }

#----------------------------------------------------------------------------
#compute glow factors for nozzles and afterburners
#----------------------------------------------------------------------------

var glow_factor_burner_target = 0.0;
var current_glow_factor_burner = 0.0;
var burner_setting = 0.0;
var max_glow_factor_burner = 0.5;
var max_glow_factor_flame = 0.8;
var burner_speed = 0.2;
    
var updateGlow = func
 {
      if (eng_burner) burner_setting = (Throttle - ThrottleBurner) / Burner_throttle_span;
      else burner_setting = 0.0;
      
      if (!engine_running) burner_setting = 0.0;
      
      glow_factor_burner_target =  burner_setting * max_glow_factor_flame;
      glow_factor_flame.setValue (burner_setting * max_glow_factor_flame);
   # Delayed animation
	if (current_glow_factor_burner > glow_factor_burner_target) {
		current_glow_factor_burner -= burner_speed * deltaT;
		if (current_glow_factor_burner < glow_factor_burner_target) {
			current_glow_factor_burner = glow_factor_burner_target;
		}
	} elsif (current_glow_factor_burner < glow_factor_burner_target) {
		current_glow_factor_burner += burner_speed * deltaT;
		if (current_glow_factor_burner > glow_factor_burner_target) {
			current_glow_factor_burner = glow_factor_burner_target;
		}
	}
    
    glow_factor_burner.setValue (current_glow_factor_burner);           
    
  }

#----------------------------------------------------------------------------
# Nozzle opening
#----------------------------------------------------------------------------
var nozzle = 0.0;
var NozzleTarget = 0.0;

# Constant
NozzleSpeed = 1.0;

var updateNozzle = func {

	var maxSeaLevelIdlenozzle = 0;
	var idleNozzleTarget = 0;

	if (mach < 0.45) {
		maxSeaLevelIdlenozzle = 1;
	} elsif (mach >= 0.45 and mach < 0.8) {
		maxSeaLevelIdlenozzle = (0.8 - mach) / 0.35;
	}

	if (Throttle < ThrottleIdle) {
		var gear_pos = GearPos.getValue();
		if (gear_pos == 1.0) {
		#gear down
			if (WOW) {
				idleNozzleTarget = 1;
			} 
            else {
				idleNozzleTarget = 0.26;
			}
		} 
        else {
		# gear not down
			if (altitude_ft <= 30000) {
				idleNozzleTarget = 1 + (0.15 - maxSeaLevelIdlenozzle) * altitude_ft / 30000.0;
			} else {
				idleNozzleTarget = 0.15;
			}
		}
		NozzleTarget = idleNozzleTarget;
	} 
    else 
    {
	# throttle idle
		NozzleTarget = eng_burner;        
	}
	
   if (!engine_running) NozzleTarget = 1.0;
   
   # Delayed animation
	if (nozzle > NozzleTarget) {
		nozzle -= NozzleSpeed * deltaT;
		if (nozzle < NozzleTarget) {
			nozzle = NozzleTarget;
		}
	} elsif (nozzle < NozzleTarget) {
		nozzle += NozzleSpeed * deltaT;
		if (nozzle > NozzleTarget) {
			nozzle = NozzleTarget;
		}
	}
    
    Nozzle.setValue (nozzle);   
}

#----------------------------------------------------------------------------
# Main update function
#----------------------------------------------------------------------------
var engine_running = true;

var updateEngine = func (delta_t)
{
 N2 = getprop("engines/engine/n2");
 Throttle = getprop(prop_throttle);
 engine_running = getprop ("/engines/engine/running");
 
 if (engine_cranking)
 {
      #first check if the indicator is powered
      if (caution_light_panel.intensity > 0) 
        setprop (start_control_valve_prop, 1);
      else 
        setprop (start_control_valve_prop, 0);
         
      if ((!JFS_ready 
           and !start_cart_blowing 
           and !cartridge_discharging) 
           or engine_running)
     {
       engine_cranking = false;
       setprop (starter_prop, 0);
       #shut the start cart air supply
       start_cart_blowing = true;
       airSupplyButtonCallback();  
       setprop (start_control_valve_prop, 0);     
       if (is_C_variant) 
        { 
         setprop (engine_crank_lever_prop, 0); 
         engine_crank_lever_up = false;
         settimer (JFStimeout, 600.0);
        }
     }
     
     if (cartridge_discharging)
     {
      cartridge_capacity = cartridge_capacity - delta_t;
      if (cartridge_capacity < 0)  cartridge_discharging = false;
     }
 }
 
 if (!inside_stop_detent) setprop (display_throttle_prop, Throttle);
 eng_burner = (Throttle > ThrottleBurner) 
			  and (getprop ("engines/engine[0]/n1")>90) 
			  and engine_running;
 updateFlame();
 updateNozzle ();
 updateGlow ();
 
 #Accessories
 flight_control_pump.setRPM (N2);
 utility_pump.setRPM (N2); 
 main_gen.setRPM (N2);
 backup_gen.setRPM (N2);
 
}

