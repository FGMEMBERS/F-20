########################################################################
# Bus ties 

########################################################################
#define a class for a one way circuit tie
var OneWayTie = {origin : nil,
                 destination : nil,
                 priority_for_destination : 0,
                 closed : true};

#-----------------------------------------------------------------------                 
OneWayTie.new = func (source_circuit, 
                      destination_circuit, 
                      priority)
{
  var returned_tie = {parents : [ElectricalLoad, 
								 HydraulicSource, 
								 OneWayTie]};
  returned_tie.origin = source_circuit;
  returned_tie.destination = destination_circuit;
  returned_tie.priority_for_destination = priority;
  source_circuit.connectLoad (returned_tie);
  return returned_tie;
}

#-----------------------------------------------------------------------
OneWayTie.feed = func (source_feed)
{
  if (me.closed)
  {   
   var reprioritised_feed =  {parents:[source_feed]};
  
   reprioritised_feed.priority = me.priority_for_destination;
   me.destination.feed (reprioritised_feed);
  }
}

########################################################################
#define a class for a circuit tie, just a convenience wrapper for two one way ties

var BusTie = {tie1 : nil,
              tie2 : nil};

#-----------------------------------------------------------------------
BusTie.new = func (circuit1, 
				   priority_for_1,
				   circuit2,
				   priority_for_2)
{
  var returned_object = {parents:[BusTie]};
  returned_object.tie1 = OneWayTie.new (circuit1, circuit2, priority_for_2);
  returned_object.tie2 = OneWayTie.new (circuit2, circuit1, priority_for_1);
  return returned_object;
}

#-----------------------------------------------------------------------
BusTie.close = func
{
   tie2.closed = true;
   tie1.closed = true;
}

#-----------------------------------------------------------------------
BusTie.open = func
{
   tie2.closed = false;
   tie1.closed = false;
}





