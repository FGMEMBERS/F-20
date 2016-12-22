################################################################################
# A textured button class

var TexturedButton = {callback : nil,
                      over_image : nil,
                      deact_image : nil,
                      pressed_image : nil,
                      released_image : nil,
                      x_pos : 0.0,
                      y_pos : 0.0,
                      width : 0.0,
                      height : 0.0,
                      is_enabled : true};

#-------------------------------------------------------------------------------
TexturedButton.new = func (parent,
                           callback,
                           pressed_filename,
                           over_filename,
                           deact_filename,
                           released_filename,
                           x_pos,
                           y_pos,
                           width,
                           height)
{

   var created_object = {parents : [TexturedButton]};
   created_object.callback = callback;
   created_object.x_pos = x_pos;
   created_object.y_pos = y_pos;

   created_object.over_image = parent.createChild("image")
							         .setFile(over_filename)                     
									 .setSourceRect(0,0,width,height, false)
									 .setSize(256,256)
									 .setTranslation (x_pos, y_pos)
									 .hide();
									 
   created_object.pressed_image = parent.createChild("image")
							            .setFile(pressed_filename)                     
									    .setSourceRect(0,0,width,height, false)
									    .setSize(256,256)
									    .setTranslation (x_pos, y_pos)
									    .hide();		
									    
   created_object.released_image = parent.createChild("image")
							            .setFile(released_filename)                     
									    .setSourceRect(0,0,width,height, false)
									    .setSize(256,256)
									    .setTranslation (x_pos, y_pos)
									    .show();	
									    
   created_object.deact_image = parent.createChild("image")
							             .setFile(deact_filename)                     
									     .setSourceRect(0,0,width,height, false)
									     .setSize(256,256)
									     .setTranslation (x_pos, y_pos)
									     .hide();										    

   created_object.released_image.addEventListener("mousedown",
											 func {created_object.clic()});
   created_object.pressed_image.addEventListener("mouseup",
											      func {created_object.release()});
   created_object.over_image.addEventListener("mouseleave",
											 func {created_object.overflyOut()});
   created_object.released_image.addEventListener("mouseenter",
											  func {created_object.overflyIn()});


   return created_object;
}

#-------------------------------------------------------------------------------
TexturedButton.overflyIn = func
{
  if (me.is_enabled)
  {
    me.over_image.show();
    me.deact_image.hide();
    me.pressed_image.hide();
    me.released_image.hide();
  }
}

#-------------------------------------------------------------------------------
TexturedButton.overflyOut = func
{
  if (me.is_enabled)
  {
    me.over_image.hide();
    me.deact_image.hide();
    me.pressed_image.hide();
    me.released_image.show();
  }
}

#-------------------------------------------------------------------------------
TexturedButton.clic = func
{
  if (me.is_enabled)
  {
    me.over_image.hide();
    me.deact_image.hide();
    me.pressed_image.show();
    me.released_image.hide();
  }
}

#-------------------------------------------------------------------------------
TexturedButton.release = func
{
  if (me.is_enabled)
  {
    me.over_image.hide();
    me.deact_image.hide();
    me.pressed_image.hide();
    me.released_image.show();
    me.callback();
  }
}

#-------------------------------------------------------------------------------
TexturedButton.hide = func
{
    me.over_image.hide();
    me.deact_image.hide();
    me.pressed_image.hide();
    me.released_image.hide();
}

#-------------------------------------------------------------------------------
TexturedButton.show = func
{
    me.over_image.show();
    me.deact_image.show();
    me.pressed_image.show();
    me.released_image.show();
}

#-------------------------------------------------------------------------------
TexturedButton.disable = func
{
    me.over_image.hide();
    me.deact_image.show();
    me.pressed_image.hide();
    me.released_image.hide();
    me.is_enabled = false;
}

#-------------------------------------------------------------------------------
TexturedButton.enable = func
{
    me.over_image.hide();
    me.deact_image.hide();
    me.pressed_image.hide();
    me.released_image.show();
    me.is_enabled = true;
}

