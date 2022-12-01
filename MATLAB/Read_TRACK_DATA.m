%% Clear all
clc; clear all; close all;

%% Import data from text file
% Script for importing data from the following HV_VOLTAGE file:
[file,path] = uigetfile('*.csv');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end

%% Set up the Import Options and import the data
% Automatic detect import options
opts = detectImportOptions(fullfile(path,file));
opts.PreserveVariableNames=true;

% Import the data
DATAFILE = readtable(fullfile(path,file), opts);

% Clear temporary variables
clear opts

%% Plot data
% Automatic create a figure with a series of subplot. Assuming that the first column is the time
figure; clf; hold on
sgtitle(regexprep(file, '_',' '));
for i=1:(numel(DATAFILE.Properties.VariableNames)-1)
    subplot(2,2,i)
    plot(DATAFILE.(DATAFILE.Properties.VariableNames{1}),  DATAFILE.(DATAFILE.Properties.VariableNames{i+1}) )
    xlabel('Time')
    ylabel(regexprep(DATAFILE.Properties.VariableNames{i+1}, '_', ' '))  % Convert underscore '_' to
end
hold off

