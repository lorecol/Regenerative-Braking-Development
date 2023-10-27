%% Battery parameters

%% ModuleType1
ModuleType1.SOC_vecCell = fitData.SOC'; % Vector of state-of-charge values, SOC
ModuleType1.V0_vecCell = fitData.V0'; % Open-circuit voltage, V0(SOC), V
ModuleType1.V_rangeCell = [0, inf]; % Terminal voltage operating range [Min Max], V
ModuleType1.R0_vecCell = (fitData.R0_charge' + fitData.R0_discharge')/2; % Terminal resistance, R0(SOC), Ohm
ModuleType1.AHCell = cellCapacity; %Cell capacity, AH, A*hr
ModuleType1.R1_vecCell = fitData.R1'; % First polarization resistance, R1(SOC), Ohm
ModuleType1.tau1_vecCell = fitData.Tau1'; % First time constant, tau1(SOC), s
ModuleType1.R2_vecCell = fitData.R2'; % First polarization resistance, R1(SOC), Ohm
ModuleType1.tau2_vecCell = fitData.Tau2'; % First time constant, tau1(SOC), s

%% ParallelAssemblyType1
ParallelAssemblyType1.SOC_vecCell = [0, .1, .25, .5, .75, .9, 1]; % Vector of state-of-charge values, SOC
ParallelAssemblyType1.V0_vecCell = [3.5057, 3.566, 3.6337, 3.7127, 3.9259, 4.0777, 4.1928]; % Open-circuit voltage, V0(SOC), V
ParallelAssemblyType1.V_rangeCell = [0, inf]; % Terminal voltage operating range [Min Max], V
ParallelAssemblyType1.R0_vecCell = [.0085, .0085, .0087, .0082, .0083, .0085, .0085]; % Terminal resistance, R0(SOC), Ohm
ParallelAssemblyType1.AHCell = 27; % Cell capacity, AH, A*hr
ParallelAssemblyType1.R1_vecCell = [.0029, .0024, .0026, .0016, .0023, .0018, .0017]; % First polarization resistance, R1(SOC), Ohm
ParallelAssemblyType1.tau1_vecCell = [36, 45, 105, 29, 77, 33, 39]; % First time constant, tau1(SOC), s
ParallelAssemblyType1.R2_vecCell = [.0029, .0024, .0026, .0016, .0023, .0018, .0017]; % Second polarization resistance, R2(SOC), Ohm
ParallelAssemblyType1.tau2_vecCell = [36, 45, 105, 29, 77, 33, 39]; % Second time constant, tau2(SOC), s
