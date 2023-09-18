# CAPACITY TEST


## Table of Contents
- [General information](#general-information)
- [Setup](#setup)
- [How to use](#how-to-use)

## General information
This test is based on the [Battery Test Manual For Electric Vehicles](https://www.osti.gov/biblio/1186745).\
In summary, this test measures device capacity in ampere-hours at a C/3 constant current discharge rate corresponding to the rated capacity. Discharge begins following a default rest from a fully-charged state to Vmax100 and is terminated on a manufacturer-specified discharge voltage limit (Vmin0), followed by a default rest at open-circuit voltage.\
Capacity is calculated by multiplying the discharge current (in Amps) by the discharge time (in hours) and decreases with increasing C-rate.

## Setup

## How to use
- Connect the device to the power supply and to the load.
- Connect the power supply to the PC through LAN.
- Run the matlab script [mainCapacityTest.m](mainCapacityTest.m) and follow the instructions.
- The script will show the capacity results in the command window in `Ah`
- The script will create an output folder (if it does not exist) and will save the voltage anf current data in a .mat file.


## Authors
[Lorenzo Colturato](https://github.com/lorecol)\
[Paolo Furia](https://github.com/paolofuria)


## License
This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details