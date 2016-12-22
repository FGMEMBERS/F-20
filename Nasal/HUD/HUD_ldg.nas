# HUD landing symbols
var VSI_value = HUD_SVG.getElementById("VSI");
VSI_value.setFont("condensed.txf").setFontSize(11, 1.4);
var aoa_indexer = HUD_SVG.getElementById("aoa_indexer");
var aoa_indexer_scale = 5; #pixels per alpha
var approach_path = HUD_SVG.getElementById("approach-path");
var mockup = HUD_SVG.getElementById("mockup");

HUD_page.displaysLandingSymbology = false;

#-----------------------------------------------------------------------
HUD_page.showLandingSymbology = func ()
{
  approach_path.show();
  VSI_value.show();
  aoa_indexer.show();
  mockup.show();
  
  me.displaysLandingSymbology = true;
}

#-----------------------------------------------------------------------
HUD_page.hideLandingSymbology = func ()
{
  approach_path.hide();
  VSI_value.hide();
  aoa_indexer.hide();
  mockup.hide();
  me.displaysLandingSymbology = false;
}
HUD_page.hideLandingSymbology ();

#-----------------------------------------------------------------------
HUD_page.updateLandingSymbology = func ()
{
  VSI_value.setText(sprintf ("%i",getprop("/velocities/vertical-speed-fps")*60));  
  aoa_indexer.setTranslation(0, (Alpha - central_alpha) * aoa_indexer_scale);
}
