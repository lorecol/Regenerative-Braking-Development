%
% ------------------------ SERIAL DATA LOGGING ----------------------------
% -------------------------------------------------------------------------

% This script is used to record voltage and temperature data from a block
% of cells (i.e. a series of three modules, which are four cells in 
% parallel) through a microcontroller connected to it, which samples with 
% a frequency of 10 Hz.

%% Initialization

clear all; 
close all; 
clc;

% Add all files from current folder to Matlab path
addpath(genpath(pwd));

%% Log data in external .txt file

% Define the baudrate, i.e. the number of transitions per second that occur
% on the line
baudrate = 115200;

% Check available serial ports
serialportname = serialportlist("available");

% Create a serial port object
s = serialport(serialportname, baudrate);

% Get the current date as a formatted string (YYYYMMDD format)
currentDateStr = datestr(now, 'yyyymmdd');

% Define the list of tests that can be conducted and allow the user to 
% choose which test to save data for
TestList = {'CapacityTest', 'HPPCTest', 'CCCVCharge'};
Test = listdlg('PromptString', 'Which operation are you performing?', ...
               'ListString', TestList, 'SelectionMode', 'single'         );

% Check if a test has been selected
if ~isempty(Test)
    selectedVariableTest = TestList{Test};
else
    error('No operation selected.');
end

% Create the output folder and the test subfolder if they don't exist
subdir = sprintf('%s_Block_%s', TestList{Test}, currentDateStr);
if ~exist('output', 'dir')
    mkdir('output');
    mkdir(sprintf('output/%s', subdir));
else 
    mkdir(sprintf('output/%s', subdir));
end

% Define the name of the file where to log data
FileName = sprintf("output/%s/%s_SerialDataLog.txt", subdir, TestList{Test});

% Open the file where to log data in writing mode; create the file if not 
% already present
newFileID = fopen(FileName, 'w+');

% Visualize the file where to log data
open(FileName);

% Create a button to stop data logging
ButtonHandle = uicontrol('Style', 'PushButton', 'String', 'Stop', ...
                         'Callback', 'delete(gcbf)'                  );

% Send a string to start data logging
writeline(s, "start");

% Start the external reference timer
timerStart = tic;

% Log data until the specific button is pressed
while true

    % Read each line of data from the serial port object
    idn = readline(s);
    
    % Append the data to the external .txt file
    fprintf(newFileID, "%s\n", idn);
    
    % Print the elapsed time
    fprintf("%g\n", toc(timerStart));
    
    % Check if the button is pressed
    if ~ishandle(ButtonHandle)

        % Send the terminator command
        writeline(s, "LF");

        disp('Loop stopped by user');
        break;

    end

end

% Close the file where data are logged
fclose(newFileID);

% Clear the serial port object
clear s;