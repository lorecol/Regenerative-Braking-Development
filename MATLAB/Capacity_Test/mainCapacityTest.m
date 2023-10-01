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

%% Let the user choose which battery configuration to test

BatteryList = {'SingleCell', 'Block'};
Battery = listdlg('PromptString', {'For which type of battery do you want to test the capacity?', ''}, ...
               'ListString', BatteryList, 'SelectionMode', 'single'                                       );

% Check if a battery configuration has been selected
if ~isempty(Battery)
    selectedVariable = BatteryList{Battery};
else
    fprintf('No battery configuration selected.\n');
end

% Battery configuration
if strcmp(selectedVariable, 'SingleCell') == 1
    parallel = 1;               % Number of parallels          
    series = 1;                 % Number of series
elseif strcmp(selectedVariable, 'Block') == 1
    parallel = 4;               % Number of parallels          
    series = 3;                 % Number of series
end

%% Data

Vlimreal = 4.2 * series;     % [V] Voltage upper limit when discharging
Vlimlow = 2.5 * series;      % [V] Voltage lower limit when discharging
Ilev = 2 * parallel;         % [A] Current level
Ts = 0.1;                    % [s] Sampling time

%% Initialize the instrument

% Select data format
writeline(visaObj, ":FORM:DATA ASCii");

% Enable voltage measurements
writeline(visaObj, ':SENSe:FUNCtion:VOLTage ON');

% Disable voltage measurements
writeline(visaObj, ':SENSe:FUNCtion:CURRent OFF');

% Enable voltage log
writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage:MINMax OFF');

% Disable current log
writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent:MINMax OFF');

writeline(visaObj, sprintf(':SENS:ELOG:PER %g', Ts));

% Select trigger source for datalog
writeline(visaObj, 'TRIGger:TRANsient:SOURce BUS');

% Initialize acquisition system
writeline(visaObj, ':INIT:ACQ');

% Initialize the elog system
writeline(visaObj, ':INITiate:IMMediate:ELOG');

disp('Initialization done.');

%% Open the .txt file where to log test data

% Create the output subfolder if it doesn't exist
if ~exist('output', 'dir')
    mkdir('output');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Define the name of the file where to log data
FileName = sprintf("output/Test_%s_DataLog_%s.txt", BatteryList{Battery}, currentDateStr);
% Open the file where to log data; create the file if not present
newFileID = fopen(FileName, 'w+');
% Open the visualisation of the file where to log data
open(FileName);

% Wait some time before triggering the elog system
pause(0.1);

%% Capacity test

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

% Plot current and voltage during charge
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

fprintf("\nBattery capacity: %g Ah\n", BatteryCapacity);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create struct of data
CapacityMeas.TimeDis = TimerEnd;
CapacityMeas.Time = Time;
CapacityMeas.Current = curr;
CapacityMeas.Voltage = volt;
CapacityMeas.Capacity = BatteryCapacity;

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output', [sprintf('Test_%s_%s', BatteryList{Battery}, currentDateStr), '.mat'] ), "CapacityMeas");