########################################################################
#define a class for a generator
var regulation_factor = 2;
var alternator_efficiency = 0.9;

var Generator = {regulated_voltage : 115,
				 min_voltage : 100,
				 rating : 200,
				 tripped : false,
				 low_rpm : 1000,
				 cutoff_rpm : 500,
				 rpm : 0,
				 consummer_bus : nil};

#-------------------------------------------------------------------------------
Generator.new = func (electrical_system,
                      voltage, 
					  rating,
					  bus,
					  low_rpm,
					  cutoff_rpm,
					  priority)
 {    
    created_generator = {parents : [ElectricalSource.new (electrical_system), Generator]};
    created_generator.regulated_voltage = voltage;
    created_generator.min_voltage = 0.5 * voltage;
    created_generator.rating = rating;
    created_generator.consummer_bus = bus;
    created_generator.priority = priority;
    created_generator.low_rpm = low_rpm;
    created_generator.cutoff_rpm = cutoff_rpm;
    electrical_system.addGenerator (created_generator);
    return created_generator;
 }
  
#------------------------------------------------------------------------------- 
Generator.computePowerConsumption = func (deltaT)
 {
    var mech_power_demand = 0;
    var total_load = 0;
    
    if (!me.energised) return 0;
    
    var electrical_power = me.power_demand;
    me.power_demand = 0;
    
    if (electrical_power > me.rating) 
        {
            me.voltage = me.regulated_voltage * me.rating /electrical_power;
            mech_power_demand = me.rating/ alternator_efficiency;
        }
    else
     {
        mech_power_demand = electrical_power/ alternator_efficiency;
     }  
    if (me.rpm < me.cutoff_rpm) 
    {
      me.voltage = 0; 
      me.tripped = true;
      me.energised = false;
      return 0;
    }
    
     return mech_power_demand;					
 }
 
#------------------------------------------------------------------------------- 
Generator.setRPM = func (RPM)
 {  
    me.rpm = RPM;
    if (!me.energised )
    {
      me.voltage = 0;
      return;
    }
    var target_voltage = 0;    
    if (RPM < me.low_rpm) target_voltage = RPM/me.low_rpm * me.regulated_voltage;
    else target_voltage = me.regulated_voltage;
    
    me.voltage = me.voltage + regulation_factor 
							   * (target_voltage - me.voltage) 
							   * deltaT;						   
    if (me.voltage < 0) me.voltage = 0;
	#TODO : subclass to allow alternators with variable frequency
 }
 
#----------------------------------------------------------------------- 
 Generator.switchOff = func 
 {
    me.energised = false;    
 }
 
#----------------------------------------------------------------------- 
 Generator.switchOn = func 
 {
   if (!me.tripped) me.energised = true;   
 }
 
 #----------------------------------------------------------------------- 
 Generator.switchReset = func 
 {
    me.tripped = false;
    me.energised = false;   
 }
 
 #----------------------------------------------------------------------- 
 Generator.feed = func 
 {
   if (me.energised and me.voltage > me.min_voltage)
   {
    var root_feed = SourceFeed.new (me, me.priority, me.voltage);    
    me.consummer_bus.feed (root_feed);
   }
 }
