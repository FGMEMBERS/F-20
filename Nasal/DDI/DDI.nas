#Methods ###############################################################

var DDI_resolution = 512;

var DDI = {current_page : nil,
		   root_group : nil,
		   dimmer : nil,
		   brightness : 1.0,
		   brightness_prop : nil,
		   is_on : false,
		   warm_up_timer : 0.0,
		   elec_power : nil};
		   
#-----------------------------------------------------------------------
#Create the DDI and its canvas

DDI.new = func (start_page,
			    object_mapped,
			    brightness_prop,			    
			    electrical_bus)
{

  var created_DDI = {parents:[DDI]};
  var created_canvas = canvas.new({"name": "DDI",
								   "size": [DDI_resolution, DDI_resolution],
								   "view": [DDI_resolution, DDI_resolution],
								   "mipmapping": 1});
  created_canvas.addPlacement({"node": object_mapped});
  created_canvas.setColorBackground(0.0, 0.0, 0.0, 1.00);

  created_DDI.current_page = start_page;
  created_DDI.root_group = created_canvas.createGroup();
  created_DDI.root_group.createChild("image")
					    .setFile(start_page.canvas.getPath())
						.setSize(DDI_resolution,DDI_resolution)
						.setTranslation(0,0);
  created_DDI.root_group.createChild("image")
						.setFile(start_page.bottom_line.canvas.getPath())
						.setSize(DDI_resolution,DDI_resolution)
						.setTranslation(start_page.x_offset,start_page.y_offset);
						
  created_DDI.dimmer = canvas.new({"name": "dimmer", "size": [32,32],
                                  "view": [32,32], "mipmapping": 1})
                             .setColorBackground(0.0, 0.0, 0.0, 0.0); #1 - created_DDI.brightness);
                             
  created_DDI.root_group.createChild("image")
						.setFile(created_DDI.dimmer.getPath())
						.setSize(DDI_resolution,DDI_resolution)
						.setTranslation(0,0);
						
  created_DDI.brightness_prop = brightness_prop;												
												  
  created_DDI.elec_power=GenericLoad.new (electrical_bus,
									     60, #watts
										 115);
  created_DDI.elec_power.switchOn();
  return created_DDI;

}

#-----------------------------------------------------------------------
#push buttons

DDI.pressPB = func (button_number)
{
 if (button_number < 16)
			me.current_page.button_functions[button_number-1](me);
 else
			me.current_page.bottom_line.button_functions[button_number-16](me);
}

#-----------------------------------------------------------------------
#brightness adjust
var brightness_increment = 0.1;

DDI.increaseBrt = func ()
{
  if (me.brightness == 0) me.elec_power.switchOn();
  if (me.brightness < 1.0) me.brightness = me.brightness + brightness_increment;
  if (me.brightness > 1.0) me.brightness = 1.0;
  setprop (me.brightness_prop, me.brightness);
  if (me.warm_up_timer == 0)
  {	
	me.dimmer.setColorBackground(0.0, 0.0, 0.0, 1 - me.brightness);
  }
}

DDI.decreaseBrt = func ()
{

  if (me.brightness > 0.0) me.brightness = me.brightness - brightness_increment;
  if (me.brightness <= 0.0) 
   {
     me.brightness = 0.0;
     me.elec_power.switchOff();
   }
  setprop (me.brightness_prop, me.brightness);
  if (me.warm_up_timer == 0)
  {	
	me.dimmer.setColorBackground(0.0, 0.0, 0.0, 1 - me.brightness);	
  }
}

#-----------------------------------------------------------------------
#change the page

DDI.changePage = func (new_page)
{
	 me.current_page = new_page;
	 me.root_group.removeAllChildren();
	 me.root_group.createChild("image")
				  .setFile(new_page.canvas.getPath())
				  .setSize(DDI_resolution,DDI_resolution)
				  .setTranslation(new_page.x_offset,new_page.y_offset);
	 me.root_group.createChild("image")
				  .setFile(new_page.bottom_line.canvas.getPath())
				  .setSize(DDI_resolution,DDI_resolution)
				  .setTranslation(0,0);
	 me.root_group.createChild("image")
				  .setFile(me.dimmer.getPath())
				  .setSize(DDI_resolution,DDI_resolution)
				  .setTranslation(0,0);			  
	 updatePageDisplayList ();
}

#-----------------------------------------------------------------------
var DDI_warm_up_time = 5.0; #seconds

DDI.checkPower = func (delta_t)
{   
   if (!me.elec_power.running)
    {
      me.is_on = false;
      me.root_group.removeAllChildren();
      me.warm_up_timer = 0.0;
    }
   else if (!me.is_on) 
    {
      me.is_on = true;      
      me.warm_up_timer = 5.0;
      me.changePage (IDX);
    }
    
    if (me.warm_up_timer > 0.0)
    {
      me.warm_up_timer = me.warm_up_timer - delta_t;
      me.dimmer.setColorBackground(0.0, 0.0, 0.0, 1 - (me.brightness 
													   * (1-me.warm_up_timer
															/ DDI_warm_up_time)));
      if (me.warm_up_timer <= 0.0)
      {
        me.warm_up_timer = 0.0;
        me.changePage (IDX);
      }
    }
}

