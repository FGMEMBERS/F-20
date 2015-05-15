#Digital Air Data Unit

var indicated_alpha_prop = "instrumentation/dadu/alpha";
var indicated_altitude_prop = "instrumentation/dadu/altitude";

var updateDadu = func
{
 
 #add leading zeros
 setprop (indicated_alpha_prop, alpha);
 setprop (indicated_altitude_prop, altitude);
 
}

