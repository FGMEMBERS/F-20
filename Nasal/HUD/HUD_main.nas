#F-20 HUD main module

#angular definitions
#up angle 1.73 deg
#left/right angle 5.5 deg
#down angle 10.2 deg
#total size 11x11.93 deg
#texture square 256x256
#bottom left 0,0
#viewport size  236x256
#center at 118,219
#pixels per deg = 21.458507963

var prop_v = props.globals.getNode("/fdm/jsbsim/velocities/v-fps");
var prop_w = props.globals.getNode("/fdm/jsbsim/velocities/w-fps");
var prop_speed = props.globals.getNode("/fdm/jsbsim/velocities/vt-fps");
var radio_altitude_prop = "/fdm/jsbsim/position/h-agl-ft";

var HUDcanvas= canvas.new({
                           "name": "f-20 HUD",
                           "size": [1024,1024],
                           "view": [256,256],
                           "mipmapping": 1
                          });
                          
HUD_page.canvas = HUDcanvas;

HUDcanvas.addPlacement({"node": "HudImage"});
HUDcanvas.setColorBackground(0.2, 0.8, 0.2, 0.00);

# Create a group for the parsed elements
var HUD_SVG = HUDcanvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
canvas.parsesvg(HUD_SVG, "Aircraft/F-20/Nasal/HUD/HUD.svg");
HUD_SVG.setTranslation (-20.0, 37.0);

var ladder = HUD_SVG.getElementById("ladder");
var VV = HUD_SVG.getElementById("VelocityVector");
var bird = HUD_SVG.getElementById("Bird");
var KIAS = HUD_SVG.getElementById("KIAS");
KIAS.setFont("condensed.txf").setFontSize(14, 1.4);
var Alt = HUD_SVG.getElementById("Alt");
Alt.setFont("condensed.txf").setFontSize(11, 1.4);
var AltThousands = HUD_SVG.getElementById("AltThousands");
AltThousands.setFont("condensed.txf").setFontSize(14, 1.4);
var AlphaValue = HUD_SVG.getElementById("alpha");
AlphaValue.setFont("condensed.txf").setFontSize(9, 1.4);
var gValue = HUD_SVG.getElementById("G-value");
gValue.setFont("condensed.txf").setFontSize(9, 1.4);
var MachValue = HUD_SVG.getElementById("Mach");
MachValue.setFont("condensed.txf").setFontSize(9, 1.4);
var heading_tape = HUD_SVG.getElementById("heading-scale");
var roll_pointer = HUD_SVG.getElementById("roll-pointer");
var roll_scale = HUD_SVG.getElementById("roll-scale");
var speed_box = HUD_SVG.getElementById("speed-box");
var alt_box = HUD_SVG.getElementById("alt-box");
var g_label = HUD_SVG.getElementById("g-label-1");
var alpha_label = HUD_SVG.getElementById("alpha-label");
var mach_label = HUD_SVG.getElementById("mach-label");
var heading_pointer = HUD_SVG.getElementById("heading-pointer");
var HUD_heading_bug = HUD_SVG.getElementById("heading-bug");

var HUD_labels = HUD_SVG.getElementById("heading-labels");
  foreach (var child; HUD_labels.getChildren())
    child.setFont("condensed.txf")
		 .setFontSize(9, 1.4)
		 .setAlignment("left-bottom");
    
var HUD_QNH = HUD_SVG.getElementById("QNH");
HUD_QNH.setFont("condensed.txf").setFontSize(9, 1.4);
var Ralt = HUD_SVG.getElementById("Ralt");
Ralt.setFont("condensed.txf").setFontSize(9, 1.4).hide();
var RaltLabel = HUD_SVG.getElementById("RaltLabel");
RaltLabel.setFont("condensed.txf")
	     .setFontSize(9, 1.4)
	     .setAlignment("left-bottom")
	     .hide();
	    
var RaltCross = HUD_SVG.getElementById("RadAltCross");
RaltCross.hide();
	     
var RaltBox = HUD_SVG.getElementById("RaltBox");
RaltBox.hide();

HUD_heading_bug.hide();

var main_layer = HUD_SVG.getElementById("main");
var stby_reticle = HUD_SVG.getElementById("stand-by");
stby_reticle.hide();

var roll_rad = 0.0;
var pitch_offset = 12;
var f1 = 0.0;
#var pitch_factor = 21.458507963;
var pitch_factor = 19.8;
var pitch_factor_2 = pitch_factor * 180.0 / 3.14159;
var VV_y = 0;
var sin_x = 0;
var sin_y = 0;
var VV_x = 0;
var true_speed = 0;
var altitude_hundreds = 0;
var heading_tape_position = 0;
var landing_symbology_inhibit = true;

var radio_altitude = 0;

HUD_page.x_offset = 50;
HUD_page.y_offset = -30;

#-----------------------------------------------------------------------
HUD_page.cycleDeclutter = func()
{

  me.declutter_level = me.declutter_level + 1;
  if (me.declutter_level > 2) me.declutter_level = 0;
  if (me.declutter_level == 0)
  {
    g_label.show();
    gValue.show();
    mach_label.show();
    MachValue.show();
    heading_pointer.show();
    heading_tape.show();
    nav_mode.show();
    distValue.show();
    alt_box.show();
    speed_box.show();
    roll_pointer.show();
    roll_scale.show();
  }
  else if (me.declutter_level == 1)
  {
    g_label.hide();
    gValue.hide();
    mach_label.hide();
    MachValue.hide();
  }
  else
  {
    heading_pointer.hide();
    heading_tape.hide();
    nav_mode.hide();
    distValue.hide();
    alt_box.hide();
    speed_box.hide();
    roll_pointer.hide();
    roll_scale.hide();
  }
}

#-----------------------------------------------------------------------
HUD_page.standby_reticle_required = false;
HUD_page.normal_symbology_timer = 0;
var stby_reticle_toggle_prop = "/f-20/HUD/stand-by-switch";

HUD_page.toggleStandbyReticle = func ()
{
  if (me.standby_reticle_required) 
  {    
    me.standby_reticle_required = false;
    stby_reticle.hide();
    me.normal_symbology_timer = 22; #seconds    
  }
  else
  {
    me.standby_reticle_required = true;
    stby_reticle.show();
    main_layer.hide();
    me.normal_symbology_timer = 0; #seconds  
  }
  setprop (stby_reticle_toggle_prop,  me.standby_reticle_required);
}

#-----------------------------------------------------------------------
HUD_page.setHeadingPointer = func (selected_heading)
{
  var pointer_position = 0;
  if (selected_heading < 180)
     pointer_position = -selected_heading*54/10;
  else
     pointer_position = (360-selected_heading)*54/10;

  HUD_heading_bug.setTranslation (-pointer_position,0);
}


#-----------------------------------------------------------------------
HUD_page.update = func (delta_t)
{

  if (me.standby_reticle_required) return;
  else
  {
    if (me.normal_symbology_timer > 0)
    {
      me.normal_symbology_timer = me.normal_symbology_timer - delta_t;
      return;
    }
    else main_layer.show();
  
  }
  
  if (baro_timer > 0.0)
  {
    HUD_QNH.show();
    HUD_QNH.setText (sprintf ("%2.2f", baro_setting));
    baro_timer = baro_timer - delta_t;    
  }
  else 
  {
    HUD_QNH.hide();
  }
  
  
  roll_rad = -roll*3.14159/180.0;

  #ladder
  ladder.setTranslation (0.0, pitch * pitch_factor+pitch_offset);
  ladder.setCenter (118,830 - pitch * pitch_factor-pitch_offset);
  ladder.setRotation (roll_rad);

  #velocity vector
  true_speed = prop_speed.getValue();
  sin_x = prop_v.getValue()/true_speed;
  if (sin_x < -1) sin_x = -1;
  if (sin_x > 1) sin_x = 1;
  sin_y = prop_w.getValue()/true_speed;
  if (sin_y < -1) sin_y = -1;
  if (sin_y > 1) sin_y = 1;
  VV_x = math.asin (sin_x) * pitch_factor_2;
  VV_y = math.asin (sin_y) * pitch_factor_2;
  VV.setTranslation (VV_x, VV_y+pitch_offset);

  #KIAS
  if (IAS > 40)
    KIAS.setText (sprintf("%3.0f",IAS));
  else
    KIAS.setText ("");

  #Altitude
  if (measured_altitude > 0)
  altitude_hundreds = measured_altitude-int(measured_altitude/1000.0)*1000.0;
  else
  altitude_hundreds = measured_altitude-int(measured_altitude/100.0)*100.0;
  if (altitude_hundreds < -999)   
   Alt.setText ("999");
  else if (altitude_hundreds < -100)
   Alt.setText (sprintf("%3.0f",-altitude_hundreds));
  else if (altitude_hundreds < -10)
   Alt.setText (sprintf("0%2.0f",-altitude_hundreds));
  else if (altitude_hundreds < 0)
    Alt.setText (sprintf("00%1.0f",-altitude_hundreds));
  else if (altitude_hundreds < 10)
     Alt.setText (sprintf("00%1.0f",altitude_hundreds));
  else if (altitude_hundreds < 100)
     Alt.setText (sprintf("0%2.0f",altitude_hundreds));
  else
     Alt.setText (sprintf("%3.0f",altitude_hundreds));

  if (measured_altitude < 0)
     AltThousands.setText ("-");
  else if (measured_altitude < 1000.0)
     AltThousands.setText ("");
  else
     AltThousands.setText (sprintf("%2.0f", math.floor(measured_altitude/1000.0)));

  #readouts
  if (IAS > 10.0) AlphaValue.show(); else AlphaValue.hide();
  AlphaValue.setText (sprintf("%2.1f",Alpha));
  gValue.setText (sprintf("%1.1f",Nz));
  MachValue.setText (sprintf("%1.2f",mach));

  #heading tape
  if (heading < 180)
     heading_tape_position = -heading*54/10;
  else
     heading_tape_position = (360-heading)*54/10;

  heading_tape.setTranslation (heading_tape_position,0);

  #roll pointer
  #roll_pointer.setCenter (118,-50);
  roll_pointer.setRotation (roll_rad);
  
  if (WOW) HUD_page.hideLandingSymbology();
  if (me.displaysLandingSymbology) me.updateLandingSymbology();
  if (me.displaysNav) me.updateNavSymbology();
  
  #Radio altimeter
  if (is_C_variant and me.declutter_level < 2)
  {
    if (radio_altimeter.running)
    {
     RaltCross.hide();        
	 radio_altitude = getprop (radio_altitude_prop);
	 if (radio_altitude <= 2500.0) 
	 {
	  if (roll < 90 and roll > -90) Ralt.setText (sprintf("%.0f",radio_altitude)).show();
	  else Ralt.setText ("---").show();
	  RaltLabel.show();
	  RaltBox.show();
	 }
	 else 
	 {
	  Ralt.hide();
	  RaltLabel.hide();
	  RaltBox.hide();
	 }
	}
    else 
    {
     RaltCross.show();
     RaltBox.hide();
     RaltLabel.show();
     Ralt.hide();
    }
   }
  
}


#######################################################################
#intensity adjust on the main hud
var HUD_intensity = 0.5;
var HUD_intensity_property ="f-20/HUD/intensity";
setprop (HUD_intensity_property, HUD_intensity*10);
var max_HUD_intensity = 1.0;
var min_HUD_intensity = 0.0;
var HUD_intensity_increment = 0.05;

#-----------------------------------------------------------------------
var updateIntensity = func ()
{

  var level = 0;
  var children = [];
  var child = nil;

  if (HUD_intensity < 0.8)  var color = [0.1, 0.75, 0.1, HUD_intensity+0.3];
  else var color = [0.2*(HUD_intensity-0.8)/0.2, 1.0,0.2*(HUD_intensity-0.8)/0.2,5];

  children = ladder.getChildren();
  foreach (child; children)   child.setColor(color);

  children = bird.getChildren();
  foreach (child; children)   child.setColor(color);
  
  children = short_pointer.getChildren();
  foreach (child; children)   child.setColor(color);  

  children = long_pointer.getChildren();
  foreach (child; children)   child.setColor(color);  
  
  children = right_dots.getChildren();
  foreach (child; children)   child.setColor(color);    
  
  children = left_dots.getChildren();
  foreach (child; children)   child.setColor(color); 
  
  children = stby_reticle.getChildren();
  foreach (child; children)   child.setColor(color);  
  
  children = heading_tape.getChildren();
  foreach (child; children) child.setColor(color);
  
  aoa_indexer.setColor(color);
  mockup.setColor(color);
  
  HUD_heading_bug.setColor(color);
    
  KIAS.setColor(color);
  Alt.setColor(color);
  AltThousands.setColor(color);
  AlphaValue.setColor(color);
  gValue.setColor(color);
  MachValue.setColor(color);

  children = heading_tape.getChildren();
  foreach (child; children)   child.setColor(color);

  roll_pointer.setColor(color);

  children = roll_scale.getChildren();
  foreach (child; children)   child.setColor(color);
  
  children = HUD_labels.getChildren();
  foreach (var child; children) child.setColor(color);

  speed_box.setColor(color);
  alt_box.setColor(color);
  g_label.setColor(color);
  alpha_label.setColor(color);
  heading_pointer.setColor(color);
  nav_mode.setColor(color);
  distValue.setColor(color);

}

#-----------------------------------------------------------------------
var increaseIntensity = func ()
{
  HUD_intensity = HUD_intensity + HUD_intensity_increment;
  if (HUD_intensity > max_HUD_intensity)  HUD_intensity = max_HUD_intensity;
  setprop (HUD_intensity_property, HUD_intensity*10);
  updateIntensity();
}

#-----------------------------------------------------------------------
var decreaseIntensity = func ()
{
  HUD_intensity = HUD_intensity - HUD_intensity_increment;
  if (HUD_intensity < min_HUD_intensity)  HUD_intensity = min_HUD_intensity;
  setprop (HUD_intensity_property, HUD_intensity*10);
  updateIntensity();
}

########################################################################
# HUD display
var HUD = {current_page : HUD_page,
			is_on : true,
			warm_up_timer : 0.0,			
		    elec_power : GenericLoad.new (AC_3,
									     60, #watts
										 115)};

#-----------------------------------------------------------------------
HUD.checkPower = func (delta_t)
{
   me.elec_power.update(delta_t);
   if (!me.elec_power.running)
    {
      me.is_on = false;
      HUD_SVG.hide();
      me.warm_up_timer = 0.0;
    }
   else if (!me.is_on) 
    {
      me.is_on = true;
      me.warm_up_timer = 5.0;
    }
    
    if (me.warm_up_timer > 0.0)
    {
      me.warm_up_timer = me.warm_up_timer - delta_t;
      if (me.warm_up_timer <= 0.0)
      {
        me.warm_up_timer = 0.0;
        HUD_SVG.show();
      }
    }
}

