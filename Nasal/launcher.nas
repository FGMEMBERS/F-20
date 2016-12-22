#-------------------------------------------------------------------------------
#class for jettisoning payloads mounted on rails 

var force_root="/f-20/stores/%s/forces/force-lb";
var azimuth_root = "/f-20/stores/%s/forces/force-azimuth-deg";
var elevation_root = "/f-20/stores/%s/forces/force-elevation-deg";
var burning_root = "/f-20/stores/%s/burning";

var Launcher = {previous : nil,
				 next : nil,
				 remaining_time : 0,
				 burning_prop : nil,
				 force_intensity_prop : nil,
				 force_azimuth_prop : nil,
				 force_elevation_prop : nil,};

var launcher_first = nil;
var launcher_last = nil;


#-----------------------------------------------------------------------
Launcher.destroy = func ()
{
  setprop (me.force_intensity_prop, 0);
  setprop (me.force_azimuth_prop, 0);
  setprop (me.force_elevation_prop, 0);
  setprop (me.burning_prop, false);
  me.remaining_time = 0;
  
  if (me.previous != nil)  me.previous.next = me.next;
  else launcher_first = me.next;
  if (me.next != nil) me.next.previous = me.next;
  else launcher_last = me.previous;
}

#-----------------------------------------------------------------------
Launcher.new = func (ident, burn_time, thrust)
{
  var created_launcher = {parents:[Launcher]};
  
  #double chained list stuff
  if (launcher_first == nil)
   {
     launcher_first = created_launcher;
     launcher_last = created_launcher;     
   }
  else
  {
    created_launcher.previous = launcher_last;
  }
  
  created_launcher.remaining_time = burn_time;
  created_launcher.force_intensity_prop = sprintf (force_root, ident);
  created_launcher.force_azimuth_prop = sprintf (azimuth_root, ident);
  created_launcher.force_elevation_prop = sprintf (elevation_root, ident);
  created_launcher.burning_prop = sprintf (burning_root, ident);
  
  setprop (created_launcher.force_intensity_prop, thrust);
  setprop (created_launcher.force_azimuth_prop, heading);
  setprop (created_launcher.force_elevation_prop, 10);
  setprop (created_launcher.burning_prop, true);
  
  settimer (func{created_launcher.destroy();},burn_time);
  
  return created_launcher;
}



