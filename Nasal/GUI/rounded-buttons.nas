################################################################################
# A rounded button class
var char_width = 6.5;
var button_height = 10;
var button_font = "helvetica_medium.txf";
var font_size = 12;

var RoundedButton = {text : nil,
                      callback : nil,
                      group : nil,
                      parent : nil,
                      rectangle : nil,
                      sensitive_zone : nil,
                      label : nil,
                      x_pos : 0.0,
                      text_width : 0.0,                      
                      y_pos : 0.0,
                      is_enabled : true};

#-------------------------------------------------------------------------------
RoundedButton.new = func (parent,
                           text,
                           callback,
                           x_pos,
                           y_pos)
{
   var length = size(text);
   

   var created_object = {parents : [RoundedButton]};
   created_object.text_width = length * char_width;
   created_object.callback = callback;
   created_object.x_pos = x_pos;
   created_object.y_pos = y_pos;
   created_object.group = parent.createChild("group");
  created_object.rectangle = created_object.group.createChild("path")
									.moveTo(0,5)
									.vert(button_height)
									.arcSmallCCW(5,5,0,5,5)
									.horiz(created_object.text_width)
									.arcSmallCCW(5,5,0,5,-5)									
									.vert(-button_height)
									.arcSmallCCW(5,5,0,-5,-5)
									.horiz(-created_object.text_width)
									.arcSmallCCW(5,5,0,-5,5)	
									.setStrokeLineWidth (1.5)
									.setColor(0.15,0.15,0.15,0.5)
									.show();
									
   created_object.label = created_object.group.createChild("text")
											  .setText (text)
											  .setFont(button_font)
											  .setFontSize(font_size, 1.0)
											  .setAlignment ("center-center")
											  .setTranslation ((created_object.text_width+10)/2,button_height/2+5)
											  .setColor(0.0, 0.0, 0.0)
											  .show();									
									
   created_object.sensitive_zone = created_object.group.createChild("path")
									.moveTo(0,0)
									.vert(button_height+10)
									.horiz(created_object.text_width+10)								
									.vert(-button_height-10)
									.horiz(-created_object.text_width)
									.close ()
									.show();								

   created_object.sensitive_zone.addEventListener("mousedown",
											 func {created_object.clic()});
   created_object.sensitive_zone.addEventListener("mouseup",
											  func {created_object.release()});
   created_object.sensitive_zone.addEventListener("mouseleave",
											 func {created_object.overflyOut()});
   created_object.sensitive_zone.addEventListener("mouseenter",
											 func {created_object.overflyIn()});

   created_object.group.setTranslation (x_pos-created_object.text_width/2-5, y_pos-(button_height/2+5)).show();

   return created_object;
}

#-------------------------------------------------------------------------------
RoundedButton.overflyIn = func
{
  if (me.is_enabled)
  {
	  me.rectangle.setColorFill (0.2,0.5,1.0);
	  me.label.setColor (1.0,1.0,1.0);
  }
}

#-------------------------------------------------------------------------------
RoundedButton.overflyOut = func
{
  if (me.is_enabled)
  {
	  me.rectangle.setColorFill (1.0,1.0,1.0,1.0);
	  me.label.setColor (0.0,0.0,0.0);
  }
}

#-------------------------------------------------------------------------------
RoundedButton.clic = func
{
  if (me.is_enabled)
  {
	  me.rectangle.setColorFill (0.0,0.0,1.0);
	  me.label.setColor (1.0,1.0,1.0);
  }
}

#-------------------------------------------------------------------------------
RoundedButton.release = func
{
  if (me.is_enabled)
  {
	  me.rectangle.setColorFill (1.0,1.0,1.0,1.0);
	  me.label.setColor (0.0,0.0,0.0);
	  me.callback();
  }
}

#-------------------------------------------------------------------------------
RoundedButton.hide = func
{
   me.rectangle.hide();
   me.label.hide();
}

#-------------------------------------------------------------------------------
RoundedButton.show = func
{
   me.rectangle.show();
   me.label.show();
}

#-------------------------------------------------------------------------------
RoundedButton.disable = func
{
  me.label.setColor (0.75,0.75,0.75);
  me.is_enabled = false;
}

#-------------------------------------------------------------------------------
RoundedButton.enable = func
{
   me.label.setColor (0.0,0.0,0.0);
   me.is_enabled = true;
}

#-------------------------------------------------------------------------------
RoundedButton.setText = func (new_text)
{
   var length = size(new_text);
   
  me.group.removeAllChildren();
  me.text_width = length * char_width;
  me.rectangle = me.group.createChild("path")
									.moveTo(0,5)
									.vert(button_height)
									.arcSmallCCW(5,5,0,5,5)
									.horiz(me.text_width)
									.arcSmallCCW(5,5,0,5,-5)									
									.vert(-button_height)
									.arcSmallCCW(5,5,0,-5,-5)
									.horiz(-me.text_width)
									.arcSmallCCW(5,5,0,-5,5)	
									.setStrokeLineWidth (1.5)
									.setColor(0.15,0.15,0.15,0.5)
									.show();
									
   me.label = me.group.createChild("text")
					   .setText (new_text)
					   .setFont(button_font)
					   .setFontSize(font_size, 1.0)					   
					   .setAlignment ("center-center")
					   .setTranslation ((me.text_width+10)/2,button_height/2+5)
					   .setColor(0.0, 0.0, 0.0)
					   .show();									
									
   me.sensitive_zone = me.group.createChild("path")
									.moveTo(0,0)
									.vert(button_height+10)
									.horiz(me.text_width+10)								
									.vert(-button_height-10)
									.horiz(-me.text_width)
									.close ()
									.show();								

   me.sensitive_zone.addEventListener("mousedown",
											 func {me.clic()});
   me.sensitive_zone.addEventListener("mouseup",
											  func {me.release()});
   me.sensitive_zone.addEventListener("mouseleave",
											 func {me.overflyOut()});
   me.sensitive_zone.addEventListener("mouseenter",
											 func {me.overflyIn()});							
						
   me.group.setTranslation(me.x_pos-me.text_width/2-5, me.y_pos-(button_height/2+5)).show();
}
