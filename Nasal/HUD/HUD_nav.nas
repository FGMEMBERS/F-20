# HUD landing symbols
var nav_mode = HUD_SVG.getElementById("NavMode");
var distValue = HUD_SVG.getElementById("distance");
distValue.setFont("condensed.txf").setFontSize(9, 1.4);

var left_dots = HUD_SVG.getElementById("left-dots");
var right_dots = HUD_SVG.getElementById("right-dots");
var long_pointer = HUD_SVG.getElementById("long_pointer");
var short_pointer = HUD_SVG.getElementById("short_pointer");
var HUD_slider = HUD_SVG.getElementById("hud-slider");

var hud_deviation_scale = 21.0/2.5; #pixels per degree

HUD_page.displaysNav = false;

#-----------------------------------------------------------------------
HUD_page.setTacanNav = func ()
{
  HUD_slider.show();
  nav_mode.setText("TCN").show();
  distValue.show();
  HUD_page.displaysNav = true;
}

#-----------------------------------------------------------------------
HUD_page.setINSnav = func ()
{
  HUD_slider.show();
  nav_mode.setText("WPT").show();
  distValue.show();
  HUD_page.displaysNav = true;
}

#-----------------------------------------------------------------------
HUD_page.setNoNav = func ()
{
  HUD_slider.hide();
  nav_mode.hide();
  distValue.hide();
  HUD_page.displaysNav = false;
}
HUD_page.setNoNav();

#-----------------------------------------------------------------------
HUD_page.drawDeviation = func (deviation, course_rad)
{
  var local_deviation = deviation;
  if (deviation > 180) local_deviation = deviation - 360;
  
  if (local_deviation < -7)
  {
    left_dots.show();
    right_dots.hide();
    long_pointer.hide();
    short_pointer.setTranslation(-7 * hud_deviation_scale,0).show();    
	HUD_slider.setRotation(course_rad);			     
  }
  else if (local_deviation < -2.5)
  {
    left_dots.show();
    right_dots.hide();
    long_pointer.setTranslation(local_deviation * hud_deviation_scale,0).show();
    short_pointer.hide();
    HUD_slider.setRotation(course_rad);
  }
  else if (local_deviation < 2.5)
  {
    left_dots.hide();
    right_dots.hide();
    long_pointer.hide();
    short_pointer.setTranslation(local_deviation * hud_deviation_scale,0).show();
    HUD_slider.setRotation(course_rad);				 
  }
  else if (local_deviation < 7)
  {
    left_dots.hide();
    right_dots.show();
    long_pointer.setTranslation(local_deviation * hud_deviation_scale,0).setRotation(0).show();
    short_pointer.hide();
    HUD_slider.setRotation(course_rad);
  }
  else
  {
    left_dots.hide();
    right_dots.show();
    long_pointer.hide();
    short_pointer.setTranslation(7 * hud_deviation_scale,0).show();
    HUD_slider.setRotation(course_rad);
  }
}

#-----------------------------------------------------------------------
HUD_page.updateNavSymbology = func ()
{
   
  if (HSI.nav_mode == tacan_nav)
  {
    if (TACAN.is_receiving)
    {
		distValue.setText (sprintf("%.1f", TACAN.distance));
		if (HSI.tacan_route_mode == dir_mode)
		{
		  long_pointer.hide();
		  left_dots.hide();
		  right_dots.hide();    
		  HUD_slider.setRotation ((TACAN.bearing-heading) * deg_to_rad).show();  
		  short_pointer.setTranslation (0,0).show();      
		}
		else 
		{
		  HUD_slider.show();
		  me.drawDeviation (TACAN.bearing - HSI.selected_course, 
							(HSI.selected_course - heading)*deg_to_rad);
		}
    }
    else
    {
		distValue.setText ("---");
		HUD_slider.hide();
    }
  }  
  else if (HSI.nav_mode == ins_nav)
  {
     distValue.setText (sprintf("%.1f", INS.distance));
     var INS_bearing_rad = INS.bearing * deg_to_rad;
     
    if (HSI.ins_route_mode == dir_mode)
    {
      long_pointer.hide();
      left_dots.hide();
	  right_dots.hide();   
	  HUD_slider.setRotation ((INS.bearing-heading) * deg_to_rad);   
      short_pointer.setTranslation (0,0).show();            
    }
    else if (HSI.ins_route_mode == leg_mode)
    {
      me.drawDeviation (INS.bearing - INS.current_course, 
						(INS.current_course - heading)*deg_to_rad);
    }
    else
    {
      me.drawDeviation (INS.bearing - HSI.selected_course,
						(HSI.selected_course - heading)*deg_to_rad);
    }
   }  
}
