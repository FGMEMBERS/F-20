################################################################################
# Start cart

var start_cart_engine_pitch_prop = "/f-20/start-cart/engine-pitch";
var start_cart_lo_rpm_pitch = 200.0;
var start_cart_hi_rpm_pitch = 2000.0;
var start_cart_noise_on_prop = "/f-20/start-cart/noise-on";
var start_cart_blowing = false;
var start_cart_visible_prop = "/f-20/start-cart/visible";
var start_cart_connected = false;
var start_control_valve_prop = "/f-20/start-cart/SCV";

#----------------------------------------------------------------------------
var connectStartCart = func
{
  start_cart_connected = true;
  setprop (start_cart_noise_on_prop, true);
  setprop (start_cart_engine_pitch_prop, start_cart_lo_rpm_pitch);
  setprop (start_cart_visible_prop, start_cart_connected);
  ext_elec.switchOn();
}

#----------------------------------------------------------------------------
var disconnectStartCart = func
{
  start_cart_connected = false;
  setprop (start_cart_noise_on_prop, false);
  setprop (start_cart_visible_prop, start_cart_connected);
  airStartDepressurise();
  ext_elec.switchOff();
}

#----------------------------------------------------------------------------
var airStartPressurise = func
{

      setprop (start_cart_engine_pitch_prop, start_cart_hi_rpm_pitch);
      start_cart_blowing = true;      
      if (!is_C_variant)
      {
        #autostart if no JFS installed        
        engine_cranking = true;
        cartridge_discharging = false;
        setprop (starter_prop, 1);
      }
}

#----------------------------------------------------------------------------
var airStartDepressurise = func
{
  setprop (start_cart_engine_pitch_prop, start_cart_lo_rpm_pitch);
  start_cart_blowing = false;
  setprop (start_control_valve_prop, 0);

}

#******************************************************************************
# Canvas GUI

var ground_handling_dialog = nil;
var ground_handling_dialog_canvas = nil;
var gh_widgets = nil;
var gh_image = nil;
var gh_root = nil;
var parachute_spent_label = nil;
var parachute_button = nil;
var connect_start_cart_button = nil;
var repack_chute_button = nil;
var air_supply_button = nil;
var choks_button  = nil;
var select_payload_button = nil;

#-------------------------------------------------------------------------------
var showGroundHandlingDialog = func
{
  ground_handling_dialog = canvas.Window.new ([279,185]);
  ground_handling_dialog.setPosition(screen_width-279,31);
  ground_handling_dialog.setCanvas (ground_handling_dialog_canvas);
  gh_image.setSourceRect(0,0,512,512, false);
  #grabButton.addEventListener("drag", func(e) stores_dialog.move(e.deltaX, e.deltaY));
}

#-------------------------------------------------------------------------------
var hideGroundHandlingDialog = func
{
  ground_handling_dialog.del();
}


#-------------------------------------------------------------------------------
var connectStartCartButtonCallback = func
{
  if (start_cart_connected)
  {
   connect_start_cart_button.setText("Connect");
   disconnectStartCart();
   air_supply_button.disable();
  }
  else
  {
   connect_start_cart_button.setText("Disconnect");
   connectStartCart();
   air_supply_button.enable();
  }
}

#-------------------------------------------------------------------------------
var airSupplyButtonCallback = func
{
  if (start_cart_blowing or engine_running)
  {
   air_supply_button.setText("Supply Air");
   airStartDepressurise();   
  }
  else
  {
   air_supply_button.setText("Stop Air");
   airStartPressurise ();
  }
}

#-------------------------------------------------------------------------------
var chocks_in_place = false;
var chocks_visible_prop = "/f-20/chocks-visible";

var chocksButtonCallback = func
{
  #TODO test for ground speed
  chocks_in_place = ! chocks_in_place;
  setprop (chocks_visible_prop, chocks_in_place);
  setprop ("controls/gear/brake-parking",chocks_in_place); 
  if (chocks_in_place) choks_button.setText("Remove chocks");
  else choks_button.setText("Place chocks");

}

#-------------------------------------------------------------------------------
var initGroundHandlingDialog = func
{
	ground_handling_dialog_canvas = canvas.new({"name": "Ground handling dialog",
											   "size": [279, 185],
											   "view": [279, 185],
											   "mipmapping": 0 });

	ground_handling_dialog_canvas.setColorBackground (0,0,0,0);
	ground_handling_dialog_canvas.addPlacement({"type": "ref"});
	gh_root = ground_handling_dialog_canvas.createGroup ();

	gh_image = gh_root.createChild("image")
					  .setFile("Aircraft/F-20/Nasal/GUI/ground-handling-bg.png")
					  .setSourceRect(0,0,279,185, false)
					  .setSize(512,512);

	gh_widgets = gh_root.createChild ("group");

    # Chocks
    var chocks_y = 50;
	choks_button = RoundedButton.new (gh_widgets,
									  "Place chocks",
                                      chocksButtonCallback,
									  130,
									  chocks_y);
                                      
    # Brake Parachute
    var parachute_y = 83;
	gh_widgets.createChild ("text")
			  .setText ("Brake parachute")
		      .setFont(button_font)
		      .setFontSize(14, 1.0)
			  .setAlignment ("left-center")
			  .setTranslation (15,parachute_y)
			  .setColor(0.0, 0.0, 0.0)
			  .show();

	parachute_spent_label =  gh_widgets.createChild ("text")
                                       .setText ("spent")
									   .setFont(button_font)
									   .setFontSize(12, 1.0)
                                       .setAlignment ("left-center")
                                       .setTranslation (100,parachute_y)
                                       .setColor(1.0, 0.0, 0.0)
                                       .hide();

	repack_chute_button = RoundedButton.new (gh_widgets,
											"Repack",
											repackChute,
											220,
											parachute_y);
    # Start cart 
    var start_cart_y = 116;
	gh_widgets.createChild ("text")
			  .setText ("Start Cart")
			  .setFont(button_font)
			  .setFontSize(14, 1.0)
			  .setAlignment ("left-center")
			  .setTranslation (15,start_cart_y)
			  .setColor(0.0, 0.0, 0.0)
			  .show();

	connect_start_cart_button = RoundedButton.new (gh_widgets,
												  "Connect",
												   connectStartCartButtonCallback,
												   130,
												   start_cart_y);

	air_supply_button= RoundedButton.new (gh_widgets,
										  "Supply air",
										  airSupplyButtonCallback,
										  220,
										  start_cart_y);
	air_supply_button.disable ();

    # Payload
    var select_payload_y = 150;
	select_payload_button = RoundedButton.new (gh_widgets,
											   "Select Payload",
											   showStoresDialog,
											   130,
											   select_payload_y);

	removelistener(groundHandlingDialogInitListener);

}

#-------------------------------------------------------------------------------
var groundHandlingDialogInitListener = setlistener("/sim/signals/fdm-initialized",
										            initGroundHandlingDialog);
