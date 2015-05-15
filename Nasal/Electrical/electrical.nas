########################################################################
# Electrical system base classes
########################################################################

########################################################################
#define a class for an electrical source

var ElectricalSource = {loads : nil,
						voltage : 0,
						priority : 0,
						power_demand : 0,
						electrical_system : nil,
						energised : false};

#-----------------------------------------------------------------------
ElectricalSource.new = func (electrical_system)
{
  var created_source = {parents:[ElectricalSource]};
  created_source.electrical_system = electrical_system;
  created_source.loads = [];
  return created_source;
}

#-----------------------------------------------------------------------
ElectricalSource.connectLoad = func (load)
{
   append (me.loads, load);
   if (load.isTerminal) 
    me.electrical_system.addTerminalLoad(load);
}

#-----------------------------------------------------------------------
ElectricalSource.setPriority = func (priority)
{
   me.priority = priority;
}

#-----------------------------------------------------------------------
ElectricalSource.addPowerDemand = func (watts)
{
  
  me.power_demand = me.power_demand + watts;

}

#-----------------------------------------------------------------------
ElectricalSource.resetForCycle = func ()
{
  
  me.power_demand = 0;

}


########################################################################
#define a container for propagating a source feed

var MAX_BREAKERS_CROSSED = 5;

var SourceFeed = {source : nil,
                  priority : 0,
                  voltage : 0,
                  breakers_crossed : nil,
                  number_of_breakers_crossed : 0};
                  
#-----------------------------------------------------------------------
SourceFeed.new = func (source, priority, voltage)
{
  var returned_feed = {parents:[SourceFeed]};
  returned_feed.source = source;
  returned_feed.priority = priority;
  returned_feed.voltage = voltage;
  returned_feed.breakers_crossed = [];
  setsize (returned_feed.breakers_crossed, MAX_BREAKERS_CROSSED);
  return returned_feed;
}                  

########################################################################
#define a class for an electrical load

var MAX_SOURCES_PER_LOAD = 4;

var ElectricalLoad = {amps : 0, 
					   isTerminal : false};

#-----------------------------------------------------------------------
ElectricalLoad.new = func
{
  return {parents:[ElectricalLoad]};
}


########################################################################
# define a class for a terminal electrical load
# that is a load to which no other load is connected
# e.g. : actuators, instruments, ionic thrusters, coffee makers ...
var TerminalLoad = {voltage : 0,
					fed : false, 
					visited : false,
					current_source_feed : nil,
					current_number_of_sources : 0};

###############################################################
#IMPORTANT : terminal loads should implement an update function
###############################################################

#-----------------------------------------------------------------------
TerminalLoad.new = func ()
{
  var created_load = {parents:[ElectricalLoad.new(), TerminalLoad]};
  created_load.current_source_feed = [];
  created_load.isTerminal = true;
  setsize (created_load.current_source_feed, MAX_SOURCES_PER_LOAD);  
  return created_load;
}

#-----------------------------------------------------------------------
TerminalLoad.feed = func (source_feed)
{
  if (me.current_number_of_sources < MAX_SOURCES_PER_LOAD)
  {    
    me.current_source_feed [me.current_number_of_sources] = source_feed;
    me.fed = true;      
    me.current_number_of_sources = me.current_number_of_sources+1;
    if (!me.visited) me.voltage = source_feed.voltage;
    me.visited = true;  
    if (source_feed.voltage > me.voltage) me.voltage = source_feed.voltage;    
  }#otherwise discard the new source

}

#-----------------------------------------------------------------------
TerminalLoad.powerDemand = func (deltaT)
{
  if (me.current_number_of_sources > 0)
  {
	  var index = 0;
	  var index2 = 0;	  
	  var power_demand = me.amps * me.voltage;
	   
	  for (index = 0; 
		   index < me.current_number_of_sources; 
		   index = index + 1)
	  {
	   me.current_source_feed[index].source.addPowerDemand (power_demand
	 														/
	 														me.current_number_of_sources);
      for (index2 = 0; 
		   index2 < me.current_source_feed[index].number_of_breakers_crossed; 
		   index2 = index2 + 1)
	   {
		me.current_source_feed[index].breakers_crossed[index2].addPowerDemand (power_demand);
	   }
       												
	  }  
	  for (index = 0; index < me.current_number_of_sources; index = index + 1)
						me.current_source_feed [index] = nil; #collect garbage, and reset for next cycle
	  me.current_number_of_sources = 0;
  }
  
}

#-----------------------------------------------------------------------
TerminalLoad.resetForCycle = func 
{
  if (!me.visited)
  {
    me.fed = false;
    me.voltage = 0;
  }
  me.visited = false;  
}

########################################################################
#Define an electrical system

var ElectricalSystem = {terminal_loads :[],
                         generators : [],
                         batteries : [],
                         externals : [],
                         buses : []};
                        
#-----------------------------------------------------------------------                       
ElectricalSystem.new = func
{
  return {parents : [ElectricalSystem]};  
}
						
#-----------------------------------------------------------------------
ElectricalSystem.addTerminalLoad = func (load)
{
  
  append (me.terminal_loads, load);

}

#-----------------------------------------------------------------------
ElectricalSystem.addGenerator = func (gen)
{
  
  append (me.generators, gen);

}

#-----------------------------------------------------------------------
ElectricalSystem.addExternal = func (ext)
{
  
  append (me.externals, ext);

}

#-----------------------------------------------------------------------
ElectricalSystem.addBattery = func (bat)
{
  
  append (me.batteries, bat);

}

#-----------------------------------------------------------------------
ElectricalSystem.addBus = func (bus)
{
  
  append (me.buses, bus);

}

#-----------------------------------------------------------------------
ElectricalSystem.update = func (delta_t)
{
  var index = 0;
  #first we look which are the loads attached to each generator
  forindex (index; me.generators) me.generators[index].feed();
  #then external connections 
  forindex (index; me.externals) me.externals[index].feed();
  #including batteries
  forindex (index; me.batteries) me.batteries[index].feedBus();
  #then we compute the load coming from each of the terminal loads
  forindex (index; me.terminal_loads) me.terminal_loads[index].powerDemand(delta_t);
  forindex (index; me.terminal_loads) me.terminal_loads[index].update(delta_t);
  #compute the change in battery load
  forindex (index; me.batteries) me.batteries[index].updateCharge(delta_t);
  #compute the mechanical power demand for each of the generators
  forindex (index; me.generators) me.generators[index].computePowerConsumption(delta_t);
  #reset all cyclic elements
  forindex (index; me.buses) me.buses[index].resetForCycle();
  forindex (index; me.terminal_loads) me.terminal_loads[index].resetForCycle();
  forindex (index; me.generators) me.generators[index].resetForCycle();
  forindex (index; me.batteries) me.batteries[index].resetForCycle();
}
