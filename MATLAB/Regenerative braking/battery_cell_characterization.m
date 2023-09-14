%
% ------------------- BATTERY CELL CHARACTERIZATION -----------------------
% -------------------------------------------------------------------------

clc;
clear;
close all;

% Add files and folders to Matlab path
addpath(genpath(pwd))


%% Loading data from HPPC test

% Upload the dataset 
load("Test_data/Test_20230914_1608.mat");    
data = HPPCMeas;

clear HPPCMeas;

data.SOC     = data.SOC(data.SOC ~= 0);
% data.SOC     = data.SOC';
data.Current = data.Current';
data.Voltage = data.Voltage';
data.Time    = data.Time';

%% Extracting data from dataset
% Here we extract data from our dataset: in particular, we're interested in
% current (A), voltage (V) and SOC (%); all these data are defined for each
% time step, accordingly to Ts (sample time) and toc, which are parameters
% defined in the mainHPPC file.

current = data.Current;         % Current 
voltage = data.Voltage;         % Voltage 
time    = data.Time;            % Time 
SOC     = data.SOC;             % SOC

clear data;

%% Plotting parameters

figure
subplot(2,1,1)
plot(time/3600, current)
xlabel('Time (h)')
ylabel('Current (A)')

subplot(2,1,2)
plot(time/3600, voltage)
xlabel('Time (h)')
ylabel('Voltage (V)')

%% Cell characterization 

cellCapacity   = 3;                 % Cell capacity [Ah]             
cellInitialSOC = SOC(1)/100;        % Initial SOC

% Cell properties array
cell_prop = [cellCapacity; cellInitialSOC];    

% With these values it works, but we don't know why 
% maxDischargeCurr  = 2;  % Maximum discharging current, [A]
% maxChargeCurr     = 2.2;  % Maximum charging current, [A]
% constCurrSweepSOC = 1;  % Current sweep, [A]
% toleranceVal      = 0.1;   % Tolerance current value, [A]

maxDischargeCurr  = 2;      % [A] Maximum discharge current 
maxChargeCurr     = 2;      % [A] Maximum charge current
constCurrSweepSOC = 1;      % [A] Current sweep

toleranceValChg      = 0.1;     % [A] Current tolerance for charge impulse
toleranceValDischg   = 0.5;     % [A] Current tolerance for discharge impulse
toleranceValSOC      = 0.1;     % [A] Current tolerance for SoC sweep

hppc_protocol = [maxDischargeCurr   ;...
                 maxChargeCurr      ;...
                 constCurrSweepSOC  ;...
                 toleranceValChg    ;...
                 toleranceValDischg ;...
                 toleranceValSOC];

numRCpairs      = 1;              % Number of RC pairs in the model
initialGuess_RC = [1 100];        % Initial values of RC pairs for optimization purposes

%% Computation

result = batt_BatteryCellCharacterization.ParameterEstimationLUTbattery(...
                                     [time, current, voltage],          ...
                                     cell_prop,                         ...
                                     hppc_protocol,                     ...
                                     numRCpairs,                        ...
                                     initialGuess_RC,                   ...
                                     "curvefit");

plotAndVerifyPulseData(result);

fitDataEverySOCval = 0.001;
fitDataForSOCpts = 0:fitDataEverySOCval:1;
verifyDataFit(result,fitDataEverySOCval,1);


cellParameters = exportResultsForLib(result,...
                 flip(SOC/100));