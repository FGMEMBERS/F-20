#Engine instruments

var engine_panel_light = Light.new(DC_Essential,
								     "/system/electrical/engine-panel-intensity",
									 0.1,
									 24);  
engine_panel_light.switchOn();			

var EGT_prop = "engines/engine/egt-degf";
var FF_prop = "engines/engine/fuel-flow_pph";
var OilPr_prop = "engines/engine/oil-pressure-psi";

var EGT = canvas.new({
  "name": "EGT-indicator",
  "size": [128, 128], 
  "view": [128, 128],                       
  "mipmapping": 1     
});

var N2 = canvas.new({
  "name": "N2-indicator",
  "size": [128, 128], 
  "view": [128, 128],  
  "mipmapping": 1  
});

var FF = canvas.new({
  "name": "FF-indicator",
  "size": [128, 128],
  "view": [128, 128],
  "mipmapping": 1  
});

var NozzleOpening = canvas.new({
  "name": "Nozzle-indicator",
  "size": [128, 128],
  "view": [128, 128],                     
  "mipmapping": 1    
});

var OilPr = canvas.new({
  "name": "OilPr-indicator",
  "size": [128, 128],
  "view": [128, 128],
  "mipmapping": 1    
});

EGT.addPlacement({"node": "EGT"});
N2.addPlacement({"node": "N1"});
FF.addPlacement({"node": "FF"});
NozzleOpening.addPlacement({"node": "Nozzle"});
OilPr.addPlacement({"node": "OilPr"});

var EGTroot = EGT.createGroup();
var N2root = N2.createGroup();
var FFroot = FF.createGroup();
NozzleRoot = NozzleOpening.createGroup();
var OilPrRoot = OilPr.createGroup();

var EGTtext = EGTroot.createChild("text")
                      .setTranslation(128, 128)      # The origin is in the top left corner
                      .setAlignment("right-bottom") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                      .setFont("led.txf") 
                      .setFontSize(48, 1.2)
                      .setColor(0.8,0.6,0)
                      .show();
                      
var N2text = N2root.createChild("text")
                      .setTranslation(128, 128)      # The origin is in the top left corner
                      .setAlignment("right-bottom") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                      .setFont("led.txf") 
                      .setFontSize(48, 1.2)
                      .setColor(0.8,0.6,0)
                      .show();                      
                                          
 var FFtext = FFroot.createChild("text")
                      .setTranslation(128, 128)      # The origin is in the top left corner
                      .setAlignment("right-bottom") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                      .setFont("led.txf") 
                      .setFontSize(48, 1.2)
                      .setColor(0.8,0.6,0)
                      .show();   
                      
 var NozzleText = NozzleRoot.createChild("text")
                      .setTranslation(128, 128)      # The origin is in the top left corner
                      .setAlignment("right-bottom") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                      .setFont("led.txf") 
                      .setFontSize(48, 1.2)
                      .setColor(0.8,0.6,0)
                      .show();                         
                              
 var OilPrText = OilPrRoot.createChild("text")
                      .setColor(0.8,0.6,0.0)
                      .setTranslation(128, 128)      # The origin is in the top left corner
                      .setAlignment("right-bottom") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                      .setFont("led.txf") 
                      .setFontSize(48, 1.2);                                                  

                   
var updateEngineInstrument = func ()
{
 EGTtext.setText(int((getprop(EGT_prop)-32)*5/9))
	    .setColor(engine_panel_light.intensity*0.8,
	              engine_panel_light.intensity*0.6,
	              0);
				;  
 N2text.setText(sprintf("%.1f",N2))
	   .setColor(engine_panel_light.intensity*0.8,
				 engine_panel_light.intensity*0.6,
				 0); 
 FFtext.setText(int(getprop(FF_prop)))
	   .setColor(engine_panel_light.intensity*0.8,
				 engine_panel_light.intensity*0.6,
				 0);
 NozzleText.setText(int(nozzle * 100))
	       .setColor(engine_panel_light.intensity*0.8,
					 engine_panel_light.intensity*0.6,
					 0);
 OilPrText.setText(int(getprop(OilPr_prop)))
	      .setColor(engine_panel_light.intensity*0.8,
					engine_panel_light.intensity*0.6,
					0);
}
