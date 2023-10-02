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
addpath(genpath("TelemetryData_endurances"));

%% Import data from .csv file

% Current and voltage data can be found in parsed/primary folder

% Choose the file to import data from
[file,path] = uigetfile('TelemetryData_endurances/end_009/parsed/primary/*.csv', ...
                        'MultiSelect', 'on');

% Check if the file was succesfully loaded
if isequal(file, 0)
   fprintf('User selected Cancel\n');
else
   fprintf('Selected files: %s and %s\n', file{1}, file{2});
end

%% Set up the Import Options and import the data

% Automatic detect import options
opts1 = detectImportOptions(fullfile(path, file{1}));
opts1.PreserveVariableNames = true;
opts2 = detectImportOptions(fullfile(path, file{2}));
opts2.PreserveVariableNames = true;

% Import the data
data1 = readtable(fullfile(path, file{1}), opts1);
data2 = readtable(fullfile(path, file{2}), opts2);

% Create timeseries of data
timeseries1 = timeseries(data1.current, (data1.("_timestamp"))/1000000);
timeseries2 = timeseries(data2.pack_voltage, (data2.("_timestamp"))/1000000);

% Save timeseries in a nested structure
% driveProfile = struct('ans', timeseries1);
save('../Parameter_Identification/src/loadProfiles/batt_BatteryCellCharacterizationForBEV_end_009.mat', 'timeseries1');

% Clear temporary variables
clear opts1 opts2;

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
% - Data 1
figure; clf; hold on;
sgtitle(regexprep(file, '_', ' '));

for i = 1:(numel(data1.Properties.VariableNames) - 1)

    subplot(2, 2, i);
    plot((data1.(data1.Properties.VariableNames{1}))/1000000, ...
          data1.(data1.Properties.VariableNames{i + 1})          );
    xlabel('Time [s]');
    ylabel(regexprep(data1.Properties.VariableNames{i + 1}, '_', ' '));

end
hold off;

% - Data 2
figure; clf; hold on;
sgtitle(regexprep(file, '_', ' '));

for i = 1:(numel(data1.Properties.VariableNames) - 1)

    subplot(2, 2, i);
    plot((data2.(data2.Properties.VariableNames{1}))/1000000, ...
          data2.(data2.Properties.VariableNames{i + 1})          );
    xlabel('Time [s]');
    ylabel(regexprep(data2.Properties.VariableNames{i + 1}, '_', ' '));

end
hold off;