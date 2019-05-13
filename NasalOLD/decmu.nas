
## DECMU

var apu = engines.Jet.new(2 , 0 , 0.01 , 10 , 6 , 6 , 6 , 2);
var engine1 = engines.Jet.new(0 , 0 , 0.01 , 5.21 , 4 , 4 , 0.025 , 2);
var engine2 = engines.Jet.new(1 , 0 , 0.01 , 5.21 , 4 , 4 , 0.025 , 2);

setlistener("sim/signals/fdm-initialized", func apu.init(), 0, 0);
setlistener("sim/signals/fdm-initialized", func engine1.init(), 0, 0);
setlistener("sim/signals/fdm-initialized", func engine2.init(), 0, 0);

props.globals.initNode("/engines/engine[0]/bleed-air", 0, "BOOL");
props.globals.initNode("/engines/engine[1]/bleed-air", 0, "BOOL");

  