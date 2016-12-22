#DDI pages

var DDIpage = {canvas : nil,
		        displayed : false,
		        bottom_line : nil,
		        x_offset : 0,
		        y_offset : 0,		        
		        button_functions : nil};
		       
var DDI_number_of_keys = 20;

var uselessKey = func (display)
{

}    

#-----------------------------------------------------------------------
#Create the a DDI page and attach its canvas
DDIpage.new = func (bottom_line)
{
  var created_page = {parents:[DDIpage]};
  created_page.button_functions = [];
  created_page.bottom_line = bottom_line;
  setsize (created_page.button_functions, DDI_number_of_keys);
  return created_page;
}

#-----------------------------------------------------------------------
#Attach a canvs to a DDI page
DDIpage.attachCanvas = func (attached_canvas)
{
  me.canvas = attached_canvas;
}

#precreate all pages

var IDX = DDIpage.new (permanent_line);
var HSI = DDIpage.new (permanent_line);
var INS_data = DDIpage.new (permanent_line);
var INS_align = DDIpage.new (permanent_line);
var IFF = DDIpage.new (permanent_line);
var COM = DDIpage.new (permanent_line);
var WPT = DDIpage.new (permanent_line);

########################################################################
#create a HUD page
var HUD_page = {canvas : nil,
                declutter_level : 0,
                bottom_line : permanent_line,
				displayed : false};
