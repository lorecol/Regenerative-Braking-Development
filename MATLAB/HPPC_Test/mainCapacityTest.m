clear all;
close all;
clc;

addpath(genpath(pwd));

%% Estabilish connection with the instrument

disp('STEP 1 - ENABLE COMMUNICATION WITH THE INSTRUMENT:');

% Load VISA library
Instrlist = visadevlist;
% Create VISA object
visaObj = visadev(Instrlist.ResourceName);

% Set the timeout value
visaObj.Timeout = 10;       % [s]

% Check if the connection is successful
if strcmp(visaObj.Status, 'open')
    disp('  Instrument connection established.');
else
    error('  Failed to connect to the instrument.');
end

%% Initialization

disp('STEP 2 - INITIALIZE THE INSTRUMENT:');

% Reset the instrument to pre-defined values 
writeline(visaObj, '*RST');
% Clear status command
writeline(visaObj, '*CLS');

% Enable voltage measurements
writeline(visaObj, ':SENSe:FUNCtion:VOLTage ON');

% Enable current measurements
writeline(visaObj, ':SENSe:FUNCtion:CURRent ON');

% Initialize acquisition
writeline(visaObj, ':INITiate:IMMediate:ACQuire');

disp('  Initialization done.');

%% CC-CV charge

% Data
Ts = 0.1;           % [s] Sampling time
Ilev = 2;           % [A] Current level during CC
Vliminstr = 4.4;    % [V] Voltage limit during CC - for the instrument
Vlimreal = 4.2;     % [V] Voltage limit during CC - real application

Ilimneg = 0.2;      % [A] Current negative limit during CV
Ilimpos = 2;        % [A] Current positive limit during CV

% Function to perform the CCCV charging operation
[CurrCC, VoltCC, CurrCV, VoltCV] = CCCVcharge(visaObj, Vliminstr, Vlimreal, Ilev, Ilimneg, Ilimpos, Ts);

% Concatenate the measurements 
if exist('CurrCC', 'var') == 0 && exist('CurrCV', 'var') == 0
    print("No available data !!");
elseif exist('CurrCC', 'var') == 1 && exist('CurrCV', 'var') == 1
    CurrCharge = [CurrCC; CurrCV]; % Current
    VoltCharge = [VoltCC; VoltCV]; % Voltage
    % Insert measurement data inside a structure
    CCCVchargeMeas = struct;
    CCCVchargeMeas.CurrCharge = CurrCharge;         % Current
    CCCVchargeMeas.VoltCharge = VoltCharge;         % Voltage
end

% Plot current and voltage during charge
figure;
subplot(1, 2, 1)
plot(1:length(CurrCharge), CurrCharge);
title('CCCV charge - Current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(1:length(VoltCharge), VoltCharge);
title('CCCV charge - Voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

% Create the output subfolder if it doesn't exist
if ~exist('CapacityTest', 'dir')
    mkdir('CapacityTest');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('CapacityTest', [sprintf('CCCVcharge_%s', currentDateStr), '.mat'] ), "CCCVchargeMeas");

% Clear some variables
clear Ts Ilev Vliminstr Vlimreal Ilimneg Ilimpos maxReadings;
clear idx dc_ICC dc_ICC dc_ICV dc_VCV CurrCC VoltCC CurrCV VoltCV CurrCharge VoltCharge CCCVchargeMeas currentDateStr;

%% CAPACITY TEST

% Data
BatteryVolt = 3.6;  % Nominal battery voltage
Vlimreal = 4.2;     % Voltage upper limit when discharging
Vlimlow = 2.8;      % Voltage lower limit when discharging
Ilev = -2.0;        % Current level when discharging
Ts = 0.1;           % Sampling time

% Function to perform full discharge of the battery
[VoltCapacity, CurrCapacity, time] = CompleteDischarge(visaObj, Vlimreal, Vlimlow, Ilev, Ts);

% Concatenate the measurements 
if exist('VoltCapacity', 'var') == 0 && exist('CurrCapacity', 'var') == 0
    print("No available data !!");
elseif exist('VoltCapacity', 'var') == 1 && exist('CurrCapacity', 'var') == 1
    % Insert measurement data inside a structure
    CapacityMeas = struct;
    CapacityMeas.CapVolt = VoltCapacity;         % Voltage
    CapacityMeas.CapCurr = CurrCapacity;         % Current
    CapacityMeas.Time    = time;                 % Time
end

% Plot current and voltage during charge
figure;
subplot(1, 2, 1)
plot(time, CurrCapacity);
title('Capacity Test - Current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(time, VoltCapacity);
title('Capacity Test - Voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

% Create the output subfolder if it doesn't exist
if ~exist('CapacityTest', 'dir')
    mkdir('CapacityTest');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('CapacityTest', [sprintf('CapacityTest_%s', currentDateStr), '.mat'] ), "CapacityMeas");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the capacity of the battery
BatteryCapacity = trapz(time, CurrCapacity)/3600;              % [Ah]
% BatteryCapacity = DisCapacity/(BatteryVolt * 3600);          % [Ah]

fprintf("Battery capacity: %g Ah\n", BatteryCapacity);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear some variables
clear Ts Ilev Vlimreal Vlimlow;
clear idx time VoltCapacity CurrCapacity CapacityMeas currentDateStr;

%% DATA PROCESSING

% Time = CapacityMeas.Time;           Time = Time';
% CapCurr = CapacityMeas.CapCurr;     CapCurr = CapCurr';
% CapVolt = CapacityMeas.CapVolt;     CapVolt = CapVolt';
% 
% % Keep only meaningful data: current ~ -2.0 V
% CapCurr = CapCurr(CapCurr < -1.9996);
% l = length(CapCurr);
% CapVolt = CapVolt(1:l);
% Time = Time(1:l);
% 
% figure;
% plot(Time, CapCurr);
% 
% figure;
% plot(Time, CapVolt);