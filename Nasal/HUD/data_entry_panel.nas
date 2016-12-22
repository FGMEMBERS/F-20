#Data entry panel... That's the keyboard below the HUD
#namespace
var DEP = {};

#-----------------------------------------------------------------------
DEP.pressKey0 = func(){scratchpad.append ("0");}
DEP.pressKey1 = func(){scratchpad.append ("1");}
DEP.pressKey2 = func(){scratchpad.append ("2");}
DEP.pressKey3 = func(){scratchpad.append ("3");}
DEP.pressKey4 = func(){scratchpad.append ("4");}
DEP.pressKey5 = func(){scratchpad.append ("5");}
DEP.pressKey6 = func(){scratchpad.append ("6");}
DEP.pressKey7 = func(){scratchpad.append ("7");}
DEP.pressKey8 = func(){scratchpad.append ("8");}
DEP.pressKey9 = func(){scratchpad.append ("9");}
DEP.pressKeyDot = func(){scratchpad.append (".");}
DEP.pressKeyCLR = func(){scratchpad.pressClear();}

#-----------------------------------------------------------------------
DEP.pressKeyDCL = func ()
{
  HUD_page.cycleDeclutter();
}

#-----------------------------------------------------------------------
DEP.pressKeyNAV = func ()
{
  leftDDI.changePage(HSI);
  rightDDI.changePage(IDX); #should really be radar display
}
