close all
clear all
clc

%% IMPORT THE SIMSCAPE MODULE

import simscape.battery.builder.*

%% DEFINE THE GEOMETRY OF A SINGLE CELL

% The batteries are Samsung 21700-40T

% Cylindircal cell geometry
CylGeo = CylindricalGeometry(Height = simscape.Value(0.0703, "m"), ...
    Radius = simscape.Value(0.0106, "m"));
% Mass of a single cell
mass = simscape.Value(0.07, "kg"); 

%% CREATE A CELL OBJECT

BatteryCell = Cell("Geometry", CylGeo, "Mass", mass);
% Expose a thermal port in the battery module model to model an extended
% thermal system
BatteryCell.CellModelOptions.BlockParameters.thermal_port = "model";
BatteryCell.CellModelOptions.BlockParameters.T_dependence = "yes";

%% CREATE A PARALLEL ASSEMBLY OBJECT --> MODULE: 4 CELLS IN PARALLEL

BatteryParallelAssembly = ParallelAssembly(Cell = BatteryCell, ...
                                          NumParallelCells = 4, ...
                                          Rows = 4, ...
                                          Topology = "Square", ...
                                          StackingAxis= "X", ...
                                          ModelResolution = "Detailed");

%% CREATE A MODULE OBJECT --> BLOCK: 3 MODULES IN SERIES

BatteryModule = Module(ParallelAssembly = BatteryParallelAssembly, ...
                       NumSeriesAssemblies = 3, ...
                       InterParallelAssemblyGap = simscape.Value(0.005, "m"), ...
                       ModelResolution = "Lumped", ...
                       StackingAxis = "X", ...
                       AmbientThermalPath = "CellBasedThermalResistance");

%% CREATE A MODULE ASSEMBLY OBJECT --> SEGMENT: 6 BLOCK IN SERIES

BatteryModuleAssembly = ModuleAssembly(Module = repmat(BatteryModule, 1, 6), ...
                        InterModuleGap = simscape.Value(0.01, "m"), ...
                        NumLevels = 6);

%% CREATE A PACK OBJECT: 6 SEGMENTS IN SERIES

BatteryPack = Pack(ModuleAssembly = repmat(BatteryModuleAssembly, 1, 6), ...
                   InterModuleAssemblyGap = simscape.Value(0.01, "m"));

%% VISUALIZE BATTERY MODULE AND CHECK MODULE RESOLUTION

f = uifigure(Color= "w");
tl = tiledlayout(1, 1, "Parent", f, "TileSpacing", "compact");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               UNCOMMENT THE IMAGE YOU WANT TO SEE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cell
% BatteryImage = BatteryChart(Parent = tl, Battery = BatteryCell);

% Module
% BatteryImage = BatteryChart(Parent = tl, ...
%     Battery = BatteryParallelAssembly);

% Block
% BatteryImage = BatteryChart(Parent = tl, Battery = BatteryModule);

% Segment
% BatteryImage = BatteryChart(Parent = tl, ...
%     Battery = BatteryModuleAssembly);

% Pack
BatteryImage = BatteryChart(Parent = tl, Battery = BatteryPack);

%% BUILD SIMSCAPE MODEL FOR THE BATTERY PACK OBJECT

% Parametrized model through an automatically created Matlab script
%  buildBattery(BatteryPack, "LibraryName", "packLibrary", ...
%                "MaskInitialTargets", "VariableNames", ...
%                "MaskParameters", "VariableNames");

%% BATTERY PARAMETERS

% System parameters
SOC_vec = [0, .1, .25, .5, .75, .9, 1]; % Vector of state-of-charge values, SOC
T_vec   = [278, 293, 313];              % Vector of temperatures, T, (K)
AH      = 27;                           % Cell capacity, AH, (A*hr) 
thermal_mass = 100;                     % Thermal mass (J/K)
initialSOC = 0.3;                       % Battery initial SOC
V0_mat  = [3.49, 3.5, 3.51; 3.55, 3.57, 3.56; 3.62, 3.63, 3.64;...
    3.71, 3.71, 3.72; 3.91, 3.93, 3.94; 4.07, 4.08, 4.08;...
    4.19, 4.19, 4.19];                          % Open-circuit voltage, V0(SOC,T), (V)
R0_mat  = [.0117, .0085, .009; .011, .0085, .009;...
    .0114, .0087, .0092; .0107, .0082, .0088; .0107, .0083, .0091;...
    .0113, .0085, .0089; .0116, .0085, .0089];  % Terminal resistance, R0(SOC,T), (ohm)

R1_mat  = [.0109, .0029, .0013; .0069, .0024, .0012;...
    .0047, .0026, .0013; .0034, .0016, .001; .0033, .0023, .0014;...
    .0033, .0018, .0011; .0028, .0017, .0011];  % First polarization resistance, R1(SOC,T), (ohm)
tau1_mat = [20, 36, 39; 31, 45, 39; 109, 105, 61;...
    36, 29, 26; 59, 77, 67; 40, 33, 29; 25, 39, 33]; % First time constant, tau1(SOC,T), (s)

R2_mat  = [.0109, .0029, .0013; .0069, .0024, .0012;...
    .0047, .0026, .0013; .0034, .0016, .001; .0033, .0023, .0014;...
    .0033, .0018, .0011; .0028, .0017, .0011];  % First polarization resistance, R1(SOC,T), (ohm)
tau2_mat = [20, 36, 39; 31, 45, 39; 109, 105, 61;...
    36, 29, 26; 59, 77, 67; 40, 33, 29; 25, 39, 33]; % First time constant, tau1(SOC,T), (s)

cell_area = 0.1019; % Cell area (m^2)
h_conv    = 5;      % Heat transfer coefficient (W/(K*m^2))

% Charging/Discharging Parameters

vMax = 4.2; % Maximum cell voltage
Kp   = 100; % Proportional gain CV controller
Ki   = 10;  % Integral gain CV controller
Kaw  = 1;   % Antiwindup gain CV controller
Ts   = 1;   % Sample time (s)