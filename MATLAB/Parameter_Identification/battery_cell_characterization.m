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

% The script is based on the Matlab Example "Battery Cell Characterization"
% but some functions has been changed/added to perform better data fitting 
% and pulses recognition.
% The matlab example can be open with the following command:
% openExample('simscapebattery/BatteryCellCharacterizationForElectricVehiclesExample')


%% Initialization
% Clear and close
clc; clear all; close all;

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
load(fullfile(path, file));
% Extract the data
data = HPPCMeas;

% Clear some data
clear HPPCMeas path file;

%% Extracting data from dataset
% Here we extract data from our dataset: in particular, we're interested in
% current (A), voltage (V) and SOC (%); all these data are defined for each
% time step, accordingly to Ts (sample time) and toc, which are parameters
% defined in the mainHPPC file.

% Change range if needed
current = data.Current;         % Current 
%current = current(1:157000);
voltage = data.Voltage;         % Voltage 
%voltage = voltage(1:157000);
time = data.Time;               % Time 
%time = time(1:157000);

% SOC
SOC = data.SoC;
SOC = SOC/100;

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
parallel = 1;                           
series = 1;
cellCapacity = 3;                       % Cell Capacity [Ah]
totCapacity = cellCapacity * parallel;  % Tot capacity [Ah]             
cellInitialSOC = SOC(end);              % Initial SOC

% Cell properties array
cell_prop = [totCapacity; cellInitialSOC];    

% HPPC Currents
maxDischargeCurr = 2 * parallel;    % [A] Maximum discharge current 
maxChargeCurr = 2 * parallel;       % [A] Maximum charge current
constCurrSweepSOC = 1;              % [A] Current sweep

% Tolerances depending on the power supply accuracy
toleranceValChg = 0.1;              % [A] Current tolerance for charge impulse
toleranceValDischg = 0.5;           % [A] Current tolerance for discharge impulse
toleranceValSOC = 0.1;              % [A] Current tolerance for SoC sweep
% Paramater for data fitting function diff=current(i)-current(i-k). 
% e.g.  If the power supply instrument in a sampling period time of 0.1s
%       can't achieve a desired current this helps in finding
%       the sudden changes.
k = 2;                              

% Create the hppc protocol
hppc_protocol = [maxDischargeCurr   ;...
                 maxChargeCurr      ;...
                 constCurrSweepSOC  ;...
                 toleranceValChg    ;...
                 toleranceValDischg ;...
                 toleranceValSOC    ;...
                 2];
        

%% Cell characterization
% Define number of RC pairs to consider
numRCpairs = 2;                     
% Initial guesses for resistance and time costant τ=RC
initialGuess_RC = [0.1 10 0.1 10]; 

% Perform data fitting
result = batt_BatteryCellCharacterization.ParameterEstimationLUTbattery(...
                                     [time, current, voltage],     ...
                                     cell_prop,                         ...
                                     hppc_protocol,                     ...
                                     numRCpairs,                        ...
                                     initialGuess_RC,                   ...
                                     "curvefit"); % or fminsearch

% To check if the function identified the correct pulses
plotAndVerifyPulseData(result);

% Verify the fitting procedure
fitDataEverySOCval = 0.001;
fitDataForSOCpts = 0:fitDataEverySOCval:1;
verifyDataFit(result,fitDataEverySOCval,1);

% If the estimated parameters do not look reasonable, try fitting them
% with more RC pairs or try a different initial guess. 

%% Saving parameters
% Saving parameters in a variable
battParameters = exportResultsForLib(result, SOC');

% Saving parameters in a file
% Create the output subfolder if it doesn't exist
if ~exist('output', 'dir')
    mkdir('output');
end
% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');
config = [num2str(series),'s', num2str(parallel),'p','_', num2str(numRCpairs),'RC'];
% Save the variable to the .mat file with the date-appended filename
save(fullfile('output',[sprintf('batt_BatteryCharacterizationResults_%s_%s',config, currentDateStr),'.mat'] ), 'battParameters');

%% Verify Parameters with Drive Profile
% Do verify or not
DO_VERIFY = 0;

% The CellCharacterizationVerify.slx model uses a drive profile 
% to compare the parameterized battery against the original one.

if DO_VERIFY == 1
    % Load the load profile. As default is loaded example one 
    % (src/loadProfiles/batt_BatteryCellCharacterizationForBEV_Ivst.mat)
    driveProfile = load('src/loadProfiles/batt_BatteryCellCharacterizationForBEV_Ivst.mat');
    maxCurrentPack = max(driveProfile.ans.Data);
    minCurrentPack = min(driveProfile.ans.Data);
    
    figure('Name','Drive profile');
    plot(driveProfile.ans.Time,driveProfile.ans.Data)
    title('Drive profile data')
    xlabel('Time (s)');
    ylabel('Current (A)');
    
    % Run the CellCharacterizationVerify SLX file to compare the original 
    % and the parameterized cells.
    verifyRes = sim('src/CellCharacterizationVerify.slx');
    resDriveProfile = verifyRes.CellCharacterization_DriveProfile.extractTimetable;
    
    % Plot results
    figure('Name','Error in voltage prediction');
    plot(resDriveProfile.Time,resDriveProfile.V_err*1000);
    title('Voltage Error (mV) Between Original and Parameterized Cell')
    xlabel('Time (s)');
    ylabel('Voltage Error (mV)');
    figure('Name','Voltage profile for original and parameterized cell');
    plot(resDriveProfile.Time,resDriveProfile.V);
    title('Voltage (V) for Original and Parameterized Cell')
    xlabel('Time (s)');
    ylabel('Voltage (V)');
    legend('Original Cell', 'Parameterized Cell')

    disp('*** Battery Characterization finished!!');
elseif DO_VERIFY == 0
    disp('*** Battery Characterization finished!!');
else
    error('DO_VERIFY must be 0 or 1');
end

% If the error is not within acceptable limits, try with a 
% different initial guess, a different number of RC pairs, or by using 
% a different fitting method (fminsearch, Curve Fitting Toolbox). 
