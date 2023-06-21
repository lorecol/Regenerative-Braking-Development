function logBatteryData(visaObj, time, voltage, current, SOC)
% Function for logging battery data

while ~isCancelled
    % Read voltage, current, and SOC
    v = readVoltage(visaObj);
    i = readCurrent(visaObj);
    s = readSOC(visaObj);
    t = datetime;

    % Append the data to the arrays
    time    = [time; t];
    voltage = [voltage; v];
    current = [current; i];
    SOC     = [SOC; s];

    % Pause for 1 second (sampling frequency of 1 Hz)
    pause(1);
end
end