%% Clear variables
clear all; close all; clc;
addpath(genpath(pwd))

%% Estabilish connection with the instrument
disp('STEP 1 - ENABLE COMMUNICATION WITH THE INSTRUMENT:');
power_supply = PowerSupply;

%% CC-CV charge
disp('STEP 2 - BATTERY CHARGING:');
% Data
Ts = 0.1;           % [s] Sampling time
Ilev = 2;           % [A] Current level during CC
Vliminstr = 4.4;    % [V] Voltage limit during CC - for the instrument
Vlimreal = 4.2;     % [V] Voltage limit during CC - real application
Ilimneg = 0.2;      % [A] Current negative limit during CV
Ilimpos = 2;        % [A] Current positive limit during CV

%%%%%%%%%%%%%%%%%%%%%%%%%%% CC CHARGE CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the operating mode to CC
disp('- CC MODE:');
power_supply.CCmode(Vliminstr, Ilev);
pause(0.5);
power_supply.turnON;                        % Enable the output
idx = 0;                                    % Initialize index for data collection

% Take a first measure
dc_ICC = power_supply.measureCurrent;
dc_VCC = power_supply.measureVoltage;
idx = idx + 1;                              % Update index

% Update the measurement arrays after first measure
CurrCC(idx) = dc_ICC;                       % [A] Current
VoltCC(idx) = dc_VCC;                       % [V] Voltage

% Continue until the voltage reaches the imposed limit
while dc_VCC < Vlimreal
    pause(Ts);                              % [s] Sampling time
    dc_ICC = power_supply.measureCurrent;   % [A] Measure current
    dc_VCC = power_supply.measureVoltage;   % [V] Measure voltage
    idx = idx + 1;                          % Update index

    % Update the measurement arrays after each measure
    CurrCC(idx) = dc_ICC;
    VoltCC(idx) = dc_VCC;

end

% Shut down the output
power_supply.turnOFF;
disp('  CC charge completed.');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% CV CHARGE CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the operating mode to CV
disp('- CV MODE:');
power_supply.CVmode(Ilimneg, Ilimpos, VoltCC(end))
pause(0.5);
power_supply.turnON;                        % Enable the output
idx = 0;                                    % Initialize index for data collection

% Take a first measure
dc_ICV = power_supply.measureCurrent;       % [A] Current
dc_VCV = power_supply.measureVoltage;       % [V] Voltage
idx = idx + 1;                              % Update index

% Update the measurement arrays after first measure
CurrCV(idx) = dc_ICV;
VoltCV(idx) = dc_VCV;

% Continue until the current reaches the imposed negative limit
while dc_ICV > 0.2
    pause(Ts);                              % Sampling time
    dc_ICV = power_supply.measureCurrent;   % Measure current
    dc_VCV = power_supply.measureVoltage;   % Measure voltage
    idx = idx + 1;                          % Update index

    % Update the measurement arrays after each measure
    CurrCV(idx) = dc_ICV;
    VoltCV(idx) = dc_VCV;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Shut down the output
power_supply.turnOFF;
disp('  CV charge completed.');

% Charge completed
disp('>> The battery is fully charged !! <<');

% Plot voltage and current during CCCV charge
% Concatenate the measurements
if exist('CurrCC','var')==0 && exist('CurrCV','var')==0
    print("No data available")
elseif exist('CurrCC','var')==1 && exist('CurrCV','var')==0
    CurrCharge=CurrCC;
    VoltCharge=VoltCC;
elseif exist('CurrCC','var')==1 && exist('CurrCV','var')==1
    CurrCharge = [CurrCC; CurrCV];          % [A] Current
    VoltCharge = [VoltCC; VoltCV];          % [V] Voltage
end

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

% Save voltage and current measurement in an external file
% Create the output subfolder if it doesn't exist
if ~exist('output', 'dir')
    mkdir('output');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output',[sprintf('charge_data_%s', currentDateStr),'.mat'] ), 'CurrCharge', 'VoltCharge')

% Clear some variables
clear Ts Ilev Vliminstr Vlimreal Ilimneg Ilimpos maxReadings;
clear idx dc_ICC dc_ICC dc_ICV dc_VCV CurrCC VoltCC CurrCV VoltCV;

%% DISCHARGE CYCLES - HPPC
% This script follow the HPPC test procedure of
% <https://www.osti.gov/biblio/1186745>
disp("STEP 3 - HPPC TEST");

% Data
capacity = 3;                           % [Ahr] Nominal Capacity 
SOC = 100;                              % [%] Initial SOC
discharge1C = -3;                       % [A] 1C current
t_discharge1C = 30;                     % [s]
t_charge1C = 10;                        % [s]
t_rest_charge_discharge = 40;           % [s]
charge1C = 3;                           % [A] 1C current
dischargeC3= -1;                         % [A] C/3 current
Vlimreal = 4.2;                         % [V] Voltage limit during discharge
Vlimlow = 2.55;                         % [V] Lower voltage limit during discharge
Ts = 0.1;                               % [s] Sampling time
disCapStep = 0.1;                       % [%] 10% SOC decrease in each discharge
Rest = 60;                              % [s] rest before starting procedure

% Initialize variables 
t = 0;                                  % Initialize time array
samples = 0;                            % Initialize samples array

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REST PERIOD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measure the OCV at 100% SOC during the rest phase
fprintf("%g minutes rest period ...\n", Rest);
for i = 1:(Rest*60)*1/Ts
    samples = samples + 1;              % Update samples
    current(samples) = power_supply.measureCurrent; % [A] Measure current
    voltage(samples) = power_supply.measureVoltage; % [V] Measure voltage
    
    % Update time array
    t(samples) = t(end) + Ts;
    pause(Ts);                          % Sampling time
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%% STARTING CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We assume that the battery starts from 100% SOC
for cycle = 1:1/disCapStep
    fprintf("Discharge cycle number: %g\n", cycle);
    fprintf("HPPC profile")

    % Discharge 1C for 30s
    power_supply.CCmode(Vlimreal,discharge1C);
    pause(0.5); 
    % turn the output on
    power_supply.turnON;                
    for i=1:(t_discharge1C)*1/Ts
        samples= samples + 1;           % Update samples
        current(samples) = power_supply.measureCurrent; % [A] Measure current
        voltage(samples) = power_supply.measureVoltage; % [V] Measure voltage
        
        % Update time array
        t(samples) = t(end) + Ts;
        pause(Ts);                      % Sampling time
    end
    % Update SOC
    SOC = calcSOC(SOC,capacity,discharge1C,t_discharge1C);

    % turn the output off
    power_supply.turnOFF;
    
    % Rest 40s
    for i=1:(t_rest_charge_discharge)*1/Ts
        samples= samples + 1;           % Update samples
        current(samples) = power_supply.measureCurrent; % [A] Measure current
        voltage(samples) = power_supply.measureVoltage; % [V] Measure voltage
        
        % Update time array
        t(samples) = t(end) + Ts;
        pause(Ts); % Sampling time
    end
    % Here we don't need to to update SOC since no current has been sinked
    
    % Charge 1C for 10s
    power_supply.CCmode(Vlimreal,charge1C);
    pause(0.5); 
    % turn the output on
    power_supply.turnON;                
    for i=1:(t_charge1C)*1/Ts
        samples= samples + 1;           % Update samples
        current(samples) = power_supply.measureCurrent; % [A] Measure current
        voltage(samples) = power_supply.measureVoltage; % [V] Measure voltage
        
        % Update time array
        t(samples) = t(end) + Ts;
        pause(Ts);                      % Sampling time
    end
    % Update SOC
    SOC = calcSOC(SOC,capacity,charge1C,t_charge1C);

    % turn the output OFF
    power_supply.turnOFF

    % Discharge C/3 for to the next SOC
    power_supply.CCmode(Vlimreal,dischargeC3);
    pause(0.5); 
    % turn the output on
    power_supply.turnON;  
    while SOC >= 100 - 1/disCapStep*cycle
        samples= samples + 1;           % Update samples
        current(samples) = power_supply.measureCurrent; % [A] Measure current
        voltage(samples) = power_supply.measureVoltage; % [V] Measure voltage
        
        % Update time array
        t(samples) = t(end) + Ts;
        
        % Update SOC
        SOC = calcSOC(SOC,capacity,dischargeC3,Ts);
        pause(Ts);                      % Sampling time
        
        % Exit if the voltage is below the negative limit
        if voltage(end) < Vlimlow
            disp("Voltage below the limit! Power-off")
            % Disable the output
            power_supply.turnOFF;
            break;     
        end
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot voltage and current during the discharge cycles
figure;
subplot(1, 2, 1)
plot(t, current);
title('Discharge cycle - current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(t, voltage);
title('Discharge cycle - voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

% Save voltage and current measurement in an external file
% Create the output subfolder if it doesn't exist
if ~exist('output', 'dir')
    mkdir('output');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output',[sprintf('HPPC_data_%s', currentDateStr),'.mat'] ), 'current', 'voltage')

% Clear some variables

clear Rest Ts Tdis Ilev Vlimreal disCapStep numDisCycles maxReadingsDis maxReadingsRest;
clear idx i cycle;

