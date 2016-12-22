#Radio altimeter
var rad_alt_switch_prop = "/controls/avionics/radalt-switch";

var radio_altimeter = GenericLoad.new (AC_2, 1, 115);
radio_altimeter.is_on = elec_on;
setprop (rad_alt_switch_prop, radio_altimeter.is_on);

var radAltToggle = func ()
{
  if (radio_altimeter.is_on) radio_altimeter.switchOff();
  else radio_altimeter.switchOn();
  
  setprop (rad_alt_switch_prop, radio_altimeter.is_on);
}
