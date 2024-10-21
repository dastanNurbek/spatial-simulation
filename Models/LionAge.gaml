/**
* Name: LionAge
* Based on the internal empty template. 
* Author: Dastan
* Tags: 
*/


model LionAge

global {
	list<int> lion_ages <- [];
	float mean_ages;
	
	init {
		create lions number:20 {
			speed <- 0.3;
		}
		create zebras number:20 {
			speed <- 0.3;
		}
		write("Number: " + length(lions) + "\n" + 
		"Minimum: " + min(lion_ages) with_precision 2 + "\n" + 
		"Maximum: " + max(lion_ages) with_precision 2 + "\n" + 
		"Average: " + mean(lion_ages) with_precision 2);
	}
	
	reflex report {
		write "Time step: " + cycle;
		write "Minimum: " + min(lion_ages) with_precision 2 + "\n" + 
		"Maximum: " + max(lion_ages) with_precision 2 + "\n" + 
		"Average: " + mean(lion_ages)with_precision 2;
	}
}

species lions skills:[moving] {
	int age <- rnd(0, 60) update: age + 1;
	
	init {
		add age to: lion_ages;
	}
	
	reflex update_list {
		lion_ages[index] <- age;
		mean_ages <- mean(lion_ages);
	}
	reflex move{
		do wander;
	}
	reflex kill{
		ask zebras at_distance 2 {
			do die;
		}
	}
	reflex die_old {
		if (age >= 60){
			location <- {rnd(100),rnd(100)}; // changes position
			age <- 0; // sets age to 0
			lion_ages[index] <- age; // updates the list
			mean_ages <- mean(lion_ages); // updates the mean value
		}
	}
	aspect default{
		draw circle(3) color: rgb(252, int(4000/mean_ages), 3);
	}
}

species zebras skills:[moving] {
	reflex move{
		do wander;
	}
	aspect default{
		draw triangle(2) color: #grey;
	}
}

grid grass{
	float max_bio <- 1.0;
	float bio_prod <- rnd(0.03);
	float bio <- 0.01 max: max_bio update: bio + bio_prod;
	rgb color <- rgb(int(255 * (1 - bio)), 255, int(255 * (1 - bio))) update: rgb(int(255 * (1 - bio)), 255, int(255 * (1 - bio)));
	//rgb color <- rgb(0, int(255*(bio)), 0) update: rgb(0, int(255*(bio)), 0);
}

experiment main_experiment type:gui {
	output {
		display map {
			grid grass border: #black;
			species lions aspect:default;
			species zebras aspect:default;
		}
	}
}