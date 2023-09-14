%
% ------------------- BATTERY CELL CHARACTERIZATION -----------------------
% -------------------------------------------------------------------------

clc;
clear;
close all;


%% Loading data from HPPC test

data = load("Test_data/Test_20230914_0927.mat");    % Dataset upload for 
                                                    % postprocessing 

%% Extracting data from dataset
% Here we extract data from our dataset: in particular we're interested in
% current (A), voltage (V) and SOC (%); all these data are defined for each
% time step, accordingly to Ts (sample time) and toc, which are parameters
% defined in the mainHPPC file.

current = data.HPPCMeas.Current;    % Extracting current data 
voltage = data.HPPCMeas.Voltage;    % Extracting voltage data
time = data.HPPCMeas.Time;          % Extracting time data
SOC = data.SOC;                     % Extracting SOC data

% We've also to transpose vectors in order to be fisible for postprocessing
% characterization

current_T = current';
voltage_T = voltage';
time_T = time';
SOC_T = SOC';

%% Plotting parameters

figure
subplot(2,1,1)
plot(time,current)
xlabel('Time (s)')
ylabel('Current (A)')

subplot(2,1,2)
plot(time,voltage)
xlabel('Time (s)')
ylabel('Voltage (V)')


%% Cell characterization 

cellCapacity   = 3; % Cell capacity, [Ahr]
cellInitialSOC = 1; % Initial SOC level where 1 is fully charged, [/]
cell_prop      = [cellCapacity; cellInitialSOC];    % Cell properties array

% With these values it works, but we don't know why 
% maxDischargeCurr  = 2;  % Maximum discharging current, [A]
% maxChargeCurr     = 2.2;  % Maximum charging current, [A]
% constCurrSweepSOC = 1;  % Current sweep, [A]
% toleranceVal      = 0.1;   % Tolerance current value, [A]

maxDischargeCurr  = 2;  % Maximum discharging current, [A]
maxChargeCurr     = 2;  % Maximum charging current, [A]
constCurrSweepSOC = 1;  % Current sweep, [A]

toleranceValChg      = 0.1;   % Tolerance charging current value, [A]
toleranceValDischg   = 0.5;   % Tolerance discharging current value, [A]
toleranceValSOC   = 0.1;   % Tolerance SOC current value, [A]

hppc_protocol     = [maxDischargeCurr;...
                     maxChargeCurr;...
                     constCurrSweepSOC;...
                     toleranceValChg;...
                     toleranceValDischg;...
                     toleranceValSOC];

numRCpairs      = 1;    % Number of RC pairs in our battery model
initialGuess_RC = [0 2];    % Guess values [R1, Tau1, R2, Tau2 ....]


%% Computation

result = batt_BatteryCellCharacterization.ParameterEstimationLUTbattery(...
                                     [time_T, current_T, voltage_T],...
                                     cell_prop,...
                                     hppc_protocol,...
                                     numRCpairs,...
                                     initialGuess_RC,...
                                     "curvefit");

plotAndVerifyPulseData(result);

fitDataEverySOCval = 0.001;
fitDataForSOCpts = 0:fitDataEverySOCval:1;
verifyDataFit(result,fitDataEverySOCval,1);


cellParameters = exportResultsForLib(result,...
                 flip(SOC(SOC ~= 0)/100));