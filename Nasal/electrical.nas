########################################################################
# F-20 electrical system

#general constants for the X-15 electrical system
var regulated_AC_voltage = 115; #volts
var regulated_DC_voltage = 26; #volts
var voltage_1_display  = "f-20/electrical/voltage-1";
var voltage_2_display  = "f-20/electrical/voltage-2";

var low_DC_voltage = 23; #volts
var low_AC_voltage = 90; #volts

var indicator_light_amps = 3/26; #Amps

########################################################################
#instances

#Electrical circuit
var F_20_electrical = ElectricalSystem.new ();

#buses
var AC_1 = ElectricalBus.new(F_20_electrical);
var AC_2 = ElectricalBus.new(F_20_electrical);
var AC_3 = ElectricalBus.new(F_20_electrical);
var AC_instruments = ElectricalBus.new(F_20_electrical);
var AC_navigation = ElectricalBus.new(F_20_electrical);
var AC_Essential = ElectricalBus.new(F_20_electrical);
var DC_Essential= ElectricalBus.new(F_20_electrical);
var DC_main = ElectricalBus.new(F_20_electrical);
var DC_emergency_hydraulic = ElectricalBus.new(F_20_electrical);

#generators
 var main_gen = Generator.new (F_20_electrical,
								regulated_AC_voltage,
								40e3, #VA
								AC_1, #bus
								30, #low rpm
								25, #cutoff rpm
								3); #priority on bus

 var backup_gen = Generator.new (F_20_electrical,
								regulated_AC_voltage, #volts
								5e3, #VA
								AC_2, #bus
								30, #low rpm
								25, #cutoff rpm
								3); #priority on bus;

 var ext_elec = ExternalElectricity.new (F_20_electrical,
										 regulated_AC_voltage, #volts
										 AC_1, #bus
										 4); #priority on bus
ext_elec.switchOff();

#transformers

 var DCtransformer = ElectricalTransformer.new (AC_2,
												DC_Essential,
												2,
												regulated_DC_voltage/regulated_AC_voltage);

 var static_inverter = ElectricalTransformer.new (DC_Essential,
												  AC_Essential,
												  2,
												  regulated_AC_voltage/regulated_DC_voltage);

 var InstrumentsTransformer = ElectricalTransformer.new (AC_3,
														 AC_instruments,
														 2,
														 26/regulated_AC_voltage);

 var NavigationTransformer = ElectricalTransformer.new (AC_3,
														 AC_navigation,
														 2,
														 26/regulated_AC_voltage);

 #ties
 var AC_1_2_tie = OneWayTie.new (AC_1, AC_2, 1);
 var AC_2_3_tie = OneWayTie.new (AC_2, AC_3, 1);
 var AC_3_essential_tie = BusTie.new (AC_3, 1, AC_Essential, 1);
 var DC_tie = BusTie.new (DC_Essential, 1,
					       DC_main, 1);
 var DC_Essential_hydraulic_tie = OneWayTie.new (DC_Essential, DC_emergency_hydraulic, 1);

 #batteries
  var main_battery = Battery.new (F_20_electrical,
								   17,  #amps.h
								   regulated_DC_voltage, #V DC
								   DC_Essential,
								   0, #priority (lowest for the battery)
								   5);#AMPS

 var hydraulic_battery = Battery.new (F_20_electrical,
									  58,  #amps.h
									  regulated_DC_voltage, #V DC
									  DC_emergency_hydraulic,
									  0, #priority (lowest for the battery)
									  5);#AMPS

 #circuit breakers
 var trim_CB = CircuitBreaker.new (F_20_electrical,
								   10,
								   "/systems/electrical/circuit-breakers/trim");

#switches

#Generators ----------------------------------------------------------------
var gen_switch_off = 1;
var gen_switch_on = 2;
var gen_switch_reset = 0;

var GenSwitch = {switch_prop : nil,
				 generator : nil,
				 state : gen_switch_off};

#------------------------------------------------------------------------------
GenSwitch.new = func (switch_prop, generator)
{
   var created_object = {parents : [GenSwitch]};
   created_object.generator = generator;
   created_object.switch_prop = switch_prop;
   created_object.generator.switchOff();
   setprop (created_object.switch_prop, created_object.state);
   return created_object;
}

#------------------------------------------------------------------------------
GenSwitch.moveUp = func ()
{
   if (me.state == gen_switch_off)
   {
     me.state = gen_switch_on;
     me.generator.switchOn ();
     setprop (me.switch_prop, me.state);
   }
}

#------------------------------------------------------------------------------
var genSwitchEndReset = func (switch)
{
	interpolate (me.switch_prop, gen_switch_off, 0.1);
}

GenSwitch.moveDn = func ()
{
  if (me.state == gen_switch_on)
  {
    me.state = gen_switch_off;
    me.generator.switchOff();
    setprop (me.switch_prop, gen_switch_off);
  }
  else if (me.state == gen_switch_off)
   {
     me.generator.switchReset();
     interpolate (me.switch_prop, gen_switch_reset, 0.1);
     settimer (func {interpolate (me.switch_prop, gen_switch_off, 0.1);}, 0.1);
   }
}


var gen_main_switch = GenSwitch.new ("/systems/electrical/gen-main-switch",
									 main_gen);

var gen_backup_switch = GenSwitch.new ("/systems/electrical/gen-backup-switch",
									   backup_gen);

#*******************************************************************************
#TODO : setup switches according to initialisation status i.e. cold aircraft or
#engine running
gen_main_switch.moveUp();
gen_backup_switch.moveUp();
#*******************************************************************************

#Batteries ----------------------------------------------------------------
var bat_switch_off = 0;
var bat_switch_on = 1;
var bat_switch_oride = 2;

var BatSwitch = {switch_prop : nil,
				 battery : nil,
				 state : bat_switch_off};

#------------------------------------------------------------------------------
BatSwitch.new = func (switch_prop, battery)
{
   var created_object = {parents : [BatSwitch]};
   created_object.battery = battery;
   created_object.switch_prop = switch_prop;
   created_object.battery.switchOff();
   setprop (created_object.switch_prop, created_object.state);
   return created_object;
}

#------------------------------------------------------------------------------
BatSwitch.moveUp = func ()
{
   if (me.state < bat_switch_oride)
   {
     me.state = me.state + 1;
     if (me.state > bat_switch_off) me.battery.switchOn ();
     setprop (me.switch_prop, me.state);
   }
}

#------------------------------------------------------------------------------
BatSwitch.moveDn = func ()
{
  if (me.state > bat_switch_off)
  {
     me.state = me.state - 1;
     if (me.state < bat_switch_on) me.battery.switchOff ();
     setprop (me.switch_prop, me.state);
  }
}

var main_battery_switch = BatSwitch.new ("/systems/electrical/bat-main-switch",
									     main_battery);

var hydraulic_battery_switch = BatSwitch.new ("/systems/electrical/bat-hyd-switch",
									           hydraulic_battery);

#*******************************************************************************
#TODO : setup switches according to initialisation status i.e. cold aircraft or
#engine running
main_battery_switch.moveUp();
hydraulic_battery_switch.moveUp();
#*******************************************************************************

var caution_light_panel = Light.new(DC_Essential,
								     "/systems/electrical/caution-lights-intensity",
									 0.1,
									 24);
caution_light_panel.switchOn();



