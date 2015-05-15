########################################################################
#define a class for a transformer

var PressureReducer = {ratio : 28/200,
					   source_circuit : nil,
					   destination_circuit : nil,
					   priority : 0};

#-----------------------------------------------------------------------
PressureReducer.new = func (source_circuit, 
                             destination_circuit,
                             priority,
							 ratio)
 {
    var returned_object = {parents : [PressureReducer, 
							          ElectricalLoad, 
							          HydraulicSource]};
	returned_object.source_circuit = source_circuit;
	returned_object.destination_circuit = destination_circuit;
	returned_object.ratio = ratio;
	returned_object.priority = priority;
	source_circuit.connectLoad (returned_object);
	return returned_object;
 }

#-----------------------------------------------------------------------
 PressureReducer.feed = func (source_feed)
 {
   var transformed_feed = {parents : [source_feed]};
   transformed_feed.pressure = me.source_circuit.pressure * me.ratio;
   transformed_feed.priority = me.priority;
   me.destination_circuit.feed (transformed_feed);
 }
