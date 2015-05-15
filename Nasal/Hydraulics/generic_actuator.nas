########################################################################
# Base class for an actuator connected to the JSBSim FDM
########################################################################

#constants
var max_q = 1800; #pounds per square feet

#actuator class
var Actuator = {circuits : nil,
                 hydraulic_system : nil,
				 number_of_feeds : 0,
                 equivalent_bore : 0,
				 position_property : nil,
				 max_rate : 0,				#displacement per second
				 nominal_pressure : 0,
				 previous_position : 0,
				 target_position : 0,
				 connected : false,
				 current_position : 0};

#-----------------------------------------------------------------------
Actuator.new = func (min_stroke,
					  max_stroke,
				 	  displacement, #litres
					  full_stroke_min_time,					  
					  nominal_pressure,
				 	  position_property)
{
  var created_actuator = {parents:[HydraulicComponent,
								   Actuator]};
  created_actuator.max_rate =  (max_stroke - min_stroke) / full_stroke_min_time;
  created_actuator.nominal_pressure = nominal_pressure *  PSI_to_Pa;
  created_actuator.equivalent_bore = displacement * L_to_cu_m / (max_stroke - min_stroke);
  created_actuator.circuits = [];
  created_actuator.position_property = position_property;
  return created_actuator;
}

#-----------------------------------------------------------------------
Actuator.connectToCircuit = func (circuit)
{
  append (me.circuits, circuit);
  if (!me.connected)
  {
   me.hydraulic_system = circuit.hydraulic_system;
   me.hydraulic_system.addComponent(me);
   me.connected = true;
  }
  circuit.connectComponent (me);
  me.number_of_feeds = me.number_of_feeds + 1;
}

#-----------------------------------------------------------------------
Actuator.update = func (delta_t)
{
  var index = 0;

    #compute the flow rate per feeds				   
    me.previous_position = me.current_position;
    
    #simulate the decrease in authority as speed exceeds a maximum
    current_nominal_pressure = 0;
    if (me.hydraulic_system.current_dynamic_pressure > max_q) 
		var  current_nominal_pressure = me.hydraulic_system.current_dynamic_pressure/max_q 
										* me.nominal_pressure;
    else var current_nominal_pressure = me.nominal_pressure;
    
    #compute an average pressure
    me.pressure = 0;
    forindex (index;me.circuits) 
    {
       me.pressure = me.pressure + me.circuits[index].pressure
									/
									me.number_of_feeds;
	} 
	
    var rate = me.pressure / current_nominal_pressure * me.max_rate;
    
    if (me.current_position < me.target_position)
    {
      me.current_position = me.current_position + delta_t * rate;
      if (me.current_position > me.target_position) 
					me.current_position = me.target_position;
    }
    else 
    {
      me.current_position = me.current_position - delta_t * rate;
      if (me.current_position < me.target_position)
					me.current_position = me.target_position;
    }
    setprop (me.position_property, me.current_position);
    me.flow_rate = math.abs(me.current_position-me.previous_position)*me.equivalent_bore
				   /
				   me.number_of_feeds
				   /
				   delta_t;    
}

#-----------------------------------------------------------------------
Actuator.setTarget = func (target)
{
  me.target_position = target;
}
