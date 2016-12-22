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
              dimming_value : 1.0,
              dimming_prop : nil,
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
Light.setDimmer = func (value)
{
  if (value > 1.0) me.dimming_value = 1.0;
  else if (value < 0.0) 
   { 
    me.dimming_value = 0.0;
    me.switchOff();
   }
  else me.dimming_value = value;
}

#-----------------------------------------------------------------------
Light.enableDimmer = func (prop_name, default_value)
{
  me.dimming_prop = prop_name;
  me.setDimmer (default_value);
  setprop (me.dimming_prop, me.dimming_value);
}

#-----------------------------------------------------------------------
Light.dimUp = func (increment)
{
  me.switchOn();
  me.setDimmer (me.dimming_value + increment);
  setprop (me.dimming_prop, me.dimming_value);
}

#-----------------------------------------------------------------------
Light.dimDn = func (decrement)
{
  me.setDimmer (me.dimming_value - decrement);
  setprop (me.dimming_prop, me.dimming_value);  
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
    me.intensity = me.voltage / me.nominal_voltage * me.dimming_value;
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
