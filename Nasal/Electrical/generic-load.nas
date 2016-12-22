########################################################################
# Base class for a generic load
########################################################################

#constants
var elec_off = false;
var elec_on = true;

var GenericLoad = {nominal_voltage : 0,
				   nominal_amps : 0,
				   running : false,
				   is_on : elec_off};

#-----------------------------------------------------------------------
GenericLoad.new = func (source,
						 nominal_consumption,
						 nominal_voltage)
{

  var created_load = {parents:[TerminalLoad.new(), GenericLoad]};
  created_load.nominal_amps = nominal_consumption / nominal_voltage;
  created_load.nominal_voltage = nominal_voltage;
  source.connectLoad (created_load);
  return created_load;

}

#-----------------------------------------------------------------------
GenericLoad.switchOn = func
{
  me.is_on = elec_on;
}

#-----------------------------------------------------------------------
GenericLoad.switchOff = func
{
 me.is_on = elec_off;
}

#-----------------------------------------------------------------------
GenericLoad.update = func (delta_t)
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
