########################################################################
# Define a class for an electrical bus

var ElectricalBus = {current_priority : -1,
					  highest_attached_priority : 0};

#-------------------------------------------------------------------------------
ElectricalBus.new = func  (electrical_system)
 {
    var created_bus = { parents : [ElectricalBus, 
								   ElectricalLoad, 
								   ElectricalSource.new(electrical_system)]};
    electrical_system.addBus (created_bus);
    return created_bus;
 }

#------------------------------------------------------------------------------- 
ElectricalBus.feed = func (source_feed)
{
  var index = 0;
  
  if (source_feed.priority > me.current_priority)
  {
    me.current_priority = source_feed.priority;
    forindex (index; me.loads) me.loads[index].feed (source_feed);
    me.voltage = source_feed.voltage;
  } 
}

#------------------------------------------------------------------------------- 
ElectricalBus.resetForCycle = func 
{
  me.current_priority = -1;
}

#-------------------------------------------------------------------------------
# Convenience function to compute source priorities according to the order 
# in which they are attached

ElectricalBus.nextIncreasingPriority = func 
{
 me.highest_attached_priority = me.highest_attached_priority+1;
 return me.highest_attached_priority - 1;
}
