## Global constants ##
var true = 1;
var false = 0;

var deltaT = 1.0;
var g_ft_sec2 = 32.174; 

#----------------------------------------------------------------------------
# SAS
#----------------------------------------------------------------------------

var SASpitch = 0.0;
var SASroll = 0.0;
var SASyaw = 0.0;

#----------------------------------------------------------------------------
# General aircraft values
#----------------------------------------------------------------------------

# Variables
var mach = 0.0;
var altitude_ft = 0.0;
var IAS = 0.0;
var WOW = true;
var Alpha = 0.0;
var heading = 0.0;
var track = 0.0;
var Beta = 0.0;
var dynamic_pressure = 0.0;
var ElevatorTrim = 0.0;
var pitch = 0.0;
var roll = 0.0;
var Nx = 0.0;
var Ny = 0.0;
var Nz = 0.0;
var gear_up = 0;
var gear_down = 1;
var gear_command = gear_down;
var measured_altitude = 0;
var screen_width = getprop("/sim/startup/xsize");
var is_prototype = getprop("/f-20/is-prototype");
var is_A_variant = getprop("/f-20/is-A-version");
var is_C_variant = getprop("/f-20/is-C-version");
var N2 = getprop("engines/engine/n2");


#utility function
var ABS = func (X)
{
    if (X<0) return -X; else return X;
}

# Set properties

setprop ("/controls/flight/flapscommand", 0.0);


