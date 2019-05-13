
# Tornado 2.0 Avionics
# Script V0.1

print("Initialising Avionics: Tornado 2.0");


# Glareshield Panels

# Switches & Guards



var latearmguard = switchguard.new("switches/pilot/left-glareshield-panel/late-arm-guard");
var lpcockleftguard = switchguard.new("switches/pilot/left-glareshield-panel/lpcock-left-guard");
var lpcockrightguard = switchguard.new("switches/pilot/left-glareshield-panel/lpcock-right-guard");

# Indicators

var leftglarepower = "/systems/electrical/outputs/instrument-panels/glareshield";

var revthrustleftind = indicator.new("reverse-thrust-left",
"/controls/switches/pilot/rapid-takeoff-panel/pitot-heaters",
"instrument-panels/glareshield",
"relay-click");
revthrustleftind.init();
var revthrustrightind = indicator.new("reverse-thrust-right",
"/controls/switches/pilot/rapid-takeoff-panel/pitot-heaters",
"instrument-panels/glareshield",
"relay-click");
revthrustrightind.init();
var liftdumpind = indicator.new("lift-dump",
"/controls/switches/pilot/rapid-takeoff-panel/pitot-heaters",
"instrument-panels/glareshield",
"relay-click");
liftdumpind.init();

var nogo1 = pushtest.new("no-go[0]","/controls/switches/pilot/rapid-takeoff-panel/windscreen-heater","instrument-panels/glareshield");
nogo1.init();

var nogo2 = pushtest.new("no-go[1]","/controls/switches/pilot/rapid-takeoff-panel/windscreen-heater","instrument-panels/glareshield");
nogo2.init();

var firelptt = pushtest.new("fire-left","/controls/switches/pilot/rapid-takeoff-panel/windscreen-heater","instrument-panels/glareshield");
firelptt.init();

var firerptt = pushtest.new("fire-right","/controls/switches/pilot/rapid-takeoff-panel/windscreen-heater","instrument-panels/glareshield");
firerptt.init();


# Rapid Takeoff Panel

var battmstrswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/battery-master", 0, "switch-click", 0.85);
var pitotheatswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/pitot-heaters", 0, "switch-click", 0.85);
var ignitswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/ignition", 0, "switch-click", 0.85);
var fuelboostfrontswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/fuel-boost[0]", 0, "switch-click", 0.85);
var wscreenheatswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/windscreen-heater", 0, "switch-click", 0.85);
var t1probesswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/T1-probes", 0, "switch-click", 0.85);
var fuelboostrearswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/fuel-boost[1]", 0, "switch-click", 0.85);
var apubleedswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/apu-bleed-closed", 0, "switch-click", 0.85);
var fltinstswitch = toggleswitch.new("switches/pilot/rapid-takeoff-panel/flight-instruments", 0, "switch-click", 0.85);

var gangbartrig = props.globals.getNode("/sim/sound/triggers/switch-gang",1);
gangbartrig.setValue(0);
var rtoGangbar = func {
     var time = 0.6;
     interpolate("/controls/switches/pilot/rapid-takeoff-panel/gang-bar-pos-norm",1,(time/2));
	 settimer( func {
	     foreach (sw; props.globals.getNode("/controls/switches/pilot/rapid-takeoff-panel").getChildren()) {
		     if ( sw.getName() != "gang-bar-pos-norm" ) {
			     sw.setBoolValue(1);
				}
			}
	     gangbartrig.setValue(1);
		 settimer( func { gangbartrig.setValue(0); },0.15 );
		 interpolate("/controls/switches/pilot/rapid-takeoff-panel/gang-bar-pos-norm",0,(time/2));
		},(time/2));
    }
	
var LPcockLeft = toggleswitch.new("/engines/engine[0]/LP-cock", 0, "switch-click", 1);
var LPcockRight = toggleswitch.new("/engines/engine[1]/LP-cock", 0, "switch-click", 1);
	
var engstartselectswitch = threeposswitch.new("switches/pilot/engine-start/engine-select", 0, "switch-click", 0.75);
var apustartswitch = threeposswitch.new("switches/pilot/engine-start/apu-start", 0, "switch-click", 0.75);
props.globals.initNode("/controls/switches/pilot/engine-start/start-cancel",0,"BOOL");
props.globals.initNode("/controls/engines/throttle-gate",0,"BOOL");

# Gauges

var eng0rpmgauge = gauge.new("engine-gauges/engine-rpm[0]","/engines/engine[0]/rpm","flight-instruments",1,"/engines/engine[0]/rpm");
eng0rpmgauge.init();
var eng1rpmgauge = gauge.new("engine-gauges/engine-rpm[1]","/engines/engine[1]/rpm","flight-instruments",1,"/engines/engine[0]/rpm");
eng1rpmgauge.init();

# Fuel Gauge
var fuelgaugepath = "/instrumentation/fuel-gauge";
var fuelgauge = {};
fuelgauge.power = props.globals.getNode(powerbase~"/flight-instruments");
fuelgauge.powered = props.globals.getNode(fuelgaugepath~"/powered",1);
fuelgauge.powered.setBoolValue(0);
fuelgauge.srcl = props.globals.getNode(fuelgaugepath~"/source-left",1);
fuelgauge.srcl.setValue(0);
fuelgauge.srcr = props.globals.getNode(fuelgaugepath~"/source-right",1);
fuelgauge.srcr.setValue(0);
fuelgauge.readl = props.globals.getNode(fuelgaugepath~"/reading-left",1);
fuelgauge.readl.setValue(0);
fuelgauge.readr = props.globals.getNode(fuelgaugepath~"/reading-right",1);
fuelgauge.readr.setValue(0);
fuelgauge.readt = props.globals.getNode(fuelgaugepath~"/reading-total",1);
fuelgauge.readt.setValue(0);
fuelgauge.mode = props.globals.getNode(fuelgaugepath~"/display-mode",1);
fuelgauge.mode.setIntValue(0);
fuelgauge.test = props.globals.getNode(fuelgaugepath~"/test-mode",1);
fuelgauge.test.setBoolValue(0);
fuelgauge.cover = props.globals.getNode(fuelgaugepath~"/cover-pos-norm",1);
fuelgauge.cover.setValue(1);
fuelgauge.button1 = props.globals.getNode(fuelgaugepath~"/button-CFUS",1);
fuelgauge.button1.setBoolValue(0);
fuelgauge.button2 = props.globals.getNode(fuelgaugepath~"/button-UFUS",1);
fuelgauge.button2.setBoolValue(0);
fuelgauge.button3 = props.globals.getNode(fuelgaugepath~"/button-WING",1);
fuelgauge.button3.setBoolValue(0);
fuelgauge.button4 = props.globals.getNode(fuelgaugepath~"/button-UWING",1);
fuelgauge.button4.setBoolValue(0);

fuelgauge.tanks = props.globals.getNode("/consumables/fuel");
fuelgauge.tank0 = fuelgauge.tanks.getNode("tank[0]/level-kg");
fuelgauge.tank1 = fuelgauge.tanks.getNode("tank[1]/level-kg");
fuelgauge.tank2 = fuelgauge.tanks.getNode("tank[2]/level-kg");
fuelgauge.tank3 = fuelgauge.tanks.getNode("tank[3]/level-kg");
fuelgauge.tank4 = fuelgauge.tanks.getNode("tank[4]/level-kg");
fuelgauge.tank5 = fuelgauge.tanks.getNode("tank[5]/level-kg");
fuelgauge.tank6 = fuelgauge.tanks.getNode("tank[6]/level-kg");

fuelgauge.calc = func () {
     if ( fuelgauge.test.getBoolValue() ) {
	     interpolate(fuelgauge.readl, 0, 0.2);
		 interpolate(fuelgauge.readr, 0, 0.2);
		 interpolate(fuelgauge.readt, 0, 0.2);
		}
	 else {
	     var outputl = 0;
		 var outputr = 0;
		 var outputt = 0;
		 if ( fuelgauge.mode.getValue() == 0 ) {
		     outputl = fuelgauge.tank0.getValue() + fuelgauge.tank2.getValue() + fuelgauge.tank3.getValue() + fuelgauge.tank5.getValue();
			 outputr = fuelgauge.tank1.getValue() + fuelgauge.tank4.getValue() + fuelgauge.tank6.getValue();
			 outputt = (outputl + outputr);
			}
		 if ( fuelgauge.mode.getValue() == 1 ) {
		     outputl = fuelgauge.tank2.getValue() + fuelgauge.tank3.getValue() + fuelgauge.tank4.getValue();
			 outputr = outputl;
			 outputt = outputl;
			}
		 if ( fuelgauge.mode.getValue() == 3 ) {
		     outputl = fuelgauge.tank0.getValue();
			 outputr = fuelgauge.tank1.getValue();
			 outputt = (outputl + outputr);
			}
		if ( fuelgauge.mode.getValue() == 4 ) {
		     outputl = fuelgauge.tank5.getValue();
			 outputr = fuelgauge.tank6.getValue();
			 outputt = (outputl + outputr);
			}
		 interpolate(fuelgauge.readl, outputl, 0.2);
		 interpolate(fuelgauge.readr, outputr, 0.2);
		 interpolate(fuelgauge.readt, outputt, 0.2);
		}
	}
	
fuelgauge.loop = func () {
	 if ( fuelgauge.power.getValue() < gaugepwr ) {
	     fuelgauge.powered.setBoolValue(0);
		 interpolate(fuelgauge.cover, 1, 0.1);
		 interpolate(fuelgauge.readl, 0, 0.2);
		 interpolate(fuelgauge.readr, 0, 0.2);
		 interpolate(fuelgauge.readt, 0, 0.2);
		 interpolate(fuelgauge.cover, 1, 0.2);
		}
	 else {
	     fuelgauge.powered.setBoolValue(1);
		 interpolate(fuelgauge.cover, 0, 0.1);
		 
		 var dmode = 0;
		 if ( fuelgauge.button1.getBoolValue() ) { dmode = 1; }
		 if ( fuelgauge.button2.getBoolValue() ) { dmode = 2; }
		 if ( fuelgauge.button3.getBoolValue() ) { dmode = 3; }
		 if ( fuelgauge.button4.getBoolValue() ) { dmode = 4; }
		 fuelgauge.mode.setIntValue(dmode);
		 
		 fuelgauge.calc();
		}
	 settimer(fuelgauge.loop,0.1);
	}

fuelgauge.loop();
	
var engstartswitch = func(t) {
     if ( t == 1 ) {
	     #
		}
	 if ( t == 2 ) {
	     #
		}
	}
	 



