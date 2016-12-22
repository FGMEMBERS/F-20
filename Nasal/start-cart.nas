################################################################################
# Start cart

var start_cart_engine_pitch_prop = "/f-20/start-cart/engine-pitch";
var start_cart_lo_rpm_pitch = 200.0;
var start_cart_hi_rpm_pitch = 2000.0;
var start_cart_noise_on_prop = "/f-20/start-cart/noise-on";
var start_cart_blowing = false;
var start_cart_visible_prop = "/f-20/start-cart/visible";

#----------------------------------------------------------------------------
var connectStartCart = func
{
  setprop (start_cart_noise_on_prop, true);
  setprop (start_cart_visible_prop, true);
}

#----------------------------------------------------------------------------
var connectStartCart = func
{
  setprop (start_cart_noise_on_prop, false);
  setprop (start_cart_visible_prop, false);
  start_cart_blowing = false;
}

#----------------------------------------------------------------------------
var airStartPressurise = func
{
  setprop (start_cart_engine_pitch_prop, start_cart_hi_rpm_pitch);
  start_cart_blowing = true;
}

#----------------------------------------------------------------------------
var airStartDepressurise = func
{
  setprop (start_cart_engine_pitch_prop, start_cart_lo_rpm_pitch);
  start_cart_blowing = false;
}
