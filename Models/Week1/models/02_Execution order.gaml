/**
* Model:        OrderOfExecution
* Author:       Gudrun Wallentin
* Description:  This model demonstrates the order of execution of different parts of a GAMA model.
*/
model OrderOfExecution


global
{
    int glob_var <- 1;
    
    init {
    	write "time step:" + cycle;
        write "global variable: " + glob_var;
        create agent_B number: 3;  
        create agent_A number: 5;    
        create agent_C number: 2;  
        loop i from: 0 to: 4 { 
		    ask agent_A[i] {
		    	agent_A_var <- agent_A_var + i;
		    	write "Agent A variable from global: " + agent_A_var;
		    }
		}
		ask agent_B {
			agent_B_var <- rnd(2,6);
			write "Agent B variable from global: " + agent_B_var;
		}
		ask agent_C {
			agent_C_var <- 0.0;
			write "Agent C variable from global: " + agent_C_var;
		}
    }
    reflex global_reflex_1 {
    	write "time step:" + cycle;
    }

    reflex global_reflex_2 {
        glob_var <- glob_var + 1;       
    }
    reflex global_reflex_3 {
        write "global variable: " + glob_var;
    }  
    reflex global_reflex_4 {
        ask CA[0] {
        	grid_var <- int(rnd(100));
        } 
    }
    reflex increment_vars {
    	ask agent_A {
    		agent_A_var <- agent_A_var + 1;
    	}
    }
}

species agent_A {
    int agent_A_var <- 1 update: agent_A_var + 2;

    init {
        write "Agent_A variable: " + agent_A_var;
    }    
    reflex reflex_A1 {
        write "Agent_A variable: " + agent_A_var;
    }     
}

species agent_B {
    int agent_B_var <- 1;

    init {
        write "Agent_B variable: " + agent_B_var; 
    }

    reflex reflex_B1 {
        agent_B_var <- agent_B_var + 1;
        write "Agent_B variable: " + agent_B_var;     	
    }   
}

species agent_C {
    float agent_C_var <- 1.0;

    init {
        write "Agent_C variable: " + agent_C_var; 
    }

    reflex reflex_C1 {
        agent_C_var <- agent_C_var + 1;
    } 
    reflex reflex_C2 {
        write "Agent_C variable: " + agent_C_var;     	
    }
}

grid CA width: 2 height: 2{
    int grid_var <- 1 update: grid_var + 2;
    
    init{
    	grid_var <- grid_x;
        write "CA variable: " + grid_var;
    }

    reflex reflexA{
    	grid_var <- grid_var + 1;
        write "CA variable: " + grid_var;
    }
}


experiment OrderOfExecution type: gui {

}