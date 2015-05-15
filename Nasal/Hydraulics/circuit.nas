########################################################################
# Define a class for an electrical circuit

var elastic_constant = 1e10;
var delta_pressure = 50 * PSI_to_Pa; #PSI
var regulating_valve_constant = 0;#1e-13; #m^3 per pa

var HydraulicCircuit = {hydraulic_system : nil,
						 regulated_pressure : 3000*PSI_to_Pa, #PSI
						 regulation_threshold : 3100*PSI_to_Pa,
					     attached_components : nil};

#-------------------------------------------------------------------------------
HydraulicCircuit.new = func  (hydraulic_system, regulated_pressure)
 {
    var created_circuit = { parents : [HydraulicComponent, HydraulicCircuit]};
	created_circuit.hydraulic_system = hydraulic_system;
	created_circuit.regulated_pressure = regulated_pressure * PSI_to_Pa;
	created_circuit.attached_components = [];
	created_circuit.regulation_threshold = created_circuit.regulated_pressure - delta_pressure;
    hydraulic_system.addCircuit (created_circuit);
    return created_circuit;
 }

#------------------------------------------------------------------------------- 
HydraulicCircuit.update = func (delta_t)
{
  var index = 0;
  var total_flow = 0;
  
  forindex (index; me.attached_components) 
  {
   total_flow = total_flow - me.attached_components[index].flow_rate;
  
  }
  
  #recirculate hydraulic fluid if pressure is too important
  if (me.pressure > me.regulation_threshold)  
    total_flow = total_flow - 1e-6;# regulating_valve_constant * (me.pressure - me.regulated_pressure);
    
  # The circuit is modelled like an inflated vessel with pressure 
  # proportional to volume
  me.pressure = me.pressure + elastic_constant * total_flow * delta_t;
  if (me.pressure < PSI_to_Pa) me.pressure = 0; #if below 1 PSI pressure is 0
}

#------------------------------------------------------------------------------- 
HydraulicCircuit.connectComponent = func (component)
{
  append (me.attached_components, component);
}
