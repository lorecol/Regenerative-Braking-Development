clear all;
close all;
clc;

%% Estabilish connection with the instrument

% Load VISA library
Instrlist = visadevlist;
% Create VISA object
visaObj = visadev(Instrlist.ResourceName);

% Set the timeout value
visaObj.Timeout = 10;       % [s]

% Check if the connection is successful
if strcmp(visaObj.Status, 'open')
    disp('Instrument connection established.');
else
    error('Failed to connect to the instrument.');
end

%% Initialization

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

disp('Initialization done.');

%% Data

% Common data
Vlimreal = 4.2;     % [V] Voltage upper limit when discharging
Ilev = 2;           % [A] Current level
Ts = 0.1;           % [s] Sampling time

% CCCV charge
Vliminstr = 4.4;    % [V] Voltage limit during CC - for the instrument
Ilimneg = 0.2;      % [A] Current negative limit during CV
Ilimpos = 3;        % [A] Current positive limit during CV --> set higher than actual current level

% Capacity test
Vlimlow = 2.8;      % [V] Voltage lower limit when discharging

%% CC-CV charge

% Function to perform the CCCV charging operation
[CurrCC, VoltCC, CurrCV, VoltCV] = CCCVcharge(visaObj, Vliminstr, Vlimreal, Ilev, Ilimneg, Ilimpos, Ts);

% Extract time array
Time = Ts:Ts:((length(CurrCC) + length(CurrCV)) * Ts);

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
    CCCVchargeMeas.Time = Time;                     % Time
end

% Plot current and voltage during charge
figure;
subplot(1, 2, 1)
plot(Time, CurrCharge);
title('CCCV charge - Current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(Time, VoltCharge);
title('CCCV charge - Voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

% Create the output subfolder if it doesn't exist
if ~exist('output/CapacityTest', 'dir')
    mkdir('output/CapacityTest');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output/CapacityTest', [sprintf('Charge_%s', currentDateStr), '.mat'] ), "CCCVchargeMeas");

% Clear some variables
clear Vliminstr Ilimneg Ilimpos;
clear CurrCC VoltCC CurrCV VoltCV Time currentDateStr;

%% Wait some time before performing capacity test

% Wait 30 minutes before performing capacity test
WaitBar("Rest period before capacity test...", 30);

%% Capacity test

% Function to perform full discharge of the battery
[VoltCapacity, CurrCapacity, Time, TimerEnd] = CompleteDischarge(visaObj, Vlimreal, Vlimlow, Ilev, Ts);

% Concatenate the measurements 
if exist('VoltCapacity', 'var') == 0 && exist('CurrCapacity', 'var') == 0
    print("No available data !!");
elseif exist('VoltCapacity', 'var') == 1 && exist('CurrCapacity', 'var') == 1
    % Insert measurement data inside a structure
    CapacityMeas = struct;
    CapacityMeas.CapVolt = VoltCapacity;         % Voltage
    CapacityMeas.CapCurr = CurrCapacity;         % Current
    CapacityMeas.Time = Time;                    % Time
    CapacityMeas.Timer = TimerEnd;               % Discharge time [min]
end

% Plot current and voltage during charge
figure;
subplot(1, 2, 1)
plot(Time, CurrCapacity);
title('Capacity Test - Current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(Time, VoltCapacity);
title('Capacity Test - Voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

% Create the output subfolder if it doesn't exist
if ~exist('output/CapacityTest', 'dir')
    mkdir('output/CapacityTest');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output/CapacityTest', [sprintf('Test_%s', currentDateStr), '.mat'] ), "CapacityMeas");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the capacity of the battery
BatteryCapacity = (abs(Ilev) * TimerEnd)/3600;              % [Ah]

fprintf("\nBattery capacity: %g Ah\n", BatteryCapacity);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear some variables
clear Ts Ilev Vlimreal Vlimlow;
clear VoltCapacity CurrCapacity Time TimerEnd BatteryCapacity currentDateStr;