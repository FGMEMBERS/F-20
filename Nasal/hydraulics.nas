################################################################################
# F-20 hydraulic system
################################################################################

var f20_hydraulics = HydraulicSystem.new ();

var flight_control_circuit = HydraulicCircuit.new (f20_hydraulics, 3000);
var utility_circuit = HydraulicCircuit.new (f20_hydraulics, 3000);

var flight_control_pump = Pump.new (3000, #psi
									 25000, #watts
									 100, #percent N2
									 flight_control_circuit);

var utility_pump = Pump.new (3000, #psi
							  25000, #watts
                              100, #percent N2
							  utility_circuit);

var flight_control_accumulator = Accumulator.new (flight_control_circuit,
												   5,
												   2950);

var pitch_actuator = JSBactuator.new (-0.34906585, #lower stroke position
									  0.087266463, #higher stroke position
									  0.5, # equivalent displacement of the actuator liters
									  0.1, #min stroke time
									  3000, #nominal pressure
									  "/fdm/jsbsim/fcs/pitch-actuator-rate",
									  "/fdm/jsbsim/fcs/pitch-no-pressure",
									  "/fdm/jsbsim/fcs/elevator-pos-rad");

pitch_actuator.connectToCircuit (flight_control_circuit);
pitch_actuator.connectToCircuit (utility_circuit);

var roll_actuator = JSBactuator.new (-0.35, #lower stroke position
									  0.35, #higher stroke position
									  0.5, # equivalent displacement of the actuator
									  0.1, #min full stroke time
									  3000, #nominal pressure
									  "/fdm/jsbsim/fcs/roll-actuator-rate",
									  "/fdm/jsbsim/fcs/roll-no-pressure",
									  "/fdm/jsbsim/fcs/right-aileron-pos-rad");

roll_actuator.connectToCircuit (flight_control_circuit);
roll_actuator.connectToCircuit (utility_circuit);

var yaw_actuator = JSBactuator.new (-0.35, #lower stroke position
									 0.35, #higher stroke position
									 0.5, # equivalent displacement of the actuator
									 0.1, #min full stroke time
									 3000, #nominal pressure
									 "/fdm/jsbsim/fcs/yaw-actuator-rate",
									 "/fdm/jsbsim/fcs/yaw-no-pressure",
									 "/fdm/jsbsim/fcs/rudder-pos-rad");

yaw_actuator.connectToCircuit (flight_control_circuit);
yaw_actuator.connectToCircuit (utility_circuit);						 

var flt_ctl_pressure_gauge = Gauge.new (AC_instruments,
										0,
										4000,
										drop_on_shutdown,
										24,
										1.0,
										0.1,
										"/systems/hydraulics/pressure-flt-ctl-psi");
										

var utility_pressure_gauge = Gauge.new (AC_instruments,
										0,
										4000,
										drop_on_shutdown,
										24,
										1.0,
										0.1,
										"/systems/hydraulics/pressure-utility-psi");
										
var updateHydraulics = func (delta_t)
{
  flt_ctl_pressure_gauge.computeReading (flight_control_circuit.pressure / PSI_to_Pa);
  utility_pressure_gauge.computeReading (utility_circuit.pressure / PSI_to_Pa);
  f20_hydraulics.update(delta_t);
}

