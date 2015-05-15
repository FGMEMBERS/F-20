########################################################################
# X-15 electrical system

#general constants for the X-15 electrical system
var regulated_ressure = 3000; #PSI
var hyd_low_rpm = 40000; #RPM
var pump_rating = 20000; #W
var pump_priority = 3;
var pressure_1_display  = "/systems/hydraulics/pressure-1";
var pressure_2_display  = "/systems/electrical/pressure-2";

########################################################################
#instances

#Electrical circuit
var X_15_hydraulics = HydraulicSystem.new ();

#circuit
var hyd_1 = HydraulicCircuit.new(X_15_electrical);
var hyd_2 = HydraulicCircuit.new(X_15_electrical);

#pumps
 var pump_1 = Pump.new (X_15_hydraulics,
						regulated_ressure,
						pump_rating,
						hyd_1,
						hyd_low_rpm,
						pump_priority);

 var gen_2 = Pump.new (X_15_hydraulics,
						regulated_ressure,
						pump_rating,
						hyd_2,
						hyd_low_rpm,
						pump_priority);

 #accumulators
 var accu1 = Accumulator.new (X_15_hydraulics,
							  200,  #W
							  3000, #PSI
							  hyd_1,
							  0, #priority (lowest for the battery)
							  5);#kg/s

 var accu2 = Accumulator.new (X_15_hydraulics,
							  200,  #W
							  3000, #PSI
							  hyd_2,
							  0, #priority (lowest for the battery)
							  5);#kg/s

########################################################################
#main update function
var updateHydraulicSystem = func (delta_t)
{

  X_15_hydraulics.update (delta_t);

}
