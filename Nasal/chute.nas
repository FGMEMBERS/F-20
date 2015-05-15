#Brake Parachute

var engine_thrust_prop = props.globals.getNode ("/fdm/jsbsim/propulsion/engine/thrust-lbs");

var handle_stowed = 0;
var deploy_chute = 1;
var release_chute = 2;
var chute_handle = handle_stowed;
var chute_handle_prop = props.globals.getNode ("/controls/flight/chute-handle");
var chute_deployement_prop = props.globals.getNode ("/fdm/jsbsim/fcs/chute-deployement-norm");

var chute_elev_angle_prop = props.globals.getNode ("/f-20/chute/chute-elev-angle");
var chute_azim_angle_prop = props.globals.getNode ("/f-20/chute/chute-azim-angle");
var chute_decay_angle_prop = props.globals.getNode ("/f-20/chute/chute-decay-angle");
var canopy_openning_prop = props.globals.getNode ("/f-20/chute/canopy");
var chute_angle = 0.0;
var chute_deployement = 0.0;
var chute_deployement_rate = 1; #2 seconds for full deployment

var flow_speed = 0.0;

var breakdown_flow_speed = 400.0; #Kt
var drop_flow_speed = 20.0; #Kt

var chute_azimuth = 0.0;
var chute_rotation_factor = 1.0;
var chute_rotation_speed = 0.0; 
var max_chute_rotation_speed = 180; #degrees per second

var chute_is_present = true;

#-------------------------------------------------------------------------------   
var registerChute = func {settimer (updateChute, 0);}

var updateChute = func
{
  if (chute_handle == deploy_chute and chute_is_present)
  {
    flow_speed = IAS + engine_thrust_prop.getValue() / 16000.0 * 300.0;  
    if (flow_speed > breakdown_flow_speed or flow_speed  < drop_flow_speed)
       {
         chute_deployement = 0.0;
         chute_is_present = false;
       }
    if (chute_deployement < 1.0) 
     {
       chute_deployement = chute_deployement + chute_deployement_rate * deltaT;
       if (chute_deployement > 1.0) chute_deployement = 1.0;
       chute_decay_angle_prop.setValue (-Alpha);
     }
    else
     {
       #TODO : add sideslip
       chute_decay_angle_prop.setValue (-Alpha + (drop_flow_speed/flow_speed)*5.0);
       chute_rotation_speed = chute_rotation_factor * flow_speed;
       if (chute_rotation_speed > max_chute_rotation_speed) chute_rotation_speed = max_chute_rotation_speed;
       chute_azimuth = chute_azimuth + chute_rotation_speed * deltaT;
       chute_elev_angle_prop.setValue (drop_flow_speed/flow_speed * 9.0);
       chute_azim_angle_prop.setValue (chute_azimuth);       
     }
    
     if (chute_is_present) registerChute();
     else chute_deployement = 0.0;
     chute_deployement_prop.setValue (chute_deployement);
     if (chute_deployement <= 0.85) canopy_openning_prop.setValue(0.05);
     else canopy_openning_prop.setValue((chute_deployement-0.85)/0.15);
  }  
}

#-------------------------------------------------------------------------------   
var stowChuteHandle = func 
{
  chute_handle = handle_stowed;
  chute_handle_prop.setValue (chute_handle);  
}

#-------------------------------------------------------------------------------   
var chuteActivate = func 
{
  if (chute_handle == handle_stowed)
   {
    chute_handle = deploy_chute;
    if (chute_is_present) registerChute();
   }
  else if (chute_handle == deploy_chute)
  {
    chute_handle = release_chute;
    chute_is_present = false;
    chute_deployement = 0.0;
    chute_deployement_prop.setValue(chute_deployement);
    settimer(stowChuteHandle, 0.8);
  }

  chute_handle_prop.setValue(chute_handle);  
}

#-------------------------------------------------------------------------------   
var repackChute = func 
{

  chute_is_present = true;

}

