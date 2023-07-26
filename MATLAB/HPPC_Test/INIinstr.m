function INIinstr(visaObj)

% Reset the instrument to pre-defined values 
writeline(visaObj, '*RST');
% Clear status command
writeline(visaObj, '*CLS');

% Enable voltage measurements
writeline(visaObj, ':SENSe:FUNCtion:VOLTage ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:VOLTage ON');
% Enable current measurements
writeline(visaObj, ':SENSe:FUNCtion:CURRent ON');
writeline(visaObj, ':SENSe:ELOG:FUNCtion:CURRent ON');

% Set sampling period at 1 ms
writeline(visaObj, ':SENSe:SWEep:TINTerval 0.01');
% % Set number of points in a measurement
% writeline(visaObj, ':SENSe:SWEep:POINts 1');


% Set integration period at 1 s
writeline(visaObj, ':SENSe:ELOG:PERiod 1');

% Select trigger source
writeline(visaObj, ':TRIGger:TRANsient:SOURce BUS');

end