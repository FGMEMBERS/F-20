#graphical payload editor

var stores_dialog = {};
var stores_dialog_canvas = {};
var DropR = {};
var CenterTank = {};
var SmokeR = {};
var SmokeL = {};
var DropL = {};
var grabButton = {};             

var root_group = {};
var image = {};
var widgets = {};


#-------------------------------------------------------------------------------
var wingDropTankToggleCallback = func
{
  if (wing_pylons_present_prop.getValue()) 
  {
    removeWingPylons();
    removeWingTanks();  
    DropR.setColorFill(0.6,0.6,0.6,1.0);
    DropL.setColorFill(0.6,0.6,0.6,1.0);  
  }
  else
  {
    placeWingPylons();
    placeWingTanks();
    DropR.setColorFill(0,0.5,0,1.0);
    DropL.setColorFill(0,0.5,0,1.0);
  }
}

#-------------------------------------------------------------------------------
var centerDropTankToggleCallback = func
{
  if (center_pylon_present_prop.getValue()) 
  {
    removeCenterPylon();
    removeCenterTank();    
    CenterTank.setColorFill (0.6,0.6,0.6,1.0);
    
  }
  else
  {
    placeCenterPylon();
    placeCenterTank();  
    CenterTank.setColorFill(0,0.5,0,1.0);
  }
}

#-------------------------------------------------------------------------------
var smokeGeneratorsToggleCallback = func
{
  if (smoke_generators_present_prop.getValue()) 
  {
    removeSmokeGenerators();  
    SmokeL.setColorFill(0.6,0.6,0.6,1.0);
    SmokeR.setColorFill(0.6,0.6,0.6,1.0);  
  }
  else
  {
    placeSmokeGenerators();
    SmokeL.setColorFill(0,0.5,0,1.0);
    SmokeR.setColorFill(0,0.5,0,1.0);
  }
}

#-------------------------------------------------------------------------------
var showStoresDialog = func
{
  stores_dialog = canvas.Window.new ([640,480]);
  stores_dialog.setPosition(20,20);
  stores_dialog.setCanvas (stores_dialog_canvas);
  image.setSourceRect(0,0,1024,1024, false);  
  grabButton.addEventListener("drag", func(e) stores_dialog.move(e.deltaX, e.deltaY));
}             
    
#-------------------------------------------------------------------------------             
var hideStoresDialog = func
{
  stores_dialog.del();
}      

  	var title_bar = {};
    var x = 0;
	var y = 0;
	var rx = 8;
	var ry = 8;
	var w = 640;
	var h = 20;
	
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
                 
   SmokeLButton = root_group.createChild("path")
                     .moveTo(579.453,220)
                     .horiz(10)
                     .vert(10)
                     .horiz(-10)
                     .close()
                     .setColorFill(0.0,0.0,0.0,0.0)
                     .setColor(0.0,0.0,0.0,0.0)
                     .addEventListener("click", smokeGeneratorsToggleCallback);
                     
   SmokeRButton = root_group.createChild("path")
                     .moveTo(297,220)
                     .horiz(10)
                     .vert(10)
                     .horiz(-10)
                     .close()
                     .setColorFill(0.0,0.0,0.0,0.0)                     
                     .setColor(0.0,0.0,0.0,0.0)
                     .addEventListener("click", smokeGeneratorsToggleCallback);    
                     
   DropLButton = root_group.createChild("path")
                     .moveTo(516,205)
                     .horiz(17)
                     .vert(-17)
                     .horiz(-17)
                     .close()
                     .setColorFill(0.0,0.0,0.0,0.0)                     
                     .setColor(0.0,0.0,0.0,0.0)
                     .addEventListener("click", wingDropTankToggleCallback); 
                     
   DropRButton = root_group.createChild("path")
                     .moveTo(348,205)
                     .horiz(17)
                     .vert(-17)
                     .horiz(-17)
                     .close()
                     .setColorFill(0.0,0.0,0.0,0.0)                     
                     .setColor(0.0,0.0,0.0,0.0)
                     .addEventListener("click", wingDropTankToggleCallback);        
                                                                         
   DropCenterButton = root_group.createChild("path")
                     .moveTo(431,205)
                     .horiz(17)
                     .vert(-17)
                     .horiz(-17)
                     .close()
                     .setColorFill(0.0,0.0,0.0,0.0)                     
                     .setColor(0.0,0.0,0.0,0.0)
                     .addEventListener("click", centerDropTankToggleCallback);         

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
   DropR = widgets.getElementById("DropR");
   CenterTank = widgets.getElementById("CenterTank");
   SmokeL = widgets.getElementById("SmokeL");
   SmokeR = widgets.getElementById("SmokeR");
   DropL = widgets.getElementById("DropL");
   
   removeCenterPylon();
   removeCenterTank();  
   removeWingPylons();   
   removeWingTanks();
   drag_index_prop.setValue (0.0);
   
   removelistener(storesDialogInitListener);               

}

#-------------------------------------------------------------------------------
var storesDialogInitListener = setlistener("/sim/signals/fdm-initialized", 
										    initStoresDialog);

