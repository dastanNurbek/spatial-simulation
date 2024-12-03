# Reporting demographic data of the lion population with help of lists
## Introduction
The aim of this experiment is to understand how lists work in GAML. This simulation model represents 
the age demographic changes in a lion pride consisting of 20 lions. By using lists, the statistics can 
be calculated and displayed conveniently.
## Methods
During the initialization process, lions' ages range randomly from 0 to 60, then increment by 1 each time step. 
```java
int age <- rnd(0, 60) update: age + 1;
```
To keep the same number of agents, lions over the age of 60 get teleported to a random location withing the grid, age 
is set to 0, thus simulating the birth of new lions.
```java
reflex die_old {
  if (age >= 60){
    location <- {rnd(100),rnd(100)}; // changes position
    age <- 0; // sets age to 0
    lion_ages[index] <- age; // updates the list
    mean_ages <- mean(lion_ages); // updates the mean value
  }
}
```
This is done to avoid errors associated with the length of lists, or when calculating the mean of ages. The lions’ ages are updated using index.
```java
reflex update_list {
  lion_ages[index] <- age;
  mean_ages <- mean(lion_ages);
}
```
## Results
a)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
b)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
c)
<div style="flex">
  <img src="../Models/Week2/models/snapshots/LionAge_model_display_map_cycle_1_time_1729538568771.png" alt="drawing" width="300"/>
  <img src="../Models/Week2/models/snapshots/LionAge_model_display_map_cycle_15_time_1729538820792.png" alt="drawing" width="300"/>
  <img src="../Models/Week2/models/snapshots/LionAge_model_display_map_cycle_31_time_1729538932717.png" alt="drawing" width="300"/>
</div>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Figure 1. Visualization of lion age means over time. (a) time step: 0, 
mean: 28.35. (b) time step: 15, mean: 34.3. (c) time step: 30, mean: 28.3. \
\
According to Fig. 1, the mean age change is clearly following a periodic pattern of about 15-time steps.  However, the 
observed fluctuations can only be relevant to this specific run because of assigning random ages in the beginning. 

## Discussion 
In this model only the age demographic changes of lions can be observed. Though it is an important experiment, 
the model can be further adjusted to create a much more realistic simulation. 
