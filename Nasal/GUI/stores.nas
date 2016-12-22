# Graphical payload editor

# Uses :
# payload.nas

var stores_dialog = {};
var stores_dialog_canvas = {};
var grabButton = {};
var closeButton = {};

var root_group = {};
var image = {};
var widgets = {};

var grey = [0.6,0.6,0.6,1.0];
var green = [0,0.5,0,1.0];

var sniper_and_alq_mounted = false;

var load_catalog = [];

#-------------------------------------------------------------------------------
var getIdent = func (station, payload)
{
  foreach (load; load_catalog[station])
   {
     if (load.store == payload [station]) return load.ident;
   }
  return nil;
}

#-------------------------------------------------------------------------------
var updateStationsDisplay = func
{

  var station = 0;
  var load = 0;

  forindex (station; load_catalog)
  {
    forindex (load; load_catalog[station])
    {
     if (current_payload[station] == load_catalog[station][load].store)
       load_catalog[station][load].widget.setColorFill(green);
     else
      load_catalog[station][load].widget.setColorFill(grey);
    }
  }

}

#-------------------------------------------------------------------------------
var wingDropTankToggleCallback = func
{
  if ((current_payload [inner_left] == Fuel_tank)
       or
      (current_payload [inner_right] == Fuel_tank))
  {
    setPayload (inner_left, Empty);
    setPayload (inner_right, Empty);
  }
  else
  {
    setPayload (inner_left, Fuel_tank);
    setPayload (inner_right, Fuel_tank);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var centerDropTankToggleCallback = func
{
  if (current_payload [center] == Fuel_tank)  setPayload (center, Empty);
  else setPayload (center, Fuel_tank);
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var smokeGeneratorsToggleCallback = func
{
  if (current_payload [right_tip] == smoke_generator
      or
      current_payload [left_tip] == smoke_generator)
  {
    setPayload (right_tip, Empty);
    setPayload (left_tip, Empty);
  }
  else
  {
    setPayload (right_tip, smoke_generator);
    setPayload (left_tip, smoke_generator);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var tipSidewindersCallback = func
{
  if (current_payload [right_tip] == AIM_9L
      or
      current_payload [left_tip] == AIM_9L)
  {
    setPayload (right_tip, Empty);
    setPayload (left_tip, Empty);
  }
  else
  {
    setPayload (right_tip, AIM_9L);
    setPayload (left_tip, AIM_9L);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var outerSidewinderCallback = func
{
  if (current_payload [outer_right] == AIM_9L
      or
      current_payload [outer_left] == AIM_9L)
  {
    setPayload (outer_right, Empty);
    setPayload (outer_left, Empty);
  }
  else
  {
    setPayload (outer_right, AIM_9L);
    setPayload (outer_left, AIM_9L);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var innerSidewinderCallback = func
{
  if (current_payload [inner_right] == AIM_9L
      or
      current_payload [inner_left] == AIM_9L)
  {
    setPayload (inner_right, Empty);
    setPayload (inner_left, Empty);
  }
  else
  {
    setPayload (inner_right, AIM_9L);
    setPayload (inner_left, AIM_9L);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var innerSparrowCallback = func
{
  if (current_payload [inner_right] == AIM_7M
      or
      current_payload [inner_left] == AIM_7M)
  {
    setPayload (inner_right, Empty);
    setPayload (inner_left, Empty);
  }
  else
  {
    setPayload (inner_right, AIM_7M);
    setPayload (inner_left, AIM_7M);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var outerSparrowCallback = func
{
  if (current_payload [outer_right] == AIM_7M
      or
      current_payload [outer_left] == AIM_7M)
  {
    setPayload (outer_right, Empty);
    setPayload (outer_left, Empty);
  }
  else
  {
    setPayload (outer_right, AIM_7M);
    setPayload (outer_left, AIM_7M);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var showStoresDialog = func
{
  stores_dialog = canvas.Window.new ([640,480]);
  stores_dialog.setPosition(20,20);
  stores_dialog.setCanvas (stores_dialog_canvas);
  image.setSourceRect(0,0,1024,1024, false);
  grabButton.addEventListener("drag", func(e) stores_dialog.move(e.deltaX, e.deltaY));
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var hideStoresDialog = func
{
  stores_dialog.del();
}

#-------------------------------------------------------------------------------
var initStoresDialog = func
{
   stores_dialog_canvas = canvas.new({"name": "Stores Dialog",
                                      "size": [640, 480],
                                      "view": [640, 480],
                                      "mipmapping": 0 });

   stores_dialog_canvas.setColorBackground (0,0,0,0);
   stores_dialog_canvas.addPlacement({"type": "ref"});
   root_group = stores_dialog_canvas.createGroup ();

  image = root_group.createChild("image")
					.setFile("Aircraft/F-20/Nasal/GUI/face_p.png")
					.setSourceRect(0,0,1024,1024, false)
					.setSize(640,640);
   widgets = root_group.createChild ("group");

   grabButton = root_group.createChild("path")
                     .moveTo(80,10)
                     .horiz(551)
                     .vert(90)
                     .horiz(-551)
                     .close()
                     .setColorFill(0.0,0.0,0.0,0.0)
                     .setColor(0.0,0.0,0.0,0.0);

   closeButton = root_group.createChild("path")
                     .moveTo(3.8,480-130)
                     .horiz(150)
                     .vert(-224)
                     .horiz(-150)
                     .close()
                     .setColorFill(0.0,0.0,0.0,0.0)
                     .setColor(0.0,0.0,0.0,0.0)
                     .addEventListener("click", hideStoresDialog);

   canvas.parsesvg(widgets, "Aircraft/F-20/Nasal/GUI/widgets_p.svg");

   setsize(load_catalog, number_of_stations);
   load_catalog [left_tip] = [{store : smoke_generator,
								  ident: "SmokeL",
                                  callback : smokeGeneratorsToggleCallback},
                                 {store : AIM_9L,
                                  ident : "TipL9",
                                  callback : tipSidewindersCallback}];

   load_catalog [outer_left] = [{store : AIM_7M,
								    ident : "OuterL7",
                                    callback : outerSparrowCallback},
								   {store : AIM_9L,
								    ident : "OuterL9",
                                    callback : outerSidewinderCallback}];

   load_catalog [inner_left] = [{store : Fuel_tank,
                                    ident : "DropL",
                                    callback : wingDropTankToggleCallback},
								   {store : AIM_7M,
								    ident : "InnerL7",
                                    callback : innerSparrowCallback},
								   {store : AIM_9L,
								    ident : "InnerL9",
                                    callback : innerSidewinderCallback}];

   load_catalog [center] = [{store : Fuel_tank,
	                            ident : "CenterTank",
                                callback : centerDropTankToggleCallback}];

   load_catalog [inner_right] = [{store : Fuel_tank,
	                                 ident : "DropR",
                                     callback : wingDropTankToggleCallback},
     							    {store : AIM_7M,
	                                 ident : "InnerR7",
                                     callback : innerSparrowCallback},
								    {store : AIM_9L,
	                                 ident : "InnerR9",
                                     callback : innerSidewinderCallback}];


   load_catalog [outer_right] = [{store : AIM_7M,
								     ident : "OuterR7",
                                     callback : outerSparrowCallback},
								    {store : AIM_9L,
								     ident : "OuterR9",
                                     callback : outerSidewinderCallback}];

   load_catalog [right_tip] = [{store : smoke_generator,
                                ident : "SmokeR",
                                callback : smokeGeneratorsToggleCallback},
							   {store : AIM_9L,
								ident : "TipR9",
                                callback : tipSidewindersCallback}];                                   					  								  								  								 
								 

   forindex (var station; load_catalog)
   {
     forindex (var store; load_catalog [station])
     {
       load_catalog [station][store].widget = 
            widgets.getElementById(load_catalog [station][store].ident);
      load_catalog [station]
	  				  [store]
	  				  .widget
	  				  .addEventListener("click", load_catalog [station]
	  															 [store]
	 														     .callback);
	 }
   }

   executePayloadChange ();
   
   removelistener(storesDialogInitListener);

}


#-------------------------------------------------------------------------------
var storesDialogInitListener = setlistener("/sim/signals/fdm-initialized",
										    initStoresDialog);

