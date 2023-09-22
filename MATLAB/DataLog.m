clear all; 
close all; 
clc;

%% Code to log data in txt file

baudrate = 115200;

% Check available serial ports
serialportname = serialportlist("available");

% Create a serial port object
s = serialport(serialportname, baudrate);

% Define the name of the file where to log data
FileName = "datalog.txt";

% Open the visualisation of the file where to log data
open(FileName);

% Open the file where to log data; create the file if not present
newFileID = fopen(FileName, 'a+');

% Create a cycle to stop data logging after a condition is met
timerStart = tic;   % Start the external reference timer
while true
    % Read each line of data from serial port object
    idn = readline(s);
    
    % Print the data to the txt file
    fprintf(newFileID, "%s\n", idn);
    
    % Print toc time
    fprintf("%g\n", toc(timerStart));
    
    % Exit if a condition is met
    if toc(timerStart) >= 10
        % Send the terminator command
        writeline(s, "LF");
        break;
    end
end

% Close the file where to log data
fclose(newFileID);
% Clear the serial port object
clear s;