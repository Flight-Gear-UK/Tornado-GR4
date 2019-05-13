# Victor Engines - modified by Algernon from generic-yasim-engine.nas 
# -- a generic Nasal-based engine control system for YASim
# Version 1.0.0
#
# Copyright (C) 2011  Ryan Miller
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

var UPDATE_PERIOD = 0; # update interval for engine init() functions

print("Initialising Engines & APU");

# jet engine class
var Jet =
{
	# creates a new engine object
	new: func(n, running = 0, idle_throttle = 0.01, max_start_n1 = 5.21, start_threshold = 3, spool_time = 4, start_time = 0.02, shutdown_time = 4)
	{
		# copy the Jet object
		var m = { parents: [Jet] };
		# declare object variables
		m.number = n;
		m.name = "Engine " ~ ( n + 1 );
		m.autostart_status = 0;
		m.autostart_id = -1;
		m.loop_running = 0;
		m.started = 0;
		m.starting = 0;
		m.idle_n1 = 48.5; # Get this from the YASim jet tags
		m.idle_throttle = idle_throttle;
		m.max_start_n1 = max_start_n1;
		m.start_threshold = start_threshold;
		m.spool_time = spool_time;
		m.start_time = start_time;
		m.shutdown_time = shutdown_time;
		m.overspeed_rpm = 118; # 118
		m.oilp_min = 28; # at 99% RPM
		m.oilp_norm = 80; # at 90% RPM
		m.oilp_idle = 20;
		m.oilp_loss = 0;
		m.failure_prob = 0.000001;
		# create references to properties and set default values
		m.cutoff = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/cutoff", 1);
		m.cutoff.setBoolValue(!running);
		m.HPcock = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/HP-cock", 1);
		m.HPcock.setBoolValue(0);
		m.LPcock = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/LP-cock", 1);
		m.LPcock.setBoolValue(0);
		m.n1 = props.globals.getNode("engines/engine[" ~ n ~ "]/n1", 1);
		m.n1.setDoubleValue(0);
		m.oilpsi = props.globals.getNode("engines/engine[" ~ n ~ "]/oil-pressure-psi", 1);
		m.oilpsi.setValue(0);
		m.oilnorm = props.globals.getNode("engines/engine[" ~ n ~ "]/oilp-norm", 1);
		m.lowoil = props.globals.getNode("engines/engine[" ~ n ~ "]/low-oil", 1);
		m.lowoil.setBoolValue(0);
		m.out_of_fuel = props.globals.getNode("engines/engine[" ~ n ~ "]/out-of-fuel", 1);
		m.out_of_fuel.setBoolValue(0);
		m.reverser = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/reverser", 1);
		m.reverser.setBoolValue(0);
		m.rpm = props.globals.getNode("engines/engine[" ~ n ~ "]/rpm", 1);
		m.rpm.setDoubleValue(running ? 100 : 0);
		m.running = props.globals.getNode("engines/engine[" ~ n ~ "]/running", 1);
		m.running.setBoolValue(running);
		m.serviceable = props.globals.getNode("engines/engine[" ~ n ~ "]/serviceable", 1);
		m.serviceable.setBoolValue(1);
		m.starter = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/starter", 1);
		m.starter.setBoolValue(0);
		m.sip = props.globals.getNode("engines/engine[" ~ n ~ "]/start-in-progress", 1);
        m.sip.setBoolValue();
		m.throttle = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/throttle", 1);
		m.throttle.setDoubleValue(0);
		m.throttle_lever = props.globals.getNode("controls/engines/engine[" ~ n ~ "]/throttle-lever", 1);
		m.throttle_lever.setDoubleValue(0);
		m.overspeed = props.globals.getNode("engines/engine[" ~ n ~ "]/overspeed",1);
		m.overspeed.setBoolValue(0);
		m.dambase = props.globals.getNode("sim/damage/damage-zones/engine[" ~ n ~"]",1);
		m.damage = m.dambase.getNode("damage-norm", 1);
		m.damage.setValue(0);
		m.powerloss = m.dambase.getNode("power-loss-norm", 1);
		m.powerloss.setValue(0);
		m.smoking = m.dambase.getNode("smoke-norm", 1);
		m.smoking.setValue(0);
		m.fire = m.dambase.getNode("fire", 1);
		m.fire.setValue(0);
		m.stable = m.dambase.getNode("stable", 1);
		m.stable.setBoolValue(1);
		m.explosion = m.dambase.getNode("explosion", 1);
		m.explosion.setValue(0);
		# return our new object
		return m;
	},
	
	startSelect: func {
	
	var switch = props.globals.getNode("/controls/switches/pilot/engine-start/engine-select");
	var startbutton = props.globals.getNode("/controls/switches/pilot/engine-start/start-cancel");
	     if ( switch.getValue() == 0 ) { 
		     var index = 0; }
		 else { 
		     var index = ( switch.getValue() - 1 );
			}
		 #air = props.globals.getNode("/systems/air/air-start-system-psi").getValue();
		 var air = 40;
		 if (( air > 32 ) and ( startbutton.getBoolValue() )) {
		     setprop("/controls/engines/engine["~index~"]/starter", 1);
			}
		else {
		     setprop("/controls/engines/engine["~index~"]/starter", 0);
			}
	},
	
	HPgate: func {
	     var gate = props.globals.getNode("controls/engines/throttle-gate");
		 var gatestate = gate.getBoolValue();
		 
		 if ( me.number != 2 ) {
		 
		 if ( ( me.throttle.getValue() < 0.02 ) and ( !gatestate ) ) {
		     me.HPcock.setBoolValue(0);
			}
		 else {
		     me.HPcock.setBoolValue(1);
			}
		}
		},
	
	fuelSupply: func {
         
	     #Work differently if starting engine
		 var igswitch = props.globals.getNode("/controls/switches/pilot/rapid-takeoff-panel/ignition").getValue();
	     if ( igswitch ) {
	         if ( me.HPcock.getBoolValue() and me.LPcock.getBoolValue() ) {
		         if ( me.rpm.getValue() >= 11 ) {
			         me.cutoff.setBoolValue(0);
				    }
		         else {
		             me.cutoff.setBoolValue(1);
			        }
				}
			}
		 else {
		     if ( me.HPcock.getBoolValue() and me.LPcock.getBoolValue() ) {
			     me.cutoff.setBoolValue(0);
			    }
		     else {
		         me.cutoff.setBoolValue(1);
			    }
		    }
	 
	},
	
	# engine-specific autostart
	autostart: func
	{
		if (me.autostart_status)
		{
			me.autostart_status = 0;
			me.LPcock.setBoolValue(0);
			me.HPcock.setBoolValue(0);
		}
		else
		{
			me.autostart_status = 1;
			me.starter.setBoolValue(1);
			settimer(func
			{
				me.LPcock.setBoolValue(1);
				me.HPcock.setBoolValue(1);
			}, me.max_start_n1 / me.start_time);
		}
	},
	# creates an engine update loop (optional)
	init: func
	{
	    props.globals.getNode("engines/engine["~me.number~"]/serviceable",1).alias("/sim/failure-manager/engines/engine["~me.number~"]/serviceable");
		
		setlistener("/sim/damage/damage-zones/engine["~me.number~"]/damage-norm", func { me.fail_check(); } );
		
		if (me.loop_running) return;
		me.loop_running = 1;
		var loop = func
		{
			me.update();
			me.startSelect();
			me.fuelSupply();
			me.HPgate();
			
			settimer(loop, UPDATE_PERIOD);
		};
		var fail_loop = func {
		     me.fail_check();
			 # Debug
			 # print("Failure Probability: "~ me.failure_prob);
			 settimer(fail_loop, 10);
			}
			
		settimer(loop, 0);
		settimer(fail_loop, 0);
	},
	# updates the engine
	update: func {
		
		# Check Damage
		
		if ( me.damage.getValue() > 0.15 ) {
		     me.oilp_loss = ( ( me.oilp_idle * 2 ) * me.damage.getValue() );
			}
		
		# Calculate Oil Pressure
		
		#var oilwarn = 0;
		#var x = me.rpm.getValue();
		#if ( me.running.getBoolValue() ) { x = 48; }
		#var idlep = ( ( me.oilp_idle / me.idle_n1 ) * x );
		#if ( idlep > me.oilp_idle ) { idlep = me.oilp_idle };
		#var oilp = ( idlep + ( ( me.oilp_norm * 0.55 ) * me.oilnorm.getValue() ) );
		
		#if ( oilp < ( ( me.rpm.getValue() / 100 ) * me.oilp_min ) ) {
		#     oilwarn = 1;
		#	}
		 #me.oilpsi.setValue(oilp);    
		 #me.lowoil.setBoolValue(oilwarn);
		
		# Calculate Smoking

        me.smoking.setValue( ( me.damage.getValue() * 0.55 ) * ( me.rpm.getValue() * 0.009 ) + ( me.explosion.getValue() * 2 ) + ( me.fire.getValue() * 0.6 ) );
	
		if (me.running.getBoolValue() and !me.started)
		{
			me.running.setBoolValue(0);
		}
		
		if ( !me.running.getBoolValue() and me.starter.getBoolValue() ) {
			 
			 if ( ( me.rpm.getValue() > 0.4 ) and ( me.rpm.getValue() <50 ) ) { 
			     me.sip.setBoolValue(1);
				}
				
			else {
			     me.sip.setBoolValue(0);
			    }
			}
	
		else {
		     me.sip.setBoolValue(0);
		}
		
		if (me.cutoff.getBoolValue() or !me.serviceable.getBoolValue() or me.out_of_fuel.getBoolValue())
		{
			var rpm = me.rpm.getValue();
			var time_delta = getprop("sim/time/delta-realtime-sec");
			
			if (me.starter.getBoolValue())
			{
				rpm += time_delta * me.spool_time;
				me.rpm.setValue(rpm >= me.max_start_n1 ? me.max_start_n1 : rpm);
			}
			else
			{
				rpm -= time_delta * me.shutdown_time;
				me.rpm.setValue(rpm <= 0 ? 0 : rpm);
				me.running.setBoolValue(0);
				me.throttle_lever.setDoubleValue(0);
				me.started = 0;
			}
		 
		}
		elsif (me.starter.getBoolValue())
		{
			var rpm = me.rpm.getValue();
			if (rpm >= me.start_threshold)
			{
				var time_delta = getprop("sim/time/delta-realtime-sec");
				rpm += time_delta * me.spool_time;
				me.rpm.setValue(rpm);
				if (rpm >= me.n1.getValue())
				{
					me.running.setBoolValue(1);
					me.starter.setBoolValue(0);
					me.started = 1;
				}
				else
				{
					me.running.setBoolValue(0);
				}
			}
		}
		elsif (me.running.getBoolValue())
		{
			me.throttle_lever.setValue(me.idle_throttle + (1 - me.idle_throttle) * me.throttle.getValue() - me.powerloss.getValue() );
			
			me.rpm.setValue( me.n1.getValue() );
			
			# me.smoking.setValue( ( me.damage.getValue() * 0.2 ) + ( me.rpm.getValue() * 0.009 ) );

             if ( me.rpm.getValue() < me.overspeed_rpm ) { me.overspeed.setBoolValue(0); }	 
			 else { me.overspeed.setBoolValue(1); }
		}
	},
	fail_check: func {
		 var x = rand();
		 #print("Random Failure Generator: "~x);
		 if ( me.damage.getValue() > 0.2 ) {
		     me.stable.setBoolValue(0);
			}
		 if ( me.damage.getValue() > 0.65 ) {
		     me.serviceable.setBoolValue(0);
			}
			
		 if (( me.damage.getValue() > 0.85 ) and ( me.running.getBoolValue() )) {
		     me.explode(0.95);
			}

		
		 if ( x < me.failure_prob ) {
		     var sev = 0;
			 if ( me.failure_prob < 0.00 ) { sev = ( rand() / 5 ); }
			 else { sev = ( ( rand() + me.damage.getValue() ) / 4 ); }
		     me.fail(sev);
			 
			}
			
		 if ( me.overspeed.getBoolValue() ) {
  		     me.failure_prob += (( rand() * 0.001 ) + ( ( ( me.rpm.getValue() * me.failure_prob ) / 1000 ) ));
			}
			
		 if ( !me.stable.getBoolValue() and me.running.getBoolValue() ) {
		     # Generate and add random damage

			}
		},
	fail: func (sev = 0.2) { 
         print("Severity "~sev~" failure on "~ me.name );
		 #me.damage.setValue( me.damage.getValue() += sev);
	     var dx = ( me.damage.getValue() + sev );
		 me.damage.setValue(dx);
		 me.powerloss.setValue( dx * 4 );
		 #interpolate(me.powerloss, ( dx * 4 ), 5);				 
	    },
    explode: func (sev = 0.4) {
	     print("Explosion in " ~ me.name );
	     me.explosion.setValue(sev);
		 interpolate( me.explosion, 0, ( sev * 1.15 ) );
		 if ( rand() < 0.85 ) { me.fire.setValue( ( sev + rand() ) * 0.5 ); }
		 me.fail( sev );
		},
};

# Now do it!

#new: func(n, running = 0, idle_throttle = 0.01, max_start_n1 = 5.21, start_threshold = 3, 
#     spool_time = 4, start_time = 0.02, shutdown_time = 4)

      var apu     = Jet.new(2 , 0 , 0.105 , 10 , 6 , 1 , 0.05 , 3);
      var engine0 = Jet.new(0 , 0 , 0.005 , 12.8 , 10 , 1 , 0.05 , 1);
      var engine1 = Jet.new(1 , 0 , 0.005 , 12.2 , 10 , 1 , 0.05 , 1);
	  
	  apu.init();
	  engine0.init();
	  engine1.init();

	
   
