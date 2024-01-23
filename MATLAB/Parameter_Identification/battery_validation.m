%
% ------------------- BATTERY VALIDATION-----------------------------------
% -------------------------------------------------------------------------

% This script is used to validate the data obtained from the battery 
% characterisation.
% First of all, it is therefore necessary to parameterise the cell/block 
% via the file 'battery_characterisation.m'. 
% The results obtained (saved in the "output/" folder) are then used 
% to recreate the entire battery pack via Matlab Simulink and using 
% the "Battery Builder" tool. The model is then saved
% in the "src/" folder and named "batteryModel{...}". 
% For the script to work, it is necessary to have telemetry data 
% for current (hw_current), voltage (hw_voltage) and temperature 
% within the "src/loadProfiles/" folder.
% The script then performs a simulation by current checking the battery pack. 
% The 'computed' voltage at the ends of the pack is then compared 
% with the 'original' voltage from the telemetry
%

%% Initialization

% Clear and close
close all; clear all; clc;

% Add all files in current folder to Matlab path
addpath(genpath(pwd))

%% Validation
disp('*** Battery Validation started');
    
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

% TODO: do a piece of script that takes in consideration the offset 
%curr_Profile.(fields{1}).Data(curr_Profile.(fields{1}).Data<0)=0;
% curr_Profile.(fields{1}).Data = curr_Profile.(fields{1}).Data + 4.88;
% timeseries1 = curr_Profile.timeseries1;
% save([curr_path_to_profile,'load_end_00_current_new2.mat'],"timeseries1",  "-v7.3");

% Set Simulation STOP TIME
sim_StopTime = curr_Profile.(fields{1}).Time(end);

% Load the VOLTAGE profile from telemetry
disp('Load the VOLTAGE profile');
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


% Plot the CURRENT and VOLTAGE Profile
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
ylabel('Voltage (V)');

%% Load the CellCharacterizationVerify SLX file to compare the original 
% and the parameterized cells
fprintf('Select the Simulink battery model \n ')
[simName, path_to_simName] = uigetfile('src/*.slx');
% Check file selection
if isequal(simName, 0)
   error('No file has been selected! Please select a file.');
else
   disp(['Selected file: ', fullfile(path_to_simName, simName)]);
end
verifyResPath= fullfile(path_to_simName, simName);
load_system(verifyResPath);

% TODO: Maybe is better to create a matlab file that create the symulink
% file accordingly to the Cell Characterization parameters

% Changing Simulation Parameters accordingly
% Load the Battery Characterization results
fprintf('Select the Battery Characterization results \n ')
[charName, path_to_charName] = uigetfile('output/*.mat');
load(charName);
% Check file selection
if isequal(charName, 0)
   error('No file has been selected! Please select a file.');
else
   disp(['Selected file: ', fullfile(path_to_charName, charName)]);
end
% Change the initialization function
cellData=load(charName);
fitData = cellData.battParameters{1,3};
cellCapacity = cellData.battParameters{1,2};

[simpathstr,simname,simext] = fileparts(simName);

% Change the Profile blocks
set_param([simname,'/Current_Profile'], 'FileName', CURR_PROFILE_PATH);
set_param([simname,'/Voltage_Profile'], 'FileName', VOLT_PROFILE_PATH);
disp('LoadProfile updated.');
% Change the StopTime
set_param(simname,'StopTime',num2str(sim_StopTime));
disp('StopTime updated.');
% Saving the system
save_system(verifyResPath);

% Find the initial SOC of the pack
if contains(charName,'1s1p')
    % IF IS A CELL ->  DIVIDE BY 108
    initialSOC = interp1(battParameters{3}.V0,battParameters{3}.SOC,volt_Profile.timeseries1.Data(1,1)/108);
elseif contains(charName,'3s4p')
    % If SIMULATE THE BLOCK -> DIVIDE BY 36; 
    initialSOC = interp1(battParameters{3}.V0,battParameters{3}.SOC,volt_Profile.timeseries1.Data(1,1)/36);
end
%initialSOC = 1;
%cellCapacity = 15.5;
disp(['Your battery pack started the test (from telemetry) with: ', num2str(initialSOC*100), ' %SOC'])

% Start Simulating the system
verifyRes = sim(verifyResPath);
resDriveProfile = verifyRes.logsout.extractTimetable;

% Display some results
disp(['The mean of the error is: ', num2str(mean(resDriveProfile.V_error))])

%% Plot results
figure('Name','Error in voltage prediction');
hold on
plot(resDriveProfile.Time,resDriveProfile.V_error);
yline(mean(resDriveProfile.V_error),'-r',['Mean: ', num2str(mean(resDriveProfile.V_error))]);
title('Voltage Error (V) Between Original and Parameterized battery pack')
xlabel('Time (s)');
ylabel('Voltage Error (V)');
hold off

figure('Name','Voltage profile of original and parameterized battery pack');
hold on
plot(resDriveProfile.Time,resDriveProfile.V_computed, 'DisplayName','V_{computed}');
plot(resDriveProfile.Time,resDriveProfile.V_original, 'DisplayName','V_{original}');
title('Voltage (V) of Original and Parameterized battery pack')
xlabel('Time (s)');
ylabel('Voltage (V)');
legend('Location','best')
hold off

figure('Name', 'V_computed/V_original');
plot(resDriveProfile.V_original,resDriveProfile.V_computed, "o");
title('V_{computed}/V_{original}')
xlabel('V_{original}');
ylabel('V_{computed}');


disp('*** Battery Validation finished!!');
