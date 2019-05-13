##Taken from the B-1B##

setlistener("/sim/signals/fdm-initialized", func {
	init_tornado();
});

init_tornado = func {
setprop("instrumentation/teravd/target-vfpm-exec", 0);
setprop("instrumentation/teravd/target-alt-exec", 0);
setprop("instrumentation/teravd/alt-reached", 1);
setprop("instrumentation/teravd/ridge-clear", 0);
setprop("instrumentation/teravd/target-vfpm", 0);
setprop("instrumentation/teravd/target-alt", 0);

setprop("/sim/current-view/field-of-view", 60);
wingSweep(1);#sweep wings to fwd position
wingSweep(1);
fuelsweep(1);
fuelsweepleft(1);
fuelsweepright(1);
print ("Tornado warming up!");
}

aftburn_on = func {

setprop("/controls/engines/engine[0]/afterburner", 1);
setprop("/controls/engines/engine[1]/afterburner", 1);
}

aftburn_off = func {

setprop("/controls/engines/engine[0]/afterburner", 0);
setprop("/controls/engines/engine[1]/afterburner", 0);
}

##
# Wrapper around stepProps() which emulates the "old" wing sweep behavior for
# configurations that aren't using the new mechanism.
#
wingSweep = func {
    if(arg[0] == 0) { return; }
    if(props.globals.getNode("/sim/wing-sweep") != nil) {
        stepProps("/controls/flight/wing-sweep", "/sim/wing-sweep", arg[0]);
        return;
    }
    # Hard-coded flaps movement in 3 equal steps:
    val = 0.25 * arg[0] + getprop("/controls/flight/wing-sweep");
    if(val > 1) { val = 1 } elsif(val < 0) { val = 0 }
    setprop("/controls/flight/wing-sweep", val);
}

stepProps = func {
    dst = props.globals.getNode(arg[0]);
    array = props.globals.getNode(arg[1]);
    delta = arg[2];
    if(dst == nil or array == nil) { return; }

    sets = array.getChildren("setting");

    curr = array.getNode("current-setting", 1).getValue();
    if(curr == nil) { curr = 0; }
    curr = curr + delta;
    if   (curr < 0)           { curr = 0; }
    elsif(curr >= size(sets)) { curr = size(sets) - 1; }

    array.getNode("current-setting").setIntValue(curr);
    dst.setValue(sets[curr].getValue());
}

##
#wingsweep monitor to adjust position of the weight of the wings
##
setlistener("controls/flight/wing-sweep", func {
var sweep = getprop("controls/flight/wing-sweep");
var wingm = 4000;# estimated mass of both wings
var fwdsweep = wingm * sweep;
var aftsweep = wingm - fwdsweep;
setprop("sim/weight[0]/weight-lb", fwdsweep);
setprop("sim/weight[1]/weight-lb", aftsweep);
},0,0);

##
#wingsweep monitor to adjust wingfuel position
##
var fuelsweep = func {
var sweep = getprop("controls/flight/wing-sweep");
var fuelml = getprop("consumables/fuel/tank[0]/level-lbs");
var fuelmr = getprop("consumables/fuel/tank[1]/level-lbs");

var aftfuel = ((fuelml + fuelmr) * (1 - sweep));
var fwdfuel = (aftfuel * (-1));
setprop("sim/weight[2]/weight-lb", fwdfuel);
setprop("sim/weight[3]/weight-lb", aftfuel);
settimer(fuelsweep, 0.3);
}

##
#wingsweep monitor to adjust external fuel pylons
##
var fuelsweepleft = func {
var sweep = getprop("controls/flight/wing-sweep");
var fuelm = getprop("consumables/fuel/tank[5]/level-lbs");

var aftfuel = (fuelm * (1 - sweep));
var fwdfuel = (aftfuel * (-1));
setprop("sim/weight[4]/weight-lb", fwdfuel);
setprop("sim/weight[5]/weight-lb", aftfuel);
settimer(fuelsweepleft, 0.3);
}

var fuelsweepright = func {
var sweep = getprop("controls/flight/wing-sweep");
var fuelm = getprop("consumables/fuel/tank[6]/level-lbs");

var aftfuel = (fuelm * (1 - sweep));
var fwdfuel = (aftfuel * (-1));
setprop("sim/weight[6]/weight-lb", fwdfuel);
setprop("sim/weight[7]/weight-lb", aftfuel);
settimer(fuelsweepright, 0.3);
}

### tacan follow autopilot
var tacan_follow = func {
var ap_state = getprop("autopilot/locks/heading");
if (ap_state == "tacan-hold") {
  var tacan_hdg = getprop("instrumentation/tacan/indicated-bearing-true-deg");
  setprop("autopilot/settings/heading-bug-deg", tacan_hdg);
}
settimer(tacan_follow, 1);
}

