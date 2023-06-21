clear all;
close all;
clc;

%% Instrument connection

% Load the VISA library and create a VISA object. Make sure to insert the 
% appropriate instrument address
visaObj = visadev('  ');

% Set the timeout value, i.e. the max time duration that MATLAB will wait 
% to receive a response from the instrument before considering the 
% operation as timed out
visaObj.Timeout = 10;       % [s]

% Check if the connection is successful
if strcmp(visaObj.Status, 'open')
    disp('Instrument connection established.');
else
    error('Failed to connect to the instrument.');
end

%% Send commands to charge the battery using CCCV

% Set the charging mode to Constant Current (CC) mode
writeline(visaObj, 'CC:ON');

% Set the current to 2A
writeline(visaObj, 'CURRent 2');

% Set the voltage to the maximum limit of 4.20V
writeline(visaObj, 'VOLTage 4.20');

% Enable the output
writeline(visaObj, 'OUTPut ON');

% Wait for the battery to reach the desired state of charge (SOC) of 100%
writeline(visaObj, 'SOC:WAIT 100');

% Rest for 30 minutes
writeline(visaObj, 'WAIT:TIME 1800'); % 30 minutes

%% Discharge the battery from 100% to 5% SOC with steps of 5% SOC

% Define test parameters
initialSOC       = 100;     % starting SOC in percentage
targetSOC        = 5;       % target SOC in percentage
dischargeCurrent = -4;      % discharge current of 4A

% Create data logging variables
time    = [];
voltage = [];
current = [];
SOC     = [];

% Define the data logging function
logData = @(visaObj) logBatteryData(visaObj, time, voltage, current, SOC);

% Start the data logging in parallel
t = parfeval(@() logData(visaObj));

% Execute the test sequence
while initialSOC > targetSOC
    % Discharge at the specified current for 5 minutes
    writeline(visaObj, ['CURRent ' num2str(dischargeCurrent)]);
    writeline(visaObj, 'OUTPut ON');
    writeline(visaObj, 'WAIT:TIME 300'); % 5 minutes
    writeline(visaObj, 'OUTPut OFF');

    % Update the SOC values
    initialSOC = initialSOC - 5;

    % Display the current SOC
    disp(['Current SOC: ' num2str(initialSOC) '%']);

    % Rest for 30 minutes
    writeline(visaObj, 'REST:TIME 1800'); % 30 minutes
    
end

% Stop the data logging
cancel(t);
wait(t);

% Retrieve the logged data
time = fetchOutputs(t);

% Close the instrument connection and clean up the VISA object
clear visaObj;

% Extract the logged data
voltage = time{1};
current = time{2};
SOC     = time{3};
time    = time{4};