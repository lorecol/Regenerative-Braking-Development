function [ICV, VCV] = ChargeModeCV(visaObj, Mode, numReadings, maxReadings, ICVtarget, ICV, VCV)

% Set the operating mode to CV
writeline(visaObj, ':SOURce:FUNCtion VOLTAGE');

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

% Continue charging in CV mode until the current goes below a threshold, 
% which is set to 0.2 A
while numReadings < maxReadings
    % Read measured current values
    dcCurr = writeread(visaObj, 'MEASure:ARRay:CURRent:DC?');
    dcCurr = str2double(dcCurr);
    % Read measured voltage values
    dcVolt = writeread(visaObj, ':MEASure:ARRay:VOLTage:DC?');
    dcVolt = str2double(dcVolt);

    % Update number of readings
    numReadings = numReadings + 1;
    ICV(numReadings) = dcCurr;
    VCV(numReadings) = dcVolt;
    
    % Exit the cycle when the voltage exceeds the limit
    if dcCurr < ICVtarget
        % Abort data acquisition
        writeline(visaObj, ':ABORt:ACQuire');
        % Disable the output
        writeline(visaObj, ':OUTPut:STATe OFF');
        disp('  Charge in CV mode done.');
        break;
    end

    % Wait 1 s before next reading
    pause(1);

end

end