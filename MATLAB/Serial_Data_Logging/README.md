# SERIAL DATALOG

## Table of Contents
- [General information](#general-information)
- [How to use](#how-to-use)

## General information

**Functioning**\
Record voltage and temperature data from a block of cells (i.e. a series of three modules, which are four cells in parallel) via a microcontroller connected to it, which samples with a frequency of 10 Hz. The microcontroller provides three voltage measurements (for the 3 parallels in the configuration) and four temperature measurements, which are carried out through NTC sensors.

**Goal**\
Record temperature and voltage data for a 3s4p battery configuration via a microcontroller.

## How to use
- Connect the battery to the instrument.
- [Connect the instrument to the PC](../../DOCS/Keysight_regenerative_power_supply/Interface_Connections.pdf).
- Run the Matlab script [mainSerialDataLog.m](mainSerialDataLog.m).
- A .txt file is created in the output folder where data is saved:
  - Four measures of temperature (`°C`)
  - Three measures of voltage (`V`)


## Authors
[Lorenzo Colturato](https://github.com/lorecol)\
[Paolo Furia](https://github.com/paolofuria99)


## License
This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details