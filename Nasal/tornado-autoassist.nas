
# autoassist

printf("Loading AutoAssist for Tornado 2.0...");

var basepath = "/sim/autoassist";

var base = props.globals.getNode(basepath,1);

var printmsg = func(z) {
     printf("Autoassist Message: "~z);
	}  

var enginestart = {
     go: func(a) {
         var running = 0;
	     if ( running ) {
		     printmsg("Engine "~a~" is already running.");
			 return;
			}
		 else {
		     printmsg("Starting Engine "~a~"...");
			 settimer( func {
			     setprop("/controls/engines/engine["~(a-1)~"]/HP-cock",1);
                 avionics.battmstrswitch.go(1);
				},0.5);
			 settimer( func {
			     setprop("/controls/engines/engine["~(a-1)~"]/HP-cock",1);
				 if ( a == 1 ) { avionics.lpcockleftguard.toggle(); }
			     if ( a == 2 ) { avionics.lpcockrightguard.toggle(); }
				},1.5);
			 settimer( func {
			     setprop("/controls/engines/engine["~(a-1)~"]/HP-cock",1);
				 if ( a == 1 ) { avionics.fuelboostfrontswitch.go(1); }
				 if ( a == 2 ) { avionics.fuelboostrearswitch.go(1); }				 
				},3.5);
			 settimer( func {
                 setprop("/controls/engines/engine["~(a-1)~"]/starter",1);				 
				},4.5);
			 settimer( func {
			     if ( a == 1 ) { avionics.LPcockLeft.go(1); }
			     if ( a == 2 ) { avionics.LPcockRight.go(1); }
				},14);
			 settimer( func {
			     if ( a == 1 ) { avionics.lpcockleftguard.toggle(); }
			     if ( a == 2 ) { avionics.lpcockrightguard.toggle(); }
				},15);
			}
		},
	 stop: func(a) {
	     var running = 1;
	     if ( !running ) {
		     printmsg("Engine "~a~" is not running.");
			 return;
			}
		 else {
		     printmsg("Stopping Engine "~a~"...");
			 settimer( func {
			     if ( a == 1 ) { avionics.lpcockleftguard.toggle(); }
			     if ( a == 2 ) { avionics.lpcockrightguard.toggle(); }
				},0.5);
			 settimer( func {
			     setprop("/controls/engines/engine["~(a-1)~"]/HP-cock",0);
				 if ( a == 1 ) { avionics.LPcockLeft.go(0); }
			     if ( a == 2 ) { avionics.LPcockRight.go(0); }
				},1.5);
			 settimer( func {
				 if ( a == 1 ) { avionics.fuelboostfrontswitch.go(0); }
				 if ( a == 2 ) { avionics.fuelboostrearswitch.go(0); }				 
				},3.5);
			 settimer( func {
			     if ( a == 1 ) { avionics.lpcockleftguard.toggle(); }
			     if ( a == 2 ) { avionics.lpcockrightguard.toggle(); }
				},2.5);
			}
		},
	 monitor: func(b) {
	     
		}
	};
	
var autostart = func {
     settimer( func {
         enginestart.go(1);			 
	     },1);
	 settimer( func {
         enginestart.go(2);			 
		},15);
	}
	