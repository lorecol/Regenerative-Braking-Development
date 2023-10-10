%% Initialization

clear all; 
close all;
clc; 

% Add all files in current folder to Matlab path
addpath(genpath(pwd));

%% Load voltage and current data from HPPC test

% Let the user choose a .mat file where HPPC data are stored
fprintf('Select an HPPC .mat file \n');
[file, path] = uigetfile('../HPPC_Test/output/*.mat');
% Check file selection
if isequal(file, 0)
   error('No file has been selected! Please select a file.');
else
   disp(['Selected file: ', fullfile(path, file)]);
end

% Load the data
load(fullfile(path, file));
% Extract the data
data = HPPCMeas;

% Clear some variables
clear HPPCMeas path file;

% Extract data arrays
time = data.Time;                                   % [s] Time 
voltage = data.Voltage;                             % [V] Voltage
current = data.Current;                             % [A] Current
SoC = data.SoC; SoC = SoC'; SoC = flip(SoC);        % [%] SoC

% Define the sampling time
Ts = time(1);                                       % [s]

%% Parameters definition

capacity = data.Capacity;                                       % [Ah] Battery capacity 
dischargeC3 = data.dischargeC3;                                 % [A] SoC decrement current
pulse_current = data.curr_charge_pulse;                         % [A] Pulse current
pulse_duration = 30;                                            % [s] Pulses duration 
rest_duration_pulse = 40;                                       % [s] Rest period after pulses 
rest_duration = 10 * 60;                                        % [s] Rest duration between pulses 
num_pulses = 10;                                                % Number of pulses
SOC_init = 100;                                                 % [%] Initial SOC
disCapStep = 0.1;                                               % 10% SOC decrement
tDisCycle = ((capacity * 3600 * disCapStep)/abs(dischargeC3));  % [s] Discharge cycle time

%% Variables initialization

index = zeros(num_pulses, 1);                   % Indexes for OCV estimation
index_dischg = cell(1, 2);                      % Indexes for R0_discharge estimation
index_dischg{1, 1} = zeros(num_pulses, 1);
index_dischg{1, 2} = zeros(num_pulses, 1);
index_chg = cell(1, 2);                         % Indexes for R0_charge estimation
index_chg{1, 1} = zeros(num_pulses, 1);
index_chg{1, 2} = zeros(num_pulses, 1);
start_index_Dyn = zeros(num_pulses, 1);
end_index_Dyn = zeros(num_pulses, 1);
OCV = zeros(num_pulses + 1, 1);                 % OCV vector
R0_discharge = zeros(num_pulses, 1);        % R0 during discharge pulse vector
R0_charge = zeros(num_pulses, 1);           % R0 during charge pulse vector
Ri = zeros(num_pulses + 1, 1);                  % Ri vector
Ci = zeros(num_pulses + 1, 1);                  % Ci vector

%% OCV computation     

for i = 1:(num_pulses + 1)

    % Find the indices where to compute the OCV
    index(i) = (rest_duration/2)/Ts + (i - 1) * (2 * pulse_duration + ...
                2 * rest_duration_pulse + ceil(tDisCycle) + rest_duration)/Ts;

    % Collect OCV values
    OCV(i) = voltage(index(i));

end

%% Plot OCV curve againts SoC intervals

figure, clf;
plot(flip(SoC), flip(OCV), 'o-');
xlabel('SOC (%)');
ylabel('OCV (V)');
title('OCV-SOC curve', 'FontWeight', 'bold');
grid on;

%% R0 computation

for i = 1:num_pulses

    % Find the start and end indexes where to estimate R0_discharge
    index_dischg{1, 1}(i) = index(i);
    index_dischg{1, 2}(i) = index(i) + 2;

    R0_discharge(i) = abs(voltage(index_dischg{1, 2}(i)) - voltage(index_dischg{1, 1}(i)))/pulse_current;

    % Find the start and end indexes where to estimate R0_charge
    index_chg{1, 1}(i) = index(i) + (pulse_duration + rest_duration_pulse)/Ts;
    index_chg{1, 2}(i) = index_chg{1, 1}(i) + 2;

    R0_charge(i) = abs(voltage(index_chg{1, 2}(i)) - voltage(index_chg{1, 1}(i)))/pulse_current;

end

%% Plot R0 curve againts SoC intervals

figure, clf;
subplot(1, 2, 1);
plot(flip(SoC(1:(end - 1))), flip(R0_discharge), 'o-');
xlabel('SOC (%)');
ylabel('R0 discharge (Ohm)');
title('R0 discharge-SOC curve', 'FontWeight', 'bold');
grid on;
subplot(1, 2, 2);
plot(flip(SoC(1:(end - 1))), flip(R0_charge), 'o-');
xlabel('SOC (%)');
ylabel('R0 charge (Ohm)');
title('R0 charge-SOC curve', 'FontWeight', 'bold');
grid on;

%% Dynamic computation

% Calculate Ri and Ci
for i = 1:num_pulses

    % First order RC model
    fun_1RC = @(p,x) OCV(num_pulses) - p(1)*exp(-x/p(2));
    % Second order RC model
    fun_2RC= @(p,x) OCV(num_pulses) - p(1)*exp(-x/p(2)) - p(3)*exp(-x/p(4));

    % Find the indices of the start and end of each pulse
    start_index_Dyn(i) = (rest_duration/2)/Ts + i * pulse_duration/Ts + ...
                   (i - 1) * (pulse_duration + rest_duration + ceil(tDisCycle) + rest_duration)/Ts + 1;
    end_index_Dyn(i) = start_index_Dyn(i) + rest_duration_pulse;

    % % Extract the voltage response after each pulse
    % t = time(start_index+1:end_index) - time(start_index+1); % Time vector relative to the start of the pulse
    % V = voltage(start_index+1:end_index); % Voltage vector
    % % Fit the exponential decay function to the voltage response
    % p0_1RC = [delta_V, 10]; % Initial guess for the parameters
    % p0_2RC = [delta_V, 10, delta_V, 10];
    % options = optimoptions('lsqcurvefit','Display','off'); % Set options for optimization
    % p_1RC = lsqcurvefit(fun_1RC,p0_1RC,t,V,[],[],options); % Perform nonlinear least squares fitting
    % p_2RC = lsqcurvefit(fun_2RC,p0_2RC,t,V,[],[],options); 
    % % Extract fitted parameters considering first order model
    % R1i_1RC(i) = p_1RC(1)/pulse_current; % Ri is the total resistance minus R0
    % C1i_1RC(i) = p_1RC(2)/R1i_1RC(i); % Ci is the time constant divided by Ri
    % % Extract fitted parameters considering second order model
    % R1i_2RC(i) = p_2RC(1)/pulse_current;
    % R2i_2RC(i) = p_2RC(3)/pulse_current;
    % C1i_2RC(i) = p_2RC(2)/R1i_2RC(i);
    % C2i_2RC(i) = p_2RC(4)/R2i_2RC(i);

end

% % Plot first order RC model
% figure;
% subplot(2,1,1) % Plot Ri-SOC curve
% plot(SOC(2:end),R1i_1RC,'o-')
% set(gca, 'xdir', 'reverse' )
% xlabel('SOC (%)')
% ylabel('R1 (Ohm)')
% title('R1-SOC curve')
% grid on
% subplot(2,1,2)  % Plot Ci-SOC curve
% plot(SOC(2:end),C1i_1RC,'o-')
% set(gca, 'xdir', 'reverse' )
% xlabel('SOC (%)')
% ylabel('C1 (F)')
% title('C1-SOC curve')
% grid on
% sgtitle('First Order RC Model Parameters', 'FontWeight', 'bold');
% 
% % Plot second order RC model
% figure;
% subplot(2,2,1) % Plot R1i-SOC curve
% plot(SOC(2:end),R1i_2RC,'o-')
% set(gca, 'xdir', 'reverse' )
% xlabel('SOC (%)')
% ylabel('R1 (Ohm)')
% title('R1-SOC curve')
% grid on
% subplot(2,2,2) % Plot R2i-SOC curve
% plot(SOC(2:end),R2i_2RC,'o-')
% set(gca, 'xdir', 'reverse' )
% xlabel('SOC (%)')
% ylabel('R2 (Ohm)')
% title('R2-SOC curve')
% grid on
% subplot(2,2,3)  % Plot C1i-SOC curve
% plot(SOC(2:end),C1i_2RC,'o-')
% set(gca, 'xdir', 'reverse' )
% xlabel('SOC (%)')
% ylabel('C1 (F)')
% title('C1-SOC curve')
% grid on
% subplot(2,2,4)  % Plot C2i-SOC curve
% plot(SOC(2:end),C2i_2RC,'o-')
% set(gca, 'xdir', 'reverse' )
% xlabel('SOC (%)')
% ylabel('C2 (F)')
% title('C2-SOC curve')
% grid on
% sgtitle('Second Order RC Model Parameters', 'FontWeight', 'bold');