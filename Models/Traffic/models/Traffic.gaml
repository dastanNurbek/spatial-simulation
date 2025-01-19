/**
* Name: Traffic
* Description: define species for traffic simulation
* Author: Patrick Taillandier & Duc Pham
* Tags: driving skill, graph, agent_movement, skill, transport
*/

model traffic_simulation

global {
	////////////////////////////////////////////////////////////////
	
    // Import shapefiles
    file building_shapefile <- file("../includes/buildings.shp");
    file road_shapefile <- file("../includes/roads.shp");
    // Create the geometric objects from shapefiles
    geometry shape <- envelope(building_shapefile);
    float step <- 5 #s;
    field cell <- field(300,300);
    
    float l0 <- 1/9;
    float l1 <- 1/69;
    
    
    ////////////////////////////////////////////////////////////////
    
    int current_hour update: int((cycle * step) / #hour) mod 24;
    string traffic_attribute update: "t" + string(current_hour);
    
    ////////////////////////////////////////////////////////////////
    
    init {
        // Create building agents from shapefile
        create building from: building_shapefile;
        // Create road agents from shapefile
        create road from: road_shapefile;
    }
    
    ////////////////////////////////////////////////////////////////
    
    reflex generate_cars {
        ask road {
        	if (cars_to_create >= 750) {
        		loop times: cars_to_create/750{
	        		create car {
		                location <- myself.shape.points[0]; // Start of the road
		                target <- myself.shape.points[length(myself.shape.points) - 1]; // End of the road
		                current_road <- myself;
	            	}
	        	}
        	}
        	else {
        		// Calculate how many steps we have in total (assuming simulation length)
	            float total_simulation_steps <- 750.0;  // You can adjust this value
	            
	            // Calculate probability of creating a car each step
	            float creation_probability <- cars_to_create / total_simulation_steps;
	            
	            // Use probability to determine if we should create a car this step
	            if (flip(creation_probability)) {
	                create car {
	                    location <- myself.shape.points[0];
	                    target <- myself.shape.points[length(myself.shape.points) - 1];
	                    current_road <- myself;
	                }
	            }
        	}
        }
    }
    
    ////////////////////////////////////////////////////////////////
    
    //Reflex to decrease and diffuse the pollution of the environment
	reflex pollution_evolution {
		//ask all cells to decrease their level of pollution
		cell <- cell * 0.8;
		
		matrix<float> mat_diff <- matrix([
		[l1,l1,l1,l1,l1],
		[l1,l0,l0,l0,l1],
		[l1,l0,l0,l0,l1],
		[l1,l0,l0,l0,l1],
		[l1,l1,l1,l1,l1]
		]);
	
		//diffuse the pollutions to neighbor cells
		diffuse var: pollution on: cell matrix: mat_diff;
	}
	
	////////////////////////////////////////////////////////////////
}

// Building species (passive)
species building {
    aspect default {
        draw shape color: #gray;
    }
}

// Road species
species road {
	int last_processed_hour <- -1;
	int cars_to_create;
	
	init {
		cars_to_create <- int(get('t0'));
	}
    
    reflex update_hour when: current_hour != last_processed_hour {
        cars_to_create <- int(get(traffic_attribute));
        last_processed_hour <- current_hour;
        
        write 'traffic attribute: ' + traffic_attribute;
    }
    
    aspect default {
        draw shape color: #black;
    }
}

// Car species
species car skills: [moving] {
    point target;
    road current_road;
    float speed <- 30 #km/#h;
    
    reflex move {
        do goto target: target speed: speed on: current_road;
        if location = target {
            do die;
        }
    }
    
    reflex pollute {
    	cell[location] <- cell[location] + 10;
    }
    
    aspect default {
        draw circle(3) color: #red;
    }
}

experiment traffic type: gui {
	list<rgb> pal <- palette([ #black, #green, #yellow, #orange, #orange, #red, #red, #red]);
	map<rgb,string> pollutions <- [#green::"Good",#yellow::"Average",#orange::"Bad",#red::"Hazardous"];
	
    output {
        display main_display {
            species building aspect: default;
            species road aspect: default;
            species car aspect: default;
            
            mesh cell scale: 9 triangulation: true transparency: 0.4 smooth: 3 above: 0.8 color: pal;
        }
    }
}
