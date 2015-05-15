########################################################################
# Base class for an electrical actuator
########################################################################

##############################
#
# WARNING : NOT FINISHED YET
#
#############################

#constants
var elec_off = false;
var elec_on = true;

var ElecActuator = {nominal_voltage : 0,
				    nominal_amps : 0,
				    nominal_rate : 0,
				    stroke_time :0,
				    running : false,
				    is_on : elec_off};

#-----------------------------------------------------------------------
ElecActuator.new = func (source,
						  min_stroke,
						  max_stroke,
						  nominal_stroke_time,
						  nominal_consumption,
						  nominal_voltage)
{

  var created_load = {parents:[TerminalLoad.new(), ElecActuator]};
  created_load.nominal_amps = nominal_consumption / nominal_voltage;
  created_load.nominal_voltage = nominal_voltage;
  source.connectLoad (created_load);
  return created_load;

}

#-----------------------------------------------------------------------
ElecActuator.update = func (delta_t)
{
  if (me.fed and me.is_on)
  {
    me.amps = me.nominal_amps;
    me.running = true;
  }
  else
  {
    me.amps = 0.0;
    me.running = false;
  }
}

#-----------------------------------------------------------------------
ElecActuator.setTarget = func (target)
{

}
