%% INITIALIZATION

clear all;
close all;
clc;

addpath(genpath(pwd));

%% DATA LOADING

% Path where data can be found
path = "Parameters_Identification/Samsung_INR21700_30T_RC_Identification/25degC";
% Load the data
data = load(path + "/03-14-19_17.34 729_HPPC_25degC_IN21700_30T.mat");
data = data.meas;

%% PRE-PROCESSING - Resample the data

% Define new sampling time 
Ts = 1; % [s]
% Define new vector of time
time = (0:Ts:data.Time(end))';
% Define timeseries vectors
timeseriesC = timeseries(data.Current, data.Time);               % current
timeseriesV = timeseries(data.Voltage, data.Time);               % voltage
timeseriesT = timeseries(data.Battery_Temp_degC, data.Time);     % temperature
timeseriesAh = timeseries(data.Ah, data.Time);                   % capacity
% Resample
timeseriesC = resample(timeseriesC, time);                       % current
timeseriesV = resample(timeseriesV, time);                       % voltage
timeseriesT = resample(timeseriesT, time);                       % temperature
timeseriesAh = resample(timeseriesAh, time);                     % capacity

% Create new struct of data
field1 = 'Time';  value1 = time;
field2 = 'Voltage';  value2 = timeseriesV.data;
field3 = 'Current';  value3 = timeseriesC.data;
field4 = 'Temperature';  value4 = timeseriesT.data;
field5 = 'Capacity';  value5 = timeseriesAh.data;
data = struct(field1, value1, field2, value2, field3, value3, ...
    field4, value4, field5, value5);

% Clear some variables
clear field1 field2 field3 field4 field5 value1 value2 value3 value4 value5;
clear timeseriesC timeseriesV timeseriesT timeseriesAh;
clear time Ts;

%% PLOT OF THE DATA

% % Save the name of the fields that define the dataset structure
% fields = fieldnames(data);
% % Measurement units of data to be plotted
% units = [" [V]"; " [A]"; " [°C]"; " [Ah]"];
% 
% % Plots
% for i = 1:(length(fields) - 1)
%     if(isnumeric(data.(fields{i})))
%         if fields{i + 1} ~= "Capacity"
%             figure(i), clf;
%             plot(data.Time, data.(fields{i+1}));
%             xlabel('time [s]');
%             ylabel(fields{i+1} + units(i));
%             title(fields{i+1});
%         elseif fields{i + 1} == "Capacity"            % skip the cell capacity figure
%             continue;
%         end
%     end
% end
% 
% % Clear some variables
% clear fields units;
% clear i;

%% OPEN-CIRCUIT-VOLTAGE (OCV) ESTIMATION

SOCv = [1 0.95 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.15 0.1 0.05 0.025]';   % SoC vector
Cap = 3;                                                                % cell capacity [Ah]
SOCt = ((data.Capacity + Cap)/Cap);                                     % cell SoC

% Values of SoC above 1 are not accepted. All values of SoC above 1 are
% considered equal to 1
SOClim = 1;
SOCt(SOCt > SOClim) = 1;

% Plot the SoC of the cell during the hppc test
figure, clf;
plot(data.Time, SOCt);
xlabel('time [s]');
ylabel('SoC');
title('SoC');

% Enter the SoC values within the dataset structure
data.SOC = SOCt;

% Clear some variables
clear Cap SOCt SOClim;

% Find the minimum value of the SoC and its index in the dataset
SOCmin = min(data.SOC);
SOCminidx = find(data.SOC == SOCmin);
SOCminidx = SOCminidx(end);

% Cut all data (voltage, current, capacity, temperature and SoC) to the
% index computed previously
fields = fieldnames(data);
for i = 1:numel(fields)
    if(isnumeric(data.(fields{i})))
        data.(fields{i}) = data.(fields{i})(1:SOCminidx);
    end
end

% Plots
units = [" [V]"; " [A]"; " [°C]"; " [Ah]"; " "];
for i = 1:(length(fields) - 1)
    if(isnumeric(data.(fields{i})))
        if fields{i + 1} ~= "Capacity"
            figure(i), clf;
            plot(data.Time, data.(fields{i+1}));
            xlabel('time [s]');
            ylabel(fields{i+1} + units(i));
            title(fields{i+1});
        elseif fields{i + 1} == "Capacity"          % skip the cell capacity figure
            continue;
        end
    end
end

% Clear some variables
clear fields units;
clear i;
clear SOCmin SOCminidx;

%% PARAMETERS IDENTIFICATION

% % Define equation variables symbolically
% syms u1(t) u2(t)
% syms R0 R1 R2 C1 C2
% x = sym('x', [1 7]);
% 
% % Define variables and parameters
% vars = [u1(t) u2(t)];
% pars = [R0 R1 R2 C1 C2];
% curr = [0 -3.01 3.01 0 1 -1 -3.01 3.01];
% I = data.Current';
% 
% % Initial conditions
% vars0 = [3.6 3.6];
% x0 = [1 10 100 1 100];
% 
% % Battery dynamics equations
% eqs = [u1(t) == I * R1 - R1 * C1 * diff(u1(t), t), ...
%        u2(t) == I * R2 - R2 * C2 * diff(u2(t), t)];
% 
% dsol = dsolve(eqs, [u1(0) == vars0(1), u2(0) == vars0(2)]);
% 
% u1 = dsol.u1;
% u2 = dsol.u2;
% 
% u1 = subs(u1, {C1, R1}, {str2sym('x(2)'), str2sym('x(4)')});
% u2 = subs(u2, {C2, R2}, {str2sym('x(3)'), str2sym('x(5)')});
% 
% % Create strings with the solution of dynamics equations
% u1f = sprintf("@(x, t) %s", char(u1));
% u2f = sprintf("@(x, t) %s", char(u2));
% 
% % Create function handles from previous strings
% Fu1 = str2func(sprintf("%s", char(u1f)));
% Fu2 = str2func(sprintf("%s", char(u2f)));
% 
% % Concatenate the solutions of the 2 dynamics
% Fu12 = @(x, t) (Fu1(x, t) + Fu2(x, t));
% 
% % Function handle for the entire battery model equation
% Fdyn = @(x, t) (x(1) * I - I * Fu12(x, t));

% x = lsqcurvefit(Fdyn, x0, data.Time', data.Voltage');




