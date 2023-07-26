function [Mode, ICC, VCC] = ChargeModeCC(visaObj, Mode, numReadings, maxReadings, VCCtarget, ICC, VCC)

% Set the operating mode to CC
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Sends appropriate commands based on the operating mode of the instrument
ModelCCCV(visaObj, Mode);

% Wait some time before turning the output on
pause(5);

% Enable the output
writeline(visaObj, ':OUTPut:STATe ON');

% Wait for some time before triggering data acquisition
pause(5);

% Trigger the acquisition system
writeline(visaObj, ':TRIGger:ACQuire:IMMediate');
% Trigger data logging
% writeline(visaObj, ':TRIGger:ELOG:IMMediate');

% Wait for some time before retrieving data 
pause(5);

% Continue charging in CC mode until the voltage exceeds a threshold, which
% is set to 4.2 V
while numReadings < maxReadings
    % Read measured current values
    dcCurr = writeread(visaObj, 'MEASure:ARRay:CURRent:DC?');
    dcCurr = str2double(dcCurr);
    % Read measured voltage values
    dcVolt = writeread(visaObj, ':MEASure:ARRay:VOLTage:DC?');
    dcVolt = str2double(dcVolt);

    % Update number of readings
    numReadings = numReadings + 1;
    ICC(numReadings) = dcCurr;
    VCC(numReadings) = dcVolt;
    
    % Exit the cycle when the voltage exceeds the limit
    if dcVolt > VCCtarget
        % Abort data acquisition
        writeline(visaObj, ':ABORt:ACQuire');
        % Switch to CV mode
        Mode = 'CV';
        disp('  Charge in CC mode done.');
        break;
    end

    % Wait 1 s before next reading
    pause(1);

end

end