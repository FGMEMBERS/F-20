#Clock

var hour_prop = "sim/time/utc/hour";
var minute_prop = "sim/time/utc/minute";
var second_prop = "sim/time/utc/second";



var clock = canvas.new({
  "name": "Clock",
  "size": [128, 128], # Size of the underlying texture (should be a power of 2, required)
  "view": [128, 128],  # Virtual resolution (Defines the coordinate system of the canvas
                        # which will be stretched the size of the texture, required)
  "mipmapping": 1       # Enable mipmapping (optional)
});

clock.setColorBackground(0.0,0.0,0);

clock.addPlacement({"node": "Clock"});

var clockRoot = clock.createGroup();

var clockText = clockRoot.createChild("text", "optional-id-for element")
                      .setTranslation(64, 128)      # The origin is in the top left corner
                      .setAlignment("center-bottom") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                      .setFont("led.txf") 
                      .setFontSize(24, 1.2)
                      .setColor(1.0,0.0,0.0)
                      .show();                                                 
var minutes = 0;
var seconds = 0;
var display_time = "";

var updateClock = func
{
 minutes = getprop(minute_prop);
 seconds = getprop(second_prop);
 
 #add leading zeros
 if (seconds < 10)
   display_time = sprintf (":0%i",seconds);
 else
  display_time = sprintf (":%i",seconds);
  
 if (minutes < 10)
   display_time = sprintf (":0%i%s",minutes,display_time);
 else
  display_time = sprintf (":%i%s",minutes,display_time);
  
 clockText.setText(sprintf("%i%s",getprop(hour_prop), display_time));  
}

