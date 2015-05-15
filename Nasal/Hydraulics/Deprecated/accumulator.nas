########################################################################
#define a class for a Accumulator
Accumulator = {max_capacity : 200,
		   current_capacity : 200,
		   nominal_pressure : 12,		   
		   nominal_charge_current : 2,
		   attached_circuit : nil,
		   charging : false,
		   charging_source : nil};

#-------------------------------------------------------------------------------
Accumulator.new = func (electrical_circuit,
                    capacity, 
					pressure,
					circuit,
					priority,
					charge_current) #capacity in Amp/hour
{
  
  var returned_object = {parents : [HydraulicSource.new (electrical_circuit),
									 ElectricalLoad, Accumulator]};
  returned_object.max_capacity = capacity;
  returned_object.current_capacity = capacity;
  returned_object.nominal_pressure = pressure;
  returned_object.nominal_charge_current = charge_current;
  returned_object.attached_circuit = circuit;
  circuit.connectLoad (returned_object);
  return returned_object;
  
}


#-------------------------------------------------------------------------------
Accumulator.feed = func (source_feed) 
{
  if (me.pressurised)
  {
   if (me.attached_circuit.current_priority > me.priority) me.charging = true;
   me.charging_source = source_feed;
  }
}

#-------------------------------------------------------------------------------
Accumulator.feedBus = func  
{
  if (!me.charging and me.pressurised) 
  {
   var my_feed = SourceFeed (me, me.pressure, me.priority);
   attached_circuit.feed (my_feed);
  }  
}

#-------------------------------------------------------------------------------
Accumulator.updateCharge = func (delta_t)
{
 if (me.pressurised)
  {
	  if (!me.charging) 
	  {
		  me.current_capacity = me.current_capacity 
								- 
								me.power_demand/me.pressure * delta_t / 3600;
		  var charge_ratio = me.current_capacity / me.max_capacity;
		  if (charge_ratio  < 0.2)
		   me.pressure =  me.nominal_pressure/((0.2-charge_ratio)/0.2);  
		  if (charge_ratio < 0) charge_ratio = 0;
	  }
	  else 
	  {		
		me.current_capacity = me.current_capacity 
							  +	 
							  me.nominal_charge_current * delta_t / 3600;
		if (current_capacity >= me.max_capacity) 
			current_capacity = me.max_capacity
		else 
			me.charging_source.addPowerDemand (me.pressure * me.nominal_charge_current);
	  }
   }
}
