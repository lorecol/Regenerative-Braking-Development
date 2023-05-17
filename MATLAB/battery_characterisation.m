%% INITIALIZATION

clear all;
close all;
clc;

addpath(genpath(pwd));

%% DATA LOADING

% Path where data can be found
path = "Parameters_Identification\Samsung_INR21700_30T_RC_Identification\25degC";
% Load the data
data = load(path + "\03-14-19_17.34 729_HPPC_25degC_IN21700_30T.mat");
data = data.meas;

%% PRE-PROCESSING - Resample the data

% Define new sampling time 
Ts = 1; % [s]
% Define new vector of time
t = (0:Ts:data.Time(end))';
% Define timeseries vectors
timeseriesC = timeseries(data.Current, data.Time);            % current
timeseriesV = timeseries(data.Voltage, data.Time);            % voltage
timeseriesT = timeseries(data.Battery_Temp_degC, data.Time);  % temperature
% Resample
timeseriesC = resample(timeseriesC, t);                       % current
timeseriesV = resample(timeseriesV, t);                       % voltage
timeseriesT = resample(timeseriesT, t);                       % temperature

% Create new struct of data
field1 = 'Time';  value1 = t;
field2 = 'Voltage';  value2 = timeseriesV.data;
field3 = 'Current';  value3 = timeseriesC.data;
field4 = 'Temperature';  value4 = timeseriesT.data;
data = struct(field1, value1, field2, value2, field3, value3, field4, value4);

% Clear some variables
clear field1 field2 field3 field4 value1 value2 value3 value4;
clear timeseriesC timeseriesV timeseriesT;
clear t Ts;

%% PLOT OF THE DATA

% Fields name inside data struct
fields = fieldnames(data);
% Measurement units
units = [" [V]"; " [A]"; " [°C]"];
% Number of elements to be plotted
n = length(fields) - 1;
% Plots
for i = 1:n
    figure(i), clf;
    plot(data.Time, data.(fields{i+1}));
    xlabel('time [s]');
    ylabel(fields{i+1} + units(i));
    title(fields{i+1});
end

% Clear some variables
clear fields units;
clear i n;

%% PARAMETERS IDENTIFICATION




