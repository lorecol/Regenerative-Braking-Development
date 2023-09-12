function [VoltCapacity, CurrCapacity, Time, TimerEnd] = CompleteDischarge(visaObj, Vlimreal, Vlimlow, Ilev, Ts)

fprintf("Start of capacity test");

% Initialize data arrays
VoltCapacity = [];       % Voltage 
CurrCapacity = [];       % Current 
Time = [];               % Time 

% Initialize index for data collection
idx = 1;

% Set the operating mode to CC
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the voltage limit
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vlimreal));
% Set the output current
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', -Ilev));

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Start the external timer
TimerStart = tic;

% Take a first measure
dc_VDis = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));    % Voltage
dc_IDis = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));    % Current

% Update the measurement arrays after first measure
VoltCapacity(idx) = dc_VDis;         % Voltage
CurrCapacity(idx) = dc_IDis;         % Current

% Update time array after first measure
Time(idx) = idx * Ts;

%%%%%%%%%%%%%%%%%%%%%%%%%% COMPLETE DISCHARGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue until the voltage reaches the imposed limit
while dc_VDis >= Vlimlow

    % Sampling time
    pause(Ts);

    % Measure voltage
    dc_VDis = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));

    % Measure current
    dc_IDis = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));

    % Update index after each measure
    idx = idx + 1;

    % Update the measurement arrays after each measure
    VoltCapacity(idx) = dc_VDis;         % Voltage
    CurrCapacity(idx) = dc_IDis;         % Current

    % Update time array
    Time(idx) = idx * Ts;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stop the external timer
TimerEnd = toc(TimerStart)/60;          % [min]

% Shut down the output
writeline(visaObj, ':OUTPut:STATe OFF');

% Convert data array to column vectors
VoltCapacity = VoltCapacity';
CurrCapacity = CurrCapacity';
Time = Time';

fprintf(" ------> Capacity test completed.\n");

end