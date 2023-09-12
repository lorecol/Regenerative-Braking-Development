clear all;
close all;
clc;

% Add files and folders to Matlab path
addpath(genpath(pwd))

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
Vliminstr = 5;      % [V] Voltage limit during CC - for the instrument
Ilev = 2;           % [A] Current level
Ts = 0.1;           % [s] Sampling time

% CCCV charge
Ilimneg = 0.2;      % [A] Current negative limit during CV
Ilimpos = 3;        % [A] Current positive limit during CV --> set higher than actual current level

% HPPC test
Vlimlow = 2.8;                              % [V] Voltage lower limit when discharging
SOC = 100;                                  % Initial SOC
disCapStep = 0.1;                           % 10% SOC decrement
capacity = 3;                               % [Ah] Nominal Capacity 
curr_discharge_pulse = -(2/3) * capacity;   % [A] 2/3C current for discharge pulse
curr_charge_pulse = (2/3) * capacity;       % [A] 2/3C current for charge pulse
dischargeC3= -(capacity/3);                 % [A] C/3 current for SOC discharge
t_discharge_pulse = 30;                     % [s] Discharge pulse time
t_charge_pulse = 10;                        % [s] Charge pulse time
t_rest_pulse = 40;                          % [s] Rest period between pulses
Rest = 20 * 60;                             % [min] Rest period between discharge cycles
Rest100SOC = 10 * 60;                       % [min] Rest period at full capacity

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
if ~exist('output/HPPC_Test', 'dir')
    mkdir('output/HPPC_Test');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output/HPPC_Test', [sprintf('Charge_%s', currentDateStr), '.mat'] ), "CCCVchargeMeas");

% Clear some variables
clear Vliminstr Ilimneg Ilimpos;
clear CurrCC VoltCC CurrCV VoltCV Time currentDateStr;

%% HPPC test

% This script follows the HPPC test procedure of 
% <https://www.osti.gov/biblio/1186745>

% Initialise number of samples
samples = 0;                  

% Pre-allocate data arrays
current = zeros(1, 10^6);
voltage = zeros(1, 10^6);
t = zeros(1, 10^6);

%%%%%%%%%%%%%%%%%%%%%%%%% Rest period at 100% SoC %%%%%%%%%%%%%%%%%%%%%%%%%

fprintf("   Rest at full charge for %g min\n", (Rest100SOC/60));

% Start the external timer
tic
for i = 1:((Rest100SOC) * (1/Ts))
    % Exit when the operation duration time is reached
    if toc >= Rest100SOC
        break;
    end

    % Update samples index
    samples = samples + 1;
    % Update time array
    t(samples) = Ts * samples;

    % Measure current and voltage and update data arrays
    current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
    voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage
    
    % Sampling time
    pause(Ts); 

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HPPC Test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We assume that the battery starts from 100% SOC, i.e. at full capacity

for cycle = 1:(1/disCapStep)

    fprintf("   Discharge cycle number: %g\n", cycle);

    %%%%%%%%%%%%%%%%%%%%%%%%%% Discharge pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Discharge 2/3C for 30s
    fprintf("      Impulsive discharge\n");
    
    % Set the power supply to current priority mode
    writeline(visaObj, ':SOURce:FUNCtion CURRENT');
    % Set the voltage limit
    writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
    % Set the output current
    writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', curr_discharge_pulse)); 

    % Turn the output on
    writeline(visaObj, ':OUTPut ON');  

    % Start the external timer
    tic
    % Exit when the operation duration time is reached
    for i = 1:((t_discharge_pulse) * (1/Ts))
        if toc >= t_discharge_pulse
            break;
        end

        % Update samples index
        samples= samples + 1;     
        % Update time array
        t(samples) = Ts * samples;

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

        % Sampling time
        pause(Ts);                      

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Update SoC
    SOC = calcSOC(SOC, capacity, curr_discharge_pulse, t_discharge_pulse);

    % Print the SoC value after pulse discharge
    fprintf("         SOC value: %g\n", SOC);

    % Turn the output off
    writeline(visaObj, ':OUTPut OFF');

    %%%%%%%%%%%%%%%%%%%%%%%%%%% Rest for 40s %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      Rest\n");

    % Start the external timer
    tic
    for i = 1:((t_rest_pulse) * (1/Ts))
        % Exit when the operation duration time is reached
        if toc >= t_rest_pulse
            break;
        end

        % Update samples index
        samples= samples + 1;     
        % Update time array
        t(samples) = Ts * samples;

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage
        
        % Sampling time
        pause(Ts); 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Charge pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Charge 2/3C for 30s
    fprintf("      Impulsive charge\n");

    % Set the power supply to current priority mode
    writeline(visaObj, ':SOURce:FUNCtion CURRENT');
    % Set the voltage limit
    writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
    % Set the output current
    writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', curr_charge_pulse));

    % Turn the output on
    writeline(visaObj, ':OUTPut ON'); 

    % Start the external timer
    tic
    for i = 1:((t_charge_pulse) * (1/Ts))
        % Exit when the operation duration time is reached
        if toc >= t_charge_pulse
            break;
        end

        % Update samples index
        samples= samples + 1;
        % Update time array
        t(samples) = Ts * samples;

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage
        
        % Sampling time
        pause(Ts);     

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Update SoC
    SOC = calcSOC(SOC, capacity, curr_charge_pulse, t_charge_pulse);

    % Print the SoC value after pulse charge
    fprintf("         SOC value: %g\n", SOC);
    
    % Initialize SoC
    SOC0 = SOC;

    % Turn the output OFF
    writeline(visaObj, ':OUTPut OFF');

    %%%%%%%%%%%%%%%%%%%%%%%%%% Discharge cycle %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Discharge C/3 for to the next SoC
    fprintf("      Start of Discharge\n");

    % Set the power supply to current priority mode
    writeline(visaObj, ':SOURce:FUNCtion CURRENT');
    % Set the voltage limit
    writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
    % Set the output current
    writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', dischargeC3));

    % Turn the output on
    writeline(visaObj, ':OUTPut ON');  

    % Start the external trigger
    tStart = tic;
    while SOC >= SOC0 - (1/disCapStep) * cycle
        tic;
        samples= samples + 1;           % Update samples
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));

        % Exit if the voltage is below the negative limit
        if voltage(samples) < Vlimlow
            disp("Voltage below the limit! Power-off");

            % Disable the output
            writeline(visaObj, ':OUTPut OFF');
            break;     
        end
        
        % Update time array
        t(samples) = Ts * samples;
        
        % Sampling time
        pause(Ts);                      
        
        % Update SoC
        SOC = calcSOC(SOC,capacity,dischargeC3,toc);

        % Print:
        %  - time to complete one iteration
        %  - external timer time
        %  - SoC updates 
        fprintf("         Titer: %g, Tsum: %g ; SOC: %g\n", toc, toc(tStart), SOC);

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      End of Discharge\n");

    % Disable the output
    writeline(visaObj, ':OUTPut OFF');

    %%%%%%%%%%%%%%%%%%%%%%%%%% Rest for 20min %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      Rest before next cycle\n");

    % Start the external timer
    tic
    for i = (1:(Rest) * (1/Ts))
        % Exit when the operation duration time is reached
        if toc >= Rest
            break;
        end

        % Update samples index
        samples= samples + 1;

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage
        
        % Update time array
        t(samples) = Ts * samples;
        
        % Sampling time
        pause(Ts); 

    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Insert measurement data inside a structure
HPPCMeas = struct;
HPPCMeas.Current = current;         % Current
HPPCMeas.Voltage = voltage;         % Voltage
HPPCMeas.Time = t;                  % Time

% Plot voltage and current during the test
figure;
subplot(1, 2, 1)
plot(t, current);
title('HPPC Test - current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(t, voltage);
title('HPPC Test - voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

% Save voltage and current measurement in an external file
% Create the output subfolder if it doesn't exist
if ~exist('output/HPPC_Test', 'dir')
    mkdir('output/HPPC_Test');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output/HPPC_Test',[sprintf('Test_%s', currentDateStr),'.mat'] ), 'HPPCMeas')

% Clear some variables
% ...
% ...