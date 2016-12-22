###############################################################################
#TACAN

var tacan_channel_prop = "/instrumentation/tacan/frequencies/selected-channel[0]";
var tacan_XY_prop = "/instrumentation/tacan/frequencies/selected-channel[4]";
var tacan_receiving_prop = "/instrumentation/tacan/in-range";
var tacan_bearing_prop = "/instrumentation/tacan/indicated-bearing-true-deg";
var tacan_distance_prop = "/instrumentation/tacan/indicated-distance-nm";
var tacan_time_prop = "/instrumentation/tacan/indicated-time-min";

var x_channel = 0;
var y_channel = 1;

var tacan_x = "X";
var tacan_y = "Y";

var air_to_air_rec = 0;
var air_to_air_tr = 0;
var gnd_to_air_rec = 0;
var gnd_to_air_tr = 0;

var TACAN = {
              selected_course : 0,
              channel : 29,
              channel_kind : y_channel,
              letter : tacan_x,
			  mode : gnd_to_air_rec,			  
			  bearing : 0,
			  distance : 999.9,
			  TTG : "--:--",
			  elec_power : GenericLoad.new (AC_1, 20, 115),
			  is_receiving : false
            };

#-----------------------------------------------------------------------            
TACAN.setChannel = func (channel)
{
  me.channel = channel;
  setprop (tacan_channel_prop, channel);
}      

#-----------------------------------------------------------------------
TACAN.toggleChannelKind = func ()
{
  me.channel_kind = !me.channel_kind;
  if (me.channel_kind == x_channel) me.letter = tacan_x;
  else me.letter = tacan_y;
  setprop (tacan_XY_prop, me.letter);
}    

#-----------------------------------------------------------------------
TACAN.update = func (delta_t)
{
  me.is_receiving = getprop (tacan_receiving_prop);
  
  if (me.is_receiving)
  {
	  me.bearing = getprop (tacan_bearing_prop); 
	  me.distance = getprop (tacan_distance_prop); 
	  var TTG_minutes = getprop (tacan_time_prop);
	  if (TTG_minutes < 60)
	  {
	   var TTG_seconds = 60*(TTG_minutes -int(TTG_minutes));
	   if (TTG_seconds < 10) me.TTG = sprintf ("%i:0%i",TTG_minutes, TTG_seconds);
	   else me.TTG = sprintf ("%i:%i",TTG_minutes, TTG_seconds);
	  }
	  else 
	   me.TTG = "--:--";
  }
  else
  {
	  me.bearing = 0;
	  me.distance = 999.9;
  }
}

