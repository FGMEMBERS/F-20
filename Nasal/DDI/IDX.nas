#F-20 HUD main module

#angular definitions
#up angle 1.73 deg
#left/right angle 5.5 deg
#down angle 10.2 deg
#total size 11x11.93 deg
#texture square 256x256
#bottom left 0,0
#viewport size  236x256
#center at 118,219
#pixels per deg = 21.458507963

var IDXcanvas= canvas.new({
                           "name": "f-20 HUD",
                           "size": [512,512], 
                           "view": [512,512],                       
                           "mipmapping": 1     
                          });                          
                          
IDXcanvas.addPlacement({"node": "DDIleft"});
IDXcanvas.setColorBackground(0.0, 0.0, 0.0, 1.00);

# Create a group for the parsed elements
var IDXsvg = IDXcanvas.createGroup();
 
# Parse an SVG file and add the parsed elements to the given group
canvas.parsesvg(IDXsvg, "Aircraft/F-20/Nasal/DDI/index.svg");
 
#var ladder = SVGfile.getElementById("ladder");
#var VV = SVGfile.getElementById("VelocityVector");
#var KIAS = SVGfile.getElementById("KIAS");
#KIAS.setFont("condensed.txf").setFontSize(14, 1.4);
#var Alt = SVGfile.getElementById("Alt");
#Alt.setFont("condensed.txf").setFontSize(11, 1.4);
#var AltThousands = SVGfile.getElementById("AltThousands");
#AltThousands.setFont("condensed.txf").setFontSize(14, 1.4);
#var AlphaValue = SVGfile.getElementById("alpha");
#AlphaValue.setFont("condensed.txf").setFontSize(9, 1.4);
#var gValue = SVGfile.getElementById("G-value");
#gValue.setFont("condensed.txf").setFontSize(9, 1.4);
#var MachValue = SVGfile.getElementById("Mach");
#MachValue.setFont("condensed.txf").setFontSize(9, 1.4);
#var heading_tape = SVGfile.getElementById("heading-scale");
#var roll_pointer = SVGfile.getElementById("roll-pointer");


var updateIDX = func ()
{  
  

}

