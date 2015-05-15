########################################################################
#define a class for a transformer

var ElectricalTransformer = {ratio : 28/200,
							 source_bus : nil,
							 destination_bus : nil,
							 priority : 0};

#-----------------------------------------------------------------------
ElectricalTransformer.new = func (source_bus, 
                                  destination_bus,
                                  priority,
								  ratio)
 {
    var returned_transformer = {parents : [ElectricalTransformer, 
							                ElectricalLoad, 
											ElectricalSource.new (source_bus.electrical_system)]};
	returned_transformer.source_bus = source_bus;
	returned_transformer.destination_bus = destination_bus;
	returned_transformer.ratio = ratio;
	returned_transformer.priority = priority;
	source_bus.connectLoad (returned_transformer);
	return returned_transformer;
 }

#-----------------------------------------------------------------------
 ElectricalTransformer.feed = func (source_feed)
 {
   var transformed_feed = {parents : [source_feed]};
   transformed_feed.voltage = me.source_bus.voltage * me.ratio;
   transformed_feed.priority = me.priority;
   me.destination_bus.feed (transformed_feed);
 }
