################################################################################
#F-20 HSI

var HSIcanvas= canvas.new({
                           "name": "HSI page",
                           "size": [512,512],
                           "view": [512,512],
                           "mipmapping": 1
                          });

HSIcanvas.setColorBackground(0.0, 0.0, 0.0, 1.00);

# Create a group for the parsed elements
HSI.trackLine =  HSIcanvas.createGroup();
var HSIsvg = HSIcanvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
if (is_C_variant)
canvas.parsesvg(HSIsvg, "Aircraft/F-20/Nasal/DDI/HSI-C.svg");
else
canvas.parsesvg(HSIsvg, "Aircraft/F-20/Nasal/DDI/HSI.svg");

var rose = HSIsvg.getElementById("rose_1");
var E_label = HSIsvg.getElementById("east_label");
var W_label = HSIsvg.getElementById("west_label");
var N_label = HSIsvg.getElementById("north_label");
var S_label = HSIsvg.getElementById("south_label");
var label_3 = HSIsvg.getElementById("3_label");
var label_6 = HSIsvg.getElementById("6_label");
var label_12 = HSIsvg.getElementById("12_label");
var label_15 = HSIsvg.getElementById("15_label");
var label_21 = HSIsvg.getElementById("21_label");
var label_24 = HSIsvg.getElementById("24_label");
var label_30 = HSIsvg.getElementById("30_label");
var label_33 = HSIsvg.getElementById("33_label");
var compass_labels = HSIsvg.getElementById("compass_labels");

var ground_speed_label = HSIsvg.getElementById("ground_speed");
var heading_label = HSIsvg.getElementById("heading");

#Selected Heading
var heading_bug = HSIsvg.getElementById("hdg-pointer");
var heading_box = HSIsvg.getElementById("HDG-box");
HSI.selected_heading_rad = 0;
HSI.heading_bug_displayed = false;
heading_bug.hide();
heading_box.hide();

#selected course
HSI.selected_course_rad = 0;
HSI.selected_course = 0;

#HSI nav mode
var no_nav = 0;
var tacan_nav = 1;
var ins_nav = 2;
var adf_nav = 3;

var leg_mode = 0;
var crs_mode = 1;
var dir_mode = 2;

HSI.nav_mode = no_nav;
HSI.tacan_route_mode = dir_mode;
HSI.ins_route_mode = leg_mode;

#ADF data
var adf_box = HSIsvg.getElementById("adf_box");
adf_box.hide();

#VOR data
var VOR_box = HSIsvg.getElementById("VOR-box");
VOR_box.hide();
var VOR_label = HSIsvg.getElementById("VOR-label");
VOR_label.hide();


#INS waypoint data
var wpt_box = HSIsvg.getElementById("wpt_box");
var ins_waypoint_label = HSIsvg.getElementById("wpt_number");
var ins_to_waypoint_label = HSIsvg.getElementById("to_wpt_number");
var from_label = HSIsvg.getElementById("from_label");
var to_label = HSIsvg.getElementById("to_label");
var down_arrow = HSIsvg.getElementById("down_arrow");
var up_arrow = HSIsvg.getElementById("up_arrow");
var ins_from_waypoint_label = HSIsvg.getElementById("from_waypoint_number");
var ins_brg_dist_label = HSIsvg.getElementById("INS-bearing_distance");
var ins_TTG_label = HSIsvg.getElementById("INS-TTG");
var waypoint_symbol = HSIsvg.getElementById("waypoint_symbol");
var waypoint_needle = HSIsvg.getElementById("wpt_needle");
wpt_box.hide();
HSI.from_wpt_number = 0;
HSI.to_wpt_number = 1;
HSI.leg_navigation_possible = false;


#TACAN data
var tacan_box = HSIsvg.getElementById("TACAN-box");
var tacan_symbol = HSIsvg.getElementById("tacan_symbol");
var tacan_brg_dist_label = HSIsvg.getElementById("tacan-bearing_distance");
var tacan_TTG_label = HSIsvg.getElementById("TACAN-TTG");
var tacan_needle = HSIsvg.getElementById("tacan_needle");
tacan_box.hide();

#CRS/DIR boxes
var crs_box = HSIsvg.getElementById("crs_box");
crs_box.hide();
var crs_value = HSIsvg.getElementById("crs");
crs_value.hide();
var dir_box = HSIsvg.getElementById("dir_box");
dir_box.hide();

HSI.attachCanvas (HSIcanvas);

HSI.range = 80;
var radius_pixels = 150;
var range_label = HSIsvg.getElementById("range");
HSI.pixels_per_NM = radius_pixels / HSI.range;

#Helper functions **************************************************************

#-------------------------------------------------------------------------------
#always returns a three digit string
var threeDigitsAngle = func (angle)
{
  if (angle < 10) return sprintf("00%iº", angle);
  else if (angle < 100) return sprintf("0%iº", angle);
  else return sprintf("%iº", angle);
}

#-------------------------------------------------------------------------------
var isFrom = func (bearing_deg, course_deg)
{
  var angle = course_deg - bearing_deg;
  if (angle < 0) angle = angle + 360;
  if ((angle > 90) and (angle < 270)) return true;
  else return false;
}

#-------------------------------------------------------------------------------
var isLeft = func (bearing_deg, course_deg)
{
  var angle = course_deg - bearing_deg;
  if (angle < 0) angle = angle + 360;
  if (
	  (angle > 90) and (angle < 180)
	  or
	  (angle > 270) and (angle < 360)
	 )
	return true;
  else
    return false;
}

#-------------------------------------------------------------------------------
var crossTrack = func (bearing_deg, course_deg, distance)
{
  var angle = course_deg - bearing_deg;
  if (angle < 0) angle = angle + 360;
  angle = angle * deg_to_rad;
  return -distance * math.sin(angle);
}

#-------------------------------------------------------------------------------
var setDisplayForINSleg = func ()
{
	up_arrow.hide();
	down_arrow.hide();
	ins_waypoint_label.hide();
	ins_to_waypoint_label.setText(sprintf("%i",INS.to_wpt_index)).show();
	from_label.show();
	to_label.show();
	ins_from_waypoint_label.setText(sprintf("%i",INS.from_wpt_index)).show();
}

#-------------------------------------------------------------------------------
var setDisplayForINSdirCrs = func ()
{
    if (INS.can_navigate_to_waypoint)
    {
	 up_arrow.show();
	 down_arrow.show();
	 ins_waypoint_label.setText(sprintf("%i",INS.to_wpt_index)).show();
	 ins_to_waypoint_label.hide();
	 from_label.hide();
	 to_label.hide();
	 ins_from_waypoint_label.hide();
	}
	else
	{
	 up_arrow.hide();
	 down_arrow.show();
	 ins_waypoint_label.hide();
	 ins_to_waypoint_label.hide();
	 from_label.hide();
	 to_label.hide();
	 ins_from_waypoint_label.hide();
	}
}

#-------------------------------------------------------------------------------
var setDisplayForNoWaypoint = func ()
{
	up_arrow.hide();
	down_arrow.hide();
	ins_waypoint_label.hide();
	ins_to_waypoint_label.hide();
	from_label.hide();
	to_label.hide();
	wpt_box.hide();
	ins_from_waypoint_label.hide();
}

setDisplayForNoWaypoint();

# Core functions **************************************************************

#-------------------------------------------------------------------------------
#draw a track line
HSI.slider = HSI.trackLine.createChild ("group");
HSI.slider.setCenter (256,256);
HSI.line = HSI.slider.createChild ("path");

if (is_C_variant)
HSI.line.setColor (1.0,1.0,1.0)
		.setStrokeLineWidth(2)
		.show();
else
HSI.line.setColor (0.1,0.8,0.1)
		.setStrokeLineWidth(2)
		.show();

HSI.drawTrackLine = func (course_rad, cross_track, heading_rad)
{
  if ((cross_track < HSI.range)
      and
      (cross_track > -HSI.range))
  {
	var half_length = math.sqrt(HSI.range*HSI.range - cross_track * cross_track)
					*
					HSI.pixels_per_NM;
	HSI.line.reset()
		    .moveTo (256, half_length + 256)
		    .line (0.0, -2* half_length + 10)
		    .line (5.0, 0)
		    .line (-5.0, -10)
		    .line (-5.0, 10)
		    .line (5.0,0)
		    .setTranslation (cross_track * HSI.pixels_per_NM ,0.0)
		    .show();
	HSI.slider.setRotation(-heading_rad + course_rad);
   }
   else HSI.line.reset().hide();
}

#-------------------------------------------------------------------------------
HSI.cross_track = 0.0; #Nautical miles
HSI.update = func ()
{
  #compass
  var heading_rad = heading * deg_to_rad;
  var INS_bearing_rad = INS.bearing * deg_to_rad;
  var TACAN_bearing_rad = TACAN.bearing * deg_to_rad;
  
  rose.setRotation (-heading_rad);
  E_label.setRotation (heading_rad);
  W_label.setRotation (heading_rad);
  S_label.setRotation (heading_rad);
  N_label.setRotation (heading_rad);
  label_3.setRotation (heading_rad);
  label_6.setRotation (heading_rad);
  label_12.setRotation (heading_rad);
  label_15.setRotation (heading_rad);
  label_21.setRotation (heading_rad);
  label_24.setRotation (heading_rad);
  label_30.setRotation (heading_rad);
  label_33.setRotation (heading_rad);
  compass_labels.setRotation (-heading_rad);
  ground_speed_label.setText(sprintf("G %i", getprop ("/velocities/groundspeed-kt")));

  heading_label.setText (threeDigitsAngle (heading));

 
  #show track line
  if (HSI.nav_mode == adf_nav)
  {
    if (ADF.is_receiving)
     {
      HSI.cross_track = 0.0;
      HSI.drawTrackLine (ADF.getBearing() * deg_to_rad,
						 HSI.cross_track,
						 heading_rad);
     }
     else HSI.line.reset().hide();
  }
  else if (HSI.nav_mode == ins_nav)
  {
    if (HSI.ins_route_mode == dir_mode)
     {
      if (INS.can_navigate_to_waypoint)
      {
		HSI.cross_track = 0.0;
		HSI.drawTrackLine (INS_bearing_rad,
						   HSI.cross_track,
						   heading_rad);
	  }
	  else HSI.line.reset().hide();
     }
    else if (HSI.ins_route_mode == leg_mode)
     {
      if (INS.has_minimum_flightplan)
      {       
		HSI.cross_track = crossTrack(INS.bearing,
								     INS.current_course,
								     INS.distance);
		HSI.drawTrackLine (INS.current_course * deg_to_rad,
						   HSI.cross_track,
						   heading_rad);
	  }
	  else HSI.line.reset().hide();
	 }
	else #INS is in course mode
     {
      if (INS.can_navigate_to_waypoint)
      {
		  HSI.cross_track = crossTrack(INS.bearing,
									   HSI.selected_course,
									   INS.distance);									   
		HSI.drawTrackLine (HSI.selected_course_rad,
						   HSI.cross_track,
						   heading_rad);
	  }
	  else HSI.line.reset().hide();
	 }
  }
  else if (HSI.nav_mode == tacan_nav)
  {
    if (HSI.tacan_route_mode == dir_mode)
	  HSI.drawTrackLine (TACAN_bearing_rad,
						 0,
						 heading_rad);	
    else
	  HSI.drawTrackLine (HSI.selected_course_rad,
						 crossTrack(TACAN.bearing,
								   HSI.selected_course,
								   TACAN.distance),
						 heading_rad);								   
  }
  else HSI.line.reset().hide();
  
  
  #show data needles and icons
  if (INS.can_navigate_to_waypoint)
  {
     waypoint_symbol.setTranslation(256 + INS.distance 
										  * HSI.pixels_per_NM 
										  * math.sin(INS_bearing_rad - heading_rad),
								    256 - INS.distance
										  * HSI.pixels_per_NM
										  * math.cos(INS_bearing_rad - heading_rad))
					 .show();
	  #Nav Data
	   ins_brg_dist_label.setText (sprintf("%s/%.1f",
										   threeDigitsAngle (INS.bearing),
										   INS.distance))
						  .show();										  
	   ins_TTG_label.setText(getprop(INS.TTG_prop)).show();	
	   waypoint_needle.setRotation(INS_bearing_rad).show();					  
   }
   else 
   {
     waypoint_symbol.hide();
     ins_brg_dist_label.hide();
     ins_TTG_label.hide();
     waypoint_needle.hide();
   }
   
   
   if (TACAN.is_receiving)
   {
     tacan_symbol.setTranslation(256 + TACAN.distance
									   * HSI.pixels_per_NM
									   * math.sin(TACAN_bearing_rad - heading_rad),
								    256 - TACAN.distance 
										  * HSI.pixels_per_NM
										  * math.cos(TACAN_bearing_rad - heading_rad)).show();
	 tacan_needle.setRotation(TACAN_bearing_rad).show();
	 tacan_brg_dist_label.setText(sprintf("%s/%.1f",
										   threeDigitsAngle (TACAN.bearing),
										   TACAN.distance)).show();
	 tacan_TTG_label.setText(TACAN.TTG).show();
	}
   else 
   {
     if (HSI.nav_mode == tacan_nav)
     {
       	 tacan_brg_dist_label.setText("---/---").show();
       	 tacan_TTG_label.setText("--:--").show();
     }     
     else
     {
      tacan_symbol.hide();
      tacan_brg_dist_label.hide();
      tacan_TTG_label.hide();
      tacan_needle.hide();
     }
   }
   
}

#Bezel functions #######################################################

#-------------------------------------------------------------------------------
#VOR key (only for F-20C)
HSI.button_functions[0] =  func(display)
{
}

#-------------------------------------------------------------------------------
#HDG key
HSI.button_functions[1] =  func(display)
{
  if (scratchpad.length == 0)
  {
    HSI.heading_bug_displayed = ! HSI.heading_bug_displayed;
    if (HSI.heading_bug_displayed)
     {
      heading_bug.show();
	  heading_box.show();
	  HUD_heading_bug.show();
     }
    else
    {
     heading_bug.hide();
	 heading_box.hide();
	 HUD_heading_bug.hide();
    }
  }
  else
  {
    var heading = num(scratchpad.text);
    if (heading > 359) scratchpad.flash();
    else
    {
      heading_bug.show();
	  heading_box.show();      
	  HSI.selected_heading_rad = heading * deg_to_rad;
	  heading_bug.setRotation(HSI.selected_heading_rad);	
	  HSI.heading_bug_displayed = true;  
	  HUD_page.setHeadingPointer(heading);
	  HUD_heading_bug.show();
	  scratchpad.remove();
	  
    }
  }
}

#-------------------------------------------------------------------------------
#FS
HSI.button_functions[2] =  func(display)
{
}

#-------------------------------------------------------------------------------
#ADF key
HSI.button_functions[3] =  func(display)
{

}

#-------------------------------------------------------------------------------
#TCN key
HSI.button_functions[4] =  func(display)
{
  setDisplayForINSdirCrs ();
  HUD_page.setTacanNav();
  if (HSI.nav_mode != tacan_nav)
  {
   HSI.nav_mode = tacan_nav;
   tacan_box.show();
   wpt_box.hide();   
   adf_box.hide();
   if (HSI.tacan_route_mode == dir_mode)
   {
	 crs_box.hide();
	 crs_value.hide();
	 dir_box.show();
   }
   else if (HSI.tacan_route_mode == crs_mode)
   {
	 crs_box.show();
	 crs_value.show();
	 dir_box.hide();
   }
  }
  else
  {
	HSI.nav_mode = no_nav;
	tacan_box.hide();
	crs_box.hide();
	crs_value.hide();
	dir_box.hide();
	HUD_page.setNoNav();
  }
}

#-------------------------------------------------------------------------------
#TCN mode key
HSI.button_functions[5] = func(display)
{

}

#-------------------------------------------------------------------------------
#IFF mode key
HSI.button_functions[6] = func (display)
{

}

#-------------------------------------------------------------------------------
#HDG source
HSI.button_functions[7] = func (display)
{

}

#-------------------------------------------------------------------------------
#INS data
HSI.button_functions[8] = func (display)
{
  display.changePage (INS_data);
}

#-------------------------------------------------------------------------------
#Range key
HSI.button_functions[9] = func (display)
{
  HSI.range = HSI.range / 2;
  if (HSI.range < 10) HSI.range = 80;
  HSI.pixels_per_NM = radius_pixels / HSI.range;
  range_label.setText(sprintf ("%i",  HSI.range));
}

#-------------------------------------------------------------------------------
#Wpt key
HSI.button_functions[10] =  func(display)
{
  if (INS.can_navigate_to_waypoint)
  {
      HUD_page.setINSnav();
	  if (HSI.nav_mode != ins_nav)
	  {
	   HSI.nav_mode = ins_nav;
	   wpt_box.show();
	   tacan_box.hide();
	   adf_box.hide();
	   if (!INS.has_minimum_flightplan) HSI.ins_route_mode = dir_mode;
	   
	   if (HSI.ins_route_mode == dir_mode)
	   {
		crs_box.hide();
		crs_value.hide();
		dir_box.show();
		setDisplayForINSdirCrs ();
	   }
	   else if (HSI.ins_route_mode == crs_mode)
	   {
		crs_box.show();
		crs_value.show();
		dir_box.hide();
		setDisplayForINSdirCrs ();
	   }
	   else
	   {
		crs_box.hide();
		crs_value.hide();
		dir_box.hide();
		setDisplayForINSleg ();
	   }
	  }
	  else
	  {
		HSI.nav_mode = no_nav;
		setDisplayForINSdirCrs ();
		wpt_box.hide();
		crs_box.hide();
		crs_value.hide();
		dir_box.hide();
		HUD_page.setNoNav();
	  }
   }
}

#-----------------------------------------------------------------------
#Wpt up key
HSI.button_functions[11] =  func(display)
{
  if ((HSI.nav_mode == ins_nav) and (HSI.ins_route_mode == leg_mode))
  {
   if (scratchpad.length == 0) INS.cycleToWaypoint();
   else
   {
     var new_to_wpt = num(scratchpad.text);
     if ((new_to_wpt > INS.from_wpt_index) and (new_to_wpt < 10))
     {
		INS.setToWaypoint (new_to_wpt);
		scratchpad.remove();
	 }
     else 
     {
        scratchpad.flash();
        return;     
     }
   }
   ins_to_waypoint_label.setText (sprintf ("%i", INS.to_wpt_index));
  }
  else
  {
    INS.nextToWaypoint();
    ins_waypoint_label.setText (sprintf ("%i", INS.to_wpt_index));
  }
}

#-----------------------------------------------------------------------
#Wpt dn key
HSI.button_functions[12] =  func(display)
{
  if ((HSI.nav_mode == ins_nav) and (HSI.ins_route_mode == leg_mode))
  {
   if (scratchpad.length == 0) INS.cycleFromWaypoint();
   else
   {
     var new_from_wpt = num(scratchpad.text);
     if ((new_from_wpt < INS.to_wpt_index) and (new_from_wpt < 10))
     {
       INS.setFromWaypoint(new_from_wpt);
       scratchpad.remove();
     }
     else 
      {
        scratchpad.flash();
        return;
      }
   }
   ins_from_waypoint_label.setText (sprintf ("%i", INS.from_wpt_index));
  }
  else
  {
    INS.previousToWaypoint();
    ins_waypoint_label.setText (sprintf ("%i", INS.to_wpt_index));
  }
}

#-----------------------------------------------------------------------
#Dir key
HSI.button_functions[13] =  func(display)
{
    if (HSI.nav_mode == tacan_nav)
    {
        dir_box.show();
        crs_value.hide();
	    crs_box.hide();
	    HSI.tacan_route_mode = dir_mode;
    }
    else if (HSI.nav_mode == ins_nav)
    {
      crs_value.hide();
	  crs_box.hide();    
      if ((HSI.ins_route_mode == dir_mode) and (INS.has_minimum_flightplan))
      {       
        HSI.ins_route_mode = leg_mode;
	    dir_box.hide();
	    setDisplayForINSleg ();
      }
      else
      {
        HSI.ins_route_mode = dir_mode;
		dir_box.show();
		setDisplayForINSdirCrs ();
	  }
    }
}

#-----------------------------------------------------------------------
#CRS key
HSI.button_functions[14] =  func(display)
{
  if (scratchpad.length == 0)
  {
    if (HSI.nav_mode == tacan_nav)
     {
        crs_value.show();
	    crs_box.show();
	    dir_box.hide();
	    HSI.tacan_route_mode = crs_mode;
     }
    else if (HSI.nav_mode == ins_nav)
    {
      if (HSI.ins_route_mode == crs_mode)
      {
        if (INS.has_minimum_flightplan) 
        {
         HSI.ins_route_mode = leg_mode; 
         setDisplayForINSleg ();
        }
        else HSI.ins_route_mode = dir_mode;             
	    crs_box.hide();
      }
      else
      {
        HSI.ins_route_mode = crs_mode;
        crs_value.show();
        setDisplayForINSdirCrs ();
		dir_box.hide();                
	    crs_box.show();
	  }
    }
  }
  else
  {
    HSI.selected_course = num(scratchpad.text);
    if (HSI.selected_course > 359) scratchpad.flash();
    else
    {
      if (HSI.nav_mode == tacan_nav)  HSI.tacan_route_mode = crs_mode;
      else if  (HSI.nav_mode == ins_nav) HSI.ins_route_mode = crs_mode;
      if ((HSI.nav_mode == tacan_nav) or (HSI.nav_mode == ins_nav))
      {
		crs_value.setText(threeDigitsAngle (HSI.selected_course)).show();
		crs_box.show();
		dir_box.hide();
		HSI.selected_course_rad = HSI.selected_course * deg_to_rad;
		scratchpad.remove();
	  }
	  else scratchpad.flash();
    }
  }
}
