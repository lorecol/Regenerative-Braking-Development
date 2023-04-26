%% Battery parameters

%% ModuleType1
ModuleType1.SOC_vec = [0, .1, .25, .5, .75, .9, 1]; % Vector of state-of-charge values, SOC
ModuleType1.T_vec = [278, 293, 313]; % Vector of temperatures, T, K
ModuleType1.V0_mat = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64; 3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08; 4.19, 4.19, 4.19]; % Open-circuit voltage, V0(SOC,T), V
ModuleType1.V_range = [0, inf]; % Terminal voltage operating range [Min Max], V
ModuleType1.R0_mat = [.0117, .0085, .009; .011, .0085, .009; .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091; .0113, .0085, .0089; .0116, .0085, .0089]; % Terminal resistance, R0(SOC,T), Ohm
ModuleType1.AH = 27; % Cell capacity, AH, A*hr
ModuleType1.thermal_mass = 100; % Thermal mass, J/K

%% ParallelAssemblyType1
ParallelAssemblyType1.SOC_vec = [0, .1, .25, .5, .75, .9, 1]; % Vector of state-of-charge values, SOC
ParallelAssemblyType1.T_vec = [278, 293, 313]; % Vector of temperatures, T, K
ParallelAssemblyType1.V0_mat = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64; 3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08; 4.19, 4.19, 4.19]; % Open-circuit voltage, V0(SOC,T), V
ParallelAssemblyType1.V_range = [0, inf]; % Terminal voltage operating range [Min Max], V
ParallelAssemblyType1.R0_mat = [.0117, .0085, .009; .011, .0085, .009; .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091; .0113, .0085, .0089; .0116, .0085, .0089]; % Terminal resistance, R0(SOC,T), Ohm
ParallelAssemblyType1.AH = 27; % Cell capacity, AH, A*hr
ParallelAssemblyType1.thermal_mass = 100; % Thermal mass, J/K

%% Battery initial targets

%% ModuleAssembly1.Module1
ModuleAssembly1.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly1.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly1.Module1.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly1.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly1.Module1.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly1.Module1.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly1.Module1.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly1.Module2
ModuleAssembly1.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly1.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly1.Module2.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly1.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly1.Module2.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly1.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly1.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly1.Module3
ModuleAssembly1.Module3.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly1.Module3.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly1.Module3.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly1.Module3.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly1.Module3.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly1.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly1.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly1.Module4
ModuleAssembly1.Module4.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly1.Module4.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly1.Module4.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly1.Module4.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly1.Module4.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly1.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly1.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly1.Module5
ModuleAssembly1.Module5.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly1.Module5.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly1.Module5.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly1.Module5.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly1.Module5.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly1.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly1.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly1.Module6
ModuleAssembly1.Module6.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly1.Module6.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly1.Module6.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly1.Module6.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly1.Module6.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly1.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly1.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module1
ModuleAssembly2.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly2.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly2.Module1.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly2.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly2.Module1.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly2.Module1.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module1.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module2
ModuleAssembly2.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly2.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly2.Module2.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly2.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly2.Module2.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly2.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module3
ModuleAssembly2.Module3.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly2.Module3.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly2.Module3.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly2.Module3.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly2.Module3.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly2.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module4
ModuleAssembly2.Module4.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly2.Module4.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly2.Module4.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly2.Module4.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly2.Module4.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly2.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module5
ModuleAssembly2.Module5.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly2.Module5.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly2.Module5.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly2.Module5.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly2.Module5.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly2.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly2.Module6
ModuleAssembly2.Module6.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly2.Module6.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly2.Module6.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly2.Module6.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly2.Module6.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly2.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly2.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module1
ModuleAssembly3.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly3.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly3.Module1.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly3.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly3.Module1.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly3.Module1.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module1.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module2
ModuleAssembly3.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly3.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly3.Module2.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly3.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly3.Module2.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly3.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module3
ModuleAssembly3.Module3.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly3.Module3.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly3.Module3.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly3.Module3.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly3.Module3.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly3.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module4
ModuleAssembly3.Module4.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly3.Module4.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly3.Module4.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly3.Module4.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly3.Module4.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly3.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module5
ModuleAssembly3.Module5.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly3.Module5.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly3.Module5.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly3.Module5.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly3.Module5.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly3.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly3.Module6
ModuleAssembly3.Module6.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly3.Module6.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly3.Module6.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly3.Module6.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly3.Module6.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly3.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly3.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module1
ModuleAssembly4.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly4.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly4.Module1.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly4.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly4.Module1.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly4.Module1.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module1.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module2
ModuleAssembly4.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly4.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly4.Module2.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly4.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly4.Module2.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly4.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module3
ModuleAssembly4.Module3.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly4.Module3.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly4.Module3.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly4.Module3.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly4.Module3.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly4.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module4
ModuleAssembly4.Module4.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly4.Module4.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly4.Module4.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly4.Module4.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly4.Module4.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly4.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module5
ModuleAssembly4.Module5.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly4.Module5.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly4.Module5.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly4.Module5.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly4.Module5.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly4.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly4.Module6
ModuleAssembly4.Module6.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly4.Module6.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly4.Module6.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly4.Module6.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly4.Module6.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly4.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly4.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module1
ModuleAssembly5.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly5.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly5.Module1.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly5.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly5.Module1.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly5.Module1.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module1.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module2
ModuleAssembly5.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly5.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly5.Module2.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly5.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly5.Module2.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly5.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module3
ModuleAssembly5.Module3.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly5.Module3.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly5.Module3.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly5.Module3.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly5.Module3.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly5.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module4
ModuleAssembly5.Module4.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly5.Module4.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly5.Module4.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly5.Module4.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly5.Module4.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly5.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module5
ModuleAssembly5.Module5.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly5.Module5.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly5.Module5.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly5.Module5.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly5.Module5.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly5.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly5.Module6
ModuleAssembly5.Module6.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly5.Module6.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly5.Module6.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly5.Module6.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly5.Module6.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly5.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly5.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module1
ModuleAssembly6.Module1.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly6.Module1.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly6.Module1.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly6.Module1.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly6.Module1.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly6.Module1.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module1.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module2
ModuleAssembly6.Module2.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly6.Module2.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly6.Module2.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly6.Module2.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly6.Module2.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly6.Module2.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module2.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module3
ModuleAssembly6.Module3.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly6.Module3.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly6.Module3.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly6.Module3.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly6.Module3.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly6.Module3.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module3.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module4
ModuleAssembly6.Module4.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly6.Module4.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly6.Module4.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly6.Module4.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly6.Module4.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly6.Module4.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module4.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module5
ModuleAssembly6.Module5.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly6.Module5.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly6.Module5.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly6.Module5.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly6.Module5.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly6.Module5.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module5.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

%% ModuleAssembly6.Module6
ModuleAssembly6.Module6.iCellModel = 0; % Cell model current (positive in), A
ModuleAssembly6.Module6.vCellModel = 0; % Cell model terminal voltage, V
ModuleAssembly6.Module6.socCellModel = 0.8; % Cell model state of charge
ModuleAssembly6.Module6.numCyclesCellModel = 0; % Cell model discharge cycles
ModuleAssembly6.Module6.temperatureCellModel = 298.15; % Cell model temperature, K
ModuleAssembly6.Module6.vParallelAssembly = repmat(0, 3, 1); % Parallel Assembly Voltage, V
ModuleAssembly6.Module6.socParallelAssembly = repmat(1, 3, 1); % Parallel Assembly state of charge

% Suppress MATLAB editor message regarding readability of repmat
%#ok<*REPMAT>
