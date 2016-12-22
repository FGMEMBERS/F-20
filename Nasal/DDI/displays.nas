####################################
#create all the displays of the F-20

var number_of_different_displays = 0;

#left DDI
var leftDDI = DDI.new(IDX, "DDIleft", "/instrumentation/leftDDI/brightness", AC_1);
var rightDDI = DDI.new(HSI, "DDIright","/instrumentation/rightDDI/brightness", AC_2);

var display_list =[nil,nil,nil];
var updatable_pages = [HSI, IDX, HUD_page, INS_data, INS_align];

var displays = [HUD, leftDDI, rightDDI];

HUD.elec_power.switchOn();
leftDDI.elec_power.switchOn();
rightDDI.elec_power.switchOn();

#-----------------------------------------------------------------------
var updatePageDisplayList = func ()
{
  var already_displayed = false;
  #first check wether page selected is not already being updated
  foreach (var page; updatable_pages) page.displayed = false;
  foreach (var display; displays) display.current_page.displayed = true;
  number_of_different_displays = 0;
  
  foreach (var page; updatable_pages)
  {
    if (page.displayed) 
    {
     display_list[number_of_different_displays] = page;
     number_of_different_displays = number_of_different_displays + 1;
    }
  }
}

updatePageDisplayList();

#-----------------------------------------------------------------------                   
var updateDisplays = func (delta_t)
{
  for (var i = 0; i < number_of_different_displays; i = i+1)
  display_list[i].update(delta_t);
  foreach (var display; displays)
  {
    display.checkPower(delta_t);
  }
}
