#Animations for the Kollsman AAU 34/A altimeter

var BaroBarel1 = props.globals.getNode("/instrumentation/altimeter/baro-barel-1");
var BaroBarel2 = props.globals.getNode("/instrumentation/altimeter/baro-barel-2");
var BaroBarel3 = props.globals.getNode("/instrumentation/altimeter/baro-barel-3");
var BaroBarel4 = props.globals.getNode("/instrumentation/altimeter/baro-barel-4");

var AltBarel100 = props.globals.getNode("/instrumentation/altimeter/alt-barel-100");
var AltBarel1k = props.globals.getNode("/instrumentation/altimeter/alt-barel-1k");
var AltBarel10k = props.globals.getNode("/instrumentation/altimeter/alt-barel-10k");

var measured_altitude_prop = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft");
var baro_setting_prop = props.globals.getNode("/instrumentation/altimeter/setting-inhg");



#----------------------------------------------------------------------
var animateBarel = func (value, unit, animation_margin)
{
  var digit =  (value - int (value/(unit*10))*unit*10)/unit;
  var integral_value = int (digit);
  var decimals = digit-integral_value;
  var final_value = 0;
  
  if (decimals < animation_margin)
    final_value = integral_value
                  - 
                  0.5
                  *
                  (animation_margin - decimals)
                  / animation_margin;
  else if (decimals > (1-animation_margin))
    final_value = integral_value 
                  + 
                  (decimals - 1 +  animation_margin)
                  / 
                  animation_margin
                  *
                  0.5;
  else 
    final_value = integral_value;
    
  return final_value * 36.0;
}

var baro_setting = 0;

#----------------------------------------------------------------------
var updateAltimeter = func
{
    measured_altitude = measured_altitude_prop.getValue();
    baro_setting = baro_setting_prop.getValue();
   
    BaroBarel1.setValue(animateBarel(baro_setting,0.01,0.1));
    BaroBarel2.setValue(animateBarel(baro_setting,0.1,0.1));
    BaroBarel3.setValue(animateBarel(baro_setting,1.0,0.1));
    BaroBarel4.setValue(animateBarel(baro_setting,10,0.01));
    
    AltBarel100.setValue(animateBarel(measured_altitude,100,0.1));
    AltBarel1k.setValue(animateBarel(measured_altitude,1000,0.01));
    AltBarel10k.setValue(animateBarel(measured_altitude,10000,0.001));

}
