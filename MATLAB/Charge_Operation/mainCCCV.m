%
% ---------------------------- CCCV CHARGE --------------------------------
% -------------------------------------------------------------------------

% This script is used to charge the battery through CCCV (Constant Current 
% Constant Voltage) algorithm. Operation switches between CC charging, 
% which charges with a constant current, and CV that charges at a constant 
% voltage, depending on the voltage of the rechargeable battery.
%
%  - Constant current charging is a method of continuously charging a 
%    rechargeable battery at a constant current to prevent overcurrent 
%    charge conditions. The operation continues until the voltage reaches 
%    an upper limit, which is defined by the manufacturer (typically 4.20 V
%    for lithium-ion batteries)
%
%  - Constant voltage charging is a method of charging at a constant 
%    voltage to prevent overcharging. The charging current is initially 
%    high then gradually decreases, until it reaches a lower limit, which
%    is defined by the manufacturer (typically 200 mA for lithium-ion 
%    batteries)

%% Initialization

close all;
clear all;
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

%% Let the user choose which battery configuration to charge

BatteryList = {'SingleCell', 'Block'};
Battery = listdlg('PromptString', {'For which type of battery do you want to fit the data?', ''}, ...
               'ListString', BatteryList, 'SelectionMode', 'single'                                  );

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
    disp('You are charging a single cell.');
elseif strcmp(selectedVariable, 'Block') == 1
    parallel = 4;               % Number of parallels          
    series = 3;                 % Number of series
    disp('You are charging a block - 3s4p configuration.');
end

%% Data                                                    

Vlimreal = 4.2 * series;        % [V] Voltage upper limit when discharging
Vliminstr = 5 * series;         % [V] Voltage limit during CC - for the instrument
Vlimlow = 2.5 * series;         % [V] Voltage lower limit when discharging
Ilev = 2 * parallel;            % [A] Current level
Ilimpos = Ilev + 1;             % [A] Current limit during CV
Ts = 0.1;                       % [s] Sampling time

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

%% Open the .txt file where to log test data

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd');

% Create the output folder and the test subfolder if they don't exist
subdir = sprintf('Test_%s_%s', BatteryList{Battery}, currentDateStr);
if ~exist('output', 'dir')
    mkdir('output');
    mkdir(sprintf('output/%s', subdir));
else 
    mkdir(sprintf('output/%s', subdir));
end

% Define the name of the file where to log data
FileName = sprintf("output/%s/CCCVCharge_DataLog.txt", subdir);
% Open the file where to log data; create the file if not present
newFileID = fopen(FileName, 'w+');
% Open the visualisation of the file where to log data
open(FileName);

% Wait some time before triggering the elog system
pause(1);

%% Perform CCCV charge

% Function to perform full charge of the battery
CCCVcharge(visaObj, newFileID, Vliminstr, Vlimreal, Ilev, Ilimpos);

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
title('CCCV charge - Current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(Time, volt);
title('CCCV charge - Voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

% Create struct of data
CCCVCharge = struct;
CCCVCharge.BatteryConfiguration = selectedVariable;
CCCVCharge.Time = Time;
CCCVCharge.Current = curr;
CCCVCharge.Voltage = volt;

% Save the variable to the .mat file with the date-appended filename
save(fullfile(sprintf('output/%s', subdir), ['CCCVCharge_Dataset', '.mat'] ), "CCCVCharge");