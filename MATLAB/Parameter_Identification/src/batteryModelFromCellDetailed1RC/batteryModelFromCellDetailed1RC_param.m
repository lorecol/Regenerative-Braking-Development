%% Battery parameters

%% ModuleType1
ModuleType1.SOC_vecCell = fitData.SOC'; % Vector of state-of-charge values, SOC
ModuleType1.V0_vecCell = fitData.V0'; % Open-circuit voltage, V0(SOC), V
ModuleType1.V_rangeCell = [0, inf]; % Terminal voltage operating range [Min Max], V
ModuleType1.R0_vecCell = (fitData.R0_charge' + fitData.R0_discharge')/2; % Terminal resistance, R0(SOC), Ohm
ModuleType1.AHCell = cellCapacity; % Cell capacity, AH, A*hr
ModuleType1.R1_vecCell = fitData.R1'; % First polarization resistance, R1(SOC), Ohm
ModuleType1.tau1_vecCell = fitData.Tau1'; % First time constant, tau1(SOC), s

%% ParallelAssemblyType1
ParallelAssemblyType1.SOC_vecCell = fitData.SOC'; % Vector of state-of-charge values, SOC
ParallelAssemblyType1.V0_vecCell = fitData.V0'; % Open-circuit voltage, V0(SOC), V
ParallelAssemblyType1.V_rangeCell = [0, inf]; % Terminal voltage operating range [Min Max], V
ParallelAssemblyType1.R0_vecCell = (fitData.R0_charge' + fitData.R0_discharge')/2; % Terminal resistance, R0(SOC), Ohm
ParallelAssemblyType1.AHCell = cellCapacity; % Cell capacity, AH, A*hr
ParallelAssemblyType1.R1_vecCell = fitData.R1'; % First polarization resistance, R1(SOC), Ohm
ParallelAssemblyType1.tau1_vecCell = fitData.Tau1'; % First time constant, tau1(SOC), s
