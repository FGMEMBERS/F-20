#AOA indexer
var fast_prop = "/instrumentation/aoa-indexer/fast";
var slow_prop = "/instrumentation/aoa-indexer/slow";
var on_speed_prop = "/instrumentation/aoa-indexer/on-speed";
var AOA_indexer = {
					elec_power :GenericLoad.new (DC_main,
												 10, #watts
												 28)
				  };

AOA_indexer.elec_power.switchOn();
				  
var indexer_hi_margin = 1.5;				  
var indexer_lo_margin = 0.5;	
				  
AOA_indexer.update = func (delta_t) 
{
  if (me.elec_power.running)
  {
    if (handle_command == handle_down)
    {
      if (Alpha < central_alpha - indexer_hi_margin)
      {
        setprop (fast_prop, true);
        setprop (on_speed_prop, false);
        setprop (slow_prop, false);
      }
      else if (Alpha < central_alpha - indexer_lo_margin)
      {
        setprop (fast_prop, true);
        setprop (on_speed_prop, true);
        setprop (slow_prop, false);      
      }
      else if (Alpha < central_alpha + indexer_lo_margin)
      {
        setprop (fast_prop, false);
        setprop (on_speed_prop, true);
        setprop (slow_prop, false);      
      }
      else if (Alpha < central_alpha + indexer_hi_margin)
      {
        setprop (fast_prop, false);
        setprop (on_speed_prop, true);
        setprop (slow_prop, true);      
      }
      else
      {
        setprop (fast_prop, false);
        setprop (on_speed_prop, false);
        setprop (slow_prop, true);        
      }    
    }
    else 
    {
        setprop (fast_prop, false);
        setprop (on_speed_prop, false);
        setprop (slow_prop, false);  
    }
  }
  else 
	{
		setprop (fast_prop, false);
		setprop (on_speed_prop, false);
		setprop (slow_prop, false);  
	}  

}				  
