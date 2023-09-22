% battery keeps charging and discharging for 6 hours. The extended Kalman 
% filter estimator converges to the real value of the SOC in less than 10 
% minutes and then follows the real SOC value. To use a different Kalman 
% filter implementation, in the SOC Estimator (Kalman Filter) block, set 
% the Filter type parameter to the desired value.

% Copyright 2022 The MathWorks, Inc.

%% Model

open_system('BatterySOCEstimation')

set_param(find_system('BatterySOCEstimation','FindAll', 'on','type','annotation','Tag','ModelFeatures'),'Interpreter','off')

%% Simulation Results
%
% The plot below shows the real and estimated battery state-of-charge.
%


BatterySOCEstimationPlotSOC;