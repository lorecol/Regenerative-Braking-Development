%
% --------------------------- CAPACITY TEST -------------------------------
% -------------------------------------------------------------------------

% This script is used to perform the capacity test on a specific battery 
% configuration, which can be a single cell or a block of multiple cells 
% (3 in series and 4 in parallel). Data are logged externally in a .txt 
% file with a frequency of 10 Hz and all significant parameters and results
% are saved in a .mat file, which will be then loaded to perform the HPPC
% test on the battery.

%% Initialization

clear all;
close all;
clc;

% Add all files from current folder to Matlab path
addpath(genpath(pwd))

%% Estabilish connection with the instrument

% Load VISA library
Instrlist = visadevlist("Timeout", 10);
% Create VISA object
visaObj = visadev(Instrlist.ResourceName);

% Check if the connection is successful
if strcmp(visaObj.Status, 'open')
    disp('Instrument connection established.');
else
    error('Failed to connect to the instrument.');
end

%% Data

Vlimreal = 4.2 * series;     % [V] Voltage upper limit when discharging
Vlimlow = 2.8 * series;      % [V] Voltage lower limit when discharging
Ilev = 2 * parallel;         % [A] Current level
Ts = 0.1;                    % [s] Sampling time

%% Initialize the instrument

% Select data format
writeline(visaObj, ":FORM:DATA ASCii");

% Enable voltage log
writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage:MINMax OFF');

% Enable current log
writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent:MINMax OFF');

% Set integration time
writeline(visaObj, sprintf(':SENS:ELOG:PER %g', Ts));

% Select trigger source for datalog
writeline(visaObj, 'TRIGger:TRANsient:SOURce BUS');

% Initialize elog system
writeline(visaObj, ':INITiate:IMMediate:ELOG');

disp('Instrument initialization done.');

%% Let the user choose which battery configuration to test

BatteryList = {'SingleCell', 'Block'};
Battery = listdlg('PromptString', {'For which type of battery do you want to test the capacity?', ''}, ...
               'ListString', BatteryList, 'SelectionMode', 'single'                                       );

% Check if a battery configuration has been selected
if ~isempty(Battery)
    selectedVariable = BatteryList{Battery};
else
    error('No battery configuration selected.');
end

% Battery configuration
if strcmp(selectedVariable, 'SingleCell') == 1
    parallel = 1;               % Number of parallels          
    series = 1;                 % Number of series
    disp('You are testing a single cell.');
elseif strcmp(selectedVariable, 'Block') == 1
    parallel = 4;               % Number of parallels          
    series = 3;                 % Number of series
    disp('You are testing a block - 3s4p configuration.');
end

%% Open the .txt file where to log test data

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Create the output folder and the test subfolder if they don't exist
subdir = sprintf('Test_%s', BatteryList{Battery});
if ~exist('output', 'dir')
    mkdir('output');
    mkdir(sprintf('output/%s', subdir));
else 
    mkdir(sprintf('output/%s', subdir));
end

% Define the name of the file where to log data
FileName = sprintf("output/%s/Test_DataLog_%s.txt", subdir, currentDateStr);
% Open the file where to log data; create the file if not present
newFileID = fopen(FileName, 'w+');
% Open the visualisation of the file where to log data
open(FileName);

% Wait some time before triggering the elog system
pause(1);

%% Perform capacity test

% Function to perform full discharge of the battery
[TimerEnd] = CompleteDischarge(visaObj, Vlimreal, Vlimlow, Ilev, newFileID);

%% Data processing

% Close the file where data are logged
fclose(newFileID);

% Re-open the file where data are logged in read mode
newFileID = fopen(FileName, 'r');

DataLog = fscanf(newFileID, '%f');

% Extract logged data
curr = DataLog(1:2:end);        % Current
volt = DataLog(2:2:end);        % Voltage

% Define time vector
Time = Ts:Ts:((length(DataLog)/2) * Ts);  

% Plot current and voltage during discharge
figure;
subplot(1, 2, 1)
plot(Time, curr);
title('Capacity Test - Current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(Time, volt);
title('Capacity Test - Voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the capacity of the battery
BatteryCapacity = (abs(Ilev) * TimerEnd)/60;            % [Ah]

fprintf("Battery capacity =  %g Ah\n", BatteryCapacity);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create struct of data
CapacityMeas = struct;
CapacityMeas.BatteryConfiguration = selectedVariable;
CapacityMeas.Time = Time;
CapacityMeas.Current = curr;
CapacityMeas.Voltage = volt;
CapacityMeas.TimeDischarge = TimerEnd;
CapacityMeas.Capacity = BatteryCapacity;

% Save the variable to the .mat file with the date-appended filename
save(fullfile(sprintf('output/%s', subdir), [sprintf('Test_%s', currentDateStr), '.mat'] ), "CapacityMeas");