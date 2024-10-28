/**
* Name: Farm
* Based on the internal empty template. 
* Author: Dastan Nurbekuly
* Tags: 
*/


model Farm

global {
	init {
		create cows number:5 {
			speed <- 2.0;
		}
		create sheep number:3 {
			speed <- 1.0;
			heading <- 90.0;
		}
		create goats number:2 {
			speed <- 0.5;
		}
	}
}

species cows skills:[moving] {
	geometry action_area; 
	
	reflex walk {
		do wander amplitude: 90.0;
	}
	reflex update_actionArea {
		action_area <- circle(speed) intersection cone(heading - 45, heading + 45);
	}
	aspect default {
		draw circle(1) color: #brown;
	}
	aspect action_neighborhood {
		draw action_area color: #yellow;
	}
}

species sheep skills:[moving] {
	geometry action_area;
	
	reflex walk {
		do move;
	}
	reflex update_actionArea {
		if (heading > 90) {
			action_area <- line(self.location, self.location + {0,-1});
		}
		else {
			action_area <- line(self.location, self.location + {0,1});
		}
	}
	aspect default {
		draw circle(1) color: #black;
	}
	aspect action_neighborhood {
		draw action_area color: #yellow;
	}
}

species goats skills:[moving] {
	geometry action_area;
	
	reflex walk {
		do goto target: {0,0};
	}
	reflex update_actionArea {
		action_area <- line(self.location, {0,0})intersection circle(speed);
	}
	aspect default {
		draw circle(1) color: #gray;
	}
	aspect action_neighborhood {
		draw action_area color: #yellow;
	}
}

grid grass{
	rgb color <- rgb(0,255,0);
}

experiment main_experiment type:gui {
	output {
		display map {
			grid grass border: #black;
			species cows aspect:default;
			species cows aspect:action_neighborhood;
			species sheep aspect:default;
			species sheep aspect:action_neighborhood;
			species goats aspect:default;
			species goats aspect:action_neighborhood;
		}
	}
}

