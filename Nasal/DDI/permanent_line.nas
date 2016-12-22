#F-20 permanent line

var PermanentLineCanvas = canvas.new({
									 "name": "permanent line",
									 "size": [512,512],
									 "view": [512,512],
									 "mipmapping": 1
									});


# Create a group for the parsed elements
var PermanentLineSvg = PermanentLineCanvas.createGroup();
PermanentLineCanvas.setColorBackground(0.0, 0.0, 0.0, 0.00);

# Parse an SVG file and add the parsed elements to the given group

if (is_C_variant)
canvas.parsesvg(PermanentLineSvg, "Aircraft/F-20/Nasal/DDI/permanent_line-C.svg");
else
canvas.parsesvg(PermanentLineSvg, "Aircraft/F-20/Nasal/DDI/permanent_line.svg");


#Scratchpad handling ###################################################
var max_scratchpad_length = 12;
var scratchpad = {clear_counter : 0,
				  text : "",
				  length : 0,
				  box : PermanentLineSvg.getElementById("scratchpad_box"),
				  label : PermanentLineSvg.getElementById("scratchpad")};

#-----------------------------------------------------------------------
scratchpad.show = func()
{
  me.box.show();
  me.label.show();
}

#-----------------------------------------------------------------------
scratchpad.hide = func()
{
  me.box.hide();
  me.label.hide();
}

scratchpad.hide();

#-----------------------------------------------------------------------
scratchpad.remove = func ()
{
  me.setText ("");
  me.clear_counter = 0;
  me.length = 0;
  me.hide ();
}

#-----------------------------------------------------------------------
scratchpad.setText = func(text)
{
  me.text = text;
  me.label.setText (me.text);
}

#-----------------------------------------------------------------------
scratchpad.append = func(character)
{
  if (me.length == 0) me.show();
  if (me.length < max_scratchpad_length)
  {
   me.setText(sprintf ("%s%s", me.text, character));
   me.clear_counter = 0;
   me.length = me.length+1;
  }
}

#-----------------------------------------------------------------------
scratchpad.pressClear = func ()
{
  if (me.length > 0)
  if (me.clear_counter == 0)
  {
    me.setText (left (me.text, size (me.text) - 1));
    me.clear_counter = 1;
    me.length = me.length - 1;
    if (me.length == 0) me.hide();
  }
  else
  {
    me.remove();
  }
}

#-----------------------------------------------------------------------
scratchpad.flash = func ()
{
  me.hide();
  settimer ( func {me.show();}, 0.2);
}

#Bezel functions #######################################################

#TACAN channel
var PL_tacan_channel_label = PermanentLineSvg.getElementById("tacan_channel");
var PL_tacan_box = PermanentLineSvg.getElementById("tacan_box");

permanent_Pb_16 = func (display) 
{
  if (scratchpad.length == 0)
  {
    TACAN.toggleChannelKind();
    PL_tacan_channel_label.setText(sprintf("%i%s", TACAN.channel,TACAN.letter));
  }
  else
  {
    var new_channel = num (scratchpad.text);
    if (new_channel > 128) scratchpad.flash();
    else 
    {
      TACAN.setChannel (new_channel);
      PL_tacan_channel_label.setText(sprintf("%i%s", TACAN.channel,TACAN.letter));
      scratchpad.remove();
    }
  }
}

permanent_Pb_17 = func (display) {print ("flight test page");}
permanent_Pb_18 = func (display) {display.changePage (IDX)};
permanent_Pb_19 = func (display) {print ("sets the IFF/ATC code");}

permanent_Pb_20 = func (display) 
{
  if (scratchpad.length == 0) 
  {
  }
}

var permanent_line = {canvas : PermanentLineCanvas,
					  button_functions : [permanent_Pb_16,
										  permanent_Pb_17,
									      permanent_Pb_18,
										  permanent_Pb_19,
										  permanent_Pb_20]};
