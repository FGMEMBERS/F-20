########################################################################
# Electrical system base classes
########################################################################

#constants
var circuit_without_primary_source = 0;
var circuit_on_accu = 1;
var circuit_on_PTU = 2;
var circuit_on_reducer = 3;
var circuit_on_pump = 4;


########################################################################
#define a class for an electrical source

var HydraulicSource = {loads : [],
						pressure : 0,
						priority : 0,
						power_demand : 0,
						hydraulic_system : nil,
						pressurised : false};

#-----------------------------------------------------------------------
HydraulicSource.new = func (hydraulic_system)
{
  var obj = {parents:[HydraulicSource]};
  obj.hydraulic_system = hydraulic_system;
  obj.loads = [];
  return obj;
}

#-----------------------------------------------------------------------
HydraulicSource.connectLoad = func (load)
{
   append (me.loads, load);
   if (load.isTerminal) 
    me.hydraulic_system.addHydTerminalLoad(load);
}

#-----------------------------------------------------------------------
HydraulicSource.setPriority = func (priority)
{
   me.priority = priority;
}

#-----------------------------------------------------------------------
HydraulicSource.addPowerDemand = func (watts)
{
  
  me.power_demand = me.power_demand + watts;

}


########################################################################
#define a container for propagating a source feed

var MAX_BREAKERS_CROSSED = 5;

var SourceFeed = {source : nil,
                  priority : 0,
                  pressure : 0,
                  breakers_crossed : [],
                  number_of_breakers_crossed : 0};
                  
#-----------------------------------------------------------------------
SourceFeed.new = func (source, priority, pressure)
{
  var returned_feed = {parents:[SourceFeed]};
  returned_feed.source = source;
  returned_feed.priority = priority;
  returned_feed.pressure = pressure;
  returned_feed.breakers_crossed = [];
  setsize (returned_feed.breakers_crossed, MAX_BREAKERS_CROSSED);
  return returned_feed;
}                  

########################################################################
#define a class for an electrical load

var MAX_SOURCES_PER_LOAD = 4;

var ElectricalLoad = {flow_rate : 0, 
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
var HydTerminalLoad = {pressure : 0,
					fed : false, 
					visited : false,
					current_source_feed : [],
					current_number_of_sources : 0};

#-----------------------------------------------------------------------
HydTerminalLoad.new = func
{
  var obj = {parents:[ElectricalLoad.new(), HydTerminalLoad]};
  obj.current_source_feed = [];
  obj.isTerminal = true;
  setsize (obj.current_source_feed, MAX_SOURCES_PER_LOAD);
  return obj;
}

#-----------------------------------------------------------------------
HydTerminalLoad.feed = func (source_feed)
{
  if (me.current_number_of_sources < MAX_SOURCES_PER_LOAD)
  {    
    me.current_source_feed [me.current_number_of_sources] = source_feed;
    me.fed = true;
    me.visited = true;    
    me.current_number_of_sources = me.current_number_of_sources+1;
    if (source_feed.pressure > me.pressure) me.pressure = source_feed.pressure;
  }#otherwise discard the new source

}

#-----------------------------------------------------------------------
HydTerminalLoad.powerDemand = func (deltaT)
{
  if (me.current_number_of_sources > 0)
  {
	  var index = 0;
	  var index2 = 0;	  
	  var power_demand = me.flow_rate * me.pressure;
	   
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
HydTerminalLoad.resetForCycle = func 
{
  if (!me.visited)
  {
    me.fed = false;
    me.pressure = 0;
  }
  me.visited = false;  
}

########################################################################
#Define an electrical system

var HydraulicSystem = {terminal_loads :[],
                        pumps : [],
                        accumulators : [],
                        externals : [],
                        circuit : []};
                        
#-----------------------------------------------------------------------                       
HydraulicSystem.new = func
{
  return {parents : [HydraulicSystem]};  
}
						
#-----------------------------------------------------------------------
HydraulicSystem.addHydTerminalLoad = func (load)
{
  
  append (me.terminal_loads, load);

}

#-----------------------------------------------------------------------
HydraulicSystem.addPump = func (gen)
{
  
  append (me.pumps, gen);

}

#-----------------------------------------------------------------------
HydraulicSystem.addBattery = func (bat)
{
  
  append (me.accumulators, bat);

}

#-----------------------------------------------------------------------
HydraulicSystem.addBus = func (circuit)
{
  
  append (me.circuit, circuit);

}


#-----------------------------------------------------------------------
HydraulicSystem.update = func (delta_t)
{

  var index = 0;
  #first we look which are the loads attached to each generator
  forindex (index; me.pumps) me.pumps[index].feed();
  #then external connections 
  forindex (index; me.externals) me.externals[index].feed();
  #including accumulators
  forindex (index; me.accumulators) me.accumulators[index].feedBus();
  #then we compute the load coming from each of the terminal loads
  forindex (index; me.terminal_loads) me.terminal_loads[index].powerDemand(delta_t);
  #compute the change in battery load
  forindex (index; me.accumulators) me.accumulators[index].updateCharge(delta_t);
  #compute the mechanical power demand for each of the pumps
  forindex (index; me.pumps) me.pumps[index].computePowerConsumption(delta_t);
  #reset all cyclic elements
  forindex (index; me.circuit) me.circuit[index].resetForCycle();
  forindex (index; me.terminal_loads) me.terminal_loads[index].resetForCycle();
}
