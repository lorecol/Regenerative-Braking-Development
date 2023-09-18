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

fprintf("\n");

%% Data

Vlimreal = 4.2;                             % [V] Voltage upper limit when discharging
Vliminstr = 5;                              % [V] Voltage limit during CC - for the instrument
Vlimlow = 2.8;                              % [V] Voltage lower limit when discharging
Ilev = 2;                                   % [A] Current level
Ts = 0.1;                                   % [s] Sampling time
SOC = 100;                                  % Actual SoC measured by Coulomb counting method
soc = 100;                                  % SoC variable to keep track of discharge cycles
capacity = 3;                               % [Ah] Nominal Capacity 
curr_discharge_pulse = -(2/3) * capacity;   % [A] 2/3C current for discharge pulse
curr_charge_pulse = (2/3) * capacity;       % [A] 2/3C current for charge pulse
dischargeC3= -(capacity/3);                 % [A] C/3 current for SOC discharge
t_discharge_pulse = 30;                     % [s] Discharge pulse time
t_charge_pulse = 10;                        % [s] Charge pulse time
t_rest_pulse = 40;                          % [s] Rest period between pulses
disCapStep = 0.1;                           % 10% SOC decrement
Rest = 5 * 60;                              % [min] Rest period between discharge cycles
Rest100SOC = 5 * 60;                        % [min] Rest period at full capacity
cycle = 0;                                  % Variable to keep track of cycles number

%% HPPC test

% This script takes inspiration from the HPPC test procedure of 
% <https://www.osti.gov/biblio/1186745>

% Initialise number of samples
samples = 1;                  

% Pre-allocate data arrays
current = zeros(1, 10^6);               % Current
voltage = zeros(1, 10^6);               % Voltage
State_of_Charge = zeros(1, 10^6);       % SoC
t = zeros(1, 10^6);                     % Time

% Configure real-time plot of data
v = animatedline('Color', 'b', 'LineWidth', 2);             % Voltage
i = animatedline('Color', 'r', 'LineWidth', 2);             % Current
axis([0 samples -Vliminstr  Vliminstr]);

%%%%%%%%%%%%%%%%%%%%%%%%% Rest period at 100% SoC %%%%%%%%%%%%%%%%%%%%%%%%%

fprintf("   Rest at full charge for %g sec\n", Rest100SOC);

% Start the external reference timer
tCycle = tic;

% Loop until the operation duration time is reached
while toc(tCycle) < Rest100SOC

    % Measure current and voltage and update data arrays
    current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
    voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

    % Update axis of real-time plot
    axis([0 samples -Vliminstr Vliminstr]);

    % Real-time plot of the voltage
    addpoints(v, t(samples), voltage(samples));
    drawnow
    % Real-time plot of the current
    addpoints(i, t(samples), current(samples));
    drawnow

    % Update samples index
    samples = samples + 1;
    % Update time array
    t(samples) = toc(tCycle);

    
    % Sampling time
    pause(Ts); 

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HPPC Test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We assume that the battery starts from 100% SOC, i.e. at full capacity

while (soc > 0) && (soc <= 100) 

    % Update number of cycle and print it
    cycle = cycle + 1;
    fprintf("   Discharge cycle number: %g\n", cycle);

    %%%%%%%%%%%%%%%%%%%%%%%%%% Discharge pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Discharge 2/3C
    fprintf("      Impulsive discharge for %g sec\n", t_discharge_pulse);
    
    % Set the power supply to current priority mode
    writeline(visaObj, ':SOURce:FUNCtion CURRENT');
    % Set the voltage limit
    writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
    % Set the output current
    writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', curr_discharge_pulse)); 

    % Turn the output on
    writeline(visaObj, ':OUTPut ON');  

    % Track the start of the operation
    InDisImp = toc(tCycle);

    % Loop until the operation duration time is reached
    while toc(tCycle) < (InDisImp + t_discharge_pulse)

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

        % Update axis of real-time plot
        axis([0 samples -Vliminstr Vliminstr]);

        % Real-time plot of the voltage
        addpoints(v, t(samples), voltage(samples));
        drawnow
        % Real-time plot of the current
        addpoints(i, t(samples), current(samples));
        drawnow

        % Update samples index
        samples = samples + 1;     
        % Update time array
        t(samples) = toc(tCycle);

        % Sampling time
        pause(Ts);                      

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Turn the output off
    writeline(visaObj, ':OUTPut OFF');

    % Update actual SoC and print it
    SOC = calcSOC(SOC, capacity, curr_discharge_pulse, t_discharge_pulse);
    fprintf("         SOC value: %g\n", SOC);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 40s Rest %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      Rest for %g sec\n", t_rest_pulse);

    % Track the start of the operation
    InRest40 = toc(tCycle);

    % Loop until the operation duration time is reached
    while toc(tCycle) < (InRest40 + t_rest_pulse)

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

        % Update axis of real-time plot
        axis([0 samples -Vliminstr Vliminstr]);

        % Real-time plot of the voltage
        addpoints(v, t(samples), voltage(samples));
        drawnow
        % Real-time plot of the current
        addpoints(i, t(samples), current(samples));
        drawnow

        % Update samples index
        samples = samples + 1;     
        % Update time array
        t(samples) = toc(tCycle);
        
        % Sampling time
        pause(Ts); 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Charge pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Charge 2/3C
    fprintf("      Impulsive charge for %g sec\n", t_charge_pulse);

    % Set the power supply to current priority mode
    writeline(visaObj, ':SOURce:FUNCtion CURRENT');
    % Set the voltage limit
    writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
    % Set the output current
    writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', curr_charge_pulse));

    % Turn the output on
    writeline(visaObj, ':OUTPut ON'); 

    % Track the start of the operation
    InChImp = toc(tCycle);

    % Loop until the operation duration time is reached
    while toc(tCycle) < (InChImp + t_charge_pulse)

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

        % Update axis of real-time plot
        axis([0 samples -Vliminstr Vliminstr]);

        % Real-time plot of the voltage
        addpoints(v, t(samples), voltage(samples));
        drawnow
        % Real-time plot of the current
        addpoints(i, t(samples), current(samples));
        drawnow

        % Update samples index
        samples = samples + 1;     
        % Update time array
        t(samples) = toc(tCycle);
        
        % Sampling time
        pause(Ts);     

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Turn the output OFF
    writeline(visaObj, ':OUTPut OFF');

    % Update actual SoC and print it
    SOC = calcSOC(SOC, capacity, curr_charge_pulse, t_charge_pulse);
    fprintf("         SOC value: %g\n", SOC);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 40s Rest %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      Rest for %g sec\n", t_rest_pulse);

    % Track the start of the operation
    InRest40bis = toc(tCycle);

    % Loop until the operation duration time is reached
    while toc(tCycle) < (InRest40bis + t_rest_pulse)

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

        % Update axis of real-time plot
        axis([0 samples -Vliminstr Vliminstr]);

        % Real-time plot of the voltage
        addpoints(v, t(samples), voltage(samples));
        drawnow
        % Real-time plot of the current
        addpoints(i, t(samples), current(samples));
        drawnow

        % Update samples index
        samples = samples + 1;     
        % Update time array
        t(samples) = toc(tCycle);
        
        % Sampling time
        pause(Ts); 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Define a new SoC variable for iterating the discharge cycles
    SOC0 = SOC;

    %%%%%%%%%%%%%%%%%%%%%%%%%% Discharge cycle %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Discharge C/3 to reach the next SoC value
    fprintf("      Discharge %g %% of the State of Charge\n", (1/disCapStep));

    % Set the power supply to current priority mode
    writeline(visaObj, ':SOURce:FUNCtion CURRENT');
    % Set the voltage limit
    writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
    % Set the output current
    writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', dischargeC3));

    % Turn the output on
    writeline(visaObj, ':OUTPut ON');  

    % Loop until the battery is discharged by the desired percentage
    while SOC >= (SOC0 - 1/disCapStep)

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

        % Update axis of real-time plot
        axis([0 samples -Vliminstr Vliminstr]);

        % Real-time plot of the voltage
        addpoints(v, t(samples), voltage(samples));
        drawnow
        % Real-time plot of the current
        addpoints(i, t(samples), current(samples));
        drawnow

        % Update samples index
        samples = samples + 1;     
        % Update time array
        t(samples) = toc(tCycle);

        % Exit if the undervoltage condition is reached
%         if voltage(samples) < Vlimlow
%             disp("The voltage is below the limit! Power-off.");
% 
%             % Disable the output
%             writeline(visaObj, ':OUTPut OFF');
%             break;     
%         end
        
        % Sampling time
        pause(Ts);                      
        
        % Update actual SoC
        SOC = calcSOC(SOC, capacity, dischargeC3, (t(samples) - t(samples - 1)));

        % Print:
        %  - number of cycle
        %  - time values
        %  - SoC updates
        %  - SoC goal
        fprintf("         Cycle: %g ; time: %g ; SOC: %g ; Goal: %g\n", cycle, toc(tCycle), SOC, (SOC0 - (1/disCapStep)));

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Update SoC array
    State_of_Charge(cycle) = SOC;

    % Exit the main loop if actual SoC is less than the percentage step during
    % discharge
    if (SOC - 0.3704) < (1/disCapStep)

        % Disable the output
        writeline(visaObj, ':OUTPut OFF'); 
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Rest  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        fprintf("      Rest %g sec before ending the test\n", Rest);

        % Track the start of the operation
        InExit = toc(tCycle);

        % Loop until the operation duration time is reached
        while toc(tCycle) < (InExit + Rest)

            % Measure current and voltage and update data arrays
            current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
            voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

            % Update axis of real-time plot
            axis([0 samples -Vliminstr Vliminstr]);
    
            % Real-time plot of the voltage
            addpoints(v, t(samples), voltage(samples));
            drawnow
            % Real-time plot of the current
            addpoints(i, t(samples), current(samples));
            drawnow
    
            % Update samples index
            samples = samples + 1;     
            % Update time array
            t(samples) = toc(tCycle);
            
            % Sampling time
            pause(Ts); 
    
        end

        fprintf("      Test completed !!\n");
        break;

    end

    % Disable the output
    writeline(visaObj, ':OUTPut OFF');

    fprintf("      End of Discharge cycle\n"); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rest  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      Rest %g sec before next cycle\n", Rest);

    % Track the start of the operation
    InRest = toc(tCycle);

    % Loop until the operation duration time is reached
    while toc(tCycle) < (InRest + Rest)

        % Measure current and voltage and update data arrays
        current(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));       % Current
        voltage(samples) = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));       % Voltage

        % Update axis of real-time plot
        axis([0 samples -Vliminstr Vliminstr]);

        % Real-time plot of the voltage
        addpoints(v, t(samples), voltage(samples));
        drawnow
        % Real-time plot of the current
        addpoints(i, t(samples), current(samples));
        drawnow

        % Update samples index
        samples = samples + 1;     
        % Update time array
        t(samples) = toc(tCycle);
        
        % Sampling time
        pause(Ts); 

    end

    % Update the value of the SoC for initiating a new HPPC cycle
    soc = soc - (1/disCapStep);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Trim the measurements
current = current(current ~= 0);        % Current
voltage = voltage(voltage ~= 0);        % Voltage
t = t(t ~= 0);                          % Time
% Update SoC array
SOC = [100, State_of_Charge];
SOC = SOC(SOC ~= 0);

% Insert measurement data inside a structure
HPPCMeas = struct;
HPPCMeas.Current = current;         % Current
HPPCMeas.Voltage = voltage;         % Voltage
HPPCMeas.SOC = SOC;                 % State of Charge
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
if ~exist('output', 'dir')
    mkdir('output');
end

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Save the variable to the .mat file with the date-appended filename
save(fullfile('output',[sprintf('Test_%s', currentDateStr),'.mat'] ), 'HPPCMeas')

% Clear some variables
% ...
% ...