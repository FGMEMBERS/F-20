########################################################################
#define a class for a generator
var pump_efficiency = 0.9;

var P_flow_rate = 5e-9;
var I_flow_rate = 0;#1e-13;

var Pump = {regulated_pressure : 3000,
			 max_flow_rate : 0,
			 flow_rate : 0,
			 integral_term :0,
			 rpm : 0,
			 nominal_rpm : 100,
			 consumer_circuit : nil};

#-------------------------------------------------------------------------------
Pump.new = func (pressure,
				  rating,
				  nominal_rpm,
				  circuit)
 {
    var returned_pump = {parents : [HydraulicComponent, Pump]};
    returned_pump.regulated_pressure = pressure * PSI_to_Pa;
    returned_pump.max_flow_rate = rating / returned_pump.regulated_pressure;
    returned_pump.nominal_rpm = nominal_rpm;
    returned_pump.consumer_circuit = circuit;
    circuit.hydraulic_system.addComponent (returned_pump);
    circuit.connectComponent (returned_pump);
    return returned_pump;
 }

#-------------------------------------------------------------------------------
Pump.update = func (delta_t)
 {
    var current_max_flow = - me.max_flow_rate * me.rpm / me.nominal_rpm;

    var pressure_error = me.consumer_circuit.pressure - me.regulated_pressure;
    me.integral_term = me.integral_term  + pressure_error * delta_t;

    me.flow_rate = pressure_error * P_flow_rate
				   +
				   me.integral_term * I_flow_rate;

   if (me.flow_rate < current_max_flow) me.flow_rate = current_max_flow;
   if (me.flow_rate > 0) me.flow_rate = 0;
   if (me.rpm < 2e-2 * me.nominal_rpm) me.flow_rate = 0;
 }

#-------------------------------------------------------------------------------
Pump.setRPM = func (RPM)
 {
    me.rpm = RPM;
 }

#-----------------------------------------------------------------------
 Pump.switchOff = func
 {
    me.pressurised = false;
 }

#-----------------------------------------------------------------------
 Pump.switchOn = func
 {
    me.pressurised = true;
 }

