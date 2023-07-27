clear all;
close all;
clc;

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
writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage ON');
% Enable current measurements
writeline(visaObj, ':SENSe:FUNCtion:CURRent ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent ON');

% Initialize trigger
writeline(visaObj, ':INITiate:IMMediate:ELOG');

% Set sampling period
writeline(visaObj, ':SENSe:SWEep:TINTerval 0.1');
Ts = writeread(visaObj, ':SENSe:SWEep:TINTerval?');

% Set integration period
writeline(visaObj, ':SENSe:ELOG:PERiod 0.5');

disp('  Initialization done.');

%% CC-CV charging

disp('STEP 3 - CC MODE:');

% Data
Vtarget = 4.2;                      % Voltage limit in CC mode
Ilevel = 2.0;                       % Current level in CC mode
Itarget = 0.2;                      % Current limit in CV mode
numReadings = 0;                    % Counter for the number of measured data
maxReadings = 10000;                % Max dimension of measured data
measCC = zeros(maxReadings, 2);     % Array to collect data in CC
measCV = zeros(maxReadings, 2);     % Array to collect data in CV

% Set the operating mode to CC
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the charging current to 2 A
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', Ilevel));
% Set the voltage limit to 4.2 V
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vtarget));

% Wait some time before turning the output on
pause(5);

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Wait for some time before triggering data acquisition and data log
pause(5);

% Trigger the acquisition system
writeline(visaObj, ':TRIGger:ACQuire:IMMediate');
% Trigger data logging
writeline(visaObj, ':TRIGger:ELOG:IMMediate');

% Keep CC mode until the measured voltage exceeds the voltage limit
while numReadings < maxReadings

    % Fetch 1 record (current + voltage) at a time
    measCC = writeread(visaObj, 'FETCh:ELOG? 1');
    measCC = str2double(measCC);

    % Update number of readings
    numReadings = numReadings + 1;
    
    % Exit the cycle when the voltage exceeds the limit
    if measCC(numReadings, 2) > Vtarget
        
        disp('  CC charge completed.');

        % Abort data acquisition
        writeline(visaObj, ':ABORt:ACQuire');
        % Abort data log
        writeline(visaObj, ':ABORt:TRIGger');
        % Disable the output
        writeline(visaObj, ':OUTPut:STATe OFF'); 
        break;
    end

    % Wait 1 s before next reading
    pause(1);

end 

% Wait some time before starting the CV chargin operation
pause(10);

disp('STEP 4 - CV MODE:');

% Set the voltage level to 4.2 V
writeline(visaObj, sprintf(':SOURce:VOLTage:LEVel:IMMediate:AMPLitude %g', Vtarget));
% Set the current limit to 0.2 A
writeline(visaObj, sprintf(':SOURce:CURRent:LIMit:POSitive:IMMediate:AMPLitude %g', Itarget));

% Wait some time before turning the output on
pause(5);

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Wait for some time before triggering data acquisition
pause(5);

% Trigger the acquisition system
writeline(visaObj, ':TRIGger:ACQuire:IMMediate');
% Trigger data logging
writeline(visaObj, ':TRIGger:ELOG:IMMediate');

% Reset the number of readings variable
numReadings = 0;

% Keep CV mode until the measured current goes below the current limit
while numReadings < maxReadings

    % Fetch 1 record (current + voltage) at a time
    measCV = writeread(visaObj, 'FETCh:ELOG? 1');
    measCV = str2double(measCV);

    % Update number of readings
    numReadings = numReadings + 1;
    
    % Exit the cycle when the current exceeds the limit
    if measCV(numReadings, 1) < Itarget

        disp('  CV charge completed.');

        % Abort data acquisition
        writeline(visaObj, ':ABORt:ACQuire');
        % Abort data log
        writeline(visaObj, ':ABORt:TRIGger');
        % Disable the output
        writeline(visaObj, ':OUTPut:STATe OFF'); 
        break;
    end

    % Wait 1 s before next reading
    pause(1);

end

disp('The battery is fully charged !!!');

%% Plot voltage and current during CCCV charge

% Trim the measurements
measCC = measCC(1:numReadings, :);
measCV = measCV(1:numReadings, :);

% Concatenate the measurements
meas = [measCC;
        measCV];

figure;
subplot(1, 2, 1)
plot(1:numReadings, meas(:, 1));
title('Current during CCCV charge');
xlabel('time [s]');
ylabel('Current [A]');
subplot(1, 2, 2)
plot(1:numReadings, Meas(:, 2));
title('Voltage during CCCV charge');
xlabel('time [s]');
ylabel('Voltage [V]');

%% DISCHARGE TEST

% Let the cell rest before starting the discharge cycle
Rest = 10;          % [min]
WaitBar(sprintf("%g", Rest) + 'minutes rest', Rest * 60);

% Define time of discharge pulse
timeDis = 10;       % [s]
% Reset the number of readings variable
numReadings = 0;
% Reset the number of max readings variable
maxReadings = Ts * timeDis;

% Array to collect data during discharge cycles
measDis = zeros(maxReadings, 2); 

% Define discharge current level
IlevelDis = -3;

% Set the operating mode to CC
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the charging current to -3 A
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', IlevelDis));
% Set the voltage limit to 4.2 V
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vtarget));

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Wait for some time before triggering data acquisition and data log
pause(5);

% Trigger the acquisition system
writeline(visaObj, ':TRIGger:ACQuire:IMMediate');
% Trigger data logging
writeline(visaObj, ':TRIGger:ELOG:IMMediate');

while numReadings <= maxReadings

    % Implement while loop for discharge pulses

end

%% FROM HERE IMPLEMENT THE DISCHARGE PULSE CYCLE

% % Continue charging in CC mode until the voltage goes below a threshold, 
% % which is set to 3.6 V
% while numReadings < maxReadings
%     % Read measured current values
%     data = writeread(visaObj, 'FETCh:ELOG? 1');
%     data = str2double(data);
% 
%     % Update number of readings
%     numReadings = numReadings + 1;
%     data(:, numReadings) = data;
%     
%     % Exit the cycle when the voltage exceeds the limit
%     if v < 3.6
%         % Abort data acquisition
%         writeline(visaObj, ':ABORt:ELOG');
%         % Disable the output
%         writeline(visaObj, ':OUTPut:STATe OFF');
%         break;
%     end
% 
%     % Wait at least 2 s before next reading
%     pause(3);
% 
% end
% 
% % I = I(1:numReadings);
% % V = V(1:numReadings); 

%%

% %% Discharge the battery from 100% to 0% SOC with steps of 10% SOC
% 
% % Define test parameters
% initialSOC       = 100;     % starting SOC in percentage
% targetSOC        = 0;       % target SOC in percentage
% dischargeCurrent = -4;      % discharge current of 4A
% 
% % Create data logging variables
% elog = zeros(1000, 1);
% % time    = [];
% % voltage = [];
% % current = [];
% 
% %%
% % % Turn off the output
% % writeline(visaObj, ':OUTPut:STATe OFF');
% % 
% % % Initialize acquisition and data logging
% % writeline(visaObj, ':INITiate:IMMediate:ACQuire');
% % writeline(visaObj, ':INITiate:IMMediate:ELOG');
% % % Enable the measurement of voltage and current
% % writeline(visaObj, ':SENSe:FUNCtion:CURRent ON');
% % writeline(visaObj, ':SENSe:FUNCtion:VOLTage ON');
% % % Enable logging of voltage and current
% % writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent ON');
% % writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage ON');
% % 
% % % Sampling time
% % writeline(visaObj, 'SENSe:SWEep:TINTerval 1');
% % disp('SENSe:SWEep:TINTerval 1 DONE !!');
% % % Integration time of data logging
% % writeline(visaObj, ':SENSe:ELOG:PERiod 1');
% % disp(':SENSe:ELOG:PERiod 1 DONE !!');
% % 
% % % Triggers the acquisition and data logging
% % writeline(visaObj, ':TRIGger:ACQuire:IMMediate');
% % writeline(visaObj, ':TRIGger:ELOG:IMMediate');
% %%
% 
% % % Define the data logging function
% % logData = @(visaObj) logBatteryData(visaObj, time, voltage, current);
% % 
% % % Start the data logging in parallel
% % t = parfeval(@() logData(visaObj));
% 
% writeline(visaObj, ':SOURce:CURRent:LEVel:IMMediate:AMPLitude -3');
% writeline(visaObj, ':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude 4.2');
% 
% writeline(visaObj, ':OUTPut:STATe ON');
% 
% % tic
% % while(toc <= 10)
% %     writeline(visaObj, [':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g'  -2]);
% % end
% 
% % writeline(visaObj, ':OUTPut:STATe:DELay:RISE 2');
% 
% %%
% 
% % Execute the test sequence
% while initialSOC > targetSOC
% 
%     % Discharge at the specified current for 5 minutes
%     writeline(visaObj, ':OUTPut:STATe 1');
%     tic
%     while(toc <= 10)
%         writeline(visaObj, [':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g'  num2str(dischargeCurrent)]);
%     end
% 
%     % Update the SOC values
%     initialSOC = initialSOC - 10;
% 
%     % Display the current SOC
%     disp(['Current SOC: ' num2str(initialSOC) '%']);
% 
%     writeline(visaObj, ':OUTPut:STATe 0');
% 
%     % Rest for 5 minutes
%     pause(300);
%     
%     delete(tloop);
% end
% 
% % Stop the data logging
% % cancel(t);
% % wait(t);
% % writeline(visaObj, ':ABORt:ELOG');
% 
% 
% % Retrieve the logged data
% % time = fetchOutputs(t);
% 
% %% Close the instrument connection and clean up the VISA object
% 
% clear visaObj;
% 
% % Extract the logged data
% % voltage = time{1};
% % current = time{2};
% % time    = time{3};