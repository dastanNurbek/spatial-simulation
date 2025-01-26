/**
* Name: Traffic
* Description: simulates traffic emissions in Paris
* Author: Dastan Nurbekuly
* Tags: traffic, air pollution
*/

model Traffic

global {
    // Import shapefiles and create geometries
    file building_shapefile <- file("../includes/buildings.shp");
    file road_shapefile <- file("../includes/roads.shp");
    file station_shapefile <- file("../includes/stations.shp");
    geometry shape <- envelope(building_shapefile);
    
    // Set up global simulation variables
    float step <- 5 #s;
    field cell <- field(300,300);
    float steps_in_hour <- 3600/step;
    float l0 <- 1/9;						// Matrix weights
    float l1 <- 1/69;						// Matrix weights (outer layer)
    float decay_rate <- 0.8;
    matrix<float> mat_diff <- matrix([
		[l1,l1,l1,l1,l1],
		[l1,l0,l0,l0,l1],
		[l1,l0,l0,l0,l1],					// Diffusion matrix
		[l1,l0,l0,l0,l1],
		[l1,l1,l1,l1,l1]
	]);
	list<float> wind_speed <- [				// Wind speed for each hour
		0.0, // 00:00
		0.0, // 01:00
		0.0, // 02:00
		0.0, // 03:00
		0.0, // 04:00
		0.0, // 05:00
		2.0, // 06:00
		0.0, // 07:00
		0.0, // 08:00
		2.0, // 09:00
		3.0, // 10:00
		2.0, // 11:00
		5.0, // 12:00
		5.0, // 13:00
		7.0, // 14:00
		7.0, // 15:00
		3.0, // 16:00
		7.0, // 17:00
		3.0, // 18:00
		5.0, // 19:00
		6.0, // 20:00
		5.0, // 21:00
		5.0, // 22:00
		7.0  // 23:00
	];
	float current_wind_speed <- 0.0;
	bool wind <- false;
	bool dynamic_speed <- false;
	float pollution_rate <- 10.0;
    
    // Set up traffic count attribute according to current hour
    int current_hour update: int((cycle * step) / #hour) mod 24;
    string traffic_attribute update: "t" + string(current_hour+1);
    
    
    // Initialization
    init {
        // Create building agents from shapefile
        create building from: building_shapefile;
        // Create road agents from shapefile
        create road from: road_shapefile;
        // Create stations from shapefile
        create station from: station_shapefile;
    }
    
    // Ask road to create vehicles
    reflex generate_cars {
        ask road {
        	if (cars_to_create >= steps_in_hour) { 			// More than one car per step
        		loop times: cars_to_create/steps_in_hour{
	        		create car {
		                location <- myself.shape.points[0]; // Start of the road
		                target <- myself.shape.points[length(myself.shape.points) - 1]; // End of the road
		                current_road <- myself;
	            	}
	        	}
        	}
        	else {											//Less than one car per step
	            // Calculate probability of creating a car each step
	            float creation_probability <- cars_to_create / steps_in_hour;
	            
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
    
    //Reflex to decrease and diffuse the pollution 
	reflex pollution_evolution {
		// Update wind speed
		current_wind_speed <- wind_speed[current_hour];
		
		// Ask all cells to decrease their level of pollution
		if wind {
			cell <- cell * (decay_rate);
		}
		else{
			cell <- cell * (decay_rate - current_wind_speed*0.002);
		}
	
		// Diffuse the pollutions to neighbor cells
		diffuse var: pollution on: cell matrix: mat_diff;
	}
	
	// Stop simulation after 23 hours
	reflex stop_simulation when: cycle > (23*60*60)/step {
        do pause ;
    }
}

// Station species
species station {
	float pollution_level;
	float radius <- 20.0;
	
	// For recording pollution levels
	reflex update_pollution_level {
		pollution_level <- cell[location];
	}
	
	aspect default {
		draw shape+radius+1 color: #black;
		draw shape+radius color: #yellow;
	}
}

// Building species
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
    
    // Update number of cars needed to create each hour
    reflex update_hour when: current_hour != last_processed_hour {
        cars_to_create <- int(get(traffic_attribute));
        last_processed_hour <- current_hour;
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
    	// If traffic count affects speed
    	if dynamic_speed {
    		if current_road.cars_to_create > 500 {
	    		speed <- 15 #km/#h;
	    	}
	    	else {
	    		speed <- 30 #km/#h;
	    	}
    	}
    	else{
    		speed <- 30 #km/#h;
    	}
    	
        do goto target: target speed: speed on: current_road;
        if location = target {
            do die;
        }
    }
    
    reflex pollute {
    	cell[location] <- cell[location] + pollution_rate;
    }
    
    aspect default {
        draw circle(3) color: #red;
    }
}

experiment traffic type: gui {
	list<rgb> pal <- palette([ #black, #green, #yellow, #orange, #orange, #red, #red, #red]);
	map<rgb,string> pollutions <- [#green::"Good",#yellow::"Average",#orange::"Bad",#red::"Hazardous"];
	
	parameter "Add wind" var: wind;
	parameter "Traffic affects speed" var: dynamic_speed;
	parameter "Pollution rate" var: pollution_rate min: 5.0 max: 15.0 step: 0.3;
	
	/*reflex save_data{ 
		save [cycle, station[0].pollution_level,station[1].pollution_level,station[2].pollution_level] 
		to: "../results/fourteenth_run_5s_pol10_wind0_nospeed.csv" format: "csv" rewrite:false header:true;
	}*/
	
    output {
    	monitor "Number of Cars" value: length(car);
    	monitor "Pl. de l'Opera" value: station[0].pollution_level;
    	monitor "Bvd. Haussman" value: station[1].pollution_level;
    	monitor "Paris 1er les Halles" value: station[2].pollution_level;
    	
    	layout #split;
    	
        display map {
            species building aspect: default;
            species road aspect: default;
            species car aspect: default;
            species station aspect: default;
            
            mesh cell scale: 9 triangulation: true transparency: 0.4 smooth: 3 above: 0.8 color: pal;
        }
       	
       	display pollution_chart {
       		chart 'Pollution levels from traffic' type: series {
				data "Pl. de l'Opera" value: station[0].pollution_level color: #red;
				data "Bvd. Haussman" value: station[1].pollution_level color: #blue;
				data "Paris 1er les Halles" value: station[2].pollution_level color: #green;
			}
       	}
    }
}
