function CCCVcharge(visaObj, newFileID, Vliminstr, Vlimreal, Ilev, Ilimpos, Ilim)

%------------------------------
% Set the operating mode to CC
%------------------------------

disp('Start of CC charge.');

% Set CC mode
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the voltage limit
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
% Set the output current
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', Ilev));

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Wait some time before starting CC operation
pause(1);

% Trigger elog system
writeline(visaObj, ':TRIGger:ELOG:IMMediate');

%%%%%%%%%%%%%%%%%%%%%%%%%%% CC CHARGE CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue until the voltage reaches the imposed limit
while true
    
    % Wait to collect some samples
    pause(10);

    % Log data
    data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));

    % Print the data to the .txt file
    fprintf(newFileID, "%g\n", data);

    % Exit condition --> voltage above the limit
    if data(end) > Vlimreal
        break;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Turn the output off
writeline(visaObj, ':OUTPut:STATe OFF');

% Abort the elog system
writeline(visaObj, ':ABORt:ELOG');

disp('CC charge completed.');

%------------------------------
% Set the operating mode to CV
%------------------------------

disp('Start of CV charge');

% Switch to CV mode
writeline(visaObj, ':SOURce:FUNCtion VOLTAGE');

% Set the current limit    
writeline(visaObj, sprintf(':SOURce:CURRent:LIMit:POSitive:IMMediate:AMPLitude %g', Ilimpos));         
% Set the voltage level to the value reached at the end of the CC cycle
writeline(visaObj, sprintf(':SOURce:VOLTage:LEVel:IMMediate:AMPLitude %g', data(end)));

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Wait some time before starting CV operation
pause(1);

% Trigger elog system
writeline(visaObj, ':TRIGger:ELOG:IMMediate');

%%%%%%%%%%%%%%%%%%%%%%%%%%% CV CHARGE CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue until the current reaches the imposed limit
while true

    % Wait to collect some samples
    pause(10);

    % Log data
    data = str2double(regexp(writeread(visaObj, sprintf('FETCh:ELOG? %g', 100)), ',', 'split'));

    % Print the data to the .txt file
    fprintf(newFileID, "%g\n", data);

    % Exit condition --> voltage above the limit
    if data(end - 1) < Ilim
        break;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Turn the output off
writeline(visaObj, ':OUTPut:STATe OFF');

% Abort the elog system
writeline(visaObj, ':ABORt:ELOG');

disp('CV charge completed.');

disp('The battery is fully charged!');

end