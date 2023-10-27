%
% ------------------- BATTERY CHARACTERIZATION ----------------------------
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

% The script is based on the Matlab Example "Battery Cell Characterization"
% but some functions has been changed/added to perform better data fitting 
% and pulses recognition.
% The matlab example can be open with the following command:
% openExample('simscapebattery/BatteryCellCharacterizationForElectricVehiclesExample')

%% Initialization

% Clear and close
close all; clear all; clc;

% Add all files in current folder to Matlab path
addpath(genpath(pwd))

%% Loading data from HPPC test

% Let the user choose a .mat file where HPPC data are stored
fprintf('Select an HPPC .mat file \n');
[file, path] = uigetfile('../HPPC_Test/output/*.mat');
% Check file selection
if isequal(file, 0)
   error('No file has been selected! Please select a file.');
else
   disp(['Selected file: ', fullfile(path, file)]);
end

% Load the data
load(fullfile(path, file));
% Extract the data
data = HPPCMeas;

% Clear some data
clear HPPCMeas path file;

%% Extracting data from the dataset
% Here we extract data from our dataset: in particular, we're interested in
% current (A), voltage (V) and SOC (%); all these data are defined for each
% time step, accordingly to Ts (sample time) and toc, which are parameters
% defined in the mainHPPC file.

% Change range if needed
current = data.Current;         % Current 
%current = current(1:166590);
voltage = data.Voltage;         % Voltage 
%voltage = voltage(1:166590);
time = data.Time;               % Time 
%time = time(1:166590);

% SOC
SOC = data.SoC;
SOC = SOC/100;                  % Convert to decimals

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

%% Define parameters for battery characterization 

% Battery configuration
parallels = data.parallels;     % Number of series
series = data.series;           % Number of parallels

Capacity = data.Capacity;       % [Ah] Battery capacity
cellInitialSOC = SOC(end);      % Initial SOC

% Cell properties array
cell_prop = [Capacity; cellInitialSOC];    

% HPPC Currents
maxDischargeCurr = abs(data.curr_discharge_pulse);     % [A] Maximum discharge current 
maxChargeCurr = abs(data.curr_charge_pulse);           % [A] Maximum charge current
constCurrSweepSOC = abs(data.dischargeC3);             % [A] Current sweep

% Tolerances depending on the power supply accuracy
toleranceValChg = 0.1;                                 % [A] Current tolerance for charge impulse
toleranceValDischg = 0.5;                              % [A] Current tolerance for discharge impulse
toleranceValSOC = 0.1;                                 % [A] Current tolerance for SoC sweep

% Paramater for data fitting function: diff = current(i) - current(i - k) 
k = 2;  
% e.g.  If the power supply instrument in a sampling period of 0.1 s fails 
%       to reach the desired current, this helps to detect sudden changes.                            

% Create the hppc protocol
hppc_protocol = [maxDischargeCurr   ;...
                 maxChargeCurr      ;...
                 constCurrSweepSOC  ;...
                 toleranceValChg    ;...
                 toleranceValDischg ;...
                 toleranceValSOC    ;...
                 k];

%% Cell characterization

% Define number of RC pairs to consider
numRCpairs = 1;                     
% Initial guesses for resistance and time costant τ=RC
initialGuess_RC = [0.1 10]; 

% Perform data fitting
result = batt_BatteryCellCharacterization.ParameterEstimationLUTbattery(     ...
                                     [time, current, voltage],          ...
                                     cell_prop,                         ...
                                     hppc_protocol,                     ...
                                     numRCpairs,                        ...
                                     initialGuess_RC,                   ...
                                     "curvefit");% curvefit or fminsearch

% Check if the the correct pulses have been identified 
plotAndVerifyPulseData(result);

% Verify the fitting procedure
fitDataEverySOCval = 0.001;
fitDataForSOCpts = 0:fitDataEverySOCval:1;
verifyDataFit(result, fitDataEverySOCval, 1);

% If the estimated parameters do not look reasonable, try fitting them
% with more RC pairs or try different initial guesses. 

%% Save parameters resulting from fitting procedure

% Saving parameters in a variable
battParameters = exportResultsForLib(result, SOC);

% Saving parameters in a file
% Create the output subfolder if it doesn't exist
if ~exist('output', 'dir')
    mkdir('output');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');
config = [num2str(series),'s', num2str(parallels),'p','_', num2str(numRCpairs),'RC'];

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output',[sprintf('batt_BatteryCharacterizationResults_%s_%s',config, currentDateStr),'.mat'] ), 'battParameters');


disp('*** Battery Characterization finished!! Results are saved in output/');
