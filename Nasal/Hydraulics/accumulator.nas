########################################################################
#define a class for an hydraulic accumulator

#constants
var flow_constant = 1e-10;#1/3000/PSI_to_Pa;
var unusable_ratio = 0.05;

Accumulator = {consumer_circuit : nil,
			   charge_pressure : 3000,
			   max_gas_volume : 0,
			   min_gas_volume : 0,
			   gas_volume : 0.05, 
			   volume : 1};

#-------------------------------------------------------------------------------
Accumulator.new = func (hydraulic_circuit,
                         volume, 
						 charge_pressure)
{  
  var created_accumulator = {parents : [HydraulicComponent, 
									     Accumulator]};
  created_accumulator.volume = volume * L_to_cu_m;
  created_accumulator.min_gas_volume = volume * unusable_ratio * L_to_cu_m;
  created_accumulator.max_gas_volume = volume * (1 - unusable_ratio) * L_to_cu_m;
  created_accumulator.gas_volume = 0.4 * volume * L_to_cu_m;
  created_accumulator.consumer_circuit = hydraulic_circuit;  
  created_accumulator.charge_pressure =  charge_pressure * PSI_to_Pa;
  created_accumulator.pressure = charge_pressure * PSI_to_Pa;
  hydraulic_circuit.hydraulic_system.addComponent (created_accumulator);
  hydraulic_circuit.connectComponent (created_accumulator);
  return created_accumulator;  
}

#-------------------------------------------------------------------------------
Accumulator.update = func (delta_t)
{
  me.flow_rate = (me.consumer_circuit.pressure - me.pressure) * flow_constant;
  var initial_volume = me.gas_volume;
  me.gas_volume = me.gas_volume - me.flow_rate * delta_t;
  if (me.gas_volume > me.max_gas_volume) 
  {
   me.gas_volume = me.max_gas_volume;
   me.flow_rate = 0;
  }
  if (me.gas_volume < me.min_gas_volume) 
  {
    me.gas_volume =  me.min_gas_volume;
    me.flow_rate = 0;
  }  

  me.pressure = me.pressure +
                me.charge_pressure * (math.pow(me.volume/me.gas_volume, 1.4)
									  -
									  math.pow(me.volume/initial_volume, 1.4));
}
