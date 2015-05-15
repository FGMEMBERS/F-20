################################################################################
#Payload switcher

var drag_index_prop = props.globals.getNode ("/fdm/jsbsim/aero/drag-index");
var drag_index = 0;

var wing_tanks_present_prop = props.globals.getNode ("/f-20/wing-tanks-present");
var wing_pylons_present_prop = props.globals.getNode ("/f-20/wing-pylons-present");
var center_pylon_present_prop = props.globals.getNode ("/f-20/center-pylon-present");
var center_tank_present_prop = props.globals.getNode ("/f-20/center-tank-present");
var smoke_generators_present_prop = props.globals.getNode ("/f-20/smoke-generators-present");

var left_wing_tank_fuel_qty_prop = props.globals.getNode ("/consumables/fuel/tank[3]/level-lbs");
var right_wing_tank_fuel_qty_prop = props.globals.getNode ("/consumables/fuel/tank[4]/level-lbs");
var center_tank_fuel_qty_prop = props.globals.getNode ("/consumables/fuel/tank[2]/level-lbs");

var left_wing_drop_tank_fuel_qty = 0.0;
var right_wing_drop_tank_fuel_qty = 0.0;
var center_drop_tank_fuel_qty = 0.0;
var center_tank_capacity = 1995.0;
var center_tank_empty = 229.0;
var wing_tank_capacity = 2085.0;
var wing_tank_empty = 227.0;

var selective_jettison_station_enabled = [false, false, false, false, false, false, false];

#-------------------------------------------------------------------------------
var toggleSelectiveJettison = func (station_number)
{
  
  if (selective_jettison_station_enabled [station_number]) selective_jettison_station_enabled [station_number] = false;
  else selective_jettison_station_enabled [station_number] = true;
  
}

#-------------------------------------------------------------------------------
var placeWingPylons = func
{
  wing_pylons_present_prop.setValue(1);
  drag_index = drag_index + 27;
  drag_index_prop.setValue (drag_index);
}

#-------------------------------------------------------------------------------
var removeWingPylons = func
{
  wing_pylons_present_prop.setValue(0);
  drag_index = drag_index - 27;
  drag_index_prop.setValue (drag_index);
}

#-------------------------------------------------------------------------------
var placeWingTanks = func
{
  wing_tanks_present_prop.setValue(1);
  left_wing_drop_tank_fuel_qty = 1995.0;
  right_wing_drop_tank_fuel_qty = 1995.0;
  left_wing_tank_fuel_qty_prop.setValue (left_wing_drop_tank_fuel_qty);
  right_wing_tank_fuel_qty_prop.setValue (right_wing_drop_tank_fuel_qty);
  drag_index = drag_index + 43;
  drag_index_prop.setValue (drag_index);
}

#-------------------------------------------------------------------------------
var removeWingTanks = func
{
  wing_tanks_present_prop.setValue(0);
  left_wing_drop_tank_fuel_qty = 0.0;
  right_wing_drop_tank_fuel_qty = 0.0;
  left_wing_tank_fuel_qty_prop.setValue (left_wing_drop_tank_fuel_qty);
  right_wing_tank_fuel_qty_prop.setValue (right_wing_drop_tank_fuel_qty);
  drag_index = drag_index - 43;
  drag_index_prop.setValue (drag_index); 
}

#-------------------------------------------------------------------------------
var toggleWingTanks = func
{

}

#-------------------------------------------------------------------------------
var placeCenterPylon = func
{
  center_pylon_present_prop.setValue(1);
  drag_index = drag_index + 14;
  drag_index_prop.setValue (drag_index);
}

#-------------------------------------------------------------------------------
var removeCenterPylon = func
{
  center_pylon_present_prop.setValue(0);
  drag_index = drag_index - 14;
  drag_index_prop.setValue (drag_index);
}

#-------------------------------------------------------------------------------
var placeCenterTank = func
{
  center_tank_present_prop.setValue(1);
  center_drop_tank_fuel_qty = 2085.0;
  center_tank_fuel_qty_prop.setValue (center_drop_tank_fuel_qty);
  drag_index = drag_index + 18;
  drag_index_prop.setValue (drag_index);
  updateCenterStationSpeedBrakesLimit (true);
}

#-------------------------------------------------------------------------------
var removeCenterTank = func
{
  center_tank_present_prop.setValue(0);
  center_drop_tank_fuel_qty = 0.0;
  center_tank_fuel_qty_prop.setValue (center_drop_tank_fuel_qty);
  drag_index = drag_index - 18;
  drag_index_prop.setValue (drag_index);
  updateCenterStationSpeedBrakesLimit (false);
}

#-------------------------------------------------------------------------------
var toggleCenterTank = func
{

}

#-------------------------------------------------------------------------------
var placeSmokeGenerators = func
{
  smoke_generators_present_prop.setValue(1);
  drag_index = drag_index + 1;
  drag_index_prop.setValue (drag_index);
}

#-------------------------------------------------------------------------------
var removeSmokeGenerators = func
{
  smoke_generators_present_prop.setValue(0);
  drag_index = drag_index - 1;
  drag_index_prop.setValue (drag_index);
}
