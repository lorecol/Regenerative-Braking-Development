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
current = current(1:157000);
voltage = data.Voltage;         % Voltage 
voltage = voltage(1:157000);
time = data.Time;               % Time 
time = time(1:157000);

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
numRCpairs = 2;                     
% Initial guesses for resistance and time costant τ=RC
initialGuess_RC = [0.1 10 0.1 10]; 

% Perform data fitting
result = batt_BatteryCellCharacterization.ParameterEstimationLUTbattery(     ...
                                     [time, current, voltage],          ...
                                     cell_prop,                         ...
                                     hppc_protocol,                     ...
                                     numRCpairs,                        ...
                                     initialGuess_RC,                   ...
                                     "curvefit");           % or fminsearch

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
battParameters = exportResultsForLib(result, SOC');

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

%% Verify Parameters with Drive Profile
%close all; clear all; clc;

% This part is use to verify the parameters found with the original pack
% telemetry datas. Some variable have to be changed depending on the
% battery load profile and Simulink model

VERIFY = {'Yes', 'No'};
DO_VERIFY = listdlg('PromptString', {'Do you want to validate the resulting model? Y/N:', ''}, ...
               'ListString', VERIFY, 'SelectionMode', 'single'                               );

% Check if a battery configuration has been selected
if ~isempty(DO_VERIFY)
    selectedVariable = VERIFY{DO_VERIFY};
else
    error('No answer selected.\n');
end

% The CellCharacterizationVerify.slx model uses a drive profile to compare 
% the parameterized battery against the original one.
if strcmp(selectedVariable, VERIFY{1}) == 1
    fprintf('Verification started... \n');
    
    % Load the CURRENT profile from telemetry
    fprintf('Load the CURRENT profile \n');
    [curr_profileName, curr_path_to_profile] = uigetfile('src/loadProfiles/*.mat');
    % Check file selection
    if isequal(curr_profileName, 0)
       error('No file has been selected! Please select a file.');
    else
       disp(['  Selected file: ', fullfile(curr_path_to_profile, curr_profileName)]);
    end
    CURR_PROFILE_PATH = fullfile(curr_path_to_profile, curr_profileName);
    curr_Profile = load(CURR_PROFILE_PATH);
    % Extract the name of the fields of the structure
    fields = fieldnames(curr_Profile);
    maxCurrentPack = max(curr_Profile.(fields{1}).Data);
    minCurrentPack = min(curr_Profile.(fields{1}).Data);

    % Load the VOLTAGE profile from telemetry
    fprintf('Load the VOLTAGE profile \n');
    % Load the Current profile.
    [volt_profileName, volt_path_to_profile] = uigetfile('src/loadProfiles/*.mat');
    % Check file selection
    if isequal(volt_profileName, 0)
       error('No file has been selected! Please select a file.');
    else
       disp(['  Selected file: ', fullfile(volt_path_to_profile, volt_profileName)]);
    end
    VOLT_PROFILE_PATH= fullfile(volt_path_to_profile, volt_profileName);
    volt_Profile = load(VOLT_PROFILE_PATH);
    % Extract the name of the fields of the structure
    volt_fields = fieldnames(volt_Profile);
    maxVoltagePack = max(volt_Profile.(fields{1}).Data);
    minVoltagePack = min(volt_Profile.(fields{1}).Data);
    
    % Plot the Current and Voltage Profile
    figure('Name','Drive profile');
    subplot(2,1,1)
    plot(curr_Profile.(fields{1}).Time, curr_Profile.(fields{1}).Data)
    title('Current profile data')
    xlabel('Time (s)');
    ylabel('Current (A)');
    subplot(2,1,2)
    plot(volt_Profile.(fields{1}).Time, volt_Profile.(fields{1}).Data)
    title('Voltage profile data')
    xlabel('Time (s)');
    ylabel('Voltage (A)');
    
    % Run the CellCharacterizationVerify SLX file to compare the original 
    % and the parameterized cells
    fprintf('Select the Simulink battery model \n ')
    % Load the current profile.
    [simName, path_to_simName] = uigetfile('src/loadProfiles/*.slx');
    % Check file selection
    if isequal(simName, 0)
       error('No file has been selected! Please select a file.');
    else
       disp(['Selected file: ', fullfile(path_to_simName, simName)]);
    end
    verifyResPath= fullfile(path_to_simName, simName);
    load_system(verifyResPath);
    
    % Changing Parameters accordingly
    % Change the initialization function
    new_initfcn = [...
        'cellData=load(''batt_BatteryCharacterizationResults_3s4p_2RC_20230929_1552.mat'');',...
        'fitData = cellData.battParameters{1,3};',...
        'cellCapacity = cellData.battParameters{1,2};',...
        'run(''CellCharacterizationOrigCell.m'');'];
    set_param(simName, 'InitFcn', new_initfcn);
    disp('InitFcn function updated.');
    % Change the 'Voltage_Profile' block
    set_param([simName,'/Current_Profile'], 'FileName', CURR_PROFILE_PATH);
    set_param([simName,'/Voltage_Profile'], 'FileName', VOLT_PROFILE_PATH)
    disp('LoadProfile updated.');
    % Saving the system
    save_system(verifyResPath);

    % Start Simulating the system
    verifyRes = sim(verifyResPath);
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

elseif strcmp(selectedVariable, VERIFY{2}) == 1
    disp('*** Battery Characterization finished!!');
else
    error('You have to choose between Y/N.');
end

% If the error is not within acceptable limits, try with a different 
% initial guess, a different number of RC pairs, or by using a different 
% fitting method (fminsearch, Curve Fitting Toolbox). 