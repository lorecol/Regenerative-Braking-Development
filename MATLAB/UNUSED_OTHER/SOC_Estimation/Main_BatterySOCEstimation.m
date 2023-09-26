%
% -------------------------- SOC ESTIMATION -------------------------------
% -------------------------------------------------------------------------

clear all;
close all;
clc;

% Add files and folders to Matlab path
addpath(genpath(pwd))

%% Model

open_system('BatterySOCEstimation')

set_param(find_system('BatterySOCEstimation','FindAll', 'on','type','annotation','Tag','ModelFeatures'),'Interpreter','off')

%% Kalman Filter

Q    = [1e-4 0; 0 1e-4];    % Covariance of the process noise, Q
R    = 0.7;                 % Covariance of the measurement noise, R
P0   = [1e-5 0; 0 1];       % Initial state error covariance, P0
Ts   = 0.1;                 % Sample time

%% Simulation Results
%
% The plot below shows the real and estimated battery state-of-charge.
%

BatterySOCEstimationPlotSOC;