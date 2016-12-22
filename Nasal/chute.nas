#Brake Parachute

var engine_thrust_prop = props.globals.getNode ("/fdm/jsbsim/propulsion/engine/thrust-lbs");

var handle_stowed = 0;
var deploy_chute = 1;
var release_chute = 2;
var chute_handle = handle_stowed;
var chute_handle_prop = props.globals.getNode ("/controls/flight/chute-handle");
var chute_deployement_prop = props.globals.getNode ("/fdm/jsbsim/fcs/chute-deployement-norm");
var chute_visual_prop = "/f-20/chute/deployement-norm";

var chute_elev_angle_prop = props.globals.getNode ("/f-20/chute/chute-elev-angle");
var chute_azim_angle_prop = props.globals.getNode ("/f-20/chute/chute-azim-angle");
var chute_decay_angle_prop = props.globals.getNode ("/f-20/chute/chute-decay-angle");
var canopy_openning_prop = props.globals.getNode ("/f-20/chute/canopy");
var chute_angle = 0.0;
var chute_deployement = 0.0;
var chute_deployement_rate = 1; #2 seconds for full deployment

var flow_speed = 0.0;

var breakdown_flow_speed = 400.0; #Kt
var drop_flow_speed = 0.0; #Kt

var chute_azimuth = 0.0;
var chute_rotation_factor = 1.0;
var chute_rotation_speed = 0.0; 
var max_chute_rotation_speed = 180; #degrees per second

var chute_is_present = true;

#-------------------------------------------------------------------------------
var attachChute = func (ident)
{  
  if (ident == "" or ident == nil) return; #sanity check
  
  var submodel_index = checkSubmodelExistence (ident);
  
  if (submodel_index != nil) #the model has a node
  {
    if (submodelIsValid(submodel_index))
    {
     #the model is either there or flying somewhere, need to have it attached
     setprop (sprintf("/ai/models/ballistic[%i]/controls/slave-to-ac",submodel_index), true);
     setprop (sprintf("/ai/models/ballistic[%i]/controls/invisible",submodel_index), false);    
    }
    else
    {
     #the model is spent, reattach and trigger again
     setprop (sprintf("/f-20/stores/%s/trigger", ident), true);
    }
  }
  else #we need to create it
  {    
    setprop (sprintf("/f-20/stores/%s/trigger", ident), true);
  }
}

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
       setprop (chute_visual_prop, chute_deployement);
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
    if (chute_is_present) 
    {
     setprop (chute_visual_prop, 0);     
     attachChute("chute");
     registerChute();
    }
   }
  else if (chute_handle == deploy_chute)
  {
    chute_handle = release_chute;
    if (chute_is_present) dropSubmodel("chute");
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

#-------------------------------------------------------------------------------   
var chuteOnGround = func(n) {
    var node = props.globals.getNode(n.getValue(), 1);
    var submodel_index = checkSubmodelExistence ("chute");

    geo.put_model("Aircraft/F-20/Models/dropped-chute.xml",
        node.getNode("impact/latitude-deg").getValue(),
        node.getNode("impact/longitude-deg").getValue(),
        node.getNode("impact/elevation-m").getValue() + 0.25, # +0.25 to ensure the droptank isn't buried
        node.getNode("impact/heading-deg").getValue(),
    0, 0);    
          
     setprop (sprintf("/ai/models/ballistic[%i]/controls/slave-to-ac",submodel_index), true);
     setprop (sprintf("/ai/models/ballistic[%i]/controls/invisible",submodel_index), false);
     setprop ("/f-20/stores/chute/trigger", false);
}

setlistener("/f-20/stores/chute/impact", chuteOnGround);

