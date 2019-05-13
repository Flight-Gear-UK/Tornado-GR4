# Here goes


      props.globals.initNode("/instrumentation/MFD/situana/contacts/multiplayer[0]/x-shift",0, "DOUBLE");
      props.globals.initNode("/instrumentation/MFD/situana/contacts/multiplayer[0]/y-shift",0, "DOUBLE");

var contact_pos = func {
  foreach (var ai_aircraft; props.globals.getNode("/ai/models").getChildren("aircraft")) {
     var n = ai_aircraft.getIndex();
	 var xshift = getprop("/ai/models/multiplayer[",n,"]/radar/x-shift");
	 var yshift = getprop("/ai/models/multiplayer[",n,"]/radar/y-shift");
	 var factor = getprop("/instrumentation/MFD/situana/grid-scale");
	 var xsout = ( xshift * factor );
	 var ysout = ( yshift * factor );
	 setprop("/instrumentation/MFD/situana/contacts/multiplayer[",n,"]/x-shift", xshift);
	 setprop("/instrumentation/MFD/situana/contacts/multiplayer[",n,"]/y-shift", yshift);
   }
   settimer(contact_pos, 1);
}

setlistener("/sim/signals/fdm-initialized", contact_pos);