################################################################################
#Payload switcher

#note : this code does not handle multiple ejection racks nor intends to.

# Uses :
# payload.nas
# stores.nas

#Constants

var station_button_off = 0;
var station_button_present = 1;
var station_button_ready = 2;
var station_button_hanging = 3;

var station_button_offset_map = [{x : 0, y : 0},
                                 {x : 1, y :0},
                                 {x : 1, y : 1},
                                 {x : 0, y : 1}];
                                 
var station_button_names = ["TipL",
                             "OuterL",
                             "InnerL",
                             "CTR",
                             "InnerR",
                             "OuterR",
                             "TipR"];
                             
var emergency_jettison_prop = "/f-20/stores/management-panel/emerJettButton";
var jettison_prop = "/f-20/stores/management-panel/jettButton";            

var arm_brightness = 0.5;
var arm_brightness_prop = "/f-20/stores/management-panel/intensity";                     
                    
var JettisonAll = 0;                             
var JettisonOff = 1;
var JettisonSelect = 2;                                                                                    
var selective_jettison_switch_position = JettisonOff;

var jettison_selected = [false,
					      false,
					      false,
					      false,
					      false,
					      false,
					      false];
					      
var launchable_properties = [{type : AIM_120A,
                              thrust : 3000,
                              burn_time : 7},
                              {type : AIM_9L,
							   thrust :2000,
							   burn_time : 3}];				      

var armament_control_panel = GenericLoad.new (DC_Essential,
											  10, #Watts
											  24); #Volts
armament_control_panel.switchOn();											  

#-------------------------------------------------------------------------------
var launchableIndex = func (load)
{
  forindex (var i; launchable_properties) 
  if (load == launchable_properties[i].type) return i;
  else return -1;
}

#-------------------------------------------------------------------------------
var toggleSmokeGenerator = func (station)
{
  if (station == left_tip) left_smoking = ! left_smoking;
  if (station == right_tip) right_smoking = ! right_smoking;
  setprop ("/f-20/stores/smoke/smoke-l", left_smoking);
  setprop ("/f-20/stores/smoke/smoke-r", right_smoking);
}

#-------------------------------------------------------------------------------
var setStationButton = func (station, status)
{

  setprop (sprintf ("/f-20/stores/management-panel/%s/x-shift",
					 station_button_names[station]),
		    station_button_offset_map [status].x);
		    
  setprop (sprintf ("/f-20/stores/management-panel/%s/y-shift",
					 station_button_names[station]),
		    station_button_offset_map [status].y);  
}

#-------------------------------------------------------------------------------
var pressStationButton = func (station)
{
  var animation_prop = sprintf ("/f-20/stores/management-panel/%s/pressed",
								 station_button_names[station]);

  if (armament_control_panel.fed
      and selective_jettison_switch_position ==  JettisonSelect
      and is_jettisonable[current_payload[station]]
      and jettison_selected [station] == false)
      {
       jettison_selected [station] = true;
      }
      else jettison_selected [station] = false;
      
  #animation of the button
  interpolate (animation_prop, 1, 0.1);    
  settimer (func{interpolate (animation_prop, 0, 0.1);},0.1);
}

#-------------------------------------------------------------------------------
var deselectAllStations = func()
{
  forindex (var station; jettison_selected) jettison_selected [station] = false;
}

#-------------------------------------------------------------------------------
var jettisonSwitchUp = func 
{
  selective_jettison_switch_position = selective_jettison_switch_position + 1;
  
  if (selective_jettison_switch_position > JettisonSelect)
    selective_jettison_switch_position = JettisonSelect;
        
  setprop ("/f-20/stores/management-panel/selector", 
			selective_jettison_switch_position);
}

#-------------------------------------------------------------------------------
var jettisonSwitchDn = func 
{
  selective_jettison_switch_position = selective_jettison_switch_position - 1;
  
  if (selective_jettison_switch_position < JettisonAll)
    selective_jettison_switch_position = JettisonAll;
  deselectAllStations();
        
  setprop ("/f-20/stores/management-panel/selector", 
			selective_jettison_switch_position);
}

#-------------------------------------------------------------------------------
var armBrtUp = func 
{
  arm_brightness = arm_brightness + 0.1;
  
  if (arm_brightness > 1.0) arm_brightness = 1.0;
        
  setprop (arm_brightness_prop, arm_brightness);
}

#-------------------------------------------------------------------------------
var armBrtDn = func 
{
  arm_brightness = arm_brightness - 0.1;
  
  if (arm_brightness < 0.1) arm_brightness = 0.1;
        
  setprop (arm_brightness_prop, arm_brightness);
}

#-------------------------------------------------------------------------------
var emerJettisonPress = func 
{
  		
  forindex (var station; current_payload)
  {
    if (is_jettisonable[current_payload[station]]) jettison_selected [station] = true;
    else jettison_selected [station] = false;
  }					    
  executeSelectiveJettison(); #always hot
  
  #animation of the button
  interpolate (emergency_jettison_prop, 1, 0.1);    
  settimer (func{interpolate (emergency_jettison_prop, 0, 0.1);},0.1);
}

#-------------------------------------------------------------------------------
var jettisonPress = func 
{				  
  if (armament_control_panel.fed)
  {
    if (selective_jettison_switch_position == JettisonAll)
       executeAllJettison ();
    else
       executeSelectiveJettison();
  }
  
  #animation of the button
  interpolate (jettison_prop, 1, 0.1);    
  settimer (func{interpolate (jettison_prop, 0, 0.1);},0.1);
}

#-------------------------------------------------------------------------------
var executeSelectiveJettison = func ()
{
  var station = 0;
  var adapter = Empty;
  var launchable_index = -1;
  var launcher = nil;
  var drag_index =  getprop (drag_index_prop);

  #start by putting the actual payload
  forindex (station; current_payload)
  {
    if (jettison_selected [station])
    {
      #decrease the drag
      drag_index = drag_index - drag_indices[current_payload[station]];
      
      if (station == left_tip
          or station == right_tip)
          {
            if (current_payload[station] == smoke_generator)
            {
				# toggle smoke generator
                toggleSmokeGenerator (station);
            }
            else
            {
				# payload needs firing
				launchable_index = launchableIndex(current_payload[station]);
				launcher = Launcher.new (getIdent (station,current_payload),
										 launchable_properties[launchable_index].burn_time,
										 launchable_properties[launchable_index].thrust);
				dropSubmodel (getIdent(station, current_payload));                                      
				
				setprop (weight_props [station],
						  getprop (weight_props [station])
						  -
						  payload_weights [current_payload[station]]);  
		   }             
          }
          else #drop load
          {
           if (current_payload[station] == Fuel_tank)
            setprop (drop_tank_qty_props [station], 0);                       
           else           
            setprop (weight_props [station],
                      getprop (weight_props [station])
                      -
					  payload_weights [current_payload[station]]);   
          
          dropSubmodel (getIdent(station, current_payload));                               
        }
       if (current_payload[station] != smoke_generator) 
											current_payload[station] = Empty;
       
       #identify the adapters and drop them
         adapter = -1;
         forindex (var adapter_index; adapter_names)
          if (checkSubmodelExistence (adapter_names[adapter_index].names_per_station [station]))
           adapter = adapter_index;

         if (adapter != -1)
         {
          dropSubmodel (adapter_names[adapter].names_per_station [station]);
          drag_index = drag_index - adapter_physics [adapter].drag_index;
          setprop (weight_props [station],
				    getprop (weight_props[station]) 
				    - adapter_physics [adapter].weight);
        }          
     }
    }
    
    #handle center station speed brake limiter
    if (current_payload[center] != Empty)
				updateCenterStationSpeedBrakesLimit (true);
    else
				updateCenterStationSpeedBrakesLimit (false);

	#house keeping
	 forindex (station; current_payload)
	  previous_payload[station] = current_payload[station];
	  
    setprop (drag_index_prop, drag_index);
}

#-------------------------------------------------------------------------------
var executeAllJettison = func ()
{
  var station = 0;
  var adapter = "";
  var drag_index =  getprop (drag_index_prop);

  #start by putting the actual payload
  forindex (station; current_payload)
  {
    if (is_jettisonable[current_payload[station]])
    {
      #decrease the drag
      drag_index = drag_index - drag_indices[current_payload[station]];
      
      if (station == left_tip
          or station == right_tip)
          {
            # tips are not fired
            #launchable_index = launchableIndex(current_payload[station]);
            #launcher = Launcher.new (getIdent (station,current_payload),
			#						 launchable_properties[launchable_index].burn_time,
            #                         launchable_properties[launchable_index].thrust);
            #dropSubmodel (getIdent(station, current_payload));             
            #setprop (weight_props [station],
            #          getprop (weight_props [station])
            #          -
		    #		  payload_weights [current_payload[station]]);               
          }
          else #drop load
          {
           if (current_payload[station] == Fuel_tank)
            setprop (drop_tank_qty_props [station], 0);                       
           else           
            setprop (weight_props [station],
                      getprop (weight_props [station])
                      -
					  payload_weights [current_payload[station]]);   
          
           dropSubmodel (getIdent(station, current_payload));
          }
       current_payload[station] = Empty;
     }
         #identify the adapters and drop them
         adapter = -1;
         forindex (var adapter_index; adapter_names)
          if (checkSubmodelExistence (adapter_names[adapter_index].names_per_station [station]))
           adapter = adapter_index;

         if (adapter != -1)
         {
          dropSubmodel (adapter_names[adapter].names_per_station [station]);
          drag_index = drag_index - adapter_physics [adapter].drag_index;
          setprop (weight_props [station],
				    getprop (weight_props[station]) 
				    - adapter_physics [adapter].weight);
        }     
    }
    #Drop pylons 
      # Place pylons if needed, always symmetrical

  #outer
    if (checkSubmodelExistence ("outer_pylons") != nil)
      {
        dropSubmodel ("outer_pylons");
        drag_index = drag_index - 2*pylon_drag_index;
        setprop (weight_props [outer_left],
				  getprop (weight_props[outer_left]) - outboard_pylon_weight);
        setprop (weight_props [outer_right],
				  getprop (weight_props[outer_right]) - outboard_pylon_weight);
      }

   #inner
    if (checkSubmodelExistence ("inner_pylons") != nil)
      {
        dropSubmodel ("inner_pylons");
        drag_index = drag_index - 2*pylon_drag_index;
        setprop (weight_props [inner_left],
				  getprop (weight_props[inner_left]) - inboard_pylon_weight);
        setprop (weight_props [inner_right],
				  getprop (weight_props[inner_right]) - inboard_pylon_weight);
      }   

   #center
    if (checkSubmodelExistence ("center_pylon") != nil)
      {
        dropSubmodel ("center_pylon");
        drag_index = drag_index - pylon_drag_index;
        setprop (weight_props [center],
				  getprop (weight_props[center]) - centerline_pylon_weight);
      }      
    
    #handle center station speed brake limiter
    if (current_payload[center] != Empty)
				updateCenterStationSpeedBrakesLimit (true);
    else
				updateCenterStationSpeedBrakesLimit (false);

	#house keeping
	 forindex (station; current_payload)
	  previous_payload[station] = current_payload[station];
	  
    setprop (drag_index_prop, drag_index);
}

#-------------------------------------------------------------------------------
var switchOffAllStations = func()
{
  forindex (var station; jettison_selected)     
     setStationButton (station, station_button_off);
}

#-------------------------------------------------------------------------------
var updateArmamentPanel = func (deltaT)
{

  if (armament_control_panel.fed)
  {
    if (selective_jettison_switch_position == JettisonSelect)
    {
      forindex (var station; current_payload)
      {
        if (current_payload[station] != Empty)
        {
  	     if (jettison_selected [station]) 
  	           setStationButton (station, station_button_ready); 
		 else setStationButton (station, station_button_present); 
		 		 		 
        }
        else 
	   {
		 jettison_selected [station] = false;
		 setStationButton (station, station_button_off);
	   }        
      }
    }
    else switchOffAllStations();
  }
  else 
   {
    deselectAllStations();
    switchOffAllStations();
   }  
}
