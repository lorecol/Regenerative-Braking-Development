function SOC = readSOC()
% Function to read SOC from the instrument   

% Replace with the appropriate command to read SOC from the instrument
writeline(visaObj, 'MEASure:SOC?');
SOC = str2double(readline(visaObj));
end