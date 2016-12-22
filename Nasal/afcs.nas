#F-20C autopilot logics

var ap_pitch_switch_prop = "/controls/avionics/AP-pitch-switch";
var ap_roll_switch_prop = "/controls/avionics/AP-roll-switch";

var ap_controls_jsb_roll_prop = "/fdm/jsbsim/fcs/ap-roll-engaged";
var ap_controls_jsb_pitch_prop = "/fdm/jsbsim/fcs/ap-pitch-engaged";

var ap_alt_lock_prop ="/autopilot/locks/altitude";
var ap_hdg_lock_prop ="/autopilot/locks/heading";
var ap_height_target_prop = "/autopilot/settings/target-agl-ft";
var ap_alt_target_prop = "/autopilot/settings/target-altitude-ft";
var ap_hdg_target_prop = "/autopilot/settings/heading-bug-deg";


var ap_pitch_alt = 2;
var ap_pitch_off = 1;
var ap_pitch_ralt = 0;

var ap_roll_hdg = 2;
var ap_roll_off = 1;
var ap_roll_nav = 0;

var ap_roll_switch_pos = 1;
var ap_pitch_switch_pos = 1;

var pitchSwitchUp = func ()
{
   ap_pitch_switch_pos = ap_pitch_switch_pos + 1;
   if (ap_pitch_switch_pos > ap_pitch_alt) ap_pitch_switch_pos = ap_pitch_alt;
   setprop (ap_pitch_switch_prop, ap_pitch_switch_pos);
  if (ap_pitch_switch_pos == ap_pitch_off) 
   {
    setprop (ap_alt_lock_prop, "");
    setprop (ap_controls_jsb_pitch_prop, false);
   }
  else 
  {
    setprop (ap_alt_lock_prop, "altitude-hold");
    setprop (ap_controls_jsb_pitch_prop, true);
    setprop (ap_alt_target_prop, measured_altitude);
  }   
}

var pitchSwitchDn = func ()
{
  ap_pitch_switch_pos = ap_pitch_switch_pos - 1;
  if (ap_pitch_switch_pos < ap_pitch_ralt) ap_pitch_switch_pos = ap_pitch_ralt;
  #switch off or ralt  
  setprop (ap_pitch_switch_prop, ap_pitch_switch_pos);
  if (ap_pitch_switch_pos == ap_pitch_off) 
   {
    setprop (ap_alt_lock_prop, "");
    setprop (ap_controls_jsb_pitch_prop, false);
   }
  else 
  {
    setprop (ap_alt_lock_prop, "agl-hold");
    setprop (ap_controls_jsb_pitch_prop, true);
    setprop (ap_height_target_prop, getprop (radio_altitude_prop));
  }
}

var rollSwitchUp = func ()
{
   ap_roll_switch_pos = ap_roll_switch_pos + 1;
   if (ap_roll_switch_pos > ap_roll_hdg) ap_roll_switch_pos = ap_roll_hdg;
   
  #switch off or heading selected. If no selected heading, disengage
  setprop (ap_roll_switch_prop, ap_roll_switch_pos);
  if (ap_roll_switch_pos == ap_roll_off) 
   {
    setprop (ap_hdg_lock_prop, "");
    setprop (ap_controls_jsb_roll_prop, false);
   }
  else 
  {
    setprop (ap_hdg_lock_prop, "dg-heading-hold");
    setprop (ap_controls_jsb_roll_prop, true);
    setprop (ap_hdg_target_prop, HSI.selected_heading_rad/deg_to_rad);
  }     
}

var rollSwitchDn = func ()
{
   ap_roll_switch_pos = ap_roll_switch_pos - 1;
   if (ap_roll_switch_pos < ap_roll_nav) ap_roll_switch_pos = ap_roll_nav;
   if (! INS.can_navigate_to_waypoint) ap_roll_switch_pos = ap_roll_off;
  #switch off or to nav. if no nav possible, disengage
  setprop (ap_roll_switch_prop, ap_roll_switch_pos);
  if (ap_roll_switch_pos == ap_roll_off) 
   {
    setprop (ap_hdg_lock_prop, "");
    setprop (ap_controls_jsb_roll_prop, false);
   }
  else 
  {
    setprop (ap_hdg_lock_prop, "true-heading-hold");
    setprop (ap_controls_jsb_roll_prop, true);
  }     
}

var updateAutopilot = func()
{
  #if roll or pitch exceeds certain values disengage
  
  #if waypoint exceeds last one disengage
  
}
