########################################################################
# Base class for a gauge
########################################################################


#constants
var switch_is_off = false;
var switch_is_on = true;

var Switch = {is_off_when_not_powered : true,
			   state : false};

#-----------------------------------------------------------------------
Switch.new = func (source,
				   unpowered_value,
                   initial_state)
{

  var created_switch = {parents:[TerminalLoad.new(), Switch]};
  created_switch.unpowered_value = unpowered_value;
  created_switch.state = initial_state;
  source.connectLoad (created_switch);
  return created_switch;
  
}

#-----------------------------------------------------------------------
Switch.switchOn = func 
{
  
  if (me.fed or !me.is_off_when_not_powered) me.state = switch_is_on;
  else me.state = switch_is_off;
   
}

#-----------------------------------------------------------------------
Switch.switchOff = func 
{
  
  if (!me.fed and !me.is_off_when_not_powered) me.state = switch_is_on;
  else me.state = switch_is_off;
}

#-----------------------------------------------------------------------
Switch.update = func (delta_t)
{
  if (!me.fed and me.is_off_when_not_powered) me.state = switch_is_off;
  if (!me.fed and !me.is_off_when_not_powered) me.state = switch_is_on;
  #else keep state as it is 
}
