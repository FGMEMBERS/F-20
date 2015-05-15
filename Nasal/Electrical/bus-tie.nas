########################################################################
# Bus ties

########################################################################
#define a class for a one way bus tie
var OneWayTie = {origin : nil,
                 destination : nil,
                 priority_for_destination : 0,
                 closed : true};

#-----------------------------------------------------------------------
OneWayTie.new = func (source_bus,
                      destination_bus,
                      priority)
{
  var created_tie = {parents : [ElectricalLoad,
								 ElectricalSource,
								 OneWayTie]};
  created_tie.origin = source_bus;
  created_tie.destination = destination_bus;
  created_tie.priority_for_destination = priority;
  source_bus.connectLoad (created_tie);
  return created_tie;
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
#define a class for a bus tie, just a convenience wrapper for two one way ties

var BusTie = {tie1 : nil,
              tie2 : nil};

#-----------------------------------------------------------------------
BusTie.new = func (bus1,
				   priority_for_1,
				   bus2,
				   priority_for_2)
{
  var returned_object = {parents:[BusTie]};
  returned_object.tie1 = OneWayTie.new (bus1, bus2, priority_for_2);
  returned_object.tie2 = OneWayTie.new (bus2, bus1, priority_for_1);
  return returned_object;
}

#-----------------------------------------------------------------------
BusTie.close = func
{
   me.tie2.closed = true;
   me.tie1.closed = true;
}

#-----------------------------------------------------------------------
BusTie.open = func
{
   me.tie2.closed = false;
   me.tie1.closed = false;
}





