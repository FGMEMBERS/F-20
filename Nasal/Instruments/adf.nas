###############################################################################
#ADF

var adf_channel_prop = "/instrumentation/adf/frequency";
var adf_bearing_prop = "/instrumentation/adf/bearing";
var adf_is_receiving_prop = "/instrumentation/adf/receiving";

var ADF = {
            frequency : 0.0,
			is_receiving : false,
			elec_power : GenericLoad.new (AC_1, 30, 115)
          }

#-----------------------------------------------------------------------
ADF.setFrequency = func (frequency)
{
  me.frequency = frequency;
  setprop (tacan_channel_prop, frequency);
}

#-----------------------------------------------------------------------
ADF.isReceiving = func ()
{

  return getprop (adf_is_receiving_prop);

}

#-----------------------------------------------------------------------
ADF.getBearing = func ()
{

  return getprop (tacan_bearing_prop);

}
