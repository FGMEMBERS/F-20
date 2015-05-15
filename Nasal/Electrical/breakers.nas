########################################################################
#define a class for a circuit breaker

var breaker_closed = 0;
var breaker_open = 1;

var CircuitBreaker = {rating : 5, #Amperes
     			      position : breaker_closed,
    				  property : nil};

#-----------------------------------------------------------------------
CircuitBreaker.new = func (electrical_system,
							rating, 
							breaker_property)
{
   var created_breaker = {parents : [CircuitBreaker,
									  ElectricalLoad, 
									  ElectricalSource.new(electrical_system)]};
   created_breaker.rating = rating;
   created_breaker.property = breaker_property;
   if (breaker_property != nil) setprop (breaker_property, me.position);
   return created_breaker;
}

#------------------------------------------------------------------------------- 
#todo : improve to avoid that much garbage collection (tree structure)
CircuitBreaker.feed = func (source_feed)
{
   if ((me.power_demand / source_feed.voltage) > me.rating) 
   { 
     me.position = breaker_open;     
     me.power_demand = 0;
     return;
   }
   else
   {
	   #reset the power demand since this call corresponds to the begining of
	   #the update cycle
       me.power_demand = 0;
	   if (me.position == breaker_closed)
	   {    
		if (forked_source_feed.number_of_breakers_crossed < MAX_BREAKERS_CROSSED)
		{
		 var forked_source_feed = {parents : source_feed};
		 forked_source_feed.breakers_crossed [forked_source_feed.number_of_breakers_crossed] =  me;
		 forked_source_feed.number_of_breakers_crossed = forked_source_feed.number_of_breakers_crossed + 1;
		 foreach (var load; loads) load.feed (forked_source_feed);
		} #otherwise just ignore the breaker ...
		else foreach (var load; loads) load.feed (source_feed);
	  }
   }
}

#------------------------------------------------------------------------------- 
CircuitBreaker.pop = func ()
{
     me.position = breaker_open;     
     setprop (me.property, breaker_open);
}

#------------------------------------------------------------------------------- 
CircuitBreaker.push = func ()
{
     me.position = breaker_closed;     
     setprop (me.property, breaker_closed);
}
