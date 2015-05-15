########################################################################
# Define a class for an electrical circuit

var HydraulicCircuit = {current_priority : 0,
                     highest_attached_priority : 0};

#-------------------------------------------------------------------------------
HydraulicCircuit.new = func  (hydraulic_system)
 {
    var obj = { parents : [HydraulicCircuit, 
						   ElectricalLoad, 
						   HydraulicSource.new(hydraulic_system)]};
    obj.current_priority = 0;
    hydraulic_system.addBus (obj);
    return obj;
 }

#------------------------------------------------------------------------------- 
HydraulicCircuit.feed = func (source_feed)
{
  var index = 0;
  
  if (source_feed.priority > me.current_priority)
  {
    me.current_priority = source_feed.priority;
    forindex (index; me.loads) me.loads[index].feed (source_feed);
    me.pressure = source_feed.pressure;
  } 
}

#------------------------------------------------------------------------------- 
HydraulicCircuit.resetForCycle = func 
{
  me.current_priority = 0;
}

#-------------------------------------------------------------------------------
# Convenience function to compute source priorities according to the order 
# in which they are attached

HydraulicCircuit.nextIncreasingPriority = func 
{
 me.highest_attached_priority = me.highest_attached_priority+1;
 return me.highest_attached_priority - 1;
}
