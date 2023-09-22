function [CurrCC, VoltCC, CurrCV, VoltCV] = CCCVcharge(visaObj, Vliminstr, Vlimreal, Ilev, Ilimneg, Ilimpos, Ts)

%------------------------------
% Set the operating mode to CC
%------------------------------

fprintf("Start of CC charge");

% Set CC mode
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the voltage limit
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vliminstr));
% Set the output current
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', Ilev));

% Initialize index for CC data collection
idx = 1;

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Take a first measure
dc_ICC = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));     % [A] Current
dc_VCC = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));     % [V] Voltage

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

% Convert data array to column vectors
CurrCC = CurrCC';
VoltCC = VoltCC';

fprintf(" ------> CC charge completed.\n");

%------------------------------
% Set the operating mode to CV
%------------------------------

fprintf("Start of CV charge");

% Re-initialize index for CV data collection
idx = 1;

% Switch to CV mode
writeline(visaObj, ':SOURce:FUNCtion VOLTAGE');

% Initialize voltage and current level after CC exit
dc_ICV = CurrCC(end);                % Current
dc_VCV = VoltCC(end);                % Voltage

% Set the current limits      
writeline(visaObj, sprintf(':SOURce:CURRent:LIMit:POSitive:IMMediate:AMPLitude %g', Ilimpos));         
% Set the voltage level to the value reached at the end of the CC cycle
writeline(visaObj, sprintf(':SOURce:VOLTage:LEVel:IMMediate:AMPLitude %g', dc_VCV));

% Update the measurement arrays after first measure
CurrCV(idx) = dc_ICV;
VoltCV(idx) = dc_VCV; 

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

%%%%%%%%%%%%%%%%%%%%%%%%%%% CV CHARGE CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Continue until the current reaches the imposed negative limit
while dc_ICV > Ilimneg

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

% Convert data array to column vectors
CurrCV = CurrCV';
VoltCV = VoltCV';

fprintf(" ------> CV charge completed.\n");

fprintf("The battery is fully charged !!");

end