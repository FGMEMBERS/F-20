#F-20 INS page

var INSalignCanvas = canvas.new({
                           "name": "INS align page",
                           "size": [512,512],
                           "view": [512,512],
                           "mipmapping": 1
                          });
                          
var latitude_prop = "/position/latitude-deg";
var longitude_prop = "/position/longitude-deg";


# Create a group for the parsed elements
var INSalignSvg = INSalignCanvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
if (is_C_variant)
canvas.parsesvg(INSalignSvg, "Aircraft/F-20/Nasal/DDI/INS_align-C.svg");
else
canvas.parsesvg(INSalignSvg, "Aircraft/F-20/Nasal/DDI/INS_align.svg");

INS_align.attachCanvas (INSalignCanvas);

INS_align.time = INSalignSvg.getElementById("time");
INS_align.quality = INSalignSvg.getElementById("qual");
INS_align.north_south = INSalignSvg.getElementById("north-south");
INS_align.latdeg = INSalignSvg.getElementById("latdeg");
INS_align.east_west = INSalignSvg.getElementById("east-west");
INS_align.longdeg = INSalignSvg.getElementById("longdeg");
INS_align.latmin = INSalignSvg.getElementById("latmin");
INS_align.longmin = INSalignSvg.getElementById("longmin");
INS_align.heading = INSalignSvg.getElementById("hdg");
INS_align.lat_sign = north;
INS_align.long_sign = south;

#-----------------------------------------------------------------------
#update function
INS_align.update = func (delta_t)
{  

  if (INS.switch_position == ins_off) 
  {
   foreach (var display; displays)
      if (display.current_page == me) display.changePage(IDX);
   return;
  }
  else if (INS.switch_position == ins_navigate)
  {
    foreach (var display; displays)
       if (display.current_page == me) display.changePage(INS_data);
    return;
  }
  

  var altered_coords = geo.Coord.new();
  altered_coords.set_latlon (getprop (latitude_prop),
							 getprop (longitude_prop));
  altered_coords.set_x (altered_coords.x() + INS.long_drift_nm * 1852);
  altered_coords.set_y (altered_coords.y() + INS.lat_drift_nm * 1852);
  
  var new_lat = altered_coords.lat();
  var lat_min = (new_lat - int(new_lat)) * 60;
  var new_long = altered_coords.lon();
  var long_min = (new_long - int(new_long)) * 60;
  
  if (new_lat > 0)
   me.north_south.setText ("NORTH");
  else
   me.north_south.setText ("SOUTH");
   
  me.latdeg.setText (sprintf("%i°", abs(new_lat)));
  
  if (new_long > 0)
   me.east_west.setText ("EAST");
  else
   me.east_west.setText ("WEST");
  me.longdeg.setText (sprintf("%i°", abs(new_long)));
  
  me.latmin.setText (sprintf ("%.1f", abs (lat_min)));
  me.longmin.setText (sprintf ("%.1f", abs(long_min)));
  
  var minutes = int(INS.alignement_elapsed_time/60);
  var seconds = INS.alignement_elapsed_time - 60 * minutes;
  me.time.setText (sprintf ("%i:%i", minutes, seconds));
  me.quality.setText (sprintf ("%.1f", 10.1 - INS.drift_nm));
  
  
}

#Bezel functions #######################################################

INS_align.button_functions[0] = uselessKey;
INS_align.button_functions[1] = uselessKey;
INS_align.button_functions[2] = uselessKey;
INS_align.button_functions[3] = uselessKey;
INS_align.button_functions[4] = uselessKey;
INS_align.button_functions[5] = uselessKey;

#Latitude Key
INS_align.button_functions[6] = func (display)
{
 
  if (scratchpad.length == 0) 
   {
     me.lat_sign = ! me.lat_sign;
     if (me.lat_sign == south) me.north_south.setText("SOUTH");
     else  me.north_south.setText("NORTH");
   }
  else
   {

		var value = split (".", scratchpad.text);
		var number_of_tokens = size (value);
		
		if (number_of_tokens > 3) scratchpad.flash();
		else 
		{
		  var lat_value = num(value[0]);
		   
		  if (number_of_tokens > 2)
		    var minutes = num (value[1]) + num (value [2])/10;	    
		  else if (number_of_tokens == 2)
		    var minutes =  num (value[1]);
		  else 
		    var minutes = 0.0;
		  
		  lat_value = lat_value + minutes / 60;  
		  current_waypoint.latmin.setText(minutes);
   
		  INS.setAlignLatitude (lat_value);
		  
		  scratchpad.remove();
		}
	}
}

INS_align.button_functions[7] = uselessKey;
INS_align.button_functions[8] = func (display) {display.changePage (HSI);}
INS_align.button_functions[9] = uselessKey;
INS_align.button_functions[10] = uselessKey;
INS_align.button_functions[11] = uselessKey;
INS_align.button_functions[12] = uselessKey;
INS_align.button_functions[13] = uselessKey;
INS_align.button_functions[14] = uselessKey;
INS_align.button_functions[15] = uselessKey;
