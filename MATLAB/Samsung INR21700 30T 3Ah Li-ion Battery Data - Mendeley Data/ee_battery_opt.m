%% Battery Parameter Extraction from Data
% This example shows optimization of the Battery block's parameters to
% fit data defined over different temperatures. It uses the MATLAB(R) 
% optimization function |fminsearch|. Other products available
% for performing this type of parameter fitting with Simscape(TM) 
% Electrical(TM) models are the Optimization Toolbox(TM) and 
% Simulink(R) Design Optimization(TM). These products provide predefined 
% functions to manipulate and analyze blocks using GUIs or a command line 
% approach.

% Copyright 2019-2020 The MathWorks, Inc.


%% Strategy
% Fit output voltage curves for a Battery to data using a 4
% step procedure:
% 
% # Optimize parameters in the Battery Main dialog tab.
% # Optimize parameters in the Battery Dynamics dialog tab.
% # Optimize nominal voltage and internal resistance in the 
% Battery Temperature Dependence dialog tab.
% # Optimize temperature dependent charge dynamics parameters 
% in the Battery Temperature Dependence dialog tab.

%% Data and Block Setup
% The MATLAB data file, _ee_battery_data.mat_, stores Battery data as
% an array of structures. Each structure contains 5 fields: _v_ (voltage) ,
% _i_ (current), _t_ (time), _SOC0_ (initial state of charge) and 
% _T_ (temperature). Scope save the output voltage as structure data, 
% out.Vo.signals.values.

clear all; clc; close all;
  % Load Battery data
  % load ee_battery_data.mat
  HPPC25C = load('25degC/03-14-19_17.34 729_HPPC_25degC_IN21700_30T.mat');
  HPPC40C = load('40degC/03-01-19_19.23 705_HPPC_40degC_IN21700_30T.mat');
  Mixed40C = load('40degC/03-07-19_07.48 710_Mixed1_40degC_IN21700_30T.mat');
 
  if length(HPPC25C.meas.Time)>length(HPPC40C.meas.Time)
    for i=1:length(HPPC40C.meas.Time)
        HPPC25C.meas.Voltage=HPPC25C.meas.Voltage(i);
        HPPC25C.meas.Current(i)=HPPC25C.meas.Current(i);
        HPPC25C.meas.Time(i)=HPPC25C.meas.Time(i);
  else
      for i=1:length(HPPC25C.meas.Time)
        HPPC40C.meas.Voltage(i)=HPPC40C.meas.Voltage(i);
        HPPC40C.meas.Current(i)=HPPC40C.meas.Current(i);
        HPPC40C.meas.Time(i)=HPPC40C.meas.Time(i);
      end
  end

  battery_data = struct('v',{HPPC25C.meas.Voltage,HPPC40C.meas.Voltage, Mixed40C.meas.Voltage},...
      'i',{HPPC25C.meas.Current,HPPC40C.meas.Current, Mixed40C.meas.Current},...
      't',{HPPC25C.meas.Time,HPPC40C.meas.Time, Mixed40C.meas.Current},...
      'SOC0',{1,1,0.8},'T',{25,40,Mixed40C.meas.Battery_Temp_degC});
  assignin('base','T1',battery_data([battery_data(1:2).T]==25).T);
  assignin('base','T2',battery_data([battery_data(1:2).T]~=25).T);
  
  % Display the Battery model
  Model = 'ee_battery';
  open_system(Model)
%%
  close_system(Model, 0);

%% Initial Parameter Specification
% Starting values for |fminsearch| can be estimated using a combination of
% Battery block defaults and data sheet values
%
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
%%
% Since |fminsearch| is an unconstrained nonlinear optimizer that locates a
% local minimum of a function, varying the initial estimate will result in
% a different solution set.

%% Plot Data Versus Battery Output Using Initial Parameters
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

%% Sum of Squares of Error Calculation
% |ee_battery_lse| is the function to be minimized by |fminsearch|. This
% function returns a sum of squares of error for the difference between the
% Battery output voltage and the data. If an invalid parameter value is
% supplied by |fminsearch|, the |catch| statement returns a large value for
% the error.

%%  Optimize Main Tab Dialog Parameters Without Charge Dynamics (Step 1)

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
  fprintf(['Optimized parameters for the battery main '      ...
    'dialog tab are:\n']);
  fprintf('\t%5s = %s\n', Pars{:});
    
  clear i_data v_data t_data T_data Ts
  clear k InitGuess

%%  Optimize Charge Dynamics Parameters (Step 2)

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
  OptCharge = fminsearch(@ee_battery_lse, InitGuessCharge,              ...
      optimset('TolX', 1e-3));
  assignin('base','AH0',OptCharge);
  % Optimize Battery charge dynamics parameters
  assignin('base','ParsList',[ParsListMain(2) ParsListDyn]);
  InitGuessDyn = [OptPars(2) InitGuessDyn];
  OptParsDyn = fminsearch(@ee_battery_lse, InitGuessDyn,              ...
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
  fprintf(['Optimized parameters for the Battery, '           ...
     'including charge dynamics, are:\n']);
  fprintf('\t%5s = %s\n', Pars{:});
  
  clear i_data v_data t_data T_data Ts
  clear i_pos a b c 
  clear k
  clear OptPars OptParsDyn ParsListMainDyn InitGuessMain InitGuessDyn ParsListDyn ParsListMain

%%  Optimize Temperature Dependent Parameters (Step 3)
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
  OptParsTemp = fminsearch(@ee_battery_lse, InitGuessTemp(1:3),              ...
      optimset('TolX', 1e-3));

  % Update Battery block with optimized parameters
  Pars = reshape([ParsListTemp(1:3); cellstr(num2str(OptParsTemp'))'],1,[]);
  for k=1:2:length(Pars)
      evalin('base',[Pars{k} '=' Pars{k+1} ';'])
  end
  assignin('base','AH0',AH*battery_data(idx_data).SOC0);
  
  % Display optimized parameters
  fprintf(['Optimized temperature dependent parameters for the Battery '           ...
     'are:\n']);
  fprintf('\t%5s = %s\n', Pars{:});
  
  clear i_data v_data t_data T_data Ts
  clear k
  clear OptParsMainDyn

%%  Optimize Charge Dynamics Parameters for Second Temperature (Step 4)

  % Find index into data for non-room temperatures
  
  % Use only one current pulse for optimizing the charge dynamics
  i_pos=battery_data(idx_data).i.*(battery_data(idx_data).i>=0);
  a=find(diff(i_pos)>0,2);
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
  OptCharge = fminsearch(@ee_battery_lse, InitGuessCharge,              ...
      optimset('TolX', 1e-3));
  assignin('base','AH0',OptCharge);

  % Optimize Battery charge dynamics parameters
  assignin('base','ParsList', [ParsListTemp(2) ParsListTemp(4:5)]);
  InitGuessTempDyn = [OptParsTemp(2) InitGuessTemp(4:5)];
  OptParsTempDyn = fminsearch(@ee_battery_lse, InitGuessTempDyn,              ...
      optimset('TolX', 1e-3));

  % Update Battery block with optimized parameters
  OptParsTempDyn = [OptParsTemp(1) OptParsTempDyn(1) OptParsTemp(3) OptParsTempDyn(2:3)];
  Pars = reshape([ParsListTemp; cellstr(num2str(OptParsTempDyn'))'],1,[]);
  for k=1:2:length(Pars)
      evalin('base',[Pars{k} '=' Pars{k+1} ';'])
  end
  assignin('base','AH0',AH*battery_data(idx_data).SOC0);
  
  % Display optimized parameters
  fprintf(['Optimized temperature dependent parameters for the Battery, '           ...
     'including charge dynamics, are:\n']);
  fprintf('\t%5s = %s\n', Pars{:});
  
  clear i_data v_data t_data T_data Ts
  clear i_pos a b c 
  clear k
  clear OptCharge OptParsMain OptParsTemp OptParsTempDyn 
  clear Pars ParsList ParsListTemp InitGuessCharge InitGuessTemp InitGuessTempDyn

 %%  Display Optimized Curves

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
  
 %%  Validation using a dynamic current cycle
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

bdclose(Model)
clear num_lines legend_info_data legend_info_model out v_model t_model
clear battery_data idx_data Ts Model

displayEndOfDemoMessage(mfilename)
