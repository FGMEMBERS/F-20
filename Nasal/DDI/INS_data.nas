#F-20 INS page

var INSdataCanvas= canvas.new({
                           "name": "INS data page",
                           "size": [512,512],
                           "view": [512,512],
                           "mipmapping": 1
                          });
                          
var latitude_prop = "/position/latitude-deg";
var longitude_prop = "/position/longitude-deg";


# Create a group for the parsed elements
var INSdataSvg = INSdataCanvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
if (is_C_variant)
canvas.parsesvg(INSdataSvg, "Aircraft/F-20/Nasal/DDI/INS_data-C.svg");
else
canvas.parsesvg(INSdataSvg, "Aircraft/F-20/Nasal/DDI/INS_data.svg");

INS_data.attachCanvas (INSdataCanvas);

INS_data.magvar_label = INSdataSvg.getElementById("magvar");
INS_data.ground_speed_label = INSdataSvg.getElementById("GS");
INS_data.error_block = INSdataSvg.getElementById("error-block");
INS_data.error_block.hide();
INS_data.lat_error = INSdataSvg.getElementById("lat-error");
INS_data.long_error = INSdataSvg.getElementById("long-error");
INS_data.north_south = INSdataSvg.getElementById("north-south");
INS_data.latdeg = INSdataSvg.getElementById("latdeg");
INS_data.east_west = INSdataSvg.getElementById("east-west");
INS_data.longdeg = INSdataSvg.getElementById("longdeg");
INS_data.latmin = INSdataSvg.getElementById("latmin");
INS_data.longmin = INSdataSvg.getElementById("longmin");
INS_data.windspeed = INSdataSvg.getElementById("wind-speed");
INS_data.winddir = INSdataSvg.getElementById("wind-dir");
INS_data.ofly_box = INSdataSvg.getElementById("overfly_box");
INS_data.ofly_box.hide();

#-----------------------------------------------------------------------
#update function
INS_data.update = func (delta_t)
{  

  if (INS.switch_position == ins_off) 
  {
   foreach (var display; displays)
      if (display.current_page == me) display.changePage(IDX);
   return;
  }
  else if (INS.switch_position != ins_navigate)
  {
    foreach (var display; displays)
       if (display.current_page == me) display.changePage(INS_align);
    return;
  }
  
  if (INS.magvar > 0) me.magvar_label.setText(sprintf("W %.1f", INS.magvar));
  else me.magvar_label.setText(sprintf("E %.1f", INS.magvar));

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
  
  me.ground_speed_label.setText (sprintf("%i", getprop ("/velocities/groundspeed-kt")));
  me.windspeed.setText (sprintf("%i", getprop ("/environment/wind-speed-kt")));
  me.winddir.setText (sprintf("%i", getprop ("/environment/wind-from-heading-deg")));
  
}

#Bezel functions #######################################################
INS_data.no_func = func (display) {}
#for (var i = 0; i < DDI_number_of_keys; i = i+1)
#	INS_data.button_functions[i] = INS_data.no_func;

INS_data.button_functions[0] = INS_data.no_func;
INS_data.button_functions[1] = INS_data.no_func;
INS_data.button_functions[2] = INS_data.no_func;
INS_data.button_functions[3] = INS_data.no_func;
INS_data.button_functions[4] = INS_data.no_func;
INS_data.button_functions[5] = INS_data.no_func;
INS_data.button_functions[6] = INS_data.no_func;
INS_data.button_functions[7] = INS_data.no_func;
INS_data.button_functions[8] = func (display) {display.changePage (HSI);}
INS_data.button_functions[9] = INS_data.no_func;
INS_data.button_functions[10] = INS_data.no_func;
INS_data.button_functions[11] = INS_data.no_func;
INS_data.button_functions[12] = INS_data.no_func;
INS_data.button_functions[13] = INS_data.no_func;
INS_data.button_functions[14] = INS_data.no_func;
INS_data.button_functions[15] = INS_data.no_func;
