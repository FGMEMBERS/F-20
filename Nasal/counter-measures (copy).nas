#F-20 expandable counter measures (chaff and flare)

var chaff_selection_prop = "/f-20/CM/chaff-selection";
var flare_selection_prop = "/f-20/CM/flare-selection";
var flare_release_x_prop = "/f-20/CM/flare-release-x";
var flare_release_y_prop = "/f-20/CM/flare-release-y";
var flare_releasing_prop = "/f-20/CM/flare-releasing";
var chaff_release_x_prop = "/f-20/CM/chaff-release-x";
var chaff_release_y_prop = "/f-20/CM/chaff-release-y";
var chaff_releasing_prop = "/f-20/CM/chaff-releasing";
var number_of_dispensers_prop = "/f-20/CM/number-of-dispensers";
var button_depressed_prop = "/f-20/CM/button-depressed";
var number_of_dispensers = getprop (number_of_dispensers_prop);

#Setup of the textures for the dispensers


#Dispenser 1 -----------------------------------------------------
var CM_launcher_1_canvas = canvas.new({
                                "name": "dispenser 1",
                                "size": [64,64], 
                                "view": [64,64],                       
                                "mipmapping": 1     
                                });                                
CM_launcher_1_group = CM_launcher_1_canvas.createGroup ();       
CM_launcher_1_image = CM_launcher_1_group.createChild("image")
                                         .setFile("Aircraft/F-20/Models/ALE-40.png")                     
                                         .setSourceRect(0,0,64,64, false)
                                         .setSize(64,64);
CM_launcher_1_canvas.addPlacement({"node": "CM_dispenser_1"});                          

#Dispenser 2 -----------------------------------------------------
var CM_launcher_2_canvas = canvas.new({
                                "name": "dispenser 2",
                                "size": [64,64], 
                                "view": [64,64],                       
                                "mipmapping": 1     
                                });     
CM_launcher_2_group = CM_launcher_2_canvas.createGroup ();       
CM_launcher_2_image = CM_launcher_2_group.createChild("image")
                                         .setFile("Aircraft/F-20/Models/ALE-40.png")                     
                                         .setSourceRect(0,0,64,64, false)
                                         .setSize(64,64);                                    
CM_launcher_2_canvas.addPlacement({"node": "CM_dispenser_2"});                                  

if (number_of_dispensers > 2)
{
#Dispenser 3 -----------------------------------------------------
var CM_launcher_3_canvas = canvas.new({
                                "name": "dispenser 3",
                                "size": [64,64], 
                                "view": [64,64],                       
                                "mipmapping": 1     
                                });  
CM_launcher_3_group = CM_launcher_3_canvas.createGroup ();       
CM_launcher_3_image = CM_launcher_3_group.createChild("image")
                                         .setFile("Aircraft/F-20/Models/ALE-40.png")                     
                                         .setSourceRect(0,0,64,64, false)
                                         .setSize(64,64);  
CM_launcher_3_canvas.addPlacement({"node": "CM_dispenser_3"});                                     

#Dispenser 4 -----------------------------------------------------
var CM_launcher_4_canvas = canvas.new({
                                "name": "dispenser 4",
                                "size": [64,64], 
                                "view": [64,64],                       
                                "mipmapping": 1     
                                });       
CM_launcher_4_group = CM_launcher_4_canvas.createGroup ();       
CM_launcher_4_image = CM_launcher_4_group.createChild("image")
                                         .setFile("Aircraft/F-20/Models/ALE-40.png")                     
                                         .setSourceRect(0,0,64,64, false)
                                         .setSize(64,64);  
CM_launcher_4_canvas.addPlacement({"node": "CM_dispenser_4"});
}

#now create the "holes"in the dispensers
var i = 0;
var j = 0;
var x_hole = 0;
var y_hole = 0;
var row_number = 0;
var column_number = 0;
var CM_launcher_holes = setsize([], 4);
for (j=0;j<4;j=j+1) CM_launcher_holes[j] = setsize([], 30);

for (i = 0; i<30; i=i+1)
{
  row_number = int(i/5);
  column_number = i - row_number * 5;
  x_hole = 2 + column_number * 10;
  y_hole = 6 + row_number * 9;
  
  CM_launcher_holes[0][i] = CM_launcher_1_group.createChild("path")
                                              .moveTo(x_hole,y_hole)
                                              .horiz(8)
                                              .vert(7)
                                              .horiz(-8)
                                              .close()
                                              .setColorFill(0.0,0.0,0.0,1.0)
                                              .hide();
  CM_launcher_holes[1][i] = CM_launcher_2_group.createChild("path")
                                              .moveTo(x_hole,y_hole)
                                              .horiz(8)
                                              .vert(7)
                                              .horiz(-8)
                                              .close()
                                              .setColorFill(0.0,0.0,0.0,1.0)
                                              .hide();
 if (number_of_dispensers >2)
 {                                              
 CM_launcher_holes[2][i] = CM_launcher_3_group.createChild("path")
                                              .moveTo(x_hole,y_hole)
                                              .horiz(8)
                                              .vert(7)
                                              .horiz(-8)
                                              .close()
                                              .setColorFill(0.0,0.0,0.0,1.0)
                                              .hide();
  CM_launcher_holes[3][i] = CM_launcher_4_group.createChild("path")
                                              .moveTo(x_hole,y_hole)
                                              .horiz(8)
                                              .vert(7)
                                              .horiz(-8)
                                              .close()
                                              .setColorFill(0.0,0.0,0.0,1.0)
                                              .hide();
 }
}     

# Counters ----------------------------------------------------------
var chaff_counter_canvas = canvas.new({
                                "name": "chaff counter",
                                "size": [64,64], 
                                "view": [64,64],                       
                                "mipmapping": 1     
                                });   
chaff_counter_canvas.addPlacement({"node": "ChaffCounter"});
chaff_group = chaff_counter_canvas.createGroup ();  
chaff_counter = chaff_group.createChild("text")                     
                           .setColor(1.0,1.0,1.0,1.0)
                           .setTranslation(0,16)
                           .setAlignment("left-top")
                           .setFont("condensed.txf")
                           .setFontSize(32, 1.0)
                           .setText ("120")
                           .show();
                          
var flare_counter_canvas = canvas.new({
                                "name": "flare counter",
                                "size": [64,64], 
                                "view": [64,64],                       
                                "mipmapping": 1     
                                });        
flare_counter_canvas.addPlacement({"node": "FlareCounter"});   
flare_group = flare_counter_canvas.createGroup ();  
flare_counter = flare_group.createChild("text")                     
                           .setColor(1.0,1.0,1.0,1.0)
                           .setTranslation(0,16)
                           .setAlignment("left-top")
                           .setFont("condensed.txf")
                           .setFontSize(32, 1.0)
                           .setText ("120")
                           .show();                              

#Reload and select the mix of Chaff/Flare
var all_flares = 1;
var chaff_flare = 2;
var dispenser_count = [0,0,0,0];
var loaded_with_chaff = 0;
var loaded_with_flares = 1;
var dispensers_contents = [loaded_with_flares, loaded_with_flares,
                           loaded_with_flares, loaded_with_flares];

#--------------------------------------
var updateFlaresCounter = func()
{
  var number_of_flares = 0;
  var i = 0;
  for (i = 0; i < 4; i=i+1)
  {
    if (dispensers_contents [i] == loaded_with_flares)
      number_of_flares = number_of_flares + dispenser_count [i];
  } 
  if (number_of_flares > 100)
    flare_counter.setText(number_of_flares);
  else if (number_of_flares > 10)
    flare_counter.setText(sprintf ("0%i",number_of_flares));
  else 
    flare_counter.setText(sprintf ("00%i",number_of_flares));
}

#--------------------------------------
var updateChaffCounter = func ()
{
  var number_of_chaff = 0;
  var i = 0;
  for (i = 0; i < 4; i=i+1)
  {
    if (dispensers_contents [i] == loaded_with_chaff)
      number_of_chaff = number_of_chaff + dispenser_count [i];
  } 
  if (number_of_chaff > 100)
    chaff_counter.setText(number_of_chaff);
  else if (number_of_chaff > 10)
    chaff_counter.setText(sprintf ("0%i",number_of_chaff));
  else 
    chaff_counter.setText(sprintf ("00%i",number_of_chaff));
}

var reloadCounterMeasures = func (reload_type)
{
    var i = 0;
    var j = 0;

    if (reload_type == all_flares)
      {
        for (i=0; i<number_of_dispensers; i=i+1)
        {
         dispensers_contents [i] =  loaded_with_flares;
         dispenser_count [i] = 30;
        }
      }
    else if (reload_type == chaff_flare)
     {
        for (i=0; i<(number_of_dispensers/2); i=i+1)
        {            
            dispensers_contents [2*i] =  loaded_with_flares;
            dispenser_count [2*i] = 30;
            dispensers_contents [2*i+1] =  loaded_with_chaff;
            dispenser_count [2*i+1] = 30;
        }
     }
     for (i = 0; i<number_of_dispensers; i=i+1)
     {
       for (j = 0; j < 30; j = j+1) CM_launcher_holes[i][j].hide();
     }
     updateFlaresCounter();
     updateChaffCounter();
}

#TODO : replace with selection from the loadout menu
reloadCounterMeasures (all_flares);
#---------------------------------------------------

#Program selection rotary switches
var sel_is_off = 0;
var sel_is_single = 1;
var sel_is_program = 2;
var sel_is_multiple = 3;

var chaff_selection = sel_is_off;
var flare_selection = sel_is_off;

var incrementChaffSelector = func ()
{

  chaff_selection = chaff_selection + 1;
  if (chaff_selection > sel_is_multiple) chaff_selection = sel_is_multiple;
  setprop (chaff_selection_prop, chaff_selection);
}

var incrementFlareSelector = func ()
{

  flare_selection = flare_selection + 1;
  if (flare_selection > sel_is_program) flare_selection = sel_is_program;
  setprop (flare_selection_prop, flare_selection);
}

var decrementChaffSelector = func ()
{

  chaff_selection = chaff_selection - 1;
  if (chaff_selection < sel_is_off) chaff_selection = sel_is_off;
  setprop (chaff_selection_prop, chaff_selection);
}

var decrementFlareSelector = func ()
{

  flare_selection = flare_selection - 1;
  if (flare_selection < sel_is_off) flare_selection = sel_is_off;
   setprop (flare_selection_prop, flare_selection);
}

#release
var cmd_button_depressed = 0;

#--------------------------------------
var repeatFlareDecrease = func (number_to_release)
{
  var callback = func () {flareDecrease(number_to_release)};
  settimer (callback, 0.3);
}

var flareDecrease = func (number_to_release)
{
  var flare_released = false;
  var i = 0;

   for (i=0; i<number_of_dispensers; i=i+1)
   {
      if ((dispenser_count [i] > 0) and (flare_released == false))
      {                
        dispenser_count [i] = dispenser_count [i] - 1;
        CM_launcher_holes[i][dispenser_count [i]].show();
        flare_released = true;
        updateFlaresCounter();
      }      
    }    
  if ((number_to_release != 1) and flare_released)
                        repeatFlareDecrease (number_to_release - 1);
}


#--------------------------------------
var stopFlares = func ()
{
  setprop(flare_releasing_prop, 0);
}

#--------------------------------------
var releaseFlares = func ()
{
  if (getprop (flare_releasing_prop) != 1)
  {
      
      if (flare_selection == sel_is_single)
      {
        setprop(flare_releasing_prop, 1); 
        settimer (stopFlares, 0.29);
        flareDecrease (1);
      }
      else if (flare_selection == sel_is_program)
      {   
        setprop(flare_releasing_prop, 1); 
        settimer (stopFlares, 1.0);
        flareDecrease (3);
      }
  }
}

#--------------------------------------
var repeatChaffDecrease = func (number_to_release)
{
  var callback = func () {chaffDecrease(number_to_release)};
  settimer (chaffDecrease(number_to_release), 0.3);
}

var chaffDecrease = func (number_to_release)
{
  var chaff_released = false;
  var i = 0;

   for (i=0;i<number_of_dispensers;i=i+1)
   {
      if ((dispenser_count [i] > 0) and (chaff_released == false))
      {                   
        dispenser_count [i] = dispenser_count [i] - 1;
        CM_launcher_holes[i][dispenser_count [i]].show();
        chaff_released = true;
        updateFlaresCounter();
      }      
    }    
  
  if ((number_to_release != 1) and chaff_released)
                        repeatChaffDecrease (number_to_release - 1);
}
  
#--------------------------------------  
var stopChaff = func ()
{  
  setprop(chaff_releasing_prop, 0); 
}

#--------------------------------------
var releaseChaff = func ()
{
  if (getprop (chaff_releasing_prop) != 1)
  {      
      if (chaff_selection == sel_is_single)
      {
        setprop(chaff_releasing_prop, 1); 
        settimer (stopChaff, 0.15);
        chaffDecrease (1);
      }
      else if (chaff_selection == sel_is_program)
      {
        setprop(chaff_releasing_prop, 1); 
        settimer (stopChaff, 0.8);
        chaffDecrease(3);
      }
    }
}  

#--------------------------------------
var CounterMeasuresButtonPress = func ()
{  
   cmd_button_depressed = 1;
   setprop (button_depressed_prop, 1);
   releaseFlares();
   releaseChaff();
}

#--------------------------------------
var CounterMeasuresButtonRelease = func ()
{  
  setprop (button_depressed_prop, 0);
  if (getprop(chaff_releasing_prop) == 1) 
                 setprop(chaff_releasing_prop,0);

}
