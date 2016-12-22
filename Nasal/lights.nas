#light system

var navigation_light = Light.new (AC_1,
								  "/f-20/lights/nav-intensity",
								  100,#watts
								  115);

var console_light = Light.new (AC_1,
							   "/f-20/lights/console-intensity",
							   50,#watts
							   115);
							   
var instrument_light = Light.new (AC_1,
							      "/f-20/lights/instrument-intensity",
							      50,#watts
							      115);	
							      
var DEP_light = Light.new (AC_1,
						   "/f-20/lights/DEP-intensity",
						   10,#watts
						   115);	
							      
instrument_light.enableDimmer ("/f-20/lights/instruments-knob", 0.0);
console_light.enableDimmer ("/f-20/lights/console-knob", 0.0);
navigation_light.enableDimmer ("/f-20/lights/nav-knob", 0.0);
DEP_light.enableDimmer ("/f-20/lights/DEP-knob", 0.0);					      						   


