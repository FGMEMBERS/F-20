########################################################################
#main update function

var main_gen_alert = Alert.new ("/systems/electrical/main-gen-caution",
								 has_master_caution);

var backup_gen_alert = Alert.new ("/systems/electrical/backup-gen-caution",
								   has_master_caution);

var main_batt_alert = Alert.new ("/systems/electrical/main-batt-caution",
								 has_master_caution);

var hyd_batt_alert = Alert.new ("/systems/electrical/hyd-batt-caution",
								 has_master_caution);

#-------------------------------------------------------------------------------
var updateElectricalSystem = func (delta_t)
{
  if (!main_gen.energised)  main_gen_alert.trigger ();
  else main_gen_alert.reset();

  if (main_gen.energised or ext_elec.energised)
  {
   AC_1_2_tie.closed = true;
   AC_2_3_tie.closed = true;
   DC_tie.closed = true;
   backup_gen.switchOff();
  }
  else
  {
   AC_1_2_tie.closed = false;
   AC_2_3_tie.closed = false;
   DC_tie.closed = false;
   if (gen_backup_switch.state != gen_switch_off) backup_gen.switchOn();
   if (!backup_gen.energised) backup_gen_alert.trigger();
   else backup_gen_alert.reset();   
  }
  if (!main_battery.energised) main_batt_alert.trigger();
  else main_batt_alert.reset();

  if (!hydraulic_battery.energised) hyd_batt_alert.trigger();
  else hyd_batt_alert.reset();

  F_20_electrical.update (delta_t);

  checkForAlertPanelPower ();
}
