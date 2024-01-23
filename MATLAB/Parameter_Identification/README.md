# PARAMETER IDENTIFICATION & VALIDATION


## Table of Contents
- [General information](#general-information)
- [Setup](#setup)
- [How to use](#how-to-use)

## General information
2 scripts are available in this folder:
- `parameter_identification.m`
    This script is used to characterize the equivalent model of the battery, i.e. to find the significant parameters, such as the RC branches, the internal resistance of the battery and the Open Circuit Voltage (OCV). All parameters are expressed as a function of the State-of-Charge of the battery and are found by fitting the data obtained from specific tests carried out on the battery with the equivalent model of the battery itself.
    The script requires data collected from the battery during an HPPC test, in order to detect the charge/discharge impulses and the drop voltages during the discharge phase. \
    The script is based on the Matlab Example "Battery Cell Characterization" but some functions has been changed/added to perform better data fitting and pulses recognition. The example can be found [here](https://www.mathworks.com/help/simscape-battery/ug/battery-cell-characterization-for-ev.html)\
    The results obtained are stored in the [output folder](output) 
- `parameter_validation.m`: 
    This script is used to validate the data obtained from the battery characterisation. First of all, it is therefore necessary to parameterise the cell/block via the file 'battery_characterisation.m'. The results obtained (saved in the "output/" folder) are then used to recreate the entire battery pack via Matlab Simulink using the "Battery Builder" tool. The model is then saved in the [src/](src) folder and a corresponding subfolder named "batteryModel{...}" is created. \
    Four type of battery model has been created: 
    - From the Block (3s4p) with 1RC and 2RC
    - From Cell (1s1p) with 1RC and 2RC. 

    For the script to work, it is necessary to have telemetry data for current (hw_current) and voltage (hw_voltage) within the [src/loadProfiles/](src/loadProfiles/) folder. This is done to compare the results of the simulated and real battery. \
    The simulated battery pack is current controlled and the voltage at the ends is measured. The voltage is then compared with the 'original' voltage from the telemetry.


## Setup
TODO
## How to use
TODO
## Authors
[Lorenzo Colturato](https://github.com/lorecol)\
[Paolo Furia](https://github.com/paolofuria99)


## License
This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details