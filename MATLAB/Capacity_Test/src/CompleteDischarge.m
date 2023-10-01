function [TimerEnd] = CompleteDischarge(visaObj, Vlimreal, Vlimlow, Ilev, newFileID)

fprintf("Start of capacity test\n");

% Set the operating mode to CC
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the voltage limit
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vlimreal));
% Set the output current
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', -Ilev));

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Wait some time before discharging
pause(1);

% Trigger elog system
writeline(visaObj, ':TRIGger:ELOG:IMMediate');

% Start the external reference timer
TimerStart = tic;

%%%%%%%%%%%%%%%%%%%%%%%%%% COMPLETE DISCHARGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue until the voltage reaches the imposed limit
while true

    % Wait to collect some samples
    pause(10);

    % Log data
    data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));

    % Print the data to the .txt file
    fprintf(newFileID, "%g\n", data);

    if data(end) <= Vlimlow
        break;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Turn the output off
writeline(visaObj, ':OUTPut:STATe OFF');

% Abort the elog system
writeline(visaObj, ':ABORt:ELOG');

% Stop the external timer
TimerEnd = toc(TimerStart)/60;          % [min]

fprintf(" ------> Capacity test completed.\n");

end