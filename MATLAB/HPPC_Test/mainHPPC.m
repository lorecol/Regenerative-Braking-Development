clear all;
close all;
clc;

%% Estabilish connection with the instrument

% Load the VISA library and create a VISA object. Make sure to insert the 
% appropriate instrument address
Instrlist = visadevlist;
visaObj = visadev(Instrlist.ResourceName);

% Set the timeout value, i.e. the max time duration that MATLAB will wait 
% to receive a response from the instrument before considering the 
% operation as timed out
visaObj.Timeout = 10;       % [s]

disp('STEP 1 - ENABLE COMMUNICATION WITH THE INSTRUMENT:');

% Check if the connection is successful
if strcmp(visaObj.Status, 'open')
    disp('  Instrument connection established.');
else
    error('  Failed to connect to the instrument.');
end

%% Initialization

% Recall the commands to initialize the instrument
INIinstr(visaObj);

disp('STEP 2 - INITIALIZE THE INSTRUMENT:');
disp('  Initialization done.');

%% Charge the battery through CC-CV

% disp('STEP 3 - CHARGE IN CC MODE:');
% 
% % Data
% VCCtarget = 4.2;                % Voltage limit in CC mode
% ICVtarget = 0.2;                % Current limit in CV mode
% numReadings = 0;                % Counter for the number of measured data
% maxReadings = 10000;            % Max dimension of voltage and current data
% ICC = zeros(1, maxReadings);    % Current array - CC mode
% VCC = zeros(1, maxReadings);    % Voltage array - CC mode
% ICV = zeros(1, maxReadings);    % Current array - CV mode
% VCV = zeros(1, maxReadings);    % Voltage array - CV mode
% 
% % Initialize the operating mode as CC
% Mode = 'CC';
% 
% % Perform CC charge
% [Mode, ICC, VCC] = ChargeModeCC(visaObj, Mode, numReadings, maxReadings, VCCtarget, ICC, VCC);
% 
% % Trim voltage and current arrays
% ICC = ICC(1:numReadings);
% VCC = VCC(1:numReadings);  
% 
% % Show the plot in CC mode
% [figure1, figure2] = IVplot(ICC, VCC, ICV, VCV, numReadings);
% figure1;
% 
% disp('STEP 4 - CHARGE IN CV MODE:');
% 
% % Perform CV charge
% [ICV, VCV] = ChargeModeCV(visaObj, Mode, numReadings, maxReadings, ICVtarget, ICV, VCV);
% 
% % Trim voltage and current arrays
% ICV = ICV(1:numReadings);
% VCV = VCV(1:numReadings); 
% 
% % Show the plot in CV mode
% figure2;
% 
% disp('The battery is fully charged !!!');

%% DISCHARGE TEST

numReadings = 0;                % Counter for the number of measured data
maxReadings = 10000;            % Max dimension of voltage and current data
% I = zeros(1, maxReadings);      % Current array
% V = zeros(1, maxReadings);      % Voltage array
Data = zeros(2, maxReadings);

writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the charging current to -2 A
writeline(visaObj, ':SOURce:CURRent:LEVel:IMMediate:AMPLitude -2');
% Set the voltage limit to 4.2 V
writeline(visaObj, ':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude 4.2');
%%
pause(5);

writeline(visaObj, ':OUTPut:STATe ON');

pause(5);

% Trigger the acquisition system
writeline(visaObj, ':TRIGger:ELOG:IMMediate');

pause(5);

% Continue charging in CC mode until the voltage goes below a threshold, 
% which is set to 3.3 V
while numReadings < maxReadings
    % Read measured current values
    data = writeread(visaObj, 'FETCh:ELOG? 5');
    data = str2double(data);

    % Update number of readings
    numReadings = numReadings + 1;
    Data(:, numReadings) = data;
    
    % Exit the cycle when the voltage exceeds the limit
    if v < 3.2
        % Abort data acquisition
        writeline(visaObj, ':ABORt:ELOG');
        % Disable the output
        writeline(visaObj, ':OUTPut:STATe OFF');
        break;
    end

    % Wait 1 s before next reading
    pause(1);

end

% I = I(1:numReadings);
% V = V(1:numReadings); 

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