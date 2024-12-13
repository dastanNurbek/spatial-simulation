# Order of execution in GAMA model

&ensp; The aim of the exercise is to understand in what order the given GAMA model code executes. This report explains the model’s structure and order of execution by answering questions.

<br />

## &ensp; 1.	Initialization 

### 1.1.	Why has the “CA variable” a value of 2 in time step 0? 
Since the variable already was equal to 1, after initialization its value increased by 1 making grid_var = 2. 
```java
int grid_var <- 1 update: grid_var + 1;

init{
  grid_var <- grid_var + 1;
  write "CA variable: " + grid_var;
}
```

### 1.2.	Why is the exact same information displayed several times for the agents and the CA? 
There are multiple instances of each agent created as shown in the code.
```java
create agent_B number: 3;  
create agent_A number: 5;    
create agent_C number: 2;  
```
As for the grid CA, it has 4 cells, 2 rows and 2 columns.
```java
grid CA width: 2 height: 2 
```

### 1.3.	Why is the “Agent_A variable from global” different from the Agent_A variables reported before?
The global block accesses the first instance of agent A, increases its variable value by 1, and prints the result.
```java
ask agent_A[0] {
  agent_A_var <- agent_A_var + 1;
  write "Agent A variable from global: " + agent_A_var;
}
```

### 1.4.	What is the order of Agent variables reported? Can this order be explained?
During the initialization the grid is initialized first, only then, in the global block, the agents are created which report their initial variable values. (grid -> B -> A -> C)

### 1.5.	What is the order of execution for the initialization?
Time step is printed, followed by the global variable value. After that, the agents are initialized. Finally, the first agent of species A is called, incremented, and the value is printed.
```java
init {
  write "time step:" + cycle;
    write "global variable: " + glob_var;
    create agent_B number: 3;  
    create agent_A number: 5;    
    create agent_C number: 2;  
    ask agent_A[0] {
      agent_A_var <- agent_A_var + 1;
        write "Agent A variable from global: " + agent_A_var;
  }
}
```

<br />

## &ensp; 2.	After 1 cycle

### 2.1.	What is the order of execution at the first step? Does it differ from the initialization?
The order at the next follows the order of declaration. Therefore, global functions (reflexes) are executed first, followed by agent functions, and grid functions at the end.

### 2.2.	Why is the order of agents different, now?
The order of agents is different because during initialization B-s was created first, then A-s and C-s (see question 1.2) However, after initialization the code executes in the order of declaration, thus changing the order.

### 2.3.	Why does one of the Agent_A variables have a value of 3, instead of value 2? 
As discussed in question 1.3, during initialization the first instance of A has been accessed and incremented by 1. 

### 2.4.	Why does one of the CA variables now differ from the others?
global_reflex_4 will assign a random number from 0 to 100 every step.
```java
reflex global_reflex_4 {
  ask CA[0] {
    grid_var <- int(rnd(100));
  } 
} 
```

### 2.5.	Have a look at how reflexes represent the behaviour of Agents in agent_B and agent_C: Is there any difference in the output? What is the better code design?
Since agents B and agents C have the exact same reflexes, they can be combined into one species. 

<br />

## &ensp; 3.	Editing the code

### 3.1.	To have a different initial value for each individual agent:

### &ensp; 3.1.1.	Agent_A should have the values 1, 2, 3, 4 and 5.
In the init{} of global{},  we can include a loop that adds from 0 to 4 to the agent A variables in the respective positions. 
```java
loop i from: 0 to: 4 { 
  ask agent_A[i] {
    agent_A_var <- agent_A_var + i;
    write "Agent A variable from global: " + agent_A_var;
	}
}
```

### &ensp; 3.1.2.	Each Agent_B should have an individual, random integer value between 2 and 6.
The same way as in 3.1.1, we can access the B agents variable from global initialization, and then assign a random number between 2 and 6 using rnd().
```java
ask agent_B {
  agent_B_var <- rnd(2,6);
  	write "Agent B variable from global: " + agent_B_var;
}
```

### &ensp; 3.1.3.	Each Agent_C should have the same float value of 0.0.
Same goes for agents C, except first the variable type must be changed to float.
```java
ask agent_C {
	agent_C_var <- 0.0;
	write "Agent C variable from global: " + agent_C_var;
}
```

### 3.2.	To have initial cell values that equal their x coordinate value.
To achieve this, the grid_x can be assigned to the cell variable inside the ‘grid’ block.
```java
init{
  grid_var <- grid_x;
    write "CA variable: " + grid_var;
}
```

### 3.3.	To increment the values of all variables with 2 units per time step.
We could create a global reflex that asks each agent’s variable to increment by 2, as shown in the example for agents A.
```java
reflex increment_vars {
  ask agent_A {
    agent_A_var <- agent_A_var + 2;
  }
}
```

### 3.4.	Increment values using update facets only.
Otherwise, same can be done using ‘update’ in the respective blocks.
```java
int agent_A_var <- 1 update: agent_A_var + 2;
```

<br />
<br />

&ensp; The order of code execution in a GAMA model has been observed. Specifically, during initialization, if there is a grid, it 
is created first, followed by agents and their own init{} functions. However, after each step the order of execution is based 
on the order of declaration. Changes to variables can be made locally (reflexes or update facet) or by accessing them in a global block using ask{}.  
