# f-20.nas

#----------------------------------------------------------------------------
# Property nodes
#----------------------------------------------------------------------------
var prop_IAS =  props.globals.getNode ("/velocities/airspeed-kt");
var prop_alpha = props.globals.getNode ("orientation/alpha-deg");
var prop_mach =  props.globals.getNode ("/velocities/mach");
var prop_altitude_ft =  props.globals.getNode ("/position/altitude-ft");
var prop_heading =  props.globals.getNode("/orientation/heading-magnetic-deg");
var prop_track = props.globals.getNode("/orientation/track-deg");
var prop_elevator_trim =  props.globals.getNode ("/controls/flight/elevator-trim");
var prop_deltaT =  props.globals.getNode ("sim/time/delta-sec");
var prop_pitch =  props.globals.getNode ("orientation/pitch-deg");
var prop_roll =  props.globals.getNode ("orientation/roll-deg");
var reheat_particle_lifetime =  props.globals.getNode("/f-20/reheat-lifetime");
var reheat_particle_number =  props.globals.getNode("/f-20/reheat-number");
var Nz_prop = props.globals.getNode("/fdm/jsbsim/accelerations/Nz");


## Global constants ##
var true = 1;
var false = 0;

var deltaT = 1.0;
var g_ft_sec2 = 32.174; 
var reheat_particle_density = 2000.0;


# Canopy switch animation and canopy move. Toggle keystroke and 2 positions switch.
var cnpy = aircraft.door.new("canopy", 4);
var pos = props.globals.getNode("canopy/position-norm");
var current_canopy_state = 0;

var canopyToggle = func {

	if (current_canopy_state == 1)
    {
        current_canopy_state = 0;
		cnpy.close();
    }
	 else
     {
        current_canopy_state = 1;
		cnpy.open();
      }	
}

#----------------------------------------------------------------------------
# update global values and call other updates
#----------------------------------------------------------------------------

var registerUpdate = func {settimer (updateF20, 0);}

var updateF20 = func {
	#Fetch most commonly used values
    Alpha = prop_alpha.getValue ();
	IAS = prop_IAS.getValue();
	mach = prop_mach.getValue(); 
	altitude_ft = prop_altitude_ft.getValue();
	WOW = getprop ("/gear/gear[1]/wow") or getprop ("/gear/gear[2]/wow");
	heading = prop_heading.getValue();	
    track = prop_track.getValue();
	ElevatorTrim = prop_elevator_trim.getValue();
	deltaT = prop_deltaT.getValue();
	pitch = prop_pitch.getValue();
	roll = prop_roll.getValue();
    Nz = Nz_prop.getValue();
    
	#update functions
	updateFuelSystem(deltaT);
    updateEngine(deltaT);
    #updateSpeedBrakes(deltaT);
    updateGearIndicators(deltaT);
    updateElectricalSystem (deltaT);    
    updateHydraulics(deltaT);
    updateEngineInstrument();
    INS.update(deltaT);
    TACAN.update (deltaT);
    AOA_indexer.update (deltaT);
    updateDisplays(deltaT);
    updateArmamentPanel(deltaT);
    updateClock();
    updateFlaps();
    updateAltimeter();

    registerUpdate();    

}

var startProcess = func {
    settimer (updateF20, 0.0);
}

setlistener("/sim/signals/fdm-initialized", startProcess);
