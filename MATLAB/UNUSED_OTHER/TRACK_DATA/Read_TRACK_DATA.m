%
% -------------------- IMPORT DATA FROM .CSV FILE  ------------------------
% -------------------------------------------------------------------------

% This script is used to import telemetry data from a .csv file. It allows
% the user to choose which file to import the data from. After the data are
% loaded succesfully, they are plotted in time.

%% Initialization

close all;
clear all; 
clc; 

% Add telemetry data to Matlab path
addpath(genpath(pwd));

%% Import data from .csv file

% Current and voltage data can be found in parsed/primary folder

% Choose the csv file to import data from
fprintf('Select a .csv file \n');
[file,path] = uigetfile([pwd,'/*.csv'],'MultiSelect', 'on');

% Check if the file was succesfully loaded
if isequal(file, 0)
   error('    User selected Cancel');
else
   fprintf('    Selected file: %s\n', file);
end

% Select the output filename
fprintf('Select the output .mat file name\n');
prompt = {'Output file name'};
dlgtitle = 'Input';
fieldsize = [1 45];
definput = {'e.g. load_end_009_voltage'};
answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
outFileName = answer{1};
fprintf('   Output file name: %s \n', outFileName);

%% Set up the Import Options and import the data

% Automatic detect import options
opts1 = detectImportOptions(fullfile(path, file));
opts1.PreserveVariableNames = true;

% Import the data
data1 = readtable(fullfile(path, file), opts1);

% Select the data to extract
fprintf('Select variable to extract: \n')
varNames = data1.Properties.VariableNames;
[indx,tf] = listdlg('ListString',varNames, 'SelectionMode','single', 'PromptString','Select a variable:');
fprintf('   Selected variable: %s \n', string(varNames(indx)));

y = data1.(string(varNames(indx)));
timestamps = data1.(string(varNames(1)));
x = (timestamps - timestamps(1) )/1e6;

% Create timeseries of data
timeseries1 = timeseries(y(1:end),x(1:end));
%====NOTE====
% If the last values are NaN -> REMOVE THEM:
% timeseries1 = timeseries(y(1:end-1),x(1:end-1));


% Save timeseries in a nested structure
% driveProfile = struct('ans', timeseries1);
fprintf('Select path folder where to save data \n')
selpath = uigetdir;
fprintf('   Selected path folder: %s \n', selpath);
save([selpath,'\', outFileName], 'timeseries1', "-v7.3");

% Clear temporary variables
clear opts1;

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