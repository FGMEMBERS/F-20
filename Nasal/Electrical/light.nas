########################################################################
# Base class for a light
########################################################################


#constants
var light_is_off = false;
var light_is_on = true;

var Light = {nominal_voltage : 0,
              nominal_amps : 0,
              intensity_prop : nil,
              intensity : 0.0,
              is_on : light_is_off};

#-----------------------------------------------------------------------
Light.new = func (source,
				   intensity_prop,
                   nominal_consumption,
                   nominal_voltage)
{

  var created_light = {parents:[TerminalLoad.new(), Light]};
  created_light.intensity_prop = intensity_prop;
  created_light.nominal_amps = nominal_consumption / nominal_voltage;
  created_light.nominal_voltage = nominal_voltage;
  source.connectLoad (created_light);
  return created_light;

}

#-----------------------------------------------------------------------
Light.switchOn = func
{
  me.is_on = light_is_on;
}

#-----------------------------------------------------------------------
Light.switchOff = func
{
 me.is_on = light_is_off;
}

#-----------------------------------------------------------------------
Light.update = func (delta_t)
{
  if (me.fed and me.is_on)
  {
    me.intensity = me.voltage / me.nominal_voltage;
    me.amps = me.nominal_amps * me.intensity;
    setprop (me.intensity_prop, me.intensity);
  }
  else
  {
    me.amps = 0.0;
    me.intensity = 0.0;
    setprop (me.intensity_prop, 0);
  }
}
