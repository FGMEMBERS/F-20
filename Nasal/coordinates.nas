# coordinates.nas

# The heading towards Edwards is computed as follows:
# Latitude and longitude coordinates are converted locally to a X-Y grid centered
# on Edwards. The heading is computed in this coordinate frame, then the heading is
# to magnetic heading using a magvar.


var AC_position_x_NM = 0.0;
var AC_position_y_NM = 0.0;

var PI = 3.1416;

var rad_to_deg = 180.0 / PI;
var deg_to_rad = PI / 180.0;

var NM_per_degree_latitude = 60.0; #assuming the earth is spherical
var m_per_degree_latitude = NM_per_degree_latitude * 1852.0;
var NM_per_degree_longitude = math.cos (Edwards.lat()*deg_to_rad) * 60.0;
var m_per_degree_longitude = NM_per_degree_longitude * 1852.0;



var true_hdg_deg  = props.globals.getNode("orientation/heading-deg");
var mag_hdg_deg   = props.globals.getNode("orientation/heading-magnetic-deg");
var mag_dev = 0;

var local_mag_deviation = func {
	var true_hdg = true_hdg_deg.getValue();
	var mag_hdg = mag_hdg_deg.getValue();
	mag_dev = geo.normdeg( mag_hdg - true_hdg );
	if ( mag_dev > 180 ) { mag_dev -= 360 }
	return mag_dev; 
}

var computeTrueTrackTowardsDestination = func (latitude, longitude, destination_lake) 
{ 
  
  var true_ground_track = 0.0;
  
  #compute X and y
  AC_position_x_nm =  (longitude - destination_lake.lon()) * NM_per_degree_longitude;
  AC_position_y_nm = (latitude - destination_lake.lat()) * NM_per_degree_latitude;
    
  true_ground_track = math.atan2 (- AC_position_x_NM, - AC_position_y_NM) * rad_to_deg;
  
  return true_ground_track;
  
}

var computeDistanceTowardsDestination = func (latitude, longitude, destination_lake)
{
 
  AC_position_x_nm = (longitude - destination_lake.lon()) * NM_per_degree_longitude;
  AC_position_y_nm = (latitude - destination_lake.lat()) * NM_per_degree_latitude;
  
  return math.sqrt (AC_position_x_nm * AC_position_x_nm 
                    + 
                    AC_position_y_nm * AC_position_y_nm);
}

