# HPPC TEST

## Table of Contents
- [General information](#general-information)
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

## How to use
- Connect the battery to the instrument.
- [Connect the instrument to the PC](../../DOCS/Keysight_regenerative_power_supply/Interface_Connections.pdf).
- Run the Matlab script [mainHPPC.m](mainHPPC.m).
- A .txt file is created in the output folder where current and voltage data is saved
- A .mat file is created in the output folder where the significant data and results are saved:
  - Time array (`s`)
  - Current array (`A`)
  - Voltage array (`V`)
  - State-of-Charge array (`%`)
  - Battery capacity (`Ah`)
  - Current for charge pulse (`A`)
  - Current for discharge pulse (`A`)
  - Current for SoC discharge (`A`)
  - Battery configuration: number of parallels and series


## Authors
[Lorenzo Colturato](https://github.com/lorecol)\
[Paolo Furia](https://github.com/paolofuria99)


## License
This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details