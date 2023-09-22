%% Clear variables
clear all; clf; clc; close all;
% Add files and folders to Matlab path
addpath(genpath(pwd))

%% Load voltage and current data from HPPC test
% Change if the structure of saved data is different
load('output/Test_20230914_1608.mat')
voltage = HPPCMeas.Voltage;
current = HPPCMeas.Current;
Ts= 0.1; % Sampling time
time = 0+Ts:Ts:((10 + 12)*60*10); % Time axis if not given

%% Define some constants
% Change if needed
capacity = 3000; % Battery capacity in mAh from Capacity Test
pulse_current = 2; % Pulse current in A
pulse_duration = 12*60; % Pulse duration in s
rest_duration = 10*60; % Rest duration between pulses in s
num_pulses = 4; % Number of pulses
SOC_init = 100; % Initial SOC in percentage
OCV_init = 4.1; % Initial OCV in Volt

%% Initialize some variables
SOC = zeros(num_pulses+1,1); % SOC vector
OCV = zeros(num_pulses+1,1); % OCV vector
R0 = zeros(num_pulses,1); % R0 vector
Ri = zeros(num_pulses,1); % Ri vector
Ci = zeros(num_pulses,1); % Ci vector

%% Calculate SOC and OCV
SOC(1) = SOC_init; % Initial SOC
OCV(1) = OCV_init; % Initial OCV 
for i = 1:num_pulses
    % Find the indices of the start and end of each pulse
    start_index = find(time >= pulse_duration  + (i-1)*(pulse_duration+rest_duration),1)+1;
    end_index = find(time >=  i*(pulse_duration + rest_duration),1);
    % Calculate the average SOC and OCV before each pulse
    discharged_Ah = (pulse_current * pulse_duration) / 3600;
    SOC(i+1) = SOC(i) - (discharged_Ah / (capacity/1000)) * 100;
    OCV(i+1) = mean(voltage(start_index:end_index));
end

%% Plot OCV-SOC curve
figure
plot(SOC,OCV,'o-')
set(gca, 'xdir', 'reverse' )
xlabel('SOC (%)')
ylabel('OCV (V)')
title('OCV-SOC curve', 'FontWeight', 'bold')
grid on

%% Calculate R0
for i = 1:num_pulses
    % Find the indices of the start and end of each pulse
    start_index = find(time >= (i-1)*(pulse_duration+rest_duration),1);
    end_index = find(time >= i*(pulse_duration+rest_duration),1)-1;
    % Calculate the voltage drop at the beginning of each pulse
    delta_V = voltage(start_index+2) - voltage(start_index);
    % Calculate R0 by Ohm's law
    R0(i) = abs(delta_V)/pulse_current;
end

%% Plot R0-SOC curve
figure
plot(SOC(2:end), R0,'o-')
set(gca, 'xdir', 'reverse' )
xlabel('SOC (%)')
ylabel('R0 (Ohm)')
title('R0-SOC curve', 'FontWeight', 'bold')
grid on

%% Define an exponential decay function for fitting
% Calculate Ri and Ci
for i = 1:num_pulses
    % First order RC model
    fun_1RC = @(p,x) OCV(num_pulses) - p(1)*exp(-x/p(2));
    % Second order RC model
    fun_2RC= @(p,x) OCV(num_pulses) - p(1)*exp(-x/p(2)) - p(3)*exp(-x/p(4));
    % Find the indices of the start and end of each pulse
    start_index = find(time >= (i-1)*(pulse_duration+rest_duration),1);
    end_index = find(time >= time(start_index) + pulse_duration,1)-1;
    % Extract the voltage response after each pulse
    t = time(start_index+1:end_index) - time(start_index+1); % Time vector relative to the start of the pulse
    V = voltage(start_index+1:end_index); % Voltage vector
    % Fit the exponential decay function to the voltage response
    p0_1RC = [delta_V, 10]; % Initial guess for the parameters
    p0_2RC = [delta_V, 10, delta_V, 10];
    options = optimoptions('lsqcurvefit','Display','off'); % Set options for optimization
    p_1RC = lsqcurvefit(fun_1RC,p0_1RC,t,V,[],[],options); % Perform nonlinear least squares fitting
    p_2RC = lsqcurvefit(fun_2RC,p0_2RC,t,V,[],[],options); 
    % Extract fitted parameters considering first order model
    R1i_1RC(i) = p_1RC(1)/pulse_current; % Ri is the total resistance minus R0
    C1i_1RC(i) = p_1RC(2)/R1i_1RC(i); % Ci is the time constant divided by Ri
    % Extract fitted parameters considering second order model
    R1i_2RC(i) = p_2RC(1)/pulse_current;
    R2i_2RC(i) = p_2RC(3)/pulse_current;
    C1i_2RC(i) = p_2RC(2)/R1i_2RC(i);
    C2i_2RC(i) = p_2RC(4)/R2i_2RC(i);
end

% Plot first order RC model
figure;
subplot(2,1,1) % Plot Ri-SOC curve
plot(SOC(2:end),R1i_1RC,'o-')
set(gca, 'xdir', 'reverse' )
xlabel('SOC (%)')
ylabel('R1 (Ohm)')
title('R1-SOC curve')
grid on
subplot(2,1,2)  % Plot Ci-SOC curve
plot(SOC(2:end),C1i_1RC,'o-')
set(gca, 'xdir', 'reverse' )
xlabel('SOC (%)')
ylabel('C1 (F)')
title('C1-SOC curve')
grid on
sgtitle('First Order RC Model Parameters', 'FontWeight', 'bold');

% Plot second order RC model
figure;
subplot(2,2,1) % Plot R1i-SOC curve
plot(SOC(2:end),R1i_2RC,'o-')
set(gca, 'xdir', 'reverse' )
xlabel('SOC (%)')
ylabel('R1 (Ohm)')
title('R1-SOC curve')
grid on
subplot(2,2,2) % Plot R2i-SOC curve
plot(SOC(2:end),R2i_2RC,'o-')
set(gca, 'xdir', 'reverse' )
xlabel('SOC (%)')
ylabel('R2 (Ohm)')
title('R2-SOC curve')
grid on
subplot(2,2,3)  % Plot C1i-SOC curve
plot(SOC(2:end),C1i_2RC,'o-')
set(gca, 'xdir', 'reverse' )
xlabel('SOC (%)')
ylabel('C1 (F)')
title('C1-SOC curve')
grid on
subplot(2,2,4)  % Plot C2i-SOC curve
plot(SOC(2:end),C2i_2RC,'o-')
set(gca, 'xdir', 'reverse' )
xlabel('SOC (%)')
ylabel('C2 (F)')
title('C2-SOC curve')
grid on
sgtitle('Second Order RC Model Parameters', 'FontWeight', 'bold');



