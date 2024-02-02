# Battery Characterization for Regenerative Braking Development
## Introduction
Development of a Battery Model for regenerative brake for UniTn Formula SAE. Season 2023/2024


<img alt="Concept of regenerative braking" src="https://user-images.githubusercontent.com/81318686/203870797-333f265f-15d4-43d7-b862-97a1fa15ece7.png" width="70%">

## Organization of the repository:
- [CELL_HOLDER](CELL_HOLDER/): Contains the step files of the battery cell holder used during single cell testing
- [MATLAB](MATLAB/): Matlab scripts and projects
	- [Max_Regen_Curr](MATLAB/Max_Regen_Curr/): Coarse estimation of the maximum current entering the battery pack during a braking stop
 	- [CCCVCharge](MATLAB/CCCVCharge/): Script to charge the battery 
 	- [CapacityTest](MATLAB/CapacityTest/): Script to perform a battery capacity test 
	- [HPPCTest](MATLAB/HPPCTest/): Script to generate the HPPC test
 	- [Parameter_Identification](MATLAB/Parameter_Identification/): Script used to characterize and validate the battery model 	
	- [UNUSED_OTHER](MATLAB/UNUSED_OTHER/): Other scripts that are not used anymore or not used yet or not working or not finished
 		- TRACK_DATA: Script to extrapolate data from the track data
		- Battery Design: Script to generate a battery model 
		- MATLAB Tutorials Battery Design: BMS following the [tutorial](https://youtube.com/playlist?list=PLn8PRpmsu08pYXwR-qihN6abrK3Io97NN)
  		- etc.. 
- [DOCS](DOCS/): Folder containg all the useful papers and documents 
	- [Papers](DOCS/Papers/): Useful articles found online
		- Regenerative brake: regenerative braking strategy and control
		- Battery: battery modeling, parameters identifications and State-of-Charge estimation 
	- [Keysight_regenerative_power_supply](DOCS/Keysight_regenerative_power_supply/): Documents related to the instrument used for cell characterization
	- [Fenice](DOCS/Fenice/): Fenice engine and battery pack
		- Battery: Documents concerning the actual battery of Fenice 
		- Motor: Documents concerning the actual motor of Fenice

---
## Requirements
- Matlab R2022b
- Simulink
- Simscape
- Simscape Battery
- Curve Fitting Toolbox
- Instrument Control Toolbox
- Symbolic Math Toolbox
