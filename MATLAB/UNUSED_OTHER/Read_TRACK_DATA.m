%
% -------------------- IMPORT DATA FROM .CSV FILE  ------------------------
% -------------------------------------------------------------------------

% This script is used to import telemetry data from a .csv file. It allows
% the user to choose which file to import the data from. After the data are
% loaded succesfully, they are plotted in time.

%% Initialization

clear all; 
close all;
clc; 

% Add telemetry data to Matlab path
addpath(genpath("endurances"));

%% Import data from .csv file

% Current and voltage data can be found in parsed/primary folder

% Choose the file to import data from
[file,path] = uigetfile('endurances/end_009/parsed/primary/*.csv');

% Check if the file was succesfully loaded
if isequal(file, 0)
   disp('User selected Cancel');
else
   disp(['Selected file: ', fullfile(path, file)]);
end

%% Set up the Import Options and import the data

% Automatic detect import options
opts = detectImportOptions(fullfile(path, file));
opts.PreserveVariableNames = true;

% Import the data
data = readtable(fullfile(path, file), opts);

% Clear temporary variables
clear opts

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Convert time from epochtime to human readable time %%%%%%%%%%%%

% % Extract time array
% t = uint64(data.("_timestamp"));

% % Conversion
% d = datetime(t, 'ConvertFrom', 'epochtime', 'Epoch', 1e6,...
%              'Format', 'dd-MMM-yyyy HH:mm:ss.SSSSSSSSS'     );
% s = second(d);
% m = minute(d);
% % Convert time array to minute + seconds format to better read it
% t = m + s/100; 

% % Clear variables that are no more useful
% clear d s m 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot data

% Create a figure with a series of subplots of data stored in the selected 
% .csv file
figure; clf; hold on;
sgtitle(regexprep(file, '_', ' '));

for i=1:(numel(data.Properties.VariableNames) - 1)

    subplot(2, 2, i);
    plot((data.(data.Properties.VariableNames{1}))/1000000, ...
          data.(data.Properties.VariableNames{i + 1})          );
    xlabel('Time [s]');
    ylabel(regexprep(data.Properties.VariableNames{i + 1}, '_', ' '));

end
hold off;