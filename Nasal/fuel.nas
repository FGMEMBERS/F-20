################################################################################
#fuel system

#fuel flows and quantities
var ext_fuel_CL_feed_prop = props.globals.getNode ("/controls/fuel/center-line-ext-feed");
var ext_fuel_wing_feed_prop = props.globals.getNode ("/controls/fuel/wing-ext-feed");
var auto_feed_prop = "/controls/fuel/auto-feed";
var feed_source_prop = "/controls/fuel/feed-source";
var fwd_xfr_prop = "/controls/fuel/fwd-xfr-source";
var fuel_test_in_progress_prop = "/controls/fuel/test-in-progress";

var forward_tank_qty =  props.globals.getNode ("/consumables/fuel/tank[0]/level-lbs");
var aft_tank_qty =  props.globals.getNode ("/consumables/fuel/tank[1]/level-lbs");

var aft_tank_reserve = 150;
var aft_tank_capacity = 2768;
var aft_tank_only_trigger = aft_tank_capacity - 1500.0;
var aft_tank_usable_fuel = 2700;
var forward_tank_capacity = 1747;
var forward_tank_usable_fuel = 1700;

var force_fuel_starvation = false;

var previous_forward_fuel = forward_tank_qty.getValue();
var fuel_used_during_cycle = 0;

var aft_tank_demand = 0.0;
var forward_tank_demand = 0.0;
var right_wing_tank_flowing = false;
var left_wing_tank_flowing = false;
var center_tank_flowing = false;
var center_tank_consumption = 0.0;
var left_tank_consumption = 0.0;
var right_tank_consumption = 0.0;
var wing_tank_consumption = 0.0;
var aft_tank_supply = 0.0;
var aft_tank_fuel = 0.0;

#fuel pumps
var pump_on = true;
var pump_off = false;

var fwd_boost_pump_switch = pump_off;
var fwd_boost_pump_switch_prop = "/controls/fuel/fwd-boost-pump";
var aft_L_boost_pump_switch = pump_off;
var aft_L_boost_pump_switch_prop = "/controls/fuel/aft-L-boost-pump";
var aft_R_boost_pump_switch = pump_off;
var aft_R_boost_pump_switch_prop = "/controls/fuel/aft-R-boost-pump";

var fwd_boost_pump = GenericLoad.new (AC_1,
									   100, #Watts
									   115); #Volts
var aft_L_boost_pump = GenericLoad.new (AC_1,
									    100, #Watts
									    115); #Volts
var aft_R_boost_pump = GenericLoad.new (AC_1,
									    100, #Watts
									    115); #Volts
var dc_boost_pump = GenericLoad.new (DC_Essential,
									  50, #Watts
									  24); #Volts
var aft_pressure_available = false;
var fwd_pressure_available = false;
var fuel_lo_press_alert = Alert.new ("/consumables/fuel/low-pressure", has_master_caution);

#bingo
var bingo_value_prop = "/consumables/fuel/bingo-value";
var bingo_value = 150.0;
setprop (bingo_value_prop, bingo_value);


var bingo_alert = Alert.new ("/consumables/fuel/bingo-reached", has_master_caution);

var aft_fuel_low_alert = Alert.new ("/consumables/fuel/aft-low", has_master_caution);
var fwd_fuel_low_alert = Alert.new ("/consumables/fuel/fwd-low", has_master_caution);

################################################################################
# Instruments

var fuel_panel_light = Light.new(DC_Essential,
								  "/systems/electrical/fuel-panel-intensity",
							      0.1,
								  24);
fuel_panel_light.switchOn();

var forward_fuel_gauge = Gauge.new (DC_Essential,
									0,
									3000,
									drop_on_shutdown,
									24,
									1.0,
									0.1,
									"/consumables/fuel/tank[0]/display-level-lbs");

var aft_fuel_gauge = Gauge.new (DC_Essential,
								0,
								3000,
								drop_on_shutdown,
								24,
								1.0,
								0.1,
								"/consumables/fuel/tank[1]/display-level-lbs");

var TotalFuel_prop = props.globals.getNode("consumables/fuel/total-fuel-lbs", 1);

var TotalFuel = canvas.new({
  "name": "TotalFuel-indicator",
  "size": [128, 128],
  "view": [128, 128],
  "mipmapping": 1
});

TotalFuel.addPlacement({"node": "FuelDigits"});

var TotalFuelRoot = TotalFuel.createGroup();

 var TotalFuelText = TotalFuelRoot.createChild("text")
                      .setColor(0.8,0.6,0.0)
                      .setTranslation(128, 128)      # The origin is in the top left corner
                      .setAlignment("right-bottom") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                      .setFont("led.txf")
                      .setFontSize(40, 1.2);

################################################################################
# switches

#-------------------------------------------------------------------------------
var fuelPumpAftLeftToggle = func
 {
   aft_L_boost_pump_switch = ! aft_L_boost_pump_switch;
   if (aft_L_boost_pump_switch)
   {
    aft_L_boost_pump.switchOn();
   }
   else
   {
    aft_L_boost_pump.switchOff();
   }
   setprop (aft_L_boost_pump_switch_prop, aft_L_boost_pump_switch);
 }

#-------------------------------------------------------------------------------
var fuelPumpAftRightToggle = func
 {
   aft_R_boost_pump_switch = ! aft_R_boost_pump_switch;
   if (aft_R_boost_pump_switch)
   {
    aft_R_boost_pump.switchOn();
   }
   else
   {
    aft_R_boost_pump.switchOff();
   }
   setprop (aft_R_boost_pump_switch_prop, aft_R_boost_pump_switch);
 }

#-------------------------------------------------------------------------------
var fuelPumpFwdToggle = func
 {
   fwd_boost_pump_switch = ! fwd_boost_pump_switch;
   if (fwd_boost_pump_switch)
   {
    fwd_boost_pump.switchOn();
   }
   else
   {
    fwd_boost_pump.switchOff();
   }
   setprop (fwd_boost_pump_switch_prop, fwd_boost_pump_switch);
 }

#*******************************************************************************
#TODO : setup switches according to initialisation status i.e. cold aircraft or
#engine running
fuelPumpFwdToggle();
fuelPumpAftRightToggle();
fuelPumpAftLeftToggle();
#*******************************************************************************

#-------------------------------------------------------------------------------
var auto_feed = true;
setprop (auto_feed_prop, auto_feed);
var autoFeedToggle = func
 {
  auto_feed = !auto_feed;
  setprop (auto_feed_prop, auto_feed);
 }

#-------------------------------------------------------------------------------
var xfr_fwd_transfer = false;
setprop (fwd_xfr_prop, xfr_fwd_transfer);
var transferToggle = func
 {
   xfr_fwd_transfer = !xfr_fwd_transfer;
   setprop (fwd_xfr_prop, xfr_fwd_transfer);
 }

#-------------------------------------------------------------------------------
var feed_aft = 0;
var feed_both = 1;
var feed_fwd = 2;
var feed_position = feed_both;
setprop (feed_source_prop,feed_position);
var fuelSourceUp = func
 {
   if (feed_position < feed_fwd) feed_position = feed_position + 1;
   setprop (feed_source_prop,feed_position);
 }

#-------------------------------------------------------------------------------
var fuelSourceDn = func
 {
   if (feed_position > feed_aft) feed_position = feed_position - 1;
   setprop (feed_source_prop,feed_position);
 }

#-------------------------------------------------------------------------------
var BingoUp = func
 {
   if (bingo_value < 3000) bingo_value = bingo_value + 50;
   setprop (bingo_value_prop, bingo_value);
 }


#-------------------------------------------------------------------------------
var BingoDn = func
 {
   if (bingo_value > 0) bingo_value = bingo_value - 50;
   setprop (bingo_value_prop, bingo_value);
 }

################################################################################
# Update function

var left_drop_tank_fuel_qty = 0.0;
var right_drop_tank_fuel_qty = 0.0;
var center_drop_tank_fuel_qty = 0.0;
var center_tank_capacity = 1995.0;
var center_tank_empty = 229.0;
var wing_tank_capacity = 2085.0;
var wing_tank_empty = 227.0;
var number_of_tanks_flowing = 0;

#-------------------------------------------------------------------------------
#sequence the consumption between tanks
var updateFuelSystem = func (delta_t)
{
  #feed only from the forward fuel tank. In normal sequencing the aft tank will empty into the forward
  #tank. External tanks empty into the aft tank
  fuel_used_during_cycle =  previous_forward_fuel - forward_tank_qty.getValue() ;

  #External tanks
  left_drop_tank_fuel_qty = getprop (drop_tank_qty_props[inner_left]);
  right_drop_tank_fuel_qty = getprop (drop_tank_qty_props[inner_right]);
  center_drop_tank_fuel_qty = getprop (drop_tank_qty_props[center]);
  aft_tank_fuel = aft_tank_qty.getValue();
  aft_tank_demand = aft_tank_usable_fuel - aft_tank_fuel;

  #add bleed pressure check
  center_tank_flowing = (current_payload[center] == Fuel_tank)
                        and
                        ext_fuel_CL_feed_prop.getValue()
                        and
                        (center_drop_tank_fuel_qty>center_tank_empty);

  left_wing_tank_flowing = (current_payload[inner_left] == Fuel_tank)
						   and
						   ext_fuel_wing_feed_prop.getValue()
						   and
						   (left_drop_tank_fuel_qty>wing_tank_empty);

  right_wing_tank_flowing = (current_payload[inner_right] == Fuel_tank)
						    and
						    ext_fuel_wing_feed_prop.getValue()
						    and
						    (right_drop_tank_fuel_qty>wing_tank_empty);

  number_of_tanks_flowing = center_tank_flowing
                            +
							left_wing_tank_flowing
							+
							right_wing_tank_flowing;  
  if (center_tank_flowing)
  {
    center_tank_consumption = aft_tank_demand / number_of_tanks_flowing;
    if ((center_drop_tank_fuel_qty - center_tank_consumption) < center_tank_empty)
    center_tank_consumption = center_drop_tank_fuel_qty - center_tank_empty;
    center_drop_tank_fuel_qty = center_drop_tank_fuel_qty - center_tank_consumption;
  }
  else center_tank_consumption = 0.0;
  
  if (left_wing_tank_flowing)
  {
    left_tank_consumption = aft_tank_demand/number_of_tanks_flowing;
    if ((left_drop_tank_fuel_qty - left_tank_consumption) < wing_tank_empty)
     left_tank_consumption = left_drop_tank_fuel_qty - wing_tank_empty;
    left_drop_tank_fuel_qty = left_drop_tank_fuel_qty - left_tank_consumption;
  }
  else left_tank_consumption = 0.0;
  
  if (right_wing_tank_flowing)
  {
    right_tank_consumption = aft_tank_demand/number_of_tanks_flowing;
    if ((right_drop_tank_fuel_qty - right_tank_consumption) < wing_tank_empty)
     right_tank_consumption = right_drop_tank_fuel_qty - wing_tank_empty;
    right_drop_tank_fuel_qty = right_drop_tank_fuel_qty - right_tank_consumption;
  }  
  else right_tank_consumption = 0.0;
     
  aft_tank_supply = right_tank_consumption
					+
					left_tank_consumption
					+
					center_tank_consumption;
					
  setprop (drop_tank_qty_props[inner_left], left_drop_tank_fuel_qty);
  setprop (drop_tank_qty_props[inner_right], right_drop_tank_fuel_qty);
  setprop (drop_tank_qty_props[center], center_drop_tank_fuel_qty);

  	 #Fuel pressure
	 if (!WOW and N2 < 60) dc_boost_pump.switchOn();
	 else dc_boost_pump.switchOff();
	 aft_pressure_available = aft_R_boost_pump.running
							  or
							  aft_L_boost_pump.running
							  and
							  aft_tank_fuel > 5;
	 fwd_pressure_available = dc_boost_pump.running
							  or
							  fwd_boost_pump.running
							  and
							  previous_forward_fuel > 5;

  #main tanks
  if (feed_position == feed_aft and !auto_feed)
  {
      if (aft_pressure_available) fuel_lo_press_alert.reset();
      else fuel_lo_press_alert.trigger();

	  if (aft_tank_fuel > 5)
	  {
	    force_fuel_starvation = false;
	    aft_tank_qty.setValue (aft_tank_fuel - fuel_used_during_cycle +  aft_tank_supply);
	  }
	  else
	    force_fuel_starvation = true;

      forward_tank_qty.setValue (previous_forward_fuel);
  }
  else if (feed_position == feed_fwd and !auto_feed)
  {
      if (fwd_pressure_available) fuel_lo_press_alert.reset();
      else fuel_lo_press_alert.trigger();
  }
  else if (feed_position == feed_both and xfr_fwd_transfer)
  {
      if (fwd_pressure_available or aft_pressure_available) fuel_lo_press_alert.reset();
      else fuel_lo_press_alert.trigger();

     if (aft_tank_fuel > 150.0)
	  {
		 aft_tank_qty.setValue (aft_tank_fuel - fuel_used_during_cycle +  aft_tank_supply);
		 forward_tank_qty.setValue (previous_forward_fuel);
	  }
	 else
	  {
	    xfr_fwd_transfer = false;
	    setprop (fwd_xfr_prop,xfr_fwd_transfer);
	  }
  }
  else #normal sequence
  {
      if (fwd_pressure_available or aft_pressure_available) fuel_lo_press_alert.reset();
      else fuel_lo_press_alert.trigger();
	  if (aft_tank_fuel > aft_tank_only_trigger)
	  {
		 aft_tank_qty.setValue (aft_tank_fuel - fuel_used_during_cycle +  aft_tank_supply);
		 forward_tank_qty.setValue (previous_forward_fuel);
	  }

	  if ( (aft_tank_fuel < aft_tank_only_trigger) and (aft_tank_fuel > 150.0))
	  {
		 aft_tank_qty.setValue (aft_tank_fuel - fuel_used_during_cycle/2.0 + aft_tank_supply);
		 forward_tank_qty.setValue (previous_forward_fuel - fuel_used_during_cycle/2.0);
	  }
  }

    previous_forward_fuel = forward_tank_qty.getValue();

    #display
     var brightness = fuel_panel_light.intensity
					  *
					 (engine_panel_light.commanded_intensity*0.9 + 0.1);
     var total_fuel = TotalFuel_prop.getValue();
	 if (getprop(fuel_test_in_progress_prop))
	 {
		 TotalFuelText.setText(5555)
					  .setColor(brightness*0.8,
								brightness*0.6,
								0);
		 forward_fuel_gauge.computeReading(1500);
		 aft_fuel_gauge.computeReading(1500);
	 }
	 else
	 {
	      TotalFuelText.setText(int(total_fuel))
					   .setColor(brightness*0.8,
								 brightness*0.6,
								 0);
		  forward_fuel_gauge.computeReading(previous_forward_fuel);
		  aft_fuel_gauge.computeReading(aft_tank_fuel);
	 }

	 #bingo
	 if (total_fuel < bingo_value) bingo_alert.trigger();
	 else  bingo_alert.reset();
	 if (aft_tank_fuel < 150) aft_fuel_low_alert.trigger();
	 else  aft_fuel_low_alert.reset();
	 if (previous_forward_fuel < 700) fwd_fuel_low_alert.trigger();
	 else  fwd_fuel_low_alert.reset();
}
