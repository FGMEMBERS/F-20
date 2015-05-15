########################################################################
#define a class for a battery
Battery = {max_capacity : 200,
		   current_capacity : 200,
		   nominal_voltage : 12,		   
		   nominal_charge_current : 2,
		   attached_bus : nil,
		   charging : false,
		   charging_source : nil};

#-------------------------------------------------------------------------------
Battery.new = func (electrical_circuit,
                    capacity, 
					voltage,
					bus,
					priority,
					charge_current) #capacity in Amp/hour
{
  
  var created_battery = {parents : [ElectricalSource.new (electrical_circuit),
									 ElectricalLoad, Battery]};
  created_battery.max_capacity = capacity;
  created_battery.current_capacity = capacity;
  created_battery.nominal_voltage = voltage;
  created_battery.voltage = voltage;
  created_battery.nominal_charge_current = charge_current;
  created_battery.attached_bus = bus;
  electrical_circuit.addBattery(created_battery);
  bus.connectLoad (created_battery);
  return created_battery;
  
}


#-------------------------------------------------------------------------------
Battery.feed = func (source_feed) 
{
  if (me.energised)
  {
   me.charging_source = source_feed;
  }
}

#-------------------------------------------------------------------------------
Battery.feedBus = func  
{
   if (me.attached_bus.current_priority > me.priority) me.charging = true;
   else me.charging = false;     
  if (!me.charging and me.energised) 
  {
   var my_feed = SourceFeed.new (me, me.priority, me.voltage);
   me.attached_bus.feed (my_feed);
  }  
}

#-------------------------------------------------------------------------------
Battery.updateCharge = func (delta_t)
{
 if (me.energised)
  {
	  if (!me.charging) 
	  {
		  me.current_capacity = me.current_capacity 
								- 
								me.power_demand/me.voltage * delta_t / 3600;
		  var charge_ratio = me.current_capacity / me.max_capacity;
		  if (charge_ratio  < 0.2)
		   me.voltage =  me.nominal_voltage/((0.2-charge_ratio)/0.2);  
		  if (charge_ratio < 0) charge_ratio = 0;
	  }
	  else 
	  {	
		me.current_capacity = me.current_capacity 
							  +	 
							  me.nominal_charge_current * delta_t / 3600;
		if (me.current_capacity >= me.max_capacity) 
			me.current_capacity = me.max_capacity
		else 
			me.charging_source.source.addPowerDemand (me.voltage * me.nominal_charge_current);
	  }
   }
}

#----------------------------------------------------------------------- 
 Battery.switchOff = func 
 {
    me.energised = false;    
 }
 
#----------------------------------------------------------------------- 
 Battery.switchOn = func 
 {
    me.energised = true;    
 }
