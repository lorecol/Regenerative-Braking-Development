% This script is used to record voltage and temperature data from a "block"
% (= a series of 3 "modules" which are 4 cells in parallel) 
% throught a microcontroller connected to it sampling period of 0.1s.

%% Clear data
clear all; 
close all; 
clc;

% Add files and folders to Matlab path
addpath(genpath(pwd))

%% Code to log data in txt file

baudrate = 115200;

% Check available serial ports
serialportname = serialportlist("available");

% Create a serial port object
s = serialport(serialportname, baudrate);

% Save log in an external file
% Create the output subfolder if it doesn't exist
if ~exist('output', 'dir')
    mkdir('output');
end
% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd_HHMM');
% Define the name of the file where to log data
FileName = ['output/SerialDataLog_', currentDateStr, '.txt'];

% Open the file where to log data; create the file if not present
newFileID = fopen(FileName, 'a+');

% Open the visualisation of the file where to log data
open(FileName);

% Create a button to stop saving data
ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                         'Callback', 'delete(gcbf)');

% Send a char to say at the micro to start sending values 
writeline(s, "hello");

% Start execution time
timerStart= tic;

% Start cycle
while true
    % Read each line of data from serial port object
    idn = readline(s);
    
    % Append the data to the txt file
    fprintf(newFileID, "%s\n", idn);
    
    % Print toc time
    fprintf("%g\n", toc(timerStart));
    
    % Check if the button is pressed
    if ~ishandle(ButtonHandle)
        % Send the terminator command
        writeline(s, "LF");
        disp('Loop stopped by user');
        break;
    end
end

% Close the file where to log data
fclose(newFileID);
% Clear the serial port object
clear s;