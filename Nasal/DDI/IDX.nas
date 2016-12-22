#F-20 index page

var IDXcanvas= canvas.new({
                           "name": "index page",
                           "size": [512,512],
                           "view": [512,512],
                           "mipmapping": 1
                          });


# Create a group for the parsed elements
var IDXsvg = IDXcanvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
if (is_C_variant)
canvas.parsesvg(IDXsvg, "Aircraft/F-20/Nasal/DDI/index-C.svg");
else
canvas.parsesvg(IDXsvg, "Aircraft/F-20/Nasal/DDI/index.svg");

IDX.attachCanvas (IDXcanvas);

#-----------------------------------------------------------------------
#update function
IDX.update = func ()
{

}

#Bezel functions #######################################################

IDX.button_functions[0] = uselessKey;
IDX.button_functions[1] = func (display) {display.changePage (HUD_page);}
IDX.button_functions[2] = func (display) {display.changePage (HSI);}
IDX.button_functions[3] = uselessKey;
IDX.button_functions[4] = uselessKey;
IDX.button_functions[5] = uselessKey;
IDX.button_functions[6] = uselessKey;
IDX.button_functions[7] = uselessKey;
IDX.button_functions[8] = uselessKey;
IDX.button_functions[9] = uselessKey;
IDX.button_functions[10] = func (display) {display.changePage (INS_data);}
IDX.button_functions[11] = func (display) {display.changePage (IFF);}
IDX.button_functions[12] = func (display) {display.changePage (COM);}
IDX.button_functions[13] = func (display) {display.changePage (WPT);}
IDX.button_functions[14] = uselessKey;
