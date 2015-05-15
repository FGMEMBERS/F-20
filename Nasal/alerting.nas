################################################################################
#Alerting

#Constants
var sound_on = 0;
var sound_off = 1;

var has_master_caution = true;
var has_not_master_caution = false;

#Properties
var single_chime_prop = "/f-20/alerting/chime";
var continuous_repetitive_chime_prop = "/f-20/alerting/continuous-repetitive-chime";
var master_depress_prop = "/f-20/alerting/master-depress";
var master_light_on_prop = "/f-20/alerting/master-light-on";

var master_caution_light = Light.new (DC_Essential,
									  "/f-20/alerting/master-light-intensity",
									  0.05,
									  24);  
master_caution_light.switchOff();

var alerts = [];

#-------------------------------------------------------------------------------
var Alert = {display_prop : nil,
			  new_alert : true,
			  master_caution_available : true};

#-------------------------------------------------------------------------------
Alert.new = func (display_prop, master_caution_available)
{
  var created_alert = {parents:[Alert]};
  created_alert.display_prop = display_prop;
  created_alert.master_caution_available = master_caution_available;
  append (alerts, created_alert);
  return created_alert;
}

#-------------------------------------------------------------------------------
Alert.trigger = func ()
{
  if (caution_light_panel.intensity > 0 and  me.new_alert)
  {
    setprop (me.display_prop,1);
    if (me.master_caution_available) 
    {
      setprop (single_chime_prop, sound_on);
      settimer (func { setprop(single_chime_prop,sound_off);}, 0.5);
      master_caution_light.switchOn();
      setprop(master_light_on_prop, true);
      me.new_alert = false;
    }
  }
}

#-------------------------------------------------------------------------------
Alert.reset = func ()
{
  setprop (me.display_prop,0);
  me.new_alert = true;
}

#-------------------------------------------------------------------------------
var resetMasterCaution = func ()
{
  master_caution_light.switchOff();
  interpolate (master_depress_prop, 1, 0.1);    
  settimer (func{setprop(master_light_on_prop, false);
				  interpolate (master_depress_prop, 0, 0.1);},0.1);
}

#-------------------------------------------------------------------------------
var checkForAlertPanelPower = func ()
{
    if (caution_light_panel.intensity <= 0)
    forindex (var i; alerts) alerts[i].reset();
}
