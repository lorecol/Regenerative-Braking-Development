function [VoltCapacity, CurrCapacity, time] = CompleteDischarge(visaObj, Vlimreal, Vlimlow, Ilev, Ts)

% Initialize data arrays
VoltCapacity = [];       % Voltage array
CurrCapacity = [];       % Current array
time = [];               % Time array

% Set the operating mode to CC
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the voltage limit
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vlimreal));
% Set the output current
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', Ilev));

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Initialize index for data collection
idx = 0;

% % Start the external timer
% timerStart = tic;

% Take a first measure
dc_VDis = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));    % Voltage
dc_IDis = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));    % Current

% Update index after first measure
idx = idx + 1;

% Update the measurement arrays after first measure
VoltCapacity(idx) = dc_VDis;         % Voltage
CurrCapacity(idx) = dc_IDis;         % Current

% % Stop the external timer
% tEnd = toc(timerStart);

% Update time array after first measure
time(idx) = idx * Ts;

%%%%%%%%%%%%%%%%%%%%%%%%%% COMPLETE DISCHARGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue until the voltage reaches the imposed limit
while dc_VDis >= Vlimlow

    % Sampling time
    pause(Ts);

%     % Restart the external timer
%     timerStart = tic;

    % Measure voltage
    dc_VDis = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));

    % Measure current
    dc_IDis = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));

    % Update index after each measure
    idx = idx + 1;

    % Update the measurement arrays after each measure
    VoltCapacity(idx) = dc_VDis;         % Voltage
    CurrCapacity(idx) = dc_IDis;         % Current

%     % Stop the external timer
%     tEnd = toc(timerStart);

    % Update time array
    time(idx) = idx * Ts;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Shut down the output
writeline(visaObj, ':OUTPut:STATe OFF');

disp('  The battery is fully discharged !!');

end