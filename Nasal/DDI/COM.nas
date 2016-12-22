#F-20 Waypoint page

var COMcanvas= canvas.new({
                           "name": "index page",
                           "size": [512,512],
                           "view": [512,512],
                           "mipmapping": 1
                          });


# Create a group for the parsed elements
var COMsvg = COMcanvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
if (is_C_variant)
canvas.parsesvg(COMsvg, "Aircraft/F-20/Nasal/DDI/COMM-C.svg");
else
canvas.parsesvg(COMsvg, "Aircraft/F-20/Nasal/DDI/COMM.svg");

COM.attachCanvas (COMcanvas);

#-----------------------------------------------------------------------
#update function
COM.update = func ()
{

}

#Bezel functions #######################################################

COM.button_functions[0] = uselessKey;
COM.button_functions[1] = uselessKey;
COM.button_functions[2] = uselessKey;
COM.button_functions[3] = uselessKey;
COM.button_functions[4] = uselessKey;
COM.button_functions[5] = uselessKey;
COM.button_functions[6] = uselessKey;
COM.button_functions[7] = uselessKey;
COM.button_functions[8] = uselessKey;
COM.button_functions[9] = uselessKey;
COM.button_functions[10] = uselessKey;
COM.button_functions[11] = uselessKey;
COM.button_functions[12] = uselessKey;
COM.button_functions[13] = uselessKey;
COM.button_functions[14] = uselessKey;
