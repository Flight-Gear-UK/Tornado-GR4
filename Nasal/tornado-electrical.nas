


var elecsyspath = "/systems/electrical";

var base = props.globals.getNode(elecsyspath);

# Contactors

var GEN1XP1 = base.getNode("contactors/GEN1-XP1",1);
GEN1XP1.setBoolValue(1);
var GEN2XP2 = base.getNode("contactors/GEN2-XP2",1);
GEN2XP2.setBoolValue(1);
var XP1TRU1 = base.getNode("contactors/XP1-TRU1",1);
XP1TRU1.setBoolValue(1);
var XP2TRU2 = base.getNode("contactors/XP2-TRU2",1);
XP2TRU2.setBoolValue(1);
var TRU1PP1 = base.getNode("contactors/TRU1-PP1",1);
TRU1PP1.setBoolValue(1);
var TRU2PP2 = base.getNode("contactors/TRU2-PP2",1);
TRU2PP2.setBoolValue(1);
var BATTPP4 = base.getNode("contactors/BATT-PP4",1);
BATTPP4.setBoolValue(1);
var PP4PP5 = base.getNode("contactors/PP4-PP5",1);
PP4PP5.setBoolValue(1);
var PP4PP5 = base.getNode("contactors/XP1-XP2",1);
PP4PP5.setBoolValue(0);
var PP4PP5 = base.getNode("contactors/GND-XP1",1);
PP4PP5.setBoolValue(0);

# Controls

var pilotfloods = props.globals.getNode("/controls/rotary/pilot/cockpit-floods",1);
pilotfloods.setValue(0.5);
var pilotintegcons = props.globals.getNode("/controls/rotary/pilot/integral-consoles",1);
pilotintegcons.setValue(0.5);
var pilotinteginst = props.globals.getNode("/controls/rotary/pilot/integral-instruments",1);
pilotinteginst.setValue(0.5)
