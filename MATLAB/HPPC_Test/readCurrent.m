function current = readCurrent()
% Function to read current from the instrument

% Replace with the appropriate command to read current from the instrument
writeline(visaObj, 'MEASure:CURRent:DC?');
current = str2double(readline(visaObj));
end