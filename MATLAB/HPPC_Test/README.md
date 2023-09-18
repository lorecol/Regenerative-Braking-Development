# HPPC TEST 

## Table of Contents
- [General information](#general-information)
- [Setup](#setup)
- [How to use](#how-to-use)

## General information
The HPPC script is based on the [Battery Test Manual For Electric Vehicles](https://www.osti.gov/biblio/1186745).

In summary, as said in the document, the Hybrid Pulse Power Characterization (HPPC) Test is intended to determine dynamic power capability over the device’s useable voltage range using a test profile that incorporates both discharge and 
regen pulses. The first step of this test is to establish, as a function of capacity removed (a) the $Vmin_{pulse}$ discharge power capability at the end of a 30-s discharge current pulse and (b) the $Vmax_{pulse}$ regen power  capability at the end of a 10-s regen current pulse. These power and energy capabilities are then used to derive other performance characteristics such as Peak Power and Available Energy. Additional data from the HPPC test include the voltage response curves, from which the fixed (ohmic) cell resistance and cell polarization resistance as a function of capacity removed can be determined assuming sufficient resolution to reliably establish cell voltage response time constants during discharge, rest, and regen operating regimes. These data can be used to evaluate resistance degradation during subsequent life testing and to develop hybrid battery performance models for vehicle systems analysis.

The power supply used for the test is the [Keysight RP7963A](docs/RP7900_RegenerativePowerSystem_Datasheet.pdf) which has the following specifications:
|Specifications|Value|
|----|----|
|*Voltage programming*|
|Range |0 to 950V|
|Resolution | 21mV|
|*Current Programming*|
|Range |0 to ±20A|
|Resolution | 190µA|
|*Resistance Programming*|
|Range |0 to 50Ω|
|Resolution| 280 µΩ|

TODO: Finish the description of the test with specifications and results and C-Rate definitions


## Setup
- Install the instruments [IO libraries](https://www.keysight.com/it/en/lib/software-detail/computer-software/io-libraries-suite-downloads-2175637.html)
- Use the program "Keysight Connection Expert" to connect to the power supply through LAN


## How to use
- Connect through LAN to the power supply 
- Excecute the matlab script [mainHPPC.m](mainHPPC.m) and follow the instructions on the command window
- The script will save the voltage and current data in the folder "output"


## Authors
[Lorenzo Colturato](https://github.com/lorecol)\
[Paolo Furia](https://github.com/paolofuria)


## License
This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details