/**
* Name: Vierkaser
* Based on the internal empty template. 
* Author: Dastan Nurbekuly
* Tags: 
*/


model Vierkaser

global {
	file vierkaser_file <- file("../includes/Vierkaser.geojson");
	file cleaned_2020_file <- file("../includes/cleaned_2020.geojson");
	file cleaned_2021_file <- file("../includes/cleaned_2021.geojson");
	file cleaned_2022_file <- file("../includes/cleaned_2022.geojson");
	file cleaned_2023_file <- file("../includes/cleaned_2023.geojson");
	file hirschanger_file <- file("../includes/Hirschanger.geojson");
	file meadow_file <- file("../includes/Meadow.geojson");
	
	geometry shape <- envelope(vierkaser_file);
	geometry cleaned_2020 <- geometry(cleaned_2020_file);
	geometry cleaned_2021 <- geometry(cleaned_2021_file);
	geometry cleaned_2022 <- geometry(cleaned_2022_file);
	geometry cleaned_2023 <- geometry(cleaned_2023_file);
	geometry hirschanger <- geometry(hirschanger_file);
	geometry meadow <- geometry(meadow_file);
	
	init {
		create cows number:6 {
			location <- any_location_in(cleaned_2020);
			speed <- 10.0;
		}
	}
}

species cows skills:[moving] {
	int action_radius <- 50;
	geometry action_area; 
	grass best_spot;
	list<grass> grass_within_reach;
	grass available_to_eat;
	
	reflex update_actionArea {
		action_area <- circle(action_radius);
	}
	reflex graze {
		best_spot <- (grass overlapping action_area) closest_to self; // finds best spot
		if best_spot.biomass >= 0.4 { // checks if biomass greater than 0.4
			write best_spot;
			do goto target: best_spot; // goes to the location
			if self distance_to best_spot <= 2 and best_spot.biomass >= 0.4{ // checks if it reached the target
				grass_within_reach <- grass intersecting(circle(3)); // gets grass that are within reach
				loop i from: 0 to: (length(grass_within_reach)-1){ // loops through the grass within reach
					ask grass_within_reach[i] { // asks the grass to lose biomass
						if biomass >= 0.4{
							biomass <- biomass - 0.4;
						}
					}
				}
			}
		}
		else {
			best_spot <- one_of (grass at_distance(action_radius)); // finds other best spot
			if best_spot.biomass >= 0.4 { // checks if biomass greater than 0.4
				write best_spot;
				do goto target: best_spot; // goes to the location
			}
		}
	}
	aspect default {
		draw circle(5) color: #brown;
	}
	aspect action_neighborhood {
		draw action_area color: #yellow;
	}
}

grid grass cell_width: 5#m cell_height: 5#m{
	float biomass;
	bool is_cleaned_2020 <- self intersects(cleaned_2020); 
	bool is_cleaned_2021_2023 <- self intersects(cleaned_2021) or self intersects(cleaned_2022) or self intersects(cleaned_2023);
	bool is_hirschanger <- self intersects (hirschanger);
	bool is_meadow <- self intersects (meadow);
	float grow_rate <- 0.001;
	
	init {
		if is_cleaned_2020 {
			biomass <- 0.7;
		}
		else if is_cleaned_2021_2023 {
			biomass <- 0.6;
		}
		else if is_hirschanger {
			biomass <- 0.4;
		}
		else if is_meadow {
			biomass <- 0.6;
		}
	}
	
	reflex grow {
		if biomass <= 0.7 and is_cleaned_2020 {
			biomass <- biomass + grow_rate;
		}
		if biomass <= 0.6 and is_cleaned_2021_2023 {
			biomass <- biomass + grow_rate;
		}
		if biomass <= 0.4 and is_hirschanger {
			biomass <- biomass + grow_rate;
		}
		if biomass <= 0.6 and is_meadow {
			biomass <- biomass + grow_rate;
		}
	}
	rgb color <- is_cleaned_2020 or is_cleaned_2021_2023 or is_hirschanger or is_meadow
	? rgb(int(255 * (1 - biomass)), 255, int(255 * (1 - biomass))) 
	: rgb(235, 186, 52) 
	update: is_cleaned_2020 or is_cleaned_2021_2023 or is_hirschanger or is_meadow 
	? rgb(int(255 * (1 - biomass)), 255, int(255 * (1 - biomass)))
	: rgb(235, 186, 52);
}

experiment main_experiment type:gui {
	output {
		display map {
			grid grass;
			species cows aspect:default;
			species cows aspect:action_neighborhood transparency: 0.5;
		}
	}
}
