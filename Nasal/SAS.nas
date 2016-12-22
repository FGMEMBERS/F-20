#----------------------------------------------------------------------------
# Stability Augmentation System
#----------------------------------------------------------------------------

# Constants
var D2R = math.pi / 180;

var PreviousHeading  = 0.0;
var PreviousSlip     = 0.0;

# Pid constants
var PitchVarTarget   =  0.0;
var PitchKp          = -30.0;
var PitchKi          =  0.0;
var PitchKd          =  0.0;

var RollRateVarTarget =  0.0;
var RollKp           =  3.0;
var RollKi           =  0.0;
var RollKd           =  0.0;

var YawVarTarget     =  0.0;
var YawKp            =  0.08;
var YawKi            =  0.0;
var YawKd            =  0.0;

var PreviousPitchBias  = 0.0;
var PreviousRollBias   = 0.0;
var PreviousYawBias    = 0.0;

# Derivative
var PitchPIDpreviousError = 0.0;
var PitchPIDppError       = 0.0;
var RollPIDpreviousError  = 0.0;
var RollPIDppError        = 0.0;
var YawPIDpreviousError   = 0.0;
var YawPIDppError         = 0.0;

# Limiters
var PitchMaxOutput   =  15.0;
var PitchMinOutput   = -15.0;
var MaxPitchElevator =  1.0;
var MinPitchElevator =  0.5;
var RollMaxOutput    =  8.0;
var RollMinOutput    = -8.0;
var YawMaxOutput     =  0.3;
var YawMinOutput     = -0.3;

# SAS and Autopilot Controls
var SASpitch_on = props.globals.getNode("/x15/controls/SAS/pitch");
var SASroll_on  = props.globals.getNode("/x15/controls/SAS/roll");
var SASyaw_on   = props.globals.getNode("/x15/controls/SAS/yaw");


# Elevator Trim
# -------------
var MaxTrimRate   = 0.015;
var TrimIncrement = 0.0075;
var CurrentTrim   = 0.0;

var trimUp = func {
	CurrentTrim += TrimIncrement;
	if (CurrentTrim > 1.0) CurrentTrim = 1.0;
	setprop ("/controls/flight/elevator-trim", CurrentTrim);
}

trimDown = func {
	CurrentTrim -= TrimIncrement;
	if (CurrentTrim < -1.0) CurrentTrim = -1.0;
	setprop ("/controls/flight/elevator-trim", CurrentTrim);
}



# Stability Augmentation System
# -----------------------------
var computeSAS = func {


	# Roll Channel
	# ------------
	# Roll PID computation
	
		RollRateVarError = RollRateVarTarget - getprop ("/fdm/jsbsim/velocities/p-rad_sec");

		SASroll = PreviousRollBias 
				+ RollKp * (RollRateVarError - RollPIDpreviousError);
				#+ RollKi * deltaT * RollVarError # unused: RollKi = 0
				#+ RollKd * (RollVarError - 2* RollPIDpreviousError + RollPIDppError) / deltaT; # unused: RollKd = 0

		RollPIDpreviousError = RollRateVarError;
		RollPIDppError = RollPIDpreviousError;
		PreviousRollBias = SASroll;

		if (SASroll > RollMaxOutput) SASroll = RollMaxOutput;
		if (SASroll < RollMinOutput) SASroll = RollMinOutput;

		setprop ("/controls/flight/SAS-roll", SASroll);

	


	# Pitch Channel
	# -------------
	# Compute pitch rate to feed PID controller
	
    q = getprop ("/fdm/jsbsim/velocities/q-rad_sec");


			# 2) PID Bias Filter based on current attitude change rate.
			var PitchVarError = PitchVarTarget - q; # PitchVarTarget: adjustment variable, normaly set to 0.0
			SASpitch = PreviousPitchBias 
					+ PitchKp * (PitchVarError - PitchPIDpreviousError);
					#+ PitchKi * deltaT * PitchVarError # unused: PitchKi = 0
					#+ PitchKd * (PitchVarError - 2* PitchPIDpreviousError + PitchPIDppError) / deltaT; # unused: PitchKd = 0

			PitchPIDpreviousError = PitchVarError;
			PitchPIDppError = PitchPIDpreviousError;
			PreviousPitchBias = SASpitch;

			if (SASpitch > PitchMaxOutput) SASpitch = PitchMaxOutput;
			if (SASpitch < PitchMinOutput) SASpitch = PitchMinOutput;
			


	setprop ("/controls/flight/SAS-pitch", SASpitch);



	# Yaw Channel
	# -----------
	# Yaw PID computation
	
	YawVarError = YawVarTarget - getprop ("/fdm/jsbsim/velocities/r-rad_sec");#getprop ("/orientation/side-slip-deg");
	SASyaw = PreviousYawBias 
			+ YawKp * (YawVarError - YawPIDpreviousError)
			+ YawKi * deltaT * YawVarError
			+ YawKd * (YawVarError - 2* YawPIDpreviousError + YawPIDppError) / deltaT;

	YawPIDpreviousError = YawVarError;
	YawPIDppError = YawPIDpreviousError;
	PreviousYawBias = SASyaw;

	if (SASyaw > YawMaxOutput) SASyaw = YawMaxOutput;
	if (SASyaw < YawMinOutput) SASyaw = YawMinOutput;

	setprop ("/controls/flight/SAS-yaw", SASyaw);



}
