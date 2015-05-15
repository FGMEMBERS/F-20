########################################################################
# Hydraulic system base classes
########################################################################

var PSI_to_Pa = 6894.757;
var L_to_cu_m = 1e-3;

#IMPORTANT NOTICE : outgoing flow is negative incoming flow is positive

########################################################################
#define a class for an hydraulic source

var HydraulicComponent = {pressure : 0,
						   flow_rate : 0};
       

########################################################################
#Define an hydraulic system

var HydraulicSystem = {current_dynamic_pressure : 0,						
                        components : [],
                        circuits : []};
                        
#-----------------------------------------------------------------------                       
HydraulicSystem.new = func ()
{
  var created_system = {parents : [HydraulicSystem]};
  created_system.components = [];
  created_system.components = [];
  return created_system;
}
						

#-----------------------------------------------------------------------
HydraulicSystem.addComponent = func (component)
{
  append (me.components, component);
}

#-----------------------------------------------------------------------
HydraulicSystem.addCircuit = func (circuit)
{
  append (me.circuits, circuit);
}



#-----------------------------------------------------------------------
HydraulicSystem.update = func (delta_t)
{
  var index = 0;
  
  me.current_dynamic_pressure = getprop("/fdm/jsbsim/aero/qbar-psf");
  
  forindex (index; me.components) me.components[index].update(delta_t);
  forindex (index; me.circuits) me.circuits[index].update(delta_t);

}
