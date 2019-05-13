
# Generic FGUK Avionics
# Script V0.1

print("Initialising Avionics: Master");

# Switches







# Path to switches base node
var switchpath = "/controls/";

var indpath = "/instrumentation/indicators";
var indvolts = 26; # Power Requirement

var pttpath = "/instrumentation/PTT-indicators";

var gaugepath = "/instrumentation";

var audtrigpath = "/sim/sound/triggers";

# Path to Electrical Outputs base node
var powerbase = "/systems/electrical/outputs";

# Sound Trigger

var trigsound = func(tprop,vol) {
     var nd = props.globals.getNode(tprop);
	 nd.setValue(vol);
	 settimer( func { nd.setValue(0); },0.1 );
	}

# Switch Classes

var toggleswitch = {
     # Arguments: (switch node, initial position, sound trigger property)
     new: func (swpath,initpos,audtrig, vol = 1) {
		 var ts = { parents: [toggleswitch] };
		 ts.path = props.globals.getNode(switchpath~"/"~swpath,1);
		 ts.path.setBoolValue(initpos);
		 ts.audpath = audtrigpath~"/"~audtrig;
		 ts.aud = props.globals.getNode(ts.audpath,1);
		 ts.aud.setValue(0);
		 ts.audgain = vol;
		 return ts;
		},
	 go: func(x) {
	     me.path.setBoolValue(x);
		 trigsound(me.audpath,me.audgain);
		},
	 toggle: func {
	     if ( me.path.getValue() ) {
		     me.go(0);
			}
		 else {
		     me.go(1);
			}
		},
	};
	
var threeposswitch = {
     # Arguments: (switch node, initial position, sound trigger property)
     new: func (swpath,initpos,audtrig, vol = 1) {
		 var ts = { parents: [threeposswitch] };
		 ts.path = props.globals.getNode(switchpath~"/"~swpath,1);
		 ts.path.setValue(initpos);
		 ts.audpath = audtrigpath~"/"~audtrig;
		 ts.aud = props.globals.getNode(ts.audpath,1);
		 ts.aud.setValue(0);
		 ts.audgain = vol;
		 return ts;
		},
	 go: func(x) {
	     me.path.setValue(x);
		 trigsound(me.audpath,me.audgain);
		},
	 toggle: func() {
	     var y = me.path.getValue();
		 if ( y == 0 ) { me.go(1); }
		 if ( y == 1 ) { me.go(2); }
		 if ( y == 2 ) { me.go(0); }
		 if ( y == 2 ) { me.go(0); }
		}
	};
	
# Indicator Class

var ind_update = 0.3; # Indicator Loop Update Period

var indicator = {
     # Arguments: (indicator node,power node)
     new: func (indnode,srcnode,pwrnode,audtrig = nil,defmode = 0) {
	     var ind = { parents: [indicator] };
		 me.loop_running = 0;
		 ind.volts = props.globals.getNode(powerbase~"/"~pwrnode,1);
		 ind.volts.setValue(0);
		 ind.power = props.globals.getNode(indpath~"/"~indnode~"/powered",1);
		 ind.power.setBoolValue(0);
		 ind.coverpos = props.globals.getNode(indpath~"/"~indnode~"/cover-pos-norm",1);
		 ind.coverpos.setValue(1);
		 ind.default = defmode;
		 ind.sourceprop = props.globals.getNode(indpath~"/"~indnode~"/source-property",1);
		 ind.sourceprop.setValue(srcnode);
		 ind.source = props.globals.getNode(srcnode);
		 ind.audtrigger = props.globals.getNode(audtrigpath~"/"~audtrig,1);
		 ind.audtrigger.setValue(0);
         return ind;
		},
	 cover: func(x) { 
		 interpolate(me.coverpos,x,0.1);
		},
	 update: func {
	     if ( me.volts.getValue() > indvolts ) {
		     me.power.setBoolValue(1);
			 me.cover(0);
			}
		 else {
		     me.power.setBoolValue(0);
			 me.cover(1);
			}
		},
	 init: func { 
	 if (me.loop_running) return;
		me.loop_running = 1;
		var loop = func {
			 me.update();
			 settimer(loop, ind_update);
		    };			
		settimer(loop, 0); 
		}
	};
	
# Push to Test Class

var pushtest = {
     # Arguments: (Push to Test unit node, source node, power node)
     new: func (pttnode,srcnode,pwrnode) {
	     var ptt = { parents: [pushtest] };
         ptt.loop_running = 0;
		 ptt.volts = props.globals.getNode(powerbase~"/"~pwrnode,1);
		 ptt.volts.setValue(0);
		 ptt.power = props.globals.getNode(pttpath~"/"~pttnode~"/powered",1);
		 ptt.power.setBoolValue(0);
		 ptt.lit = props.globals.getNode(pttpath~"/"~pttnode~"/lit",1);
		 ptt.lit.setBoolValue(0);
		 ptt.sourceprop = props.globals.getNode(pttpath~"/"~pttnode~"/source-property",1);
		 ptt.sourceprop.setValue(srcnode);
		 ptt.source = props.globals.getNode(srcnode);
		 ptt.testnode = props.globals.getNode(pttpath~"/"~pttnode~"/test",1);
		 ptt.testnode.setBoolValue(0);
		 return ptt;
		},
	 test: func (x) {
	     me.testnode.setBoolValue(x);
		},
	 update: func {
	     if ( me.volts.getValue() > indvolts ) {
		     me.power.setBoolValue(1);
			 if ( ( me.source.getValue() ) or ( me.testnode.getValue() ) ) {
			     me.lit.setBoolValue(1);
				}
			 else {
			     me.lit.setBoolValue(0);
				}
			}
		 else {
		     me.power.setBoolValue(0);
			 me.lit.setBoolValue(0);
			}
		},
	 init: func { 
	 if (me.loop_running) return;
		me.loop_running = 1;
		var loop = func {
			 me.update();
			 settimer(loop, 0.1);
		    };			
		settimer(loop, 0); 
		}
	};
	
# Gauge Class

var gaugepwr = 24; # Required power for gauges in volts

var gauge = {
     # Arguments: (name,reading source,power source,hascover = 0,dual source = nil)
     new: func (name,srcnode,pwrnode,hascover = 0,dual = nil) {
	     var g = { parents: [gauge] };
		 g.loop_running = 0;
		 g.cover = nil;
		 g.gnode = gaugepath~"/"~name;
		 g.sourcedisplay = props.globals.getNode(g.gnode~"/source-path",1);
		 g.sourcedisplay.setValue(srcnode);
		 g.source = props.globals.getNode(srcnode);
		 g.power = props.globals.getNode(powerbase~"/"~pwrnode,1);
		 g.power.setValue(0);
		 g.powered = props.globals.getNode(g.gnode~"/powered",1);
		 g.powered.setBoolValue(0);
		 g.reading = props.globals.getNode(g.gnode~"/reading",1);
		 g.reading.setValue(0);
		 g.label = props.globals.getNode(g.gnode~"/label",1);
		 g.label.setValue(0);
		 if ( hascover ) {
		     g.cover = props.globals.getNode(g.gnode~"/cover-pos-norm",1);
			 g.cover.setValue(1);
			}
		 if ( dual != nil ) {
		     g.altsrcdisplay = props.globals.getNode(g.gnode~"/alt-source-path",1);
			 g.altsrcdisplay.setValue(dual);
			 g.altsrc = props.globals.getNode(dual);
			}
		 return g;
		},
	 update: func () {
	     if ( me.power.getValue() > gaugepwr ) {
		     me.powered.setBoolValue(1);
			 if ( me.cover != nil ) {
			     interpolate(me.cover, 0, 0.2);
				}
			 interpolate(me.reading, me.source.getValue(), 0.1);
			}
		 else {
		     me.powered.setBoolValue(0);
			 interpolate(me.reading, 0, 0.25);
			 if ( me.cover != nil ) {
			     interpolate(me.cover, 1, 0.1);
				}
			}
		},
	 init: func { 
	     if (me.loop_running) return;
		 me.loop_running = 1;
		 var loop = func {
			 me.update();
			 settimer(loop, 0.1);
		    };			
		 settimer(loop, 0); 
		}
	};
	
	
var switchguard = {
     # Arguments: (position node)
     new: func (node) {
	     var sg = { parents: [switchguard] };
		 sg.path = props.globals.getNode(switchpath~"/"~node,1);
		 sg.path.setValue(0);
		 return sg;
		},
	 toggle: func {
	     if ( me.path.getValue() == 0 ) {
		     interpolate(me.path, 1, 0.2);
			}
		 if ( me.path.getValue() == 1 ) {
		     interpolate(me.path, 0, 0.2);
			}
		}
	};