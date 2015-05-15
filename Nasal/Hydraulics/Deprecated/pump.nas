########################################################################
#define a class for a generator
var regulation_factor = 2;
var alternator_efficiency = 0.9;

var Pump = {regulated_pressure : 115,
			 rating : 200,
			 tripped : false,
			 low_rpm : 1000,
			 consummer_circuit : nil};

#-------------------------------------------------------------------------------
Pump.new = func (hydraulic_system,
                  pressure, 
				  rating,
				  circuit,
				  low_rpm,
				  priority)
 {    
    returned_object = {parents : [HydraulicSource.new (hydraulic_system), Pump]};
    returned_object.regulated_pressure = pressure;
    returned_object.rating = rating;
    returned_object.consummer_circuit = circuit;
    returned_object.priority = priority;
    returned_object.low_rpm = low_rpm;
    hydraulic_system.addPump (returned_object);
    return returned_object;
 }
  
#------------------------------------------------------------------------------- 
Pump.computePowerConsumption = func (deltaT)
 {
    var mech_power_demand = 0;
    var total_load = 0;
    
    if (!me.pressurised) return 0;
    
    var hydraulic_power = me.power_demand;
    me.power_demand = 0;
    
    if (hydraulic_power > me.rating) 
        {
            me.pressure = regulated_pressure * generator_rating /hydraulic_power;
            mech_power_demand = me.rating/ alternator_efficiency;
        }
    else
        mech_power_demand = hydraulic_power/ alternator_efficiency;
   
    if (me.pressure < low_AC_pressure) 
    {
      me.pressure = 0; 
      me.tripped = true;
      me.pressurised = false;
      return 0;
    }
    
     return mech_power_demand;					
 }
 
#------------------------------------------------------------------------------- 
Pump.setRPM = func (RPM)
 {    
    var target_pressure = 0;
    if (RPM < me.low_rpm) target_pressure = RPM/trip_rpm * me.regulated_pressure;
    else target_pressure = me.regulated_pressure;
    
    me.pressure = me.pressure + regulation_factor 
							   * (target_pressure - me.pressure) 
							   * deltaT;
 }
 
#----------------------------------------------------------------------- 
 Pump.switchOff = func 
 {
    me.pressurised = false;    
 }
 
#----------------------------------------------------------------------- 
 Pump.switchOn = func 
 {
   if (!me.tripped) me.pressurised = true;    
 }
 
 #----------------------------------------------------------------------- 
 Pump.switchReset = func 
 {
    me.tripped = false;
    me.pressurised = true;    
 }
 
 #----------------------------------------------------------------------- 
 Pump.feed = func 
 {
   if (me.pressurised)
   {
    var root_feed = SourceFeed.new (me, me.priority, me.pressure);    
    me.consummer_circuit.feed (root_feed);
   }
 }
