function ModelCCCV(visaObj, Mode)

% If statement to choose the appropriate commands to send wether the 
% instrument operates in Constant Current (CC) mode or in Constant Voltage 
% (CV) mode

if strcmp(Mode, 'CC') == 1              % Operating mode: CC
    % Set the charging current to 2 A
    writeline(visaObj, ':SOURce:CURRent:LEVel:IMMediate:AMPLitude 2');
    % Set the voltage limit to 4.2 V
    writeline(visaObj, ':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude 4.2');    

elseif strcmp(Mode, 'CV') == 1          % Operating mode: CV
    % Set the voltage level to 4.2 V
    writeline(visaObj, ':SOURce:VOLTage:LEVel:IMMediate:AMPLitude 4.2');
    % Set the current limit to 0.2 A
    writeline(visaObj, ':SOURce:CURRent:LIMit:POSitive:IMMediate:AMPLitude 0.2');

end

end