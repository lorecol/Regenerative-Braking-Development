# Regenerative Braking Development
## Introduction
Development of the regenerative brake for UniTn Formula SAE


<img alt="Concept of regenerative braking" src="https://user-images.githubusercontent.com/81318686/203870797-333f265f-15d4-43d7-b862-97a1fa15ece7.png" width="70%">


## Organization of the repository:
- MATLAB: Matlab scripts and projects
	- REGENEREATION_GENERAL: Script to generate the regenerative brake model informations
	- HPPC_TEST: Script to generate the HPPC test
	- UNUSED_OTHER: Other scripts that are not used anymore or not used yet or not working or not finished
		- Battery Design: Script to generate a battery model 
		- MATLAB Tutorials Battery Design: BMS following the [tutorial](https://youtube.com/playlist?list=PLn8PRpmsu08pYXwR-qihN6abrK3Io97NN) 
- DOCS: Folder containg papers and documents 
	- PAPERS:
		- Regenerative brake: regenerative braking strategy and control
		- Battery: battery modeling, parameters identifications and State-of-Charge estimation 
	- BOOKS: books about vehicle dynamics and battery pack design
	- FENICE: Fenice engine and battery pack
		- Battery: Documents concerning the actual battery of Fenice 
		- Motor: Documents concerning the actual motor of Fenice
---
## Usefull stuff

### Matlab basics:
- **Generic battery model** can be found [here](https://www.mathworks.com/help/sps/powersys/ref/battery.html;jsessionid=84a6e893e970a46d6e4878e6924d)
- **E-mobility - Regenerative Braking - Off-shore Micro-grid** can be found [here](https://it.mathworks.com/matlabcentral/fileexchange/62092-e-mobility-regenerative-braking-off-shore-micro-grid)
- **Build full electric vehicle model** can be found [here](https://it.mathworks.com/help/autoblks/ug/explore-the-electric-vehicle-reference-application.html?searchHighlight=battery%20regenerative&s_tid=srchtitle_battery%20regenerative_5)
---
## Requirements
Matlab R2022b