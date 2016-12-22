# Animation of the main gear skids


#----------------------------------------------------------------------------
# compute skid position for each main gear
#----------------------------------------------------------------------------

var straight_up_skid_roll = 38.0;
var flat_skid_pitch = -10;
var yaw_correction = 6;

var left_gear_compression = 0.0;
var right_gear_compression = 0.0;

var right_skid_roll = 0.0;
var left_skid_roll = 0.0;

var right_skid_pitch = 0.0;
var left_skid_pitch = 0.0;

var right_skid_yaw = 0.0;
var left_skid_yaw = 0.0;

var computeGearAnimation = func 
{
  
  left_gear_compression = getprop ("gear/gear[1]/compression-norm");
  right_gear_compression = getprop ("gear/gear[2]/compression-norm");
  
  if (left_gear_compression > 0.0)
  {
  
    left_skid_roll = straight_up_skid_roll - roll;
    if (left_gear_compression < 0.1)
       left_skid_pitch = (flat_skid_pitch - pitch) * (0.1 - left_gear_compression) / 0.1;
    else
       left_skid_pitch = flat_skid_pitch - pitch;
    left_skid_yaw =  yaw_correction;
  }
  else 
  {
    left_skid_roll = 0.0;
    left_skid_pitch = 0.0;
    left_skid_yaw = 0.0;
  }
  
  
  if (right_gear_compression > 0.0)
  {
  
    right_skid_roll = -straight_up_skid_roll - roll;
    if (right_gear_compression < 0.1)
       right_skid_pitch = (flat_skid_pitch - pitch) * (0.1 - right_gear_compression) / 0.1;
    else
       right_skid_pitch = flat_skid_pitch - pitch;
    right_skid_yaw = - yaw_correction;
  
  }
  else
  { 
   right_skid_roll = 0.0;
   right_skid_pitch = 0.0;
   right_skid_yaw = 0.0;
  }
  
  setprop ("gear/gear[1]/skid-pitch", left_skid_pitch);
  setprop ("gear/gear[1]/skid-roll", left_skid_roll);
  setprop ("gear/gear[1]/skid-yaw", left_skid_yaw); 
  setprop ("gear/gear[2]/skid-pitch", right_skid_pitch);
  setprop ("gear/gear[2]/skid-roll", right_skid_roll);
  setprop ("gear/gear[2]/skid-yaw", right_skid_yaw);   
  
}
