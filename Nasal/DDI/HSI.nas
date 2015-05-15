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


var HSIcanvas= canvas.new({
                           "name": "f-20 HSI",
                           "size": [512,512], 
                           "view": [512,512],                       
                           "mipmapping": 1     
                          });                          
                          
HSIcanvas.addPlacement({"node": "DDIright"});
HSIcanvas.setColorBackground(0.0, 0.0, 0.0, 1.00);

# Create a group for the parsed elements
var HSIsvg = HSIcanvas.createGroup();
 
# Parse an SVG file and add the parsed elements to the given group
canvas.parsesvg(HSIsvg, "Aircraft/F-20/Nasal/DDI/HSI.svg");

var rose = HSIsvg.getElementById("rose_1");
var E_label = HSIsvg.getElementById("east_label");
var W_label = HSIsvg.getElementById("west_label");
var N_label = HSIsvg.getElementById("north_label");
var S_label = HSIsvg.getElementById("south_label");
var label_3 = HSIsvg.getElementById("3_label");
var label_6 = HSIsvg.getElementById("6_label");
var label_12 = HSIsvg.getElementById("12_label");
var label_15 = HSIsvg.getElementById("15_label");
var label_21 = HSIsvg.getElementById("21_label");
var label_24 = HSIsvg.getElementById("24_label");
var label_30 = HSIsvg.getElementById("30_label");
var label_33 = HSIsvg.getElementById("33_label");
var compass_labels = HSIsvg.getElementById("compass_labels");


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


var updateHSI = func ()
{  
  #compass
  var heading_rad = heading * 3.1416 / 180.0;
   
#  rose.updateCenter();
  rose.setRotation (-heading_rad);
#  E_label.updateCenter();
  E_label.setRotation (heading_rad);
#  W_label.updateCenter();
  W_label.setRotation (heading_rad);
#  S_label.updateCenter();
  S_label.setRotation (heading_rad);
#  N_label.updateCenter();
  N_label.setRotation (heading_rad);
#  label_3.updateCenter();
  label_3.setRotation (heading_rad);
#  label_6.updateCenter();
  label_6.setRotation (heading_rad);
#  label_12.updateCenter();
  label_12.setRotation (heading_rad);
#  label_15.updateCenter();
  label_15.setRotation (heading_rad);
#  label_21.updateCenter();
  label_21.setRotation (heading_rad);
#  label_24.updateCenter();
  label_24.setRotation (heading_rad);
#  label_30.updateCenter();
  label_30.setRotation (heading_rad);
#  label_33.updateCenter();
  label_33.setRotation (heading_rad);
#  compass_labels.updateCenter();
  compass_labels.setRotation (-heading_rad);

  
}
