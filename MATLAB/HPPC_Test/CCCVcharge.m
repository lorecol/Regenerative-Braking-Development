function [CurrCC, VoltCC, CurrCV, VoltCV] = CCCVcharge(visaObj, Vliminstr, Vlimreal, Ilev, Ilimneg, Ilimpos, Ts)

%------------------------------
% Set the operating mode to CC
%------------------------------

disp('STEP 3 - CC MODE:');

writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the voltage limit
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
% Set the output current
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', Ilev));

% Wait some time before turning the output on
pause(1);

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Initialize index for data collection
idx = 0;

% Take a first measure
dc_ICC = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));     % [A] Current
dc_VCC = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));     % [V] Voltage

% Update index after first measure
idx = idx + 1;

% Update the measurement arrays after first measure
CurrCC(idx) = dc_ICC;         % Current
VoltCC(idx) = dc_VCC;         % Voltage

%%%%%%%%%%%%%%%%%%%%%%%%%%% CC CHARGE CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue until the voltage reaches the imposed limit
while dc_VCC < Vlimreal
    
    % Sampling time
    pause(Ts);

    % Measure current
    dc_ICC = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));

    % Measure voltage
    dc_VCC = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));

    % Update index after each measure
    idx = idx + 1;
    
    % Update the measurement arrays after each measure
    CurrCC(idx) = dc_ICC;
    VoltCC(idx) = dc_VCC;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Shut down the output
writeline(visaObj, ':OUTPut:STATe OFF');

disp('  CC charge completed.');

%------------------------------
% Set the operating mode to CV
%------------------------------

disp('STEP 4 - CV MODE:');

% Switch to CV
writeline(visaObj, ':SOURce:FUNCtion VOLTAGE');

% Set the current limits
writeline(visaObj, sprintf(':SOURce:CURRent:LIMit:NEGative:IMMediate:AMPLitude %g', Ilimneg));       
writeline(visaObj, sprintf(':SOURce:CURRent:LIMit:POSitive:IMMediate:AMPLitude %g', Ilimpos));         
% Set the voltage level to the value reached at the end of the CC cycle
writeline(visaObj, sprintf(':SOURce:VOLTage:LEVel:IMMediate:AMPLitude %g', VoltCC(end)));

% Wait some time before turning the output on
pause(1);

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Initialize index for data collection
idx = 0;

% Take a first measure
dc_ICV = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));     % [A] Current
dc_VCV = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));     % [V] Voltage

% Update index after first measure
idx = idx + 1;

% Update the measurement arrays after first measure
CurrCV(idx) = dc_ICV;
VoltCV(idx) = dc_VCV;

%%%%%%%%%%%%%%%%%%%%%%%%%%% CV CHARGE CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue until the current reaches the imposed negative limit
while dc_ICV > 0.2

    % Sampling time
    pause(Ts);

    % Measure current
    dc_ICV = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));

    % Measure voltage
    dc_VCV = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));

    % Update index after each measure
    idx = idx + 1;

    % Update the measurement arrays after each measure
    CurrCV(idx) = dc_ICV;
    VoltCV(idx) = dc_VCV;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Shut down the output
writeline(visaObj, ':OUTPut:STATe OFF');

disp('  CV charge completed.');

disp('>> The battery is fully charged !! <<');

end