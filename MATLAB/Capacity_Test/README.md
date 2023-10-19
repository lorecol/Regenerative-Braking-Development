# CAPACITY TEST


## Table of Contents
- [General information](#general-information)
- [How to use](#how-to-use)

## General information
This test is based on the [Battery Test Manual For Electric Vehicles](https://www.osti.gov/biblio/1186745).

**Theoretical notions**\
Charge and discharge rates of a battery are governed by C-rates. The capacity of a battery is commonly rated at 1C, meaning that a fully charged battery rated at 1Ah should provide 1A for one hour. The same battery discharging at 0.5C should provide 500mA for two hours, and at 2C it delivers 2A for 30 minutes.
This is true if the battery is new, otherwise when the battery is aged, i.e. it has undergone many life cycles, it suffers a decrease in capacity (simultaneously with an increase in internal resistance and self-discharge), in the sense that by applying the same current the battery discharges sooner.
In practice the battery behaves normally but has a short life, even when fully charged.

When discharging a battery with an instrument capable of applying different C rates, a higher C rate will produce a lower capacity reading and vice versa. By discharging the 1Ah battery at the faster 2C-rate, or 2A, the battery should ideally deliver the full capacity in 30 minutes. The sum should be the same since the identical amount of energy is dispensed over a shorter time. In reality, internal losses turn some of the energy into heat and lower the resulting capacity to about 95 percent or less. Discharging the same battery at 0.5C, or 500mA over 2 hours, will likely increase the capacity to above 100 percent.

**Goal**\
Measure the battery capacity in ampere-hours.

**Test conduction**\
A constant current discharge rate C/2 is applied to the battery. Discharge starts from a fully charged state and ends at a specified discharge voltage limit (Vlimlow), which represents the threshold beyond which the battery can be considered fully discharged.

**Capacity computation**\
The capacity is computed by multiplying the discharge current (in Amps) by the time (in hours) necessary to completely discharge the battery.\
**Note** that if the battery is discharged with a higher current, the discharge time will be shorter.

## How to use
- Connect the battery to the instrument.
- [Connect the instrument to the PC](../../DOCS/Keysight%20regenerative%20power%20supply/Interface_Connections.pdf)
- Run the Matlab script [mainCapacityTest.m](mainCapacityTest.m).
- The script will show the result of capacity computation in `Ah` in the command window.
- A .mat file is created in the output folder where the significant data and results are saved:
  - Data collected performing the test:
    - Time array (`s`)
    - Current array in (`A`)
    - Voltage array (`V`)
    - Time to discharge the battery (`s`)
  - Computed battery capacity (`Ah`)


## Authors
[Lorenzo Colturato](https://github.com/lorecol)\
[Paolo Furia](https://github.com/paolofuria99)


## License
This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details