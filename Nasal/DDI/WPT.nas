#######################################################################
#F-20 Waypoint page
var WPTcanvas= canvas.new({
                           "name": "index page",
                           "size": [512,512],
                           "view": [512,512],
                           "mipmapping": 1
                          });

# Create a group for the parsed elements
var WPTsvg = WPTcanvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
if (is_C_variant)
canvas.parsesvg(WPTsvg, "Aircraft/F-20/Nasal/DDI/WPT-C.svg");
else
canvas.parsesvg(WPTsvg, "Aircraft/F-20/Nasal/DDI/WPT.svg");


WPT.attachCanvas (WPTcanvas);

WPT.currently_selected_waypoint = 0;
WPT.page_is_source_of_edition = false;



# Create the waypoint list for the page with its graphical elements
WPT.waypoints = [];
for (var i=0; i < 10; i = i+1)
  append (WPT.waypoints,
					{
					  latdeg     : WPTsvg.getElementById(sprintf("%s%i","latdeg",i)),
					  longdeg    : WPTsvg.getElementById(sprintf("%s%i","longdeg",i)),
					  latmin     : WPTsvg.getElementById(sprintf("%s%i","latmin",i)),
					  longmin    : WPTsvg.getElementById(sprintf("%s%i","longmin",i)),
					  EastWest   : WPTsvg.getElementById(sprintf("%s%i","EastWest",i)),
					  NorthSouth : WPTsvg.getElementById(sprintf("%s%i","NorthSouth",i)),
					  elev       : WPTsvg.getElementById(sprintf("%s%i","elev",i)),
					  box        : WPTsvg.getElementById(sprintf("%s%i","box",i)),
					  lat_sign   : north,
					  lat_value  : 0.0,
					  long_sign  : east,
					  long_value : 0.0,
					  elev_value : 0.0
					});
foreach (var waypoint; WPT.waypoints)
{
  waypoint.latdeg.setText("--º");
  waypoint.longdeg.setText("---º");
  waypoint.latmin.setText("--.-");
  waypoint.longmin.setText("--.-");
  waypoint.EastWest.setText("W");
  waypoint.NorthSouth.setText("N");
  waypoint.elev.setText("----");
  waypoint.box.hide();
}
WPT.waypoints[WPT.currently_selected_waypoint].box.show();

					
#-----------------------------------------------------------------------
# helper function to insert a waypoint in the route manager
var route_manager_input_prop = "/autopilot/route-manager/input";
#activate the route manager
setprop (route_manager_input_prop,"@ACTIVATE");

WPT.writeWaypoint = func (wpt_number)
{
  var waypoint = me.waypoints[wpt_number];  
  WPT.page_is_source_of_edition = true;
  setprop (route_manager_input_prop, sprintf("@DELETE%i", wpt_number));  
  WPT.page_is_source_of_edition = true;
  setprop (route_manager_input_prop,
		   sprintf ("@INSERT%i:%f,%f@%f",
					wpt_number,
					waypoint.long_value * (1-2*waypoint.long_sign),
					waypoint.lat_value * (1-2*waypoint.lat_sign),					
					waypoint.elev_value));
}

#-----------------------------------------------------------------------
WPT.getNextEditableWaypoint = func ()
{
  return getprop ("/autopilot/route-manager/route/num");
}

 setprop ("/autopilot/route-manager/route/num",0);
#-----------------------------------------------------------------------
WPT.updateForExternalRevision = func ()
{
  if (!WPT.page_is_source_of_edition)
  {
    var number_of_waypoints = getprop ("/autopilot/route-manager/route/num");

    if (number_of_waypoints > 10) 
    {
      print ("invalid flight plan, clearing now");
      setprop (route_manager_input_prop,"@CLEAR");
      return;
    }
    
    var i = 0;
    
    for (i = 0; i < number_of_waypoints; i = i +1)
     {
       WPT.waypoints[i].lat_value = ABS(getprop (sprintf("/autopilot/route-manager/route/wp[%i]/latitude-deg",i)));
       WPT.waypoints[i].latdeg.setText (sprintf("%iº",int (WPT.waypoints[i].lat_value)));
       WPT.waypoints[i].latmin.setText (sprintf("%.1i",(WPT.waypoints[i].lat_value
														-int (WPT.waypoints[i].lat_value))
														*60));
       if (WPT.waypoints[i].lat_value > 0) 
        {
         WPT.waypoints[i].NorthSouth.setText ("N");
         WPT.waypoints[i].lat_sign = north;
        }
       else 
        {         
         WPT.waypoints[i].NorthSouth.setText ("S");
         WPT.waypoints[i].lat_sign = south;
        }
        
       WPT.waypoints[i].long_value = ABS(getprop (sprintf("/autopilot/route-manager/route/wp[%i]/longitude-deg",i)));
       WPT.waypoints[i].longdeg.setText (sprintf("%iº",int (WPT.waypoints[i].long_value)));
       WPT.waypoints[i].longmin.setText (sprintf("%.1i",(WPT.waypoints[i].long_value
													    -int (WPT.waypoints[i].long_value))
													    *60));
       if (WPT.waypoints[i].long_value > 0) 
        {
         WPT.waypoints[i].EastWest.setText ("E");
         WPT.waypoints[i].long_sign = east;
        }
       else 
        {         
         WPT.waypoints[i].EastWest.setText ("W");
         WPT.waypoints[i].long_sign = west;
        }
        WPT.waypoints[i].elev_value = getprop (sprintf("/autopilot/route-manager/route/wp[%i]/altitude-ft",i));	
        if (WPT.waypoints[i].elev_value < -5000)
          WPT.waypoints[i].elev.setText ("0");
        else
          WPT.waypoints[i].elev.setText (sprintf("%i",int (WPT.waypoints[i].elev_value)));       	    
     }
     
     #clear the remaining points
     for (i = number_of_waypoints; i < 10; i = i+1)
     {
		  WPT.waypoints[i].latdeg.setText("--º");
		  WPT.waypoints[i].longdeg.setText("---º");
		  WPT.waypoints[i].long_value = 0.0;
		  WPT.waypoints[i].lat_value = 0.0;
		  WPT.waypoints[i].elev_value = 0.0;
		  WPT.waypoints[i].latmin.setText("--.-");
		  WPT.waypoints[i].longmin.setText("--.-");
		  WPT.waypoints[i].EastWest.setText("W");
		  WPT.waypoints[i].long_sign = west;
		  WPT.waypoints[i].NorthSouth.setText("N");
		  WPT.waypoints[i].lat_sign = north;
		  WPT.waypoints[i].elev.setText("----");		  
	 }
  }
  else 
   {
     WPT.page_is_source_of_edition = false;
     print ("not updating");
   }
}

#-----------------------------------------------------------------------
setlistener ("/autopilot/route-manager/signals/edited", 
			 WPT.updateForExternalRevision);


#-----------------------------------------------------------------------
#update function
WPT.update = func ()
{
  
}

#-----------------------------------------------------------------------
#change the selection box
WPT.changeBox = func (new_number)
{
  me.waypoints[me.currently_selected_waypoint].box.hide();
  me.waypoints[new_number].box.show();
  me.currently_selected_waypoint = new_number;
}

#Bezel functions #######################################################

WPT.button_functions[0] =  func(display) {WPT.changeBox (4);};
WPT.button_functions[1] =  func(display) {WPT.changeBox (3);};
WPT.button_functions[2] =  func(display) {WPT.changeBox (2);};
WPT.button_functions[3] =  func(display) {WPT.changeBox (1);};
WPT.button_functions[4] =  func(display) {WPT.changeBox (0);};

#-----------------------------------------------------------------------
#WPT key
WPT.button_functions[5] = func(display)
{
  if (scratchpad.length == 0) 
   {
    if (WPT.currently_selected_waypoint < 9)
      WPT.changeBox (WPT.currently_selected_waypoint+1);
    else 
      WPT.changeBox (0);
   }   
   else if ((scratchpad.length == 1) and (scratchpad.text !="."))
    {
     WPT.changeBox (num(scratchpad.text));
     scratchpad.remove();
    }
   else 
     scratchpad.flash();
}

#-----------------------------------------------------------------------
#LAT key
WPT.button_functions[6] = func (display)
{
 var current_waypoint = WPT.waypoints[WPT.currently_selected_waypoint];
  if (scratchpad.length == 0) 
   {
     if (current_waypoint.lat_sign == south)
     {
      current_waypoint.lat_sign = north;
      current_waypoint.NorthSouth.setText("N");
     }
     else 
     {
      current_waypoint.lat_sign = south;
      current_waypoint.NorthSouth.setText("S");
     }
     WPT.writeWaypoint (WPT.currently_selected_waypoint);
   }
  else
   {
     #first check if other waypoints have been filled
     if (WPT.currently_selected_waypoint > WPT.getNextEditableWaypoint())
       scratchpad.flash();
     else
     {
		var value = split (".", scratchpad.text);
		var number_of_tokens = size (value);
		
		if (number_of_tokens > 3) scratchpad.flash();
		else 
		{
		  current_waypoint.lat_value = num(value[0]);
		  current_waypoint.latdeg.setText(sprintf ("%sº",value[0]));
		  if (number_of_tokens > 2)
		    var minutes = sprintf ("%i.%i",value[1],value[2]);		    
		  else if (number_of_tokens == 2)
		    var minutes =  sprintf ("%i.0",value[1]);
		  else 
		    var minutes = "0.0";
		    
		  current_waypoint.latmin.setText(minutes);
		  current_waypoint.lat_value = current_waypoint.lat_value
										+
										num (minutes)/60;
		  WPT.writeWaypoint (WPT.currently_selected_waypoint);
		  scratchpad.remove();
		}
	  }
	}
}

#-----------------------------------------------------------------------
#LON key
WPT.button_functions[7] = func (display)
{
 var current_waypoint = WPT.waypoints[WPT.currently_selected_waypoint];
  if (scratchpad.length == 0) 
   {
     if (current_waypoint.long_sign == east)
     {
      current_waypoint.long_sign = west;
      current_waypoint.EastWest.setText("W");
     }
     else 
     {
      current_waypoint.long_sign = east;
      current_waypoint.EastWest.setText("E");
     }
     WPT.writeWaypoint (WPT.currently_selected_waypoint);
   }
  else
   {
     #first check if other waypoints have been filled
     if (WPT.currently_selected_waypoint > WPT.getNextEditableWaypoint())
       scratchpad.flash();
     else
     {
		var value = split (".", scratchpad.text);
		var number_of_tokens = size (value);
		
		if (number_of_tokens > 3) scratchpad.flash();
		else 
		{

   	      current_waypoint.long_value = num(value[0]);
		  current_waypoint.longdeg.setText(sprintf ("%sº",value[0]));
		  if (number_of_tokens > 2)
		    var minutes = sprintf ("%i.%i",value[1],value[2]);		    
		  else if (number_of_tokens == 2)
		    var minutes =  sprintf ("%i.0",value[1]);
		  else 
		    var minutes = "0.0";
		    
		  current_waypoint.longmin.setText(minutes);
		  current_waypoint.long_value = current_waypoint.long_value
										+
										num (minutes)/60;								
		  WPT.writeWaypoint (WPT.currently_selected_waypoint);
		  scratchpad.remove();
		}
	  }
	}
}

#-----------------------------------------------------------------------
#ELEV key
WPT.button_functions[8] = func (display)
{
 var current_waypoint = WPT.waypoints[WPT.currently_selected_waypoint];
  if (scratchpad.length == 0) 
  {
     current_waypoint.elev_value = - current_waypoint.elev_value;
     WPT.page_is_source_of_edition = true;
     WPT.writeWaypoint (WPT.currently_selected_waypoint);
  }
  else
   {
     #first check if other waypoints have been filled
     if (WPT.currently_selected_waypoint > WPT.getNextEditableWaypoint())
       scratchpad.flash();
     else
     {
		var value = split (".", scratchpad.text);
		var number_of_tokens = size (value);
		
		if (number_of_tokens > 1) scratchpad.flash();
		else 
		{ 
		   current_waypoint.elev_value = num(value[0]);
		   current_waypoint.elev.setText(value[0]);
		   WPT.page_is_source_of_edition = true;
		   WPT.writeWaypoint (WPT.currently_selected_waypoint);
		   scratchpad.remove();		   
		}		 
	  }
	}
	
}

WPT.button_functions[9] = uselessKey;
WPT.button_functions[10] =  func(display) {WPT.changeBox (5);};
WPT.button_functions[11] =  func(display) {WPT.changeBox (6);};
WPT.button_functions[12] =  func(display) {WPT.changeBox (7);};
WPT.button_functions[13] =  func(display) {WPT.changeBox (8);};
WPT.button_functions[14] =  func(display) {WPT.changeBox (9);};


