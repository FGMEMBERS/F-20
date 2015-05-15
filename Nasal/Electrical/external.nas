########################################################################
#define a class for a External connection

var ExternalElectricity = {consummer_bus : nil};

#-------------------------------------------------------------------------------
ExternalElectricity.new = func (electrical_system,
								 voltage,
								 bus,
								 priority)
 {
    created_external_connection = {parents : [ElectricalSource, ExternalElectricity]};
    created_external_connection.consummer_bus = bus;
    created_external_connection.voltage = voltage;
    created_external_connection.priority = priority;
    electrical_system.addExternal (created_external_connection);
    return created_external_connection;
 }

#-----------------------------------------------------------------------
 ExternalElectricity.switchOff = func
 {
    me.energised = false;
 }

#-----------------------------------------------------------------------
 ExternalElectricity.switchOn = func
 {
    me.energised = true;
 }

 #-----------------------------------------------------------------------
 ExternalElectricity.feed = func
 {
   if (me.energised)
   {
    var root_feed = SourceFeed.new (me, me.priority, me.voltage);
    me.consummer_bus.feed (root_feed);
   }
 }
