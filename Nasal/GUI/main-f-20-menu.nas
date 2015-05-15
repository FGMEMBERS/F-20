#******************************************************************************
# Canvas GUI

var menu_bar = nil;
var menu_bar_canvas = nil;
var menu_bar_widgets = nil;
var menu_bar_image = nil;
var menu_bar_root = nil;
var ground_handling_button = nil;
var ground_handling_dialog_visible = false;
var checklists_button = nil;
var liveries_button = nil;


#-------------------------------------------------------------------------------
var showCustomMenuBar = func
{
  menu_bar = canvas.Window.new ([379,30]);
  menu_bar.setPosition(screen_width-379, 0);
  menu_bar.setCanvas (menu_bar_canvas);
  menu_bar_image.setSourceRect(0,0,512,512, false);
}

#-------------------------------------------------------------------------------
var toggleGroundHandlingDialog = func
{
  
  if (ground_handling_dialog_visible) 
   {
    ground_handling_dialog_visible = ! ground_handling_dialog_visible;
    hideGroundHandlingDialog();
   }
  else 
  {
    if (WOW) 
    {
     showGroundHandlingDialog();
     ground_handling_dialog_visible = ! ground_handling_dialog_visible;
    }
  }
  
}

#-------------------------------------------------------------------------------
var checklistsButtonCallback = func
{
  print ("Not yet implemented !");
}


#-------------------------------------------------------------------------------
var initCustomMenuBar = func
{
   menu_bar_canvas = canvas.new({"name": "Custom menu bar",
											   "size": [379, 30],
											   "view": [379, 30],
											   "mipmapping": 0 });

   menu_bar_canvas.setColorBackground (0,0,0,0);
   menu_bar_canvas.addPlacement({"type": "ref"});
   menu_bar_root = menu_bar_canvas.createGroup ();

   menu_bar_image = menu_bar_root.createChild("image")
							     .setFile("Aircraft/F-20/Nasal/GUI/menu-ribon.png")
								 .setSourceRect(0,0,379,30, false)
								 .setSize(512,512);

   menu_bar_widgets = menu_bar_root.createChild ("group");

   ground_handling_button = RoundedButton.new (menu_bar_widgets,
												"Ground handling",
												 toggleGroundHandlingDialog,
												 180,
												 15);

	checklists_button= RoundedButton.new (menu_bar_widgets,
										  "Checklists",
										  checklistsButtonCallback,
										  275,
										  15);
  

   liveries_button = RoundedButton.new (menu_bar_widgets,
									    "Liveries",
										 func {aircraft.livery.dialog.toggle()},
										 345,
										 15);

   removelistener(customMenuBarInitListener);
   showCustomMenuBar();
}

#-------------------------------------------------------------------------------
var customMenuBarInitListener = setlistener("/sim/signals/fdm-initialized",
										    initCustomMenuBar);
