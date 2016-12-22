#F-20 Waypoint page

var IFFcanvas= canvas.new({
                           "name": "index page",
                           "size": [512,512],
                           "view": [512,512],
                           "mipmapping": 1
                          });


# Create a group for the parsed elements
var IFFsvg = IFFcanvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
if (is_C_variant)
canvas.parsesvg(IFFsvg, "Aircraft/F-20/Nasal/DDI/IFF-C.svg");
else
canvas.parsesvg(IFFsvg, "Aircraft/F-20/Nasal/DDI/IFF.svg");


IFF.attachCanvas (IFFcanvas);

#-----------------------------------------------------------------------
#update function
IFF.update = func ()
{

}

#Bezel functions #######################################################

IFF.button_functions[0] = uselessKey;
IFF.button_functions[1] = uselessKey;
IFF.button_functions[2] = uselessKey;
IFF.button_functions[3] = uselessKey;
IFF.button_functions[4] = uselessKey;
IFF.button_functions[5] = uselessKey;
IFF.button_functions[6] = uselessKey;
IFF.button_functions[7] = uselessKey;
IFF.button_functions[8] = uselessKey;
IFF.button_functions[9] = uselessKey;
IFF.button_functions[10] = uselessKey;
IFF.button_functions[11] = uselessKey;
IFF.button_functions[12] = uselessKey;
IFF.button_functions[13] = uselessKey;
IFF.button_functions[14] = uselessKey;


