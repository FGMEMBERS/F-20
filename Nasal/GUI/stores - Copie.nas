#graphical payload editor

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

var load_indicators = [];

var void_load = { setColorFill : func(){} };

var available_loads = [];

#-------------------------------------------------------------------------------
# Brute force and ignorance

var updateStationsDisplay = func
{

  var station = 0;
  var load = 0;
  
  forindex (station; available_loads)
  {
    forindex (load; available_loads[station])
    {
     if (current_payload[station] == available_loads[station][load])
       load_indicators[station][load].setColorFill(green);
     else
      load_indicators[station][load].setColorFill(grey); 
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
var innerAmraamCallback = func
{
  if (current_payload [inner_right] == AIM_120A
      or
      current_payload [inner_left] == AIM_120A)
  {
    setPayload (inner_right, Empty);
    setPayload (inner_left, Empty);
  }
  else
  {
    setPayload (inner_right, AIM_120A);
    setPayload (inner_left, AIM_120A);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var outerAmraamCallback = func
{
  if (current_payload [outer_right] == AIM_120A
      or
      current_payload [outer_left] == AIM_120A)
  {
    setPayload (outer_right, Empty);
    setPayload (outer_left, Empty);
  }
  else
  {
    setPayload (outer_right, AIM_120A);
    setPayload (outer_left, AIM_120A);
  }
  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var centerAlq131Callback = func
{
  if (current_payload [center] == ALQ_131) setPayload (center, Empty);
  else 
   { 
    setPayload (center, ALQ_131);
    if (sniper_and_alq_mounted)
      {
       setPayload (outer_right, Empty);
       setPayload (outer_left, Empty);
       sniper_and_alq_mounted = false;
      }
   }

  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var centerSniperCallback = func
{
  if (current_payload [center] == Sniper_pod) setPayload (center, Empty);
  else 
  {
   setPayload (center, Sniper_pod);
   if (sniper_and_alq_mounted)
      {
       setPayload (outer_right, Empty);
       setPayload (outer_left, Empty);
       sniper_and_alq_mounted = false;
      }
  }

  executePayloadChange();
  updateStationsDisplay();
}

#-------------------------------------------------------------------------------
var sniperAndAlqCallback = func
{
  if (current_payload [outer_right] == ALQ_131
      or
      current_payload [outer_left] == Sniper_pod)
  {
    setPayload (outer_right, Empty);
    setPayload (outer_left, Empty);
    sniper_and_alq_mounted = false;
  }
  else
  {
    setPayload (outer_right, ALQ_131);
    setPayload (outer_left, Sniper_pod);
    sniper_and_alq_mounted = true;
    if (current_payload [center] == ALQ_131) setPayload (center, Empty);
    if (current_payload [center] == Sniper_pod) setPayload (center, Empty);
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
					.setFile("Aircraft/F-20/Nasal/GUI/face.png")
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

   canvas.parsesvg(widgets, "Aircraft/F-20/Nasal/GUI/widgets.svg");
   
   setsize(load_indicators, number_of_stations);
   load_indicators [left_tip] = [widgets.getElementById("SmokeL"),
								 widgets.getElementById("TipL9")];
   load_indicators [left_tip][0].addEventListener("click", smokeGeneratorsToggleCallback);
   load_indicators [left_tip][1].addEventListener("click", tipSidewindersCallback);
   
   load_indicators [outer_left] = [widgets.getElementById("SniperL"),
								   widgets.getElementById("OuterL120"),
								   widgets.getElementById("OuterL9")];
   load_indicators [outer_left][0].addEventListener("click", sniperAndAlqCallback);								          
   load_indicators [outer_left][1].addEventListener("click", outerAmraamCallback);
   load_indicators [outer_left][2].addEventListener("click", outerSidewinderCallback);

   load_indicators [inner_left] = [widgets.getElementById("DropL"),
								   widgets.getElementById("InnerL120"),
								   widgets.getElementById("InnerL9")];
   load_indicators [inner_left][0].addEventListener("click", wingDropTankToggleCallback);
   load_indicators [inner_left][1].addEventListener("click", innerAmraamCallback);
   load_indicators [inner_left][2].addEventListener("click", innerSidewinderCallback);								          

   load_indicators [center] = [widgets.getElementById("CenterTank"),
							   widgets.getElementById("SniperC"),
							   widgets.getElementById("AlqC")];
   load_indicators [center][0].addEventListener("click", centerDropTankToggleCallback);
   load_indicators [center][1].addEventListener("click", centerSniperCallback);
   load_indicators [center][2].addEventListener("click", centerAlq131Callback);							          

   load_indicators [inner_right] = [widgets.getElementById("DropR"),
     							    widgets.getElementById("InnerR120"),
								    widgets.getElementById("InnerR9")];
   load_indicators [inner_right][0].addEventListener("click", wingDropTankToggleCallback);
   load_indicators [inner_right][1].addEventListener("click", innerAmraamCallback);
   load_indicators [inner_right][2].addEventListener("click", innerSidewinderCallback);								           

   load_indicators [outer_right] = [widgets.getElementById("AlqR"),
								    widgets.getElementById("OuterR120"),
								    widgets.getElementById("OuterR9")];
   load_indicators [outer_right][0].addEventListener("click", sniperAndAlqCallback);
   load_indicators [outer_right][1].addEventListener("click", outerAmraamCallback);
   load_indicators [outer_right][2].addEventListener("click", outerSidewinderCallback);										   

   load_indicators [right_tip] = [widgets.getElementById("SmokeR"),								 
								  widgets.getElementById("TipR9")];
   load_indicators [right_tip][0].addEventListener("click", smokeGeneratorsToggleCallback);
   load_indicators [right_tip][1].addEventListener("click", tipSidewindersCallback);							     

   setsize(available_loads, number_of_stations);
   available_loads [left_tip] = [smoke_generator, AIM_9L];
   available_loads [outer_left] = [Sniper_pod, AIM_120A, AIM_9L];
   available_loads [inner_left] = [Fuel_tank, AIM_120A, AIM_9L];
   available_loads [center] = [Fuel_tank, Sniper_pod, ALQ_131];
   available_loads [inner_right] = [Fuel_tank, AIM_120A, AIM_9L];
   available_loads [outer_right] = [ALQ_131, AIM_120A, AIM_9L];
   available_loads [right_tip] = [smoke_generator, AIM_9L];

   executePayloadChange ();
   removelistener(storesDialogInitListener);

}


#-------------------------------------------------------------------------------
var storesDialogInitListener = setlistener("/sim/signals/fdm-initialized",
										    initStoresDialog);

