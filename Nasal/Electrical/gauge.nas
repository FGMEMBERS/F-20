########################################################################
# Base class for a gauge
########################################################################

#constants
var freeze_on_shutdown = 0;
var drop_on_shutdown = 1;
var jump_on_shutdown = 2;

var Gauge = {low_value : 0,
			  high_value : 0,
			  input_value : 0,
			  behavior_when_shut : freeze_on_shutdown,
			  nominal_voltage : 0,
			  relaxation_speed : 1.0, #speed to get from bottom to top of scale
			  current_display : 0,
			  nominal_demand : 1,
			  display_property : nil};

#-----------------------------------------------------------------------
Gauge.new = func (source,
                   low_value,
                   high_value,
                   behavior_when_shut,
                   nominal_voltage,
                   relaxation_time,
                   nominal_demand,
                   display_property)
{

  var created_gauge = {parents:[TerminalLoad.new(), Gauge]};
  created_gauge.low_value = low_value;
  created_gauge.high_value = high_value;
  created_gauge.behavior_when_shut = behavior_when_shut;
  created_gauge.nominal_voltage = nominal_voltage;
  created_gauge.relaxation_speed = (high_value-low_value) / relaxation_time; #units per seconds
  if (behavior_when_shut == freeze_on_shutdown)  
				created_gauge.current_display = (high_value+low_value)/2;
  else if (behavior_when_shut == drop_on_shutdown)   
				created_gauge.current_display = low_value;
  else if (behavior_when_shut == jump_on_shutdown)  
				created_gauge.current_display = high_value;
  created_gauge.nominal_demand = nominal_demand;
  created_gauge.display_property = display_property;
  source.connectLoad (created_gauge);
  return created_gauge;
  
}

#-----------------------------------------------------------------------
Gauge.computeReading = func (input_value)
{
  me.input_value = input_value;
}

#-----------------------------------------------------------------------
Gauge.update = func (delta_t)
{
  var target = 0;
   
   if (me.fed)
   {    
     target = me.input_value * (me.voltage / me.nominal_voltage);     
     if (target < me.low_value)  target = me.low_value;
     if (target > me.high_value) target = me.high_value;
   }
   else
   {
	  if (me.behavior_when_shut == freeze_on_shutdown)  
					 setprop (me.display_property, current_display);
	  else if (me.behavior_when_shut == drop_on_shutdown)   
					target = me.low_value;
	  else if (me.behavior_when_shut == jump_on_shutdown)  
					target = me.high_value;
   }
   
   if (me.relaxation_speed == 0)  me.current_display = target;
   else
   {
      if (target > me.current_display)
       {
         me.current_display = me.current_display + delta_t * me.relaxation_speed;
        if ( me.current_display > target)  me.current_display = target;
       }
      else
       {
         me.current_display = me.current_display - delta_t * me.relaxation_speed;
        if ( me.current_display < target)  me.current_display = target;              
       }
   }
   
   me.amps = me.nominal_demand;
   setprop (me.display_property,  me.current_display);
}
