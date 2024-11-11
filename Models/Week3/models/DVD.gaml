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
		create dvd number:1 {
			speed <- 1.0;
		}
	}
}

species cows skills:[moving] {
	geometry action_area; //<- circle(speed) intersection cone(heading - 45, heading + 45);
	
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
	geometry action_area <- line(self.location, self.location + {0,1});
	
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
	geometry action_area <- line(self.location, {0,0})intersection circle(speed);
	
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

species dvd skills:[moving] {
	reflex walk {
		do move;
	}
	reflex change_direction {
		// Right wall collision
		if (self.location.x >= 99) {
			if (heading >= 0 and heading < 180) {
				heading <- (180 - heading) mod 360;
			}
			else {
				heading <- (540 - heading) mod 360;
			}
		}
		// Left wall collision
		else if (self.location.x <= 1) {
			if (heading > 180 and heading <= 359) {
				heading <- (540 - heading) mod 360;
			}
			else {
				heading <- (180 - heading) mod 360;
			}
		}
		
		// Top wall collision
		if (self.location.y >= 99) {
			if (heading >= 90 and heading < 270) {
				heading <- (360 - heading) mod 360;
			}
			else {
				heading <- (360 - heading) mod 360;
			}
		}
		// Bottom wall collision
		if (self.location.y <= 1) {
			if (heading < 90 or heading >= 270) {
				heading <- (360 - heading) mod 360;
			}
			else {
				heading <- (360 - heading) mod 360;
			}
		}
	}
	aspect default {
		draw rectangle(15,14) texture: ["../includes/dvd.png"];
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
			species dvd aspect:default;
		}
	}
}

