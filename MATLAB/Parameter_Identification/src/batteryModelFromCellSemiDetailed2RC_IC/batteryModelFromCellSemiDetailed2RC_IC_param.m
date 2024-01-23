%% Battery parameters

%% ModuleType1
ModuleType1.SOC_vecCell = fitData.SOC'; % Vector of state-of-charge values, SOC
ModuleType1.V0_vecCell = fitData.V0'; % Open-circuit voltage, V0(SOC), V
ModuleType1.V_rangeCell = [0, inf]; % Terminal voltage operating range [Min Max], V
ModuleType1.R0_vecCell = (fitData.R0_charge' + fitData.R0_discharge')/2; % Terminal resistance, R0(SOC), Ohm
ModuleType1.AHCell = cellCapacity*4; %Cell capacity, AH, A*hr
ModuleType1.R1_vecCell = fitData.R1'; % First polarization resistance, R1(SOC), Ohm
ModuleType1.tau1_vecCell = fitData.Tau1'; % First time constant, tau1(SOC), s
ModuleType1.R2_vecCell = fitData.R2'; % First polarization resistance, R1(SOC), Ohm
ModuleType1.tau2_vecCell = fitData.Tau2'; % First time constant, tau1(SOC), s

%% ParallelAssemblyType1
ParallelAssemblyType1.SOC_vecCell = fitData.SOC'; % Vector of state-of-charge values, SOC
ParallelAssemblyType1.V0_vecCell = fitData.V0'; % Open-circuit voltage, V0(SOC), V
ParallelAssemblyType1.V_rangeCell = [0, inf]; % Terminal voltage operating range [Min Max], V
ParallelAssemblyType1.R0_vecCell = (fitData.R0_charge' + fitData.R0_discharge')/2; % Terminal resistance, R0(SOC), Ohm
ParallelAssemblyType1.AHCell = cellCapacity*4; % Cell capacity, AH, A*hr
ParallelAssemblyType1.R1_vecCell =fitData.R1'; % First polarization resistance, R1(SOC), Ohm
ParallelAssemblyType1.tau1_vecCell = fitData.Tau1'; % First time constant, tau1(SOC), s
ParallelAssemblyType1.R2_vecCell = fitData.R2'; % Second polarization resistance, R2(SOC), Ohm
ParallelAssemblyType1.tau2_vecCell = fitData.Tau2'; % Second time constant, tau2(SOC), s

%% Battery initial targets

%% ModuleAssembly2.Module2
ModuleAssembly2.Module2.iCell = 0; % Cell current (positive in), A
ModuleAssembly2.Module2.vCell = 0; % Cell terminal voltage, V
ModuleAssembly2.Module2.socCell = initialSOC; % Cell state of charge
ModuleAssembly2.Module2.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly2.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module3
ModuleAssembly2.Module3.iCell = 0; % Cell current (positive in), A
ModuleAssembly2.Module3.vCell = 0; % Cell terminal voltage, V
ModuleAssembly2.Module3.socCell = initialSOC; % Cell state of charge
ModuleAssembly2.Module3.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly2.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module4
ModuleAssembly2.Module4.iCell = 0; % Cell current (positive in), A
ModuleAssembly2.Module4.vCell = 0; % Cell terminal voltage, V
ModuleAssembly2.Module4.socCell = initialSOC; % Cell state of charge
ModuleAssembly2.Module4.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly2.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module5
ModuleAssembly2.Module5.iCell = 0; % Cell current (positive in), A
ModuleAssembly2.Module5.vCell = 0; % Cell terminal voltage, V
ModuleAssembly2.Module5.socCell = initialSOC; % Cell state of charge
ModuleAssembly2.Module5.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly2.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module6
ModuleAssembly2.Module6.iCell = 0; % Cell current (positive in), A
ModuleAssembly2.Module6.vCell = 0; % Cell terminal voltage, V
ModuleAssembly2.Module6.socCell = initialSOC; % Cell state of charge
ModuleAssembly2.Module6.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly2.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.NewModule
ModuleAssembly2.NewModule.iCell = 0; % Cell current (positive in), A
ModuleAssembly2.NewModule.vCell = 0; % Cell terminal voltage, V
ModuleAssembly2.NewModule.socCell = initialSOC; % Cell state of charge
ModuleAssembly2.NewModule.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly2.NewModule.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.NewModule.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module2
ModuleAssembly3.Module2.iCell = 0; % Cell current (positive in), A
ModuleAssembly3.Module2.vCell = 0; % Cell terminal voltage, V
ModuleAssembly3.Module2.socCell = initialSOC; % Cell state of charge
ModuleAssembly3.Module2.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly3.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module3
ModuleAssembly3.Module3.iCell = 0; % Cell current (positive in), A
ModuleAssembly3.Module3.vCell = 0; % Cell terminal voltage, V
ModuleAssembly3.Module3.socCell = initialSOC; % Cell state of charge
ModuleAssembly3.Module3.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly3.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module4
ModuleAssembly3.Module4.iCell = 0; % Cell current (positive in), A
ModuleAssembly3.Module4.vCell = 0; % Cell terminal voltage, V
ModuleAssembly3.Module4.socCell = initialSOC; % Cell state of charge
ModuleAssembly3.Module4.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly3.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module5
ModuleAssembly3.Module5.iCell = 0; % Cell current (positive in), A
ModuleAssembly3.Module5.vCell = 0; % Cell terminal voltage, V
ModuleAssembly3.Module5.socCell = initialSOC; % Cell state of charge
ModuleAssembly3.Module5.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly3.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module6
ModuleAssembly3.Module6.iCell = 0; % Cell current (positive in), A
ModuleAssembly3.Module6.vCell = 0; % Cell terminal voltage, V
ModuleAssembly3.Module6.socCell = initialSOC; % Cell state of charge
ModuleAssembly3.Module6.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly3.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.NewModule
ModuleAssembly3.NewModule.iCell = 0; % Cell current (positive in), A
ModuleAssembly3.NewModule.vCell = 0; % Cell terminal voltage, V
ModuleAssembly3.NewModule.socCell = initialSOC; % Cell state of charge
ModuleAssembly3.NewModule.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly3.NewModule.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.NewModule.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module2
ModuleAssembly4.Module2.iCell = 0; % Cell current (positive in), A
ModuleAssembly4.Module2.vCell = 0; % Cell terminal voltage, V
ModuleAssembly4.Module2.socCell =initialSOC; % Cell state of charge
ModuleAssembly4.Module2.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly4.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module3
ModuleAssembly4.Module3.iCell = 0; % Cell current (positive in), A
ModuleAssembly4.Module3.vCell = 0; % Cell terminal voltage, V
ModuleAssembly4.Module3.socCell = initialSOC; % Cell state of charge
ModuleAssembly4.Module3.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly4.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module4
ModuleAssembly4.Module4.iCell = 0; % Cell current (positive in), A
ModuleAssembly4.Module4.vCell = 0; % Cell terminal voltage, V
ModuleAssembly4.Module4.socCell = initialSOC; % Cell state of charge
ModuleAssembly4.Module4.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly4.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module5
ModuleAssembly4.Module5.iCell = 0; % Cell current (positive in), A
ModuleAssembly4.Module5.vCell = 0; % Cell terminal voltage, V
ModuleAssembly4.Module5.socCell =initialSOC; % Cell state of charge
ModuleAssembly4.Module5.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly4.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module6
ModuleAssembly4.Module6.iCell = 0; % Cell current (positive in), A
ModuleAssembly4.Module6.vCell = 0; % Cell terminal voltage, V
ModuleAssembly4.Module6.socCell = initialSOC; % Cell state of charge
ModuleAssembly4.Module6.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly4.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.NewModule
ModuleAssembly4.NewModule.iCell = 0; % Cell current (positive in), A
ModuleAssembly4.NewModule.vCell = 0; % Cell terminal voltage, V
ModuleAssembly4.NewModule.socCell =initialSOC; % Cell state of charge
ModuleAssembly4.NewModule.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly4.NewModule.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.NewModule.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module2
ModuleAssembly5.Module2.iCell = 0; % Cell current (positive in), A
ModuleAssembly5.Module2.vCell = 0; % Cell terminal voltage, V
ModuleAssembly5.Module2.socCell = initialSOC; % Cell state of charge
ModuleAssembly5.Module2.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly5.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module3
ModuleAssembly5.Module3.iCell = 0; % Cell current (positive in), A
ModuleAssembly5.Module3.vCell = 0; % Cell terminal voltage, V
ModuleAssembly5.Module3.socCell = initialSOC; % Cell state of charge
ModuleAssembly5.Module3.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly5.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module4
ModuleAssembly5.Module4.iCell = 0; % Cell current (positive in), A
ModuleAssembly5.Module4.vCell = 0; % Cell terminal voltage, V
ModuleAssembly5.Module4.socCell = initialSOC; % Cell state of charge
ModuleAssembly5.Module4.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly5.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module5
ModuleAssembly5.Module5.iCell = 0; % Cell current (positive in), A
ModuleAssembly5.Module5.vCell = 0; % Cell terminal voltage, V
ModuleAssembly5.Module5.socCell = initialSOC; % Cell state of charge
ModuleAssembly5.Module5.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly5.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module6
ModuleAssembly5.Module6.iCell = 0; % Cell current (positive in), A
ModuleAssembly5.Module6.vCell = 0; % Cell terminal voltage, V
ModuleAssembly5.Module6.socCell = initialSOC; % Cell state of charge
ModuleAssembly5.Module6.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly5.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.NewModule
ModuleAssembly5.NewModule.iCell = 0; % Cell current (positive in), A
ModuleAssembly5.NewModule.vCell = 0; % Cell terminal voltage, V
ModuleAssembly5.NewModule.socCell = initialSOC; % Cell state of charge
ModuleAssembly5.NewModule.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly5.NewModule.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.NewModule.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module2
ModuleAssembly6.Module2.iCell = 0; % Cell current (positive in), A
ModuleAssembly6.Module2.vCell = 0; % Cell terminal voltage, V
ModuleAssembly6.Module2.socCell = initialSOC; % Cell state of charge
ModuleAssembly6.Module2.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly6.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module3
ModuleAssembly6.Module3.iCell = 0; % Cell current (positive in), A
ModuleAssembly6.Module3.vCell = 0; % Cell terminal voltage, V
ModuleAssembly6.Module3.socCell = initialSOC; % Cell state of charge
ModuleAssembly6.Module3.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly6.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module4
ModuleAssembly6.Module4.iCell = 0; % Cell current (positive in), A
ModuleAssembly6.Module4.vCell = 0; % Cell terminal voltage, V
ModuleAssembly6.Module4.socCell = initialSOC; % Cell state of charge
ModuleAssembly6.Module4.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly6.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module5
ModuleAssembly6.Module5.iCell = 0; % Cell current (positive in), A
ModuleAssembly6.Module5.vCell = 0; % Cell terminal voltage, V
ModuleAssembly6.Module5.socCell = initialSOC; % Cell state of charge
ModuleAssembly6.Module5.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly6.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module6
ModuleAssembly6.Module6.iCell = 0; % Cell current (positive in), A
ModuleAssembly6.Module6.vCell = 0; % Cell terminal voltage, V
ModuleAssembly6.Module6.socCell = initialSOC; % Cell state of charge
ModuleAssembly6.Module6.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly6.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.NewModule
ModuleAssembly6.NewModule.iCell = 0; % Cell current (positive in), A
ModuleAssembly6.NewModule.vCell = 0; % Cell terminal voltage, V
ModuleAssembly6.NewModule.socCell = initialSOC; % Cell state of charge
ModuleAssembly6.NewModule.numCyclesCell = 0; % Cell discharge cycles
ModuleAssembly6.NewModule.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.NewModule.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% NewModuleAssembly.Module2
NewModuleAssembly.Module2.iCell = 0; % Cell current (positive in), A
NewModuleAssembly.Module2.vCell = 0; % Cell terminal voltage, V
NewModuleAssembly.Module2.socCell = initialSOC; % Cell state of charge
NewModuleAssembly.Module2.numCyclesCell = 0; % Cell discharge cycles
NewModuleAssembly.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
NewModuleAssembly.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% NewModuleAssembly.Module3
NewModuleAssembly.Module3.iCell = 0; % Cell current (positive in), A
NewModuleAssembly.Module3.vCell = 0; % Cell terminal voltage, V
NewModuleAssembly.Module3.socCell = initialSOC; % Cell state of charge
NewModuleAssembly.Module3.numCyclesCell = 0; % Cell discharge cycles
NewModuleAssembly.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
NewModuleAssembly.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% NewModuleAssembly.Module4
NewModuleAssembly.Module4.iCell = 0; % Cell current (positive in), A
NewModuleAssembly.Module4.vCell = 0; % Cell terminal voltage, V
NewModuleAssembly.Module4.socCell = initialSOC; % Cell state of charge
NewModuleAssembly.Module4.numCyclesCell = 0; % Cell discharge cycles
NewModuleAssembly.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
NewModuleAssembly.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% NewModuleAssembly.Module5
NewModuleAssembly.Module5.iCell = 0; % Cell current (positive in), A
NewModuleAssembly.Module5.vCell = 0; % Cell terminal voltage, V
NewModuleAssembly.Module5.socCell = initialSOC; % Cell state of charge
NewModuleAssembly.Module5.numCyclesCell = 0; % Cell discharge cycles
NewModuleAssembly.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
NewModuleAssembly.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% NewModuleAssembly.Module6
NewModuleAssembly.Module6.iCell = 0; % Cell current (positive in), A
NewModuleAssembly.Module6.vCell = 0; % Cell terminal voltage, V
NewModuleAssembly.Module6.socCell = initialSOC; % Cell state of charge
NewModuleAssembly.Module6.numCyclesCell = 0; % Cell discharge cycles
NewModuleAssembly.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
NewModuleAssembly.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% NewModuleAssembly.NewModule
NewModuleAssembly.NewModule.iCell = 0; % Cell current (positive in), A
NewModuleAssembly.NewModule.vCell = 0; % Cell terminal voltage, V
NewModuleAssembly.NewModule.socCell = initialSOC; % Cell state of charge
NewModuleAssembly.NewModule.numCyclesCell = 0; % Cell discharge cycles
NewModuleAssembly.NewModule.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
NewModuleAssembly.NewModule.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

% Suppress MATLAB editor message regarding readability of repmat
%#ok<*REPMAT>
