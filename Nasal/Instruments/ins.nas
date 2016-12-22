################################################################################
# Inertial navigation system (flight plan and drift)
#
# TODO : improve the modelling of INS alignment

var waypoint_prop_root = "/autopilot/route-manager/route/wp";
var INS_ready_prop = "/f-20/INS/ready";
var INS_selector_prop = "/f-20/INS/selector";

var ins_off = 0;
var ins_stored_align = 1;
var ins_normal_align = 2;
var ins_navigate = 3;

var min_drift = 0.2;

var INS = {
            heading_is_mag : true,
            magvar : 0,
          #navigation data
            leg_is_regular : false,
            number_of_waypoints : 0,
            from_wpt_index : 0,
            to_wpt_index : 0,
            bearing : 0,
            distance : 0,
            TTG_prop : "/autopilot/route-manager/wp/eta",
            current_course : 0,
            can_navigate_to_waypoint : false,
            has_minimum_flightplan : false,
          #alignement/drift
            time_since_last_alignement : 0.0,
            alignement_elapsed_time : 0.0,
            alignement_duration : 0.0,
            drift_vector_lat : 0.0,
            drift_vector_long : 0.0,
            lat_drift_nm : 3.0,
            long_drift_nm : 3.0,
            drift_nm : 4.0,
          #functional status
            elec_power : GenericLoad.new (AC_1, 30, 115),
            switch_position : ins_off
          };

var drift_angle = rand() * math.pi * 2;
INS.drift_vector_lat  = math.cos (drift_angle);
INS.drift_vector_long = math.sin (drift_angle);
INS.switch_position = ins_off; #ins_navigate;

#-------------------------------------------------------------------------------
INS.getBearing = func ()
{
  if (me.heading_is_mag)
	return getprop ("/autopilot/route-manager/wp/bearing-deg");
  else
    return getprop ("/autopilot/route-manager/wp/true-bearing-deg");
}

#-------------------------------------------------------------------------------
INS.getDistance = func ()
{
   return getprop ("/autopilot/route-manager/wp/dist");
}

#-------------------------------------------------------------------------------
INS.getCourse = func ()
{
  var course = 0;

  if (me.leg_is_regular)
    course =  getprop (sprintf ("%s[%i]/leg-bearing-true-deg",
								waypoint_prop_root,
								me.from_wpt_index))
  else
  {
    if (me.from_wpt_index != me.to_wpt_index)
    {
	  var from_position = geo.Coord.new();
	  var to_position = geo.Coord.new();

	  from_position.set_latlon (getprop (sprintf ("%s[%i]/latitude-deg",
												waypoint_prop_root,
												me.from_wpt_index)),
								getprop (sprintf ("%s[%i]/longitude-deg",
												   waypoint_prop_root,
												   me.from_wpt_index)));
	  to_position.set_latlon (getprop (sprintf ("%s[%i]/latitude-deg",
												waypoint_prop_root,
												me.to_wpt_index)),
	                          getprop (sprintf ("%s[%i]/longitude-deg",
												waypoint_prop_root,
												me.to_wpt_index)));

	  course =  from_position.course_to(to_position);
	 }
	 else course = 0;
  }

  if (me.heading_is_mag) return course - me.magvar;
  else return course;
}

#-------------------------------------------------------------------------------
INS.getTimeToGo = func ()
{
  return getprop ("/autopilot/route-manager/wp/eta");
}

#-------------------------------------------------------------------------------
INS.setAlignLatitude = func (latitude)
{
  me.lat_drift_nm = (getprop (latitude_prop) - latitude) * 60;
  me.drift_nm = math.sqrt (me.lat_drift_nm * me.lat_drift_nm 
						   +
						   me.long_drift_nm * me.long_drift_nm);
  me.drift_vector_lat = me.lat_drift_nm / me.drift_nm;
  me.drift_vector_long = me.long_drift_nm / me.drift_nm;
  
}

#-------------------------------------------------------------------------------
INS.setAlignLongitude= func (longitude)
{
  me.long_drift_nm = (getprop (longitude_prop) - longitude) 
					* 
					60 
					* cos (getprop (latitude_prop)/deg_to_rad);
  me.drift_nm = math.sqrt (me.lat_drift_nm * me.lat_drift_nm 
						   +
						   me.long_drift_nm * me.long_drift_nm);
  me.drift_vector_lat = me.lat_drift_nm / me.drift_nm;
  me.drift_vector_long = me.long_drift_nm / me.drift_nm;
}

#-------------------------------------------------------------------------------
INS.setAlignHeading = func (heading)
{
  print ("Nothing done for the time being");
}

#-------------------------------------------------------------------------------

var drift_speed = 1.0/3600; #1NM per hour
var norm_align_duration = 240; #seconds
var stored_align_duration = 22; #seconds

INS.update = func (delta_t)
{
  #check for power
  if (me.elec_power.fed)
  {
   #simulate alignment and drift
   if ((me.switch_position == ins_normal_align)
        or
        (me.switch_position == ins_stored_align))
    {
        me.can_navigate_to_waypoint = false;

        me.drift_nm = me.drift_nm 
					  - 
					  4 * (delta_t / me.alignement_duration);
					  
        me.alignement_elapsed_time = me.alignement_elapsed_time 
							         + delta_t;

        if (me.drift_nm < 0.1) me.drift_nm = 0.1;
        	  
        me.lat_drift_nm =  me.drift_vector_lat * me.drift_nm;
        me.long_drift_nm =  me.drift_vector_long * me.drift_nm;
		if (me.drift_nm < min_drift) 
		  setprop (INS_ready_prop, true);
		else
		  setprop (INS_ready_prop, false);

    }
   else if (me.switch_position == ins_navigate)
   {
      me.lat_drift_nm = me.lat_drift_nm + me.drift_vector_lat * delta_t * drift_speed;
      me.long_drift_nm = me.long_drift_nm + me.drift_vector_long * delta_t * drift_speed;
   }

	  #raw data
	  if (me.can_navigate_to_waypoint)
	  {
		  me.distance = getprop ("/autopilot/route-manager/wp/dist");
		  if (me.heading_is_mag)
			me.bearing = getprop ("/autopilot/route-manager/wp/bearing-deg");
		  else
			me.bearing = getprop ("/autopilot/route-manager/wp/true-bearing-deg");
	  }
      else
	  {
		me.distance = 999.9;
		me.bearing = 0.0;
	  }
	  
	  me.magvar = getprop ("orientation/heading-deg")
				  -
				  getprop ("orientation/heading-magnetic-deg");

		#drifted values
		var bearing_rad = me.bearing * deg_to_rad;
		var X_waypoint = me.distance * math.sin (bearing_rad);
		var Y_waypoint = me.distance * math.cos (bearing_rad);
        var new_x = X_waypoint + me.long_drift_nm;
        var new_y = Y_waypoint + me.lat_drift_nm;
        me.distance = math.sqrt (new_x * new_x + new_y * new_y);
        me.bearing = math.atan2 (new_x, new_y) / deg_to_rad;
        if (me.bearing < 0) me.bearing = me.bearing + 360.0;
        
  }
  else
  {
    setprop (INS_ready_prop, false);
  }
}

#-------------------------------------------------------------------------------
INS.setToWaypoint = func (index)
{
  if (index < me.number_of_waypoints)
  me.to_wpt_index = index;
  setprop ("/autopilot/route-manager/current-wp", index);
  if ((me.to_wpt_index-me.to_wpt_index) == 1) me.leg_is_regular = true;
  else me.leg_is_regular = false;
  me.current_course = me.getCourse();
}

#-------------------------------------------------------------------------------
INS.nextToWaypoint = func ()
{
  if (me.to_wpt_index < (me.number_of_waypoints -1))
				me.setToWaypoint(me.to_wpt_index + 1);
}

#-------------------------------------------------------------------------------
INS.cycleToWaypoint = func ()
{
  if (me.to_wpt_index < (me.number_of_waypoints -1))
				me.setToWaypoint(me.to_wpt_index + 1);
  else if (me.from_wpt_index < (me.number_of_waypoints -1)) #cycle
				me.setToWaypoint(me.from_wpt_index + 1);
}

#-------------------------------------------------------------------------------
INS.previousToWaypoint = func ()
{
  if (me.to_wpt_index > 0)	me.setToWaypoint(me.to_wpt_index - 1);
}

#-------------------------------------------------------------------------------
INS.setFromWaypoint = func (index)
{
  if (index < me.number_of_waypoints)
  me.from_wpt_index = index;
  if ((me.to_wpt_index - me.from_wpt_index) > 1) me.leg_is_regular = false;
  me.current_course = me.getCourse();
}

#-------------------------------------------------------------------------------
INS.cycleFromWaypoint = func ()
{
  if (me.from_wpt_index < (me.to_wpt_index-1))
				me.setFromWaypoint(me.from_wpt_index + 1);
  else #cycle
				me.setFromWaypoint(0);
}

#-------------------------------------------------------------------------------
INS.switchUp = func ()
{
  if (me.switch_position == ins_off)
  {
    me.alignement_duration = stored_align_duration;
    me.elec_power.switchOn();
    me.switch_position = ins_stored_align;
  }
  else if (me.switch_position == ins_stored_align)
  {
    me.alignement_duration = norm_align_duration;
    me.switch_position = ins_normal_align;
  }
  else if (me.switch_position == ins_normal_align)
  {
    me.time_since_last_alignement = 0.0;
    me.switch_position = ins_navigate;
    me.alignement_elapsed_time = 0.0;
    setprop (INS_ready_prop, false);
  }
  setprop (INS_selector_prop, me.switch_position);
}

#-------------------------------------------------------------------------------
INS.switchDown = func ()
{
  if (me.switch_position == ins_navigate)
  {
    me.alignement_duration = norm_align_duration;
    me.switch_position = ins_normal_align;
  }
  else if (me.switch_position == ins_normal_align)
  {
    me.alignement_duration = stored_align_duration;
    me.switch_position = ins_stored_align;
  }
  else if (me.switch_position == ins_stored_align)
  {
    me.elec_power.switchOff();
    me.switch_position = ins_off;
    me.alignement_elapsed_time = 0.0;
    #reset the drift angle
    drift_angle = rand() * math.pi * 2;
    me.drift_vector_lat  = math.cos (drift_angle);
	me.drift_vector_long = math.sin (drift_angle);
	me.drift_nm = 4.0;
	setprop (INS_ready_prop, false);
  }
  setprop (INS_selector_prop, me.switch_position);
}

#-----------------------------------------------------------------------
#House keeping in case of flight plan change
INS.fplnChange = func ()
{
  var new_to_wp = getprop ("/autopilot/route-manager/current-wp");

  INS.number_of_waypoints = getprop ("/autopilot/route-manager/route/num");
  
  if ((!INS.can_navigate_to_waypoint)
	   and
	   new_to_wp != -1)
  {
    #flight plan initialised
	INS.to_wpt_index = 0;
	INS.can_navigate_to_waypoint = true;
  }
  
  if (INS.number_of_waypoints==0) #flight plan deleted
     INS.can_navigate_to_waypoint = false;
     
  if ((new_to_wp == -1) and INS.can_navigate_to_waypoint) #seauenced last wp
								new_to_wp = INS.number_of_waypoints - 1;#So we stick to it

  if ((INS.number_of_waypoints > 1) and INS.can_navigate_to_waypoint)
	{
	INS.has_minimum_flightplan = true;

	  if (new_to_wp != INS.to_wpt_index)
	  {
		#sequenced the waypoint
		if (new_to_wp > 0)
		 {
		  INS.setFromWaypoint (new_to_wp - 1);
		  INS.leg_is_regular = true;
		 }
		else
		 {
		   INS.from_wpt_index = 0;
		   INS.leg_is_regular = false;
		 }
  		  INS.to_wpt_index = new_to_wp;
	  }
	  INS.current_course = INS.getCourse();
	}
	else
	INS.has_minimum_flightplan = false;

  #Display house keeping
  #HSI

   if (!INS.can_navigate_to_waypoint)
     {
       if (HSI.nav_mode == ins_navigate) HSI.nav_mode = no_nav;
       setDisplayForNoWaypoint();
     }
   else if (!INS.has_minimum_flightplan)
    {
      if (HSI.ins_route_mode == leg_mode)
       {
         HSI.ins_route_mode = dir_mode;
         if (HSI.nav_mode == ins_navigate) dir_box.show();
         setDisplayForINSdirCrs();
       }
    }
}

setlistener ("/autopilot/route-manager/current-wp",
			 INS.fplnChange, 0, 0);

setlistener ("/autopilot/route-manager/route/num",
			 INS.fplnChange, 0, 0);
