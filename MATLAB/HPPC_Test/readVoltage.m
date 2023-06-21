function voltage = readVoltageFcn(visaObj)
% Function to read voltage from the instrument

% Replace with the appropriate command to read voltage from the instrument
writeline(visaObj, 'MEASure:VOLTage:DC?');
voltage = str2double(readline(visaObj));
end