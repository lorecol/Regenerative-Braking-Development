clear all;
close all;
clc;

%% LOAD DATA

HPPC25C = load('25degC/03-14-19_17.34 729_HPPC_25degC_IN21700_30T.mat');
HPPC40C = load('40degC/03-01-19_19.23 705_HPPC_40degC_IN21700_30T.mat');
Mixed10C = load('10degC/03-29-19_02.25 752_Mixed1_10degC_IN21700_30T.mat');

%% RESCALE DATA TO HAVE THE SAME SIZE

[HPPC25C, HPPC40C] = Rescale_data(HPPC25C, HPPC40C);

%% RESAMPLE DATA TO HAVE THE SAME TIME AXIS

[HPPC25C, HPPC40C, Mixed10C] = Resample_data(HPPC25C, HPPC40C, Mixed10C);

%% SAVE DATA IN .MAT FILE AND OPEN THE MODEL

battery_data = struct('v',{HPPC25C.meas.Voltage, HPPC40C.meas.Voltage, Mixed10C.meas.Voltage}, ...
    'i', {HPPC25C.meas.Current, HPPC40C.meas.Current, Mixed10C.meas.Current}, ...
    't',{HPPC25C.meas.Time, HPPC40C.meas.Time, Mixed10C.meas.Time}, ...
    'SOC0', {1, 1, 0.8}, 'T', {25, 40, Mixed10C.meas.Battery_Temp_degC});
 
save ee_battery_data.mat battery_data;

load ee_battery_data.mat
assignin('base','T1', battery_data(find([battery_data(1:2).T]==25)).T);
assignin('base','T2', battery_data(find([battery_data(1:2).T]~=25)).T);

% Display the Battery model
Model = 'ee_battery.slx';
open_system(Model)

%% 

close_system(Model, 0);

%% INITIAL PARAMETER SPECIFICATION

% List of parameters and initial values prior to optimization
ParsListMain = {'Vnom', 'R1', 'AH', 'V1', 'AH1'};
InitGuessMain = [3.6, 0.045, 2.7, 3.4, 1.4];
ParsListDyn = {'Rp1', 'tau1'};
InitGuessDyn = [0.006, 200];
ParsListTemp = {'Vnom_T2', 'R1_T2', 'V1_T2','Rp1_T2','tau1_T2'};
InitGuessTemp = [3.8, 0.055, 3.6, 0.006, 200 ];
  
Pars0 = reshape([[ParsListMain ParsListDyn ParsListTemp]; cellstr(num2str([InitGuessMain InitGuessDyn InitGuessTemp]'))'],1,[]);
fprintf('\t%5s = %s\n', Pars0{:});
clear Pars0

%% PLOT DATA VS BATTERY OUTPUT USING INITIAL PARAMETERS

% Load single cell Battery model and set parameters
load_system(Model);
% Enable Fast Restart to speedup the simulation
set_param(Model,'FastRestart','on')
  
Pars = reshape([ParsListMain; cellstr(num2str(InitGuessMain'))'],1,[]);
for k=1:2:length(Pars)
    evalin('base',[Pars{k} '=' Pars{k+1} ';'])
end

Pars = reshape([ParsListDyn; cellstr(num2str(InitGuessDyn'))'],1,[]);
for k=1:2:length(Pars)
    evalin('base',[Pars{k} '=' Pars{k+1} ';'])
end

Pars = reshape([ParsListTemp; cellstr(num2str(InitGuessTemp'))'],1,[]);
for k=1:2:length(Pars)
    evalin('base',[Pars{k} '=' Pars{k+1} ';'])
end

% Generate preliminary model curves and plot against data
num_lines = length(battery_data)-1;
v_model = cell(1, num_lines);
t_model = cell(1, num_lines);
legend_info_data  = cell(1, num_lines);
legend_info_model = cell(1, num_lines);

for idx_data = 1:num_lines
    assignin('base','t_data',battery_data(idx_data).t);
    assignin('base','i_data',battery_data(idx_data).i);
    assignin('base','T_data',battery_data(idx_data).T*ones(length(t_data),1));
    assignin('base','T0',battery_data(idx_data).T);
    assignin('base','Ts',t_data(2)-t_data(1));
    assignin('base','AH0',AH*battery_data(idx_data).SOC0);

    out = sim(Model);
    v_model{idx_data} = out.Vo.signals.values;
    t_model{idx_data} = out.Vo.time;
    legend_info_data{idx_data}  = [ 'Temp = '                         ...
    num2str(battery_data(idx_data).T) '\circC, Data'];
    legend_info_model{idx_data} = [ 'Temp = '                         ...
    num2str(battery_data(idx_data).T) '\circC, Model'];
end
  
plot([battery_data(1:num_lines).t]/3600, [battery_data(1:num_lines).v], 'o', [t_model{:}]/3600, [v_model{:}])
xlabel('Time (hours)');
ylabel('Battery voltage (V)');
legend([legend_info_data legend_info_model], 'Location', 'Best');
title('Model with Initial Parameter Values');

%% STEP 1) OPTIMIZE MAIN TAB DIALOG PARAMETERS WITHOUT CHARGE DYNAMICS

% Find ambient temperature data index
idx_data = find([battery_data(1:num_lines).T]==25);
assignin('base','t_data',battery_data(idx_data).t);
assignin('base','i_data',battery_data(idx_data).i);
assignin('base','T_data',battery_data(idx_data).T*ones(length(t_data),1));
assignin('base','T0',battery_data(idx_data).T);
assignin('base','Ts',t_data(2)-t_data(1));
assignin('base','v_data',battery_data(idx_data).v);

% Optimize parameters in main dialog tab of Battery
assignin('base','ParsList',ParsListMain(1:4));
InitGuess = InitGuessMain(1:4);
OptPars = fminsearch(@ee_battery_lse, InitGuess,              ...
optimset('TolX', 1e-3));

OptParsMain = [OptPars(1:4) InitGuessMain(5)];
  
% Update Battery block with optimized parameters
Pars = reshape([ParsListMain; cellstr(num2str(OptParsMain'))'],1,[]);
for k=1:2:length(Pars)
    evalin('base',[Pars{k} '=' Pars{k+1} ';'])
end
  
% Display optimized parameters
fprintf(['Optimized parameters for the battery main ' ...
         'dialog tab are:\n']);
fprintf('\t%5s = %s\n', Pars{:});
    
clear i_data v_data t_data T_data Ts
clear k InitGuess

%% STEP 2) OPTIMIZE CHARGE DYNAMICS PARAMETERS

% Use only one current pulse for optimizing the charge dynamics
i_pos=battery_data(1).i.*(battery_data(1).i>=0);
a=find(diff(i_pos)>0,2);
b = find(diff(battery_data(1).i));
c = fix((b(find(b<a(1),1,'last'))+a(1))/2);
assignin('base','i_data',battery_data(idx_data).i(c+1:a(2)));
assignin('base','v_data',battery_data(1).v(c+1:a(2)));
assignin('base','t_data',battery_data(idx_data).t(1:length(i_data)));
assignin('base','T_data',battery_data(idx_data).T*ones(length(t_data),1));
assignin('base','T0',battery_data(idx_data).T);
assignin('base','Ts',t_data(2)-t_data(1));

% Find Battery initial charge before optimizing charge dynamics parameters
assignin('base','ParsList',{'charge'});
InitGuessCharge = OptParsMain(3);
OptCharge = fminsearch(@ee_battery_lse, InitGuessCharge, ...
                       optimset('TolX', 1e-3));
assignin('base','AH0',OptCharge);
% Optimize Battery charge dynamics parameters
assignin('base','ParsList',[ParsListMain(2) ParsListDyn]);
InitGuessDyn = [OptPars(2) InitGuessDyn];
OptParsDyn = fminsearch(@ee_battery_lse, InitGuessDyn, ...
                        optimset('TolX', 1e-3));

% Update Battery block with optimized charge dynamics parameters
ParsListMainDyn = [ParsListMain ParsListDyn];
OptParsMainDyn = [OptPars(1) OptParsDyn(1) OptPars(3:4) InitGuessMain(5) OptParsDyn(2:3)];
Pars = reshape([ParsListMainDyn; cellstr(num2str(OptParsMainDyn'))'],1,[]);
for k=1:2:length(Pars)
    evalin('base',[Pars{k} '=' Pars{k+1} ';'])
end
assignin('base','AH0',AH*battery_data(idx_data).SOC0);
  
% Display optimized parameters
fprintf(['Optimized parameters for the Battery, ' ...
           'including charge dynamics, are:\n']);
fprintf('\t%5s = %s\n', Pars{:});
  
clear i_data v_data t_data T_data Ts
clear i_pos a b c 
clear k
clear OptPars OptParsDyn ParsListMainDyn InitGuessMain InitGuessDyn ParsListDyn ParSListMain

%% STEP 3) OPTIMIZE TEMPERATURE DEPENDENT PARAMETERS

idx_data = find([battery_data(1:num_lines).T]~=25);
assignin('base','t_data',battery_data(idx_data).t);
assignin('base','i_data',battery_data(idx_data).i);
assignin('base','T_data',battery_data(idx_data).T*ones(length(t_data),1));
assignin('base','T0',battery_data(idx_data).T);
assignin('base','Ts',t_data(2)-t_data(1))
assignin('base','v_data', battery_data(2).v);

% Use parameters for T1 as initial guess for T2 parameters
InitGuessTemp = [OptParsMainDyn(1:2) OptParsMainDyn(4) OptParsMainDyn(6:7)];
Pars = reshape([ParsListTemp; cellstr(num2str(InitGuessTemp'))'],1,[]);
for k=1:2:length(Pars)
    evalin('base',[Pars{k} '=' Pars{k+1} ';'])
end
  
% Optimize Battery temperature dependent parameters
assignin('base','ParsList',ParsListTemp(1:3));
OptParsTemp = fminsearch(@ee_battery_lse, InitGuessTemp(1:3), ...
                         optimset('TolX', 1e-3));

% Update Battery block with optimized parameters
Pars = reshape([ParsListTemp(1:3); cellstr(num2str(OptParsTemp'))'],1,[]);
for k=1:2:length(Pars)
    evalin('base',[Pars{k} '=' Pars{k+1} ';'])
end
assignin('base','AH0',AH*battery_data(idx_data).SOC0);
  
% Display optimized parameters
fprintf(['Optimized temperature dependent parameters for the Battery ' ...
         'are:\n']);
fprintf('\t%5s = %s\n', Pars{:});
  
clear i_data v_data t_data T_data Ts
clear k
clear OptParsMainDyn

%% STEP 4) OPTIMIZE CHARGE DYNAMICS PARAMETERS FOR 2ND TEMPERATURE

% Find index into data for non-room temperatures
  
% Use only one current pulse for optimizing the charge dynamics
i_pos=battery_data(idx_data).i.*(battery_data(idx_data).i>=0);
a = find(diff(i_pos)>0,2);
b = find(diff(battery_data(idx_data).i));
c = fix((b(find(b<a(1),1,'last'))+a(1))/2);
assignin('base','i_data',battery_data(idx_data).i(c+1:a(2)));
assignin('base','v_data',battery_data(idx_data).v(c+1:a(2)));
assignin('base','t_data',battery_data(idx_data).t(1:length(i_data)));
assignin('base','T_data',battery_data(idx_data).T*ones(length(t_data),1));
assignin('base','T0',battery_data(idx_data).T);
assignin('base','Ts',t_data(2)-t_data(1))
  
% Find Battery initial charge before optimizing charge dynamics parameters
assignin('base','ParsList',{'charge'});
InitGuessCharge = OptParsMain(3);
OptCharge = fminsearch(@ee_battery_lse, InitGuessCharge, ...
                       optimset('TolX', 1e-3));
assignin('base','AH0',OptCharge);

% Optimize Battery charge dynamics parameters
assignin('base','ParsList', [ParsListTemp(2) ParsListTemp(4:5)]);
InitGuessTempDyn = [OptParsTemp(2) InitGuessTemp(4:5)];
OptParsTempDyn = fminsearch(@ee_battery_lse, InitGuessTempDyn, ...
                            optimset('TolX', 1e-3));

% Update Battery block with optimized parameters
OptParsTempDyn = [OptParsTemp(1) OptParsTempDyn(1) OptParsTemp(3) OptParsTempDyn(2:3)];
Pars = reshape([ParsListTemp; cellstr(num2str(OptParsTempDyn'))'],1,[]);
for k=1:2:length(Pars)
    evalin('base',[Pars{k} '=' Pars{k+1} ';'])
end
assignin('base','AH0',AH*battery_data(idx_data).SOC0);
  
% Display optimized parameters
fprintf(['Optimized temperature dependent parameters for the Battery, ' ...
         'including charge dynamics, are:\n']);
fprintf('\t%5s = %s\n', Pars{:});
%%  
clear i_data v_data t_data T_data Ts
clear i_pos a b c 
clear k
clear OptCharge OptParsMain OptParsTemp OptParsTempDyn 
clear Pars ParsList ParsListTemp InitGuessCharge InitGuessTemp InitGuessTempDyn

%% DISPLAY OPTIMIZED CURVES

for idx_data = 1:num_lines
    assignin('base','t_data',battery_data(idx_data).t);
    assignin('base','i_data',battery_data(idx_data).i);
    assignin('base','T_data',battery_data(idx_data).T*ones(length(t_data),1));
    assignin('base','T0',battery_data(idx_data).T);
    assignin('base','Ts',t_data(2)-t_data(1));

    out = sim(Model);
    v_model{idx_data} = out.Vo.signals.values;
    t_model{idx_data} = out.Vo.time;
end

plot([battery_data(1:num_lines).t]/3600, [battery_data(1:num_lines).v], 'o', [t_model{:}]/3600, [v_model{:}])
xlabel('Time (hours)');
ylabel('Battery voltage (V)');
legend([legend_info_data legend_info_model], 'Location', 'Best');
title('Model with Optimized Parameter Values');

%%  VALIDATION USING A DYNAMIC CURRENT CYCLE

idx_data = 3;
assignin('base','t_data',battery_data(idx_data).t);
assignin('base','i_data',battery_data(idx_data).i);
assignin('base','T_data',battery_data(idx_data).T);
assignin('base','T0',battery_data(idx_data).T(1));
assignin('base','Ts',t_data(2)-t_data(1));
assignin('base','AH0',AH*battery_data(idx_data).SOC0)
  
out = sim(Model);
subplot(3,1,1)
plot(t_data, battery_data(3).v, 'o', out.Vo.time, out.Vo.signals.values)
xlabel('Time (s)');
ylabel('Battery voltage (V)');
legend('Data','Model', 'Location', 'Best');
subplot(3,1,2)
plot(t_data,i_data)
xlabel('Time (s)');
ylabel('Current requirement (A)');
subplot(3,1,3)
plot(t_data,T_data)
xlabel('Time (s)');
ylabel('Temperature (^oC)');
title('Model validation');

%%

% bdclose(Model)
% clear num_lines legend_info_data legend_info_model out v_model t_model
% clear battery_data idx_data Ts Model
% 
% displayEndOfDemoMessage(mfilename)
