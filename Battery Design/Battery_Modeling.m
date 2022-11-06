close all
clear all
clc

%% IMPORT THE SIMSCAPE MODULE

import simscape.battery.builder.*

%% DEFINE THE GEOMETRY OF A SINGLE CELL

% The batteries are Samsung 21700-40T

% Cylindircal cell geometry
CylGeo = CylindricalGeometry(Height = simscape.Value(0.0703, "m"), Radius = simscape.Value(0.0106, "m"));
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
                                          NumParallelCells = 3, ...
                                          Rows = 3, ...
                                          Topology = "Square", ...
                                          ModelResolution = "Detailed");

%% CREATE A MODULE OBJECT --> BLOCK: 3 MODULES IN SERIES

BatteryModule = Module(ParallelAssembly = BatteryParallelAssembly, ...
                       NumSeriesAssemblies = 4, ...
                       InterParallelAssemblyGap = simscape.Value(0.005, "m"), ...
                       ModelResolution = "Lumped", ...
                       AmbientThermalPath = "CellBasedThermalResistance");

%% CREATE A MODULE ASSEMBLY OBJECT --> SEGMENT: 6 BLOCK IN SERIES

BatteryModuleAssembly = ModuleAssembly(Module = repmat(BatteryModule, 1, 6), ...
                        NumLevels = 6, ...
                        InterModuleGap = simscape.Value(0.01, "m"));

%% CREATE A PACK OBJECT: 6 SEGMENTS IN SERIES

BatteryPack = Pack(ModuleAssembly = repmat(BatteryModuleAssembly, 1, 6), ...
                   InterModuleAssemblyGap = simscape.Value(0.01, "m"));

%% VISUALIZE BATTERY MODULE AND CHECK MODULE RESOLUTION

f = uifigure(Color= "w");
tl = tiledlayout(1, 1, "Parent", f, "TileSpacing", "compact");

% Cell
% BatteryImage = BatteryChart(Parent = tl, Battery = BatteryCell);

% Module
% BatteryImage = BatteryChart(Parent = tl, Battery = BatteryParallelAssembly);

% Block
% BatteryImage = BatteryChart(Parent = tl, Battery = BatteryModule);

% Segment
% BatteryImage = BatteryChart(Parent = tl, Battery = BatteryModuleAssembly);

% Pack
BatteryImage = BatteryChart(Parent = tl, Battery = BatteryPack);

%% BUILD SIMSCAPE MODEL FOR THE BATTERY PACK OBJECT

% Parametrized model through a created Matlab script
buildBattery(BatteryPack, "LibraryName", "packLibrary", ...
              "MaskInitialTargets", "VariableNames", ...
              "MaskParameters", "VariableNames");