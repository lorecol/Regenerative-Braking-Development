%
% -------------------- MAXIMUM REGENERATIVE CURRENT -----------------------
% -------------------------------------------------------------------------

% Reference paper: 
%        https://www.scirp.org/journal/paperinformation.aspx?paperid=106748

% This script is used to compute the admissible regenerative current in the
% most critic scenario - brake the car at maximum speed. It is composed of
% two parts:
% 1) Dynamics --> from the braking forces at the wheels we compute the
%                 braking torques. Since regenerative brake is at the rear
%                 wheels, we compute the maximum torque the motor can
%                 provide during brake considering only the torque at the 
%                 rear wheels. The motor torque is then compared with the
%                 maximum value defined in the motor datasheet and finally
%                 the resulting value is used to compute the maximum
%                 regenerative mechanical power
%
% 2) Electronics --> the maximum admissible regenerative current is
%                    computed from the maximum regenerative power 
%                    previously found in the mechanical section, the 
%                    minimum battery pack overall voltage and the total 
%                    impedance of the accumulator, which is based on the
%                    specific configuration of the battery
%                    

%% Theoretical notions

% To compute the braking forces/torques we consider the so-called bycicle
% model: it takes a 4-wheel model and combines the front and rear wheels 
% respectively to form a two-wheeled model 

%% Initialization

clear all;
close all;
clc;

% Add all files in current folder to Matlab path
addpath(genpath(pwd));

%% Data

g = vehicle_data.vehicle.g;                     % [m/s^2] Gravity
dM = vehicle_data.vehicle.dM;                   % [m/s^2] Maximum deceleration during brake
m = vehicle_data.vehicle.m;                     % [kg] Vehicle mass
bf = vehicle_data.vehicle.bf;                   % Load balance on the front
L = vehicle_data.vehicle.L;                     % [m] Wheel base
Lf = vehicle_data.vehicle.Lf;                   % [m] Distance between vehicle CoM and front wheels axel
Lr = vehicle_data.vehicle.Lr;                   % [m] Distance between vehicle CoM and rear wheels axel
hG0 = vehicle_data.vehicle.hG0;                 % [m] CoM heigth w.r.t. ground
Rf = vehicle_data.front_wheel.Rf;               % [m] Front wheel rolling radius
Rr = vehicle_data.rear_wheel.Rr;                % [m] Rear wheel rolling radius
mu_tr = vehicle_data.vehicle.mu_tr;             % Friction coefficient between tyres and ground
tau_red = vehicle_data.transmission.tau_red;    % [m] Transmission ratio
maxTorque = vehicle_data.motor.maxTorque;       % [Nm] Maximum torque the motor can provide
max_vel = 140/3.6;                              % [m/s] Maximum vehicle velocity
Vmin = 3;                                       % [V] Threshold voltage of the cell
Rint = 0.02;                                    % [Ohm] Internal impedance of the single cell
p = 4;                                          % Number of cells in parallel
s = 108;                                        % Number of cells in series
C = 4;                                          % [Ah] Cell capacity
burst = 8.75 * C;                               % [A] Maximum burst discharge current: 35 A from datasheet

%% Dynamics computation

fprintf('DYNAMICS:\n');

% Maximum braking forces on front/rear wheels
Ff = m * g * (bf * L + (dM/g) * hG0)/L;                         % [Nm] Front
Fr = m * g * ((1 - bf) * L - (dM/g) * hG0)/L;                   % [Nm] Rear 
fprintf('   Max braking force on front wheels: %.2f N\n', Ff);
fprintf('   Max braking force on rear wheels:  %.2f N\n', Fr);

% The above formulas come from a report on the brake disc- written by 
% Alberto Barban- that can be found on the shared drive

fprintf('\n');

% Maximum braking torques on front/rear wheels
Tf = Ff * Rf * mu_tr;                                           % [Nm] Front
Tr = Fr * Rr * mu_tr;                                           % [Nm] Rear 

fprintf('   Max braking torque on front wheels: %.2f Nm\n', Tf);
fprintf('   Max braking torque on rear wheels:  %.2f Nm\n', Tr);

fprintf('\n');

% Maximum motor torque to avoid rear wheels lock
Tm = Tr/tau_red; % [Nm]
fprintf(['   Max torque the motor can provide during brake:          ' ...
    'Tm = %.2f Nm\n'], Tm);
fprintf(['   Max torque that the motor can provide, from datasheet:  ' ...
    'maxTorque = %.2f Nm\n'], maxTorque);

% This braking torque produces a power flow to the battery pack that 
% depends on the vehicle speed. Now, it is important to verify that maximum
% regenerative power does not exceed the maximum charging power and current
% of Li-ion cells

% Check if the max braking torque exceeds the limit on the torque that the
% motor can provide
if Tm > maxTorque
    Tm = maxTorque;
    fprintf(['   Max braking torque exceeds the torque that the motor can provide:' ...
    ' Tm is set to %.2f Nm\n'], maxTorque);
else
    Tm;
    fprintf('   Max braking torque does not exceed the torque limit\n');
end

fprintf('\n');

% Maximum regenerative power generated during brake starting at 140 km/h - hard brake
P = Tm * (max_vel/Rr) * 10^(-3);
fprintf('   Maximum regenerative power: P = %.2f KW\n', P);

disp(['-----------------------------------------------------------------' ...
    '---------------------------']);

%% Electronics computation

% The battery pack is organized in a 108s4p configuration

fprintf('ELECTRONICS:\n');

% Total impedance of the accumulator
Rtot = p * (1/(s/Rint));                % [Ohm]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   EQUATIONS TO COMPUTE THE MAXIMUM ADMISSIBLE REGENERATIVE CURRENT:
%       1) P = Vinv * I
%       2) OCV = Rtot * I + Vinv
%   Vinv is the inverter DC voltage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syms I;
Ieq = I^2 * Rtot - I * Vmin * s + P * 10^3 == 0;
Ir = solve(Ieq, I);
Ir = double(Ir);
Ir = Ir(1);                             % [A]
fprintf('   Maximum admissible regenerative current: Ir = %.2f A\n', Ir);

% Regenerative current limit
IrL = burst * p;
fprintf('   Regenerative current limit: IrL = %.2f A\n', IrL);

% Check if max regenerative current does not exceed the limit
if Ir <= IrL
    fprintf('   Max admissible regenerative current is below the current limit.\n');
else
    fprintf('   Max admissible regenerative current exceeds the current limit.\n');
end