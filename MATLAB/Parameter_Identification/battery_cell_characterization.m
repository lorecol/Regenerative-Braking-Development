%
% ------------------- BATTERY CELL CHARACTERIZATION -----------------------
% -------------------------------------------------------------------------

% This script is used to characterize the equivalent model of the battery,
% i.e. to find the significant parameters, such as the RC branches, the
% internal resistance of the battery and the Open Circuit Voltage (OCV).
% All parameters are expressed as a function of the State-of-Charge of the 
% battery and are found by fitting the data obtained from specific tests 
% carried out on the battery with the equivalent model of the battery
% itself.
% The script requires data collected from the battery during an HPPC test,
% in order to detect the charge/discharge impulses and the drop voltages
% during the discharge phase.

%% Initialization

clc;
clear;
close all;

% Add all files in current folder to Matlab path
addpath(genpath(pwd))


%% Loading data from HPPC test

% Let the user choose a .mat file where HPPC data are stored
[file, path] = uigetfile('../HPPC_Test/output/*.mat');
% Check file selection
if isequal(file, 0)
   disp('No file has been selected! Please select a file.');
else
   disp(['Selected file: ', fullfile(path, file)]);
end

% Load the data
load(file);
% Extract the data
data = HPPCMeas;

% Clear some data
clear HPPCMeas path file;

%% Extracting data from dataset
% Here we extract data from our dataset: in particular, we're interested in
% current (A), voltage (V) and SOC (%); all these data are defined for each
% time step, accordingly to Ts (sample time) and toc, which are parameters
% defined in the mainHPPC file.

current = data.Current;         % Current 
voltage = data.Voltage;         % Voltage 
time = data.Time;               % Time 

% SOC
SOC = data.SoC;                 
SOC = flip(SOC);
SOC = SOC';

%% Plot the collected data

% Plot the current
figure
subplot(2, 1, 1)
plot(time/3600, current)
xlabel('Time (h)')
ylabel('Current (A)')

% Plot the voltage
subplot(2, 1, 2)
plot(time/3600, voltage)
xlabel('Time (h)')
ylabel('Voltage (V)')

%% Cell characterization 

% Data
parallel = 4;                       % Battery configuration
cellCapacity = 4 * parallel;        % Cell capacity [Ah]             
cellInitialSOC = SOC(1)/100;        % Initial SOC

% Cell properties array
cell_prop = [cellCapacity; cellInitialSOC];    

maxDischargeCurr = 2;               % [A] Maximum discharge current 
maxChargeCurr = 2;                  % [A] Maximum charge current
constCurrSweepSOC = 1;              % [A] Current sweep

toleranceValChg = 0.1;              % [A] Current tolerance for charge impulse
toleranceValDischg = 0.5;           % [A] Current tolerance for discharge impulse
toleranceValSOC = 0.1;              % [A] Current tolerance for SoC sweep

hppc_protocol = [maxDischargeCurr   ;...
                 maxChargeCurr      ;...
                 constCurrSweepSOC  ;...
                 toleranceValChg    ;...
                 toleranceValDischg ;...
                 toleranceValSOC];

numRCpairs = 1;                     % Number of RC pairs in the model
initialGuess_RC = [1 100];          % Initial values of RC pairs for optimization purposes

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