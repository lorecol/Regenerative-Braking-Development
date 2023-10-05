%
% ----------------------------- HPPC TEST ---------------------------------
% -------------------------------------------------------------------------

% This script is used to perform the Hybrid Pulse Power Characterization 
% test on a specific battery configuration, which can be a single cell or a
% block of multiple cells (3 in series and 4 in parallel). Data are logged
% externally in a .txt file with a frequency of 10 Hz and all significant
% parameters and results are saved in a .mat file, which will be then 
% loaded to perform battery characterization/parameters identiication

% This script takes inspiration from the HPPC test procedure of 
% <https://www.osti.gov/biblio/1186745>

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

%% Let the user choose which battery configuration to test

BatteryList = {'SingleCell', 'Block'};
Battery = listdlg('PromptString', {'For which type of battery do you want to fit the data?', ''}, ...
               'ListString', BatteryList, 'SelectionMode', 'single'                                  );

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
    Capacity = 4;               % [Ah]
elseif strcmp(selectedVariable, 'Block') == 1
    parallel = 4;               % Number of parallels          
    series = 3;                 % Number of series
    Capacity = 14;              % [Ah]
end

%% Data                                                    

Vlimreal = 4.2 * series;                                        % [V] Voltage upper limit when discharging
Vliminstr = 5 * series;                                         % [V] Voltage limit during CC - for the instrument
Vlimlow = 2.5 * series;                                         % [V] Voltage lower limit when discharging
Ilev = 2 * parallel;                                            % [A] Current level
Ts = 0.1;                                                       % [s] Sampling time
SOC = 100;                                                      % Actual SoC measured by Coulomb counting method
curr_discharge_pulse = -round((1/2) * Capacity,2);              % [A] 1/2C current for discharge pulse
curr_charge_pulse = round((1/2) * Capacity,2);                  % [A] 1/2C current for charge pulse
dischargeC3 = -round((Capacity/3),2);                           % [A] C/3 current for SOC discharge
t_discharge_pulse = 30;                                         % [s] Discharge pulse time
t_charge_pulse = 30;                                            % [s] Charge pulse time -- default: 10 sec
t_rest_pulse = 40;                                              % [s] Rest period between pulses
disCapStep = 0.1;                                               % 10% SOC decrement
tDisCycle = ((Capacity * 3600 * disCapStep)/abs(dischargeC3));  % [min] Discharge cycle time
Rest = 10 * 60;                                                 % [s] Rest period between discharge cycles
Rest100SOC = 5 * 60;                                            % [s] Rest period at full capacity
cycle = 0;                                                      % Variable to keep track of cycles number

%% Initialize the instrument

% Select data format
writeline(visaObj, ":FORM:DATA ASCii");

% Enable log of voltage data
writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage:MINMax OFF');

% Disable log of current data
writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent:MINMax OFF');

% Define integration time
writeline(visaObj, sprintf(':SENS:ELOG:PER %g', Ts));

% Select trigger source for data logging
writeline(visaObj, 'TRIGger:TRANsient:SOURce BUS');

% Initialize the elog system
writeline(visaObj, ':INITiate:IMMediate:ELOG');


disp('Initialization done.');

%% Open the .txt file where to log test data

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');

% Create the output folder and the Test subfolder if it doesn't exist
subdir = sprintf('Test_%s_%s', BatteryList{Battery}, currentDateStr);
if ~exist('output', 'dir')
    mkdir('output');
    mkdir(sprintf('output/%s',subdir));
else 
    mkdir(sprintf('output/%s', subdir));
end

% Define the name of the file where to log data
FileName = sprintf("output/%s/Test_%s_DataLog_%s.txt",subdir, BatteryList{Battery}, currentDateStr);
% Open the file where to log data in writing mode; create the file if not 
% present
newFileID = fopen(FileName, 'w+');
% Open the visualisation of the file where to log data
open(FileName);

% Wait some time before discharging
pause(1);

%% HPPC test

%%%%%%%%%%%%%%%%%%%%%%%%% Rest period at 100% SoC %%%%%%%%%%%%%%%%%%%%%%%%%

fprintf("   Rest at full charge for %g sec\n", Rest100SOC);

% Trigger elog system
writeline(visaObj, ':TRIGger:ELOG:IMMediate');

% Start the external reference timer
tCycle = tic;

% Loop until the operation duration time is reached
while true

    % Wait to collect some samples
    pause(10);

    % Log voltage and current data
    data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));

    % Print the data to the .txt file
    fprintf(newFileID, "%g\n", data);

    % Exit condition
    if toc(tCycle) >= Rest100SOC
        break;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Abort the elog system
writeline(visaObj, ':ABORt:ELOG');

% Initialize the elog system
writeline(visaObj, ':INITiate:IMMediate:ELOG');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HPPC Test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We assume that the battery starts from 100% SOC, i.e. at full capacity

while true 

    % Update number of cycle and print it
    cycle = cycle + 1;
    fprintf("   Discharge cycle number: %g\n", cycle);

    %%%%%%%%%%%%%%%%%%%%%%%%%% Discharge pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Discharge 1/2C
    fprintf("      Impulsive discharge for %g sec\n", t_discharge_pulse);
    
    % Set the power supply to current priority mode
    writeline(visaObj, ':SOURce:FUNCtion CURRENT');
    % Set the voltage limit
    writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
    % Set the output current
    writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', curr_discharge_pulse)); 

    % Turn the output on
    writeline(visaObj, ':OUTPut ON');  

    % Trigger elog system
    writeline(visaObj, ':TRIGger:ELOG:IMMediate');

    % Track the start of the operation
    InDisImp = toc(tCycle);

    % Loop until the operation duration time is reached
    while true 

        % Wait to collect some samples
        pause(10);
    
        % Log voltage and current data
        data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));
    
        % Print the data to the .txt file
        fprintf(newFileID, "%g\n", data);

        % Exit condition
        if toc(tCycle) > (InDisImp + t_discharge_pulse)
            break;
        end
    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Turn the output off
    writeline(visaObj, ':OUTPut OFF');

    % Abort the elog system
    writeline(visaObj, ':ABORt:ELOG');

    % Initialize the elog system
    writeline(visaObj, ':INITiate:IMMediate:ELOG');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 40s Rest %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      Rest for %g sec\n", t_rest_pulse);

    % Trigger elog system
    writeline(visaObj, ':TRIGger:ELOG:IMMediate');

    % Track the start of the operation
    InRest40 = toc(tCycle);

    % Loop until the operation duration time is reached
    while true

        % Wait to collect some samples
        pause(10);
    
        % Log voltage and current data
        data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));
    
        % Print the data to the .txt file
        fprintf(newFileID, "%g\n", data);

        % Exit condition
        if toc(tCycle) >= (InRest40 + t_rest_pulse)
            break;
        end

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Abort the elog system
    writeline(visaObj, ':ABORt:ELOG');

    % Initialize the elog system
    writeline(visaObj, ':INITiate:IMMediate:ELOG');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Charge pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Charge 1/2C
    fprintf("      Impulsive charge for %g sec\n", t_charge_pulse);

    % Set the power supply to current priority mode
    writeline(visaObj, ':SOURce:FUNCtion CURRENT');
    % Set the voltage limit
    writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
    % Set the output current
    writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', curr_charge_pulse));

    % Turn the output on
    writeline(visaObj, ':OUTPut ON'); 

    % Trigger elog system
    writeline(visaObj, ':TRIGger:ELOG:IMMediate');

    % Track the start of the operation
    InChImp = toc(tCycle);

    % Loop until the operation duration time is reached
    while true

        % Wait to collect some samples
        pause(10);
    
        % Log voltage and current data
        data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));
    
        % Print the data to the .txt file
        fprintf(newFileID, "%g\n", data);

        % Exit condition
        if toc(tCycle) >= (InChImp + t_charge_pulse)
            break;
        end

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Turn the output OFF
    writeline(visaObj, ':OUTPut OFF');

    % Abort the elog system
    writeline(visaObj, ':ABORt:ELOG');

    % Initialize the elog system
    writeline(visaObj, ':INITiate:IMMediate:ELOG');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 40s Rest %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      Rest for %g sec\n", t_rest_pulse);

    % Trigger elog system
    writeline(visaObj, ':TRIGger:ELOG:IMMediate');

    % Track the start of the operation
    InRest40bis = toc(tCycle);

    % Loop until the operation duration time is reached
    while true

        % Wait to collect some samples
        pause(10);
    
        % Log voltage and current data
        data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));
    
        % Print the data to the .txt file
        fprintf(newFileID, "%g\n", data);

        % Exit condition
        if toc(tCycle) >= (InRest40bis + t_rest_pulse)
            break;
        end

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Abort the elog system
    writeline(visaObj, ':ABORt:ELOG');

    % Initialize the elog system
    writeline(visaObj, ':INITiate:IMMediate:ELOG');
    
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

    % Trigger elog system
    writeline(visaObj, ':TRIGger:ELOG:IMMediate');

    % Track the start of the operation
    InDisCycle = toc(tCycle);

    % Loop until the battery is discharged by the desired percentage
    while true

        % Wait to collect some samples
        pause(10);
    
        % Log voltage and current data
        data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));
    
        % Print the data to the .txt file
        fprintf(newFileID, "%g\n", data);

        % Exit condition
        if (toc(tCycle) >= (InDisCycle + tDisCycle)) || (data(end) < Vlimlow)
            break;
        end          

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Abort the elog system
    writeline(visaObj, ':ABORt:ELOG');

    % Initialize the elog system
    writeline(visaObj, ':INITiate:IMMediate:ELOG');

    % Update SoC after discharge cycle and print it
    [SOC] = calcSOC(SOC, Capacity, dischargeC3, tDisCycle);
    fprintf("        SoC: %g\n", SOC);

    % Exit the main loop if SoC reaches zero or if under-voltage is reached
    if (SOC == 0) || (data(end) < Vlimlow)

        % Disable the output
        writeline(visaObj, ':OUTPut OFF'); 
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Rest  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        fprintf("      Rest %g sec before ending the test\n", Rest);

        % Trigger elog system
        writeline(visaObj, ':TRIGger:ELOG:IMMediate');

        % Track the start of the operation
        InExit = toc(tCycle);

        % Loop until the operation duration time is reached
        while true

            % Wait to collect some samples
            pause(10);
        
            % Log voltage and current data
            data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));
        
            % Print the data to the .txt file
            fprintf(newFileID, "%g\n", data);

            % Exit condition
            if toc(tCycle) >= (InExit + Rest)
                break;
            end
    
        end

        fprintf("      Test completed !!\n");
        break;

    end

    % Disable the output
    writeline(visaObj, ':OUTPut OFF');

    fprintf("      End of Discharge cycle\n"); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rest  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf("      Rest %g sec before next cycle\n", Rest);

    % Trigger elog system
    writeline(visaObj, ':TRIGger:ELOG:IMMediate');

    % Track the start of the operation
    InRest = toc(tCycle);

    % Loop until the operation duration time is reached
    while true

        % Wait to collect some samples
        pause(10);
    
        % Log voltage and current data
        data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));
    
        % Print the data to the .txt file
        fprintf(newFileID, "%g\n", data);

        % Exit condition
        if toc(tCycle) >= (InRest + Rest)
            break;
        end

    end

    % Abort the elog system
    writeline(visaObj, ':ABORt:ELOG');

    % Initialize the elog system
    writeline(visaObj, ':INITiate:IMMediate:ELOG');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Abort the elog system
writeline(visaObj, ':ABORt:ELOG');

%% Data processing

% Close the file where data are logged
fclose(newFileID);

% Re-open the file where data are logged in read mode
newFileID = fopen(FileName, 'r');

% Read data from the file
DataLog = fscanf(newFileID, '%f');

% Extract logged data
curr = DataLog(1:2:end);        % Current
volt = DataLog(2:2:end);        % Voltage

% Define time vector
Time = Ts:Ts:((length(DataLog)/2) * Ts);
Time = Time';

% Define SoC vector
SoC = 0:(1/disCapStep):100;

% Plot voltage and current during the test
figure;
subplot(1, 2, 1)
plot(Time, curr);
title('HPPC Test - current');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(Time, volt);
title('HPPC Test - voltage');
xlabel('time [s]');
ylabel('Voltage [V]');

% Create struct of data
HPPCMeas.Time = Time;                                   % [s]  Time vector
HPPCMeas.Current = curr;                                % [A]  Current vector
HPPCMeas.Voltage = volt;                                % [V]  Voltage vector
HPPCMeas.SoC = SoC;                                     % [%]  State-of-Charge vector
HPPCMeas.Capacity = Capacity;                           % [Ah] Capacity
HPPCMeas.curr_charge_pulse = curr_charge_pulse;         % [A]  Current during charge pulse
HPPCMeas.curr_discharge_pulse = curr_discharge_pulse;   % [A]  Current during discharge pulse
HPPCMeas.dischargeC3 = dischargeC3;                     % [A]  Current during SOC decrease
HPPCMeas.parallels = parallel;                          % Number of parallels in battery configuration
HPPCMeas.series = series;                               % Number of series in battery configuration

% Save the variable to the .mat file with the date-appended filename
save(fullfile(sprintf('output/%s',subdir), [sprintf('Test_%s_%s', BatteryList{Battery}, currentDateStr),'.mat'] ), 'HPPCMeas');
