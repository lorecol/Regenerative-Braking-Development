classdef (Sealed) ParameterEstimationLUTbattery 
% This class defines functions useful for the parameterization of the 
% Battery (Table-Based) block in Simscape Battery library. The typical 
% input is battery test data, HPPC profile. The typical output is the 
% battery parameters based on the number of RC pairs you select (cell 
% dynamics).
% 
% -------------------------------------------------------------------------
% 
% To characterize a battery cell, run the following command at the command
% line:
% 
% >> battery_params = ParameterEstimationLUTbattery(hppc_data,...
%                                                   cell_prop,...
%                                                   hppc_mag,...
%                                                   numRC,...
%                                                   ini_guess,...
%                                                   fit_method);
% 
%        where:
% 
%              hppc_data = [time, current, voltage]; 
%                           or 
%                          [time, current, voltage, SOC];
%                          
%                          time, current, voltage, and SOC are column vectors
%                          (from HPPC test data). The SOC data is optional.
%                          SOC = State of Charge of cell
%                          current, voltage, and SOC are column vectors
%                          with each row denoting an instance in time.
%                          (a) time vector is defined in seconds
%                          (b) current vector is defined in Amperes
%                          (c) voltage vector is defined in Volts
%                          (d) SOC vector is defined between 0-1
% 
%                          hppc_data can be:
%                              (1) Worspace variable
%                              (2) MAT/TX/XLSX filename with data as column
%                              vectors
% 
%              cell_prop = [cell_capacity, cell_state_of_charge]
%                          cell_capacity and cell_state_of_charge are
%                          scalars for cell capacity in Ahr and cell initial 
%                          state of charge (0-1)
% 
%              hppc_mag  = [dischg_pulse_mag, ...
%                           chg_pulse_mag, ...
%                           soc_sweep_curr, ...
%                           tolerance]
% 
%                          (a) dischg_pulse_mag is the magnitude of discharge
%                          pulse current, in A (scalar)
%                          (b) chg_pulse_mag is the magnitude of the charge
%                          pulse current, in A (scalar)
%                          (c) soc_sweep_curr is the constant current value
%                          used to move from one cell state of charge point 
%                          to the next, in A (scalar)
%                          (d) tolerance parameter is used to detect the
%                          pulses in the methods internally. It defines the
%                          difference between actual current pulse
%                          magnitude and the value set in (a) - (c), above.
%                               example: (say) dischg_pulse_mag = 50;
%                                        In test data, current suddenly
%                                        changes from zero to a certain
%                                        value Io. The parameter 'tolerance'
%                                        equals: 
%                                           (abs(Io-0) - dischg_pulse_mag)
%                                        If the value computed above is
%                                        less than the value set in
%                                        tolerance, a pulse is recorded.
%       
%              numRC     = Integer, equal to the number of RC pairs to be             
%                          fitted to the test data
% 
%              ini_guess = Initial guesses for Resistance (Ohm) and the 
%                          Time Constant (seconds) values. Size of ini_guess 
%                          is a row vector of 2 x numRC.
%                          example:
%                              numRC = 2;
%                              ini_guess = [R1, Tau1, R2, Tau2];
%           
%                              numRC = 3;
%                              ini_guess = [R1, Tau1, R2, Tau2, R3, tau3];
%
%              fit_method= "fminsearch" or "curvefit"
%                          (a) fminsearch uses MATLAB function fminsearch to
%                          fit the RC pairs to test data
%                          (b) curvefit used Curve Fitting Toolbox to fit the
%                          RC pairs to the test data
% 
% -------------------------------------------------------------------------
% 
% To export parameter results to a MAT file, run this command:
% 
% >> exportResults(battery_params,filename); 
%       
%       where: 
% 
%              battery_params = output of ParameterEstimationLUTbattery()
% 
%              filename       = MAT file name in which the data would be 
%                               stored. 
% 
% The exported data is at the SOC points where pulses occurred during the
% test. To apply it to the Battery (Table-Based) block, you must 
% interpolate the same over a uniform SOC range. For more information, see
% exportResultsForLib() method.
% 
% -------------------------------------------------------------------------
% 
% To plot the test data read by function ParameterEstimationLUTbattery(), 
% run this command:
% 
% >> plotTestData(battery_params)
%       
%       where: 
% 
%              battery_params = output of ParameterEstimationLUTbattery()
% 
% The command plots time vs. current, time vs. voltage plots as in input
% test data. This is sometime useful in debugging to check if all data was
% properly read in by the function.
% 
% -------------------------------------------------------------------------
% 
% To plot where the program detects the pulses, run:
% 
% >> plotAndVerifyPulseData(battery_params)
%       
%       where: 
% 
%              battery_params = output of ParameterEstimationLUTbattery()
% 
% The plot shows points (different colors) that have been selected for
% calculating ohmic resistance and fitting RC pairs. This is again useful
% as a debugging tool, if some pulses are not detected by the code.
% 
% -------------------------------------------------------------------------
% 
% To plot results from parameterization, run:
% 
% >> plotResults(battery_params)
%       
%       where: 
% 
%              battery_params = output of ParameterEstimationLUTbattery()
% 
% -------------------------------------------------------------------------
% 
% To generate results suitable for export to the battery LUT library block,
% run:
% 
% >> dataForLib = exportResultsForLib(battery_params,userSOCpoints)
% 
%       where: 
% 
%              battery_params = output of ParameterEstimationLUTbattery()
% 
%              userSOCpoints  = vector of SOC break points at which 
%                               parameters are required. 
%                               example: 0:0.01:1 gives parameters at every
%                               1% of SOC change
% 
% 'dataForLib' is the cell array value that is returned and contains all 
%  relevant informations pertaining to the analysis. 
%     (a) dataForLib{1,1} contains test data used to parameterize cell
%     (b) dataForLib{1,2} contains value of cell capacity, Ahr and
%     (c) dataForLib{1,3} contains data for the cell parameters (fitted)
% 
% -------------------------------------------------------------------------
% 
% To verify data fit accuracy before exporting it, run:
% 
% >> errFit = verifyDataFit(battery_params,delSOC,ts)
% 
%       where: 
% 
%              battery_params = output of ParameterEstimationLUTbattery()
% 
%              delSOC & ts are time steps at which SOC and original input
%              profile are evalauted.
% 
% -------------------------------------------------------------------------

% Copyright 2022 The MathWorks, Inc.

    properties(SetAccess = immutable)
        CellCapacity
        InputTestData
        InputTestDataIndices
        InitialCellSOC
        DischargePulseCurr
        ChargePulseCurr
        ConstantCurrDischarge
        HPPCpulseSequence
        Tolerance
        NumOfRCpairs
        OhmicResistance
        OpenCircuitPotential
        DynamicRC
        DynamicRCerr
    end
    
    properties(Access = private)
        FileFullPath
        FileType
        FileDirectory
        Name 
    end
    
    methods

        function obj = ParameterEstimationLUTbattery(filename,cellProperty,hppcCurrents,...
                                                  nTimeConst,R_Tau_guess,fitMethod)
            if fitMethod ~= "curvefit" && fitMethod ~="fminsearch"
                pm_error('Fit method must be fminsearch or curvefit');
            end
            if length(R_Tau_guess) ~= 2*nTimeConst
                pm_error(strcat('Initial R and Time Constant guess vector must be of size ',num2str(nTimeConst)));
            end
            if cellProperty(1,1) > 0
                obj.CellCapacity = cellProperty(1,1);
            else
                pm_error('Cell capacity must be greater than zero');
            end
            if cellProperty(2,1) > 0 && cellProperty(2,1) <= 1
                obj.InitialCellSOC = cellProperty(2,1);
            else
                pm_error('Cell initial state of charge must be between 0 and 1');
            end
            if any(hppcCurrents < 0)
                pm_error('Pulse charge, discharge, and constant current must be positive');
            else
                obj.DischargePulseCurr    = hppcCurrents(1,1);
                obj.ChargePulseCurr       = hppcCurrents(2,1);
                obj.ConstantCurrDischarge = hppcCurrents(3,1);
                obj.Tolerance             = hppcCurrents(4,1);
            end
            if nTimeConst > 0 && mod(nTimeConst,1) == 0
                obj.NumOfRCpairs = nTimeConst;
            else
                pm_error('Number of time constants must be an integer and greater than zero');
            end
            % Read Input Data - eg: HPPC
            if isnumeric(filename) % check if arg. filename is a file or a matrix
                if size(filename,2) > 4 || size(filename,2) < 3 % Check input parameter matrix size
                    pm_error('Input data must be a column vector of time, Current, Voltage, and SOC');
                elseif size(filename,2) == 4 % SOC input by user
                    obj.InputTestData = array2table(filename,'VariableNames',{'time','I','V','SOC'}); % renaming table to be consistent
                else % Calculate SOC based on current and time data
                    data = addSOCvectorToInputData(filename, obj.InitialCellSOC, obj.CellCapacity);
                    obj.InputTestData = array2table(data,'VariableNames',{'time','I','V','SOC'}); % renaming table to be consistent
                end
                obj.Name = "batteryTestMeas";
            else
                obj.FileFullPath = filename;
                [obj.FileDirectory, obj.Name, obj.FileType] = fileparts(filename);
                obj.FileType = upper(erase(obj.FileType,'.'));
                obj.InputTestData = obj.getDataFromFile;
            end
            isDataHavingErrors = checkInputData([obj.InputTestData.time,...
                                                 obj.InputTestData.I,...
                                                 obj.InputTestData.V,...
                                                 obj.InputTestData.SOC]);
            if isDataHavingErrors
                    pm_error('Input data must not have any NaN or Inf. Check input data');
            end
            % obj.InputTestData is a tabular data at this point
            disp('Read input data')
            [obj.InputTestDataIndices, obj.HPPCpulseSequence] = obj.getPulsesFromHPPCdata;
            disp('Extracted pulse data from input data')
            obj.OhmicResistance = obj.getOhmicResistanceData;
            disp('Calculated ohmic resistance')
            [obj.DynamicRC, obj.DynamicRCerr] = obj.getRCparametersData(R_Tau_guess, fitMethod);
            disp('Calculated RC parameters')
            obj.OpenCircuitPotential = obj.getOpenCircuitPotentialData;
            disp('Completed OCV data extraction')
        end
        
        function exportResults(obj,filename)
            if isnumeric(filename)
                matFileName = num2str(filename);
            else
                matFileName = filename;
            end
            batteryTestData = obj.InputTestData;
            batteryTestDataIndices = obj.InputTestDataIndices;
            batteryOhmicResistanceR0 = obj.OhmicResistance;
            batteryDynamicRC = obj.DynamicRC;
            batteryOCV = obj.OpenCircuitPotential;
            save(matFileName, 'batteryTestData', ...
                              'batteryTestDataIndices', ...
                              'batteryOhmicResistanceR0',...
                              'batteryDynamicRC',...
                              'batteryOCV');
        end
        
        function plotTestData(obj)
            figure('Name', 'Input Test Data' );
            a1 = subplot(3,1,1);
            plot(obj.InputTestData.time,obj.InputTestData.I)
            ylabel("Current (A)")
            a1.XTickLabel = '';
            a2 = subplot(3,1,2);
            plot(obj.InputTestData.time,obj.InputTestData.V)
            ylabel("Voltage (V)")
            a2.XTickLabel = '';
            a3 = subplot(3,1,3);
            plot(obj.InputTestData.time,obj.InputTestData.SOC)
            ylabel("SOC (-)")
            a3.XTickLabel = '';
            linkaxes([a1, a2, a3],'x')
            xlabel("Time (s)")
        end
        
        function plotAndVerifyPulseData(obj)
            % Indexing code for obj.InputTestDataIndices{}
            % [1,2,3,4]    indxDischgPulseStart, indxDischgPulseEnd, indxDischgPulseMid, indxDischgRelaxStart 
            % [5,6,7,8]    indxChgPulseStart, indxChgPulseEnd, indxChgPulseMid, indxChgRelaxStart
            % [9,10,11,12] indxSOCPulseStart, indxSOCPulseEnd, indxSOCPulseMid, indxSOCRelaxStart
            time    = obj.InputTestData.time;
            voltage = obj.InputTestData.V;
            %
            figure('Name', 'Plot and Verify Pulse Data' );
            plot(time,voltage,'k-')
            hold on
            scatter(time(obj.InputTestDataIndices{1}),voltage(obj.InputTestDataIndices{1}),'.','g');
            scatter(time(obj.InputTestDataIndices{2}),voltage(obj.InputTestDataIndices{2}),'.','g');
            scatter(time(obj.InputTestDataIndices{3}),voltage(obj.InputTestDataIndices{3}),'.','g');
            scatter(time(obj.InputTestDataIndices{4}),voltage(obj.InputTestDataIndices{4}),'.','g');
            scatter(time(obj.InputTestDataIndices{5}),voltage(obj.InputTestDataIndices{5}),'.','b');
            scatter(time(obj.InputTestDataIndices{6}),voltage(obj.InputTestDataIndices{6}),'.','b');
            scatter(time(obj.InputTestDataIndices{7}),voltage(obj.InputTestDataIndices{7}),'.','b');
            scatter(time(obj.InputTestDataIndices{8}),voltage(obj.InputTestDataIndices{8}),'.','b');
            scatter(time(obj.InputTestDataIndices{9}),voltage(obj.InputTestDataIndices{9}),'.','r');
            scatter(time(obj.InputTestDataIndices{10}),voltage(obj.InputTestDataIndices{10}),'.','r');
            scatter(time(obj.InputTestDataIndices{11}),voltage(obj.InputTestDataIndices{11}),'.','r');
            scatter(time(obj.InputTestDataIndices{12}),voltage(obj.InputTestDataIndices{12}),'.','r');
            scatter(time(obj.InputTestDataIndices{13}),voltage(obj.InputTestDataIndices{13}),'o','m');
            hold off
            xlabel('Time (s)')
            ylabel('Voltage (V)')
            title('Discharge (g), Charge (b), SOC_s_w_e_e_p (r), and OCV_p_o_i_n_t_s (m)')
        end
        
        function result = exportResultsForLib(obj,userSOCpoints)
            nChargePulses = obj.HPPCpulseSequence{4};
            nDischargePulses = obj.HPPCpulseSequence{3};
            if size(userSOCpoints,1) ~= 1
                pm_error('Enter SOC data as row vector');
            end
            if min(diff(userSOCpoints)) <= 0
                pm_error('SOC points must be in ascending order');
            end
            if min(userSOCpoints) < 0 || max(userSOCpoints) > 1
                pm_error('SOC points out of bound. SOC vector values must be between 0 and 1');
            end
            
            batteryLUTparam = obj.getBatteryParamTable(userSOCpoints);
            batteryTestData = obj.InputTestData;
            batteryCapacity = obj.CellCapacity;
            
            result = {batteryTestData, batteryCapacity, batteryLUTparam};
            
            figure('Name','Battery Open Circuit Potential');
            plot(userSOCpoints',batteryLUTparam.V0')
            xlabel("SOC");
            ylabel("V0 (V)");
            title('V0');
            if nDischargePulses > 0
                figure('Name', 'Battery Ohmic Resistance - discharge');
                plot(userSOCpoints',batteryLUTparam.R0_discharge')
                xlabel("SOC");
                ylabel("R0 (\Omega)");
                title('R0_d_i_s_c_h_a_r_g_e');
            end
            if nChargePulses > 0
                figure('Name', 'Battery Ohmic Resistance - charge');
                plot(userSOCpoints',batteryLUTparam.R0_charge')
                xlabel("SOC");
                ylabel("R0 (\Omega)");
                title('R0_c_h_a_r_g_e');
            end
            idx = 1;
            for i = 1 : obj.NumOfRCpairs
                fig_name = strcat('Battery Dynamics R-',num2str(i));
                figure('Name', fig_name);
                plot(userSOCpoints',batteryLUTparam.("R"+i));
                xlabel("SOC");
                ylabel("R (\Omega)");
                title(strcat('R',num2str(i)));
                
                fig_name = strcat('Battery Dynamics Time Constant-',num2str(i));
                figure('Name', fig_name);
                plot(userSOCpoints',batteryLUTparam.("Tau"+i));
                xlabel("SOC");
                ylabel("\tau");
                title(strcat('\tau',num2str(i)));
            end
        end
        
        function errFit = verifyDataFit(obj,delSOC,ts)
            errFit = obj.paramVerificationPlots(delSOC,ts);
        end
    
    end
    
    methods(Access = private)
        
        function [data, hppcPulseSequence] = getPulsesFromHPPCdata(obj)
            % Discharge Pulse
            indxDischgPulseStart = find(abs(abs(diff(obj.InputTestData.I)) - obj.DischargePulseCurr) < obj.Tolerance & ...
                                        diff(obj.InputTestData.I) < 0); % include the pulse current portion
            nPulses_discharge    = length(indxDischgPulseStart);
            disp(strcat('*** Number of discharge pulses = ',num2str(nPulses_discharge)));
            if nPulses_discharge > 0
                indxDischgPulseEnd   = find(abs(abs(diff(obj.InputTestData.I)) - obj.DischargePulseCurr) < obj.Tolerance & ...
                                            diff(obj.InputTestData.I) > 0);
                indxDischgPulseEnd   = indxDischgPulseEnd(indxDischgPulseEnd > indxDischgPulseStart(1));
                indxDischgPulseMid   = indxDischgPulseStart + 1;
                indxDischgRelaxStart = indxDischgPulseEnd + 1;
            else
                indxDischgPulseEnd = indxDischgPulseStart;
                indxDischgPulseMid = indxDischgPulseStart;
                indxDischgRelaxStart = indxDischgPulseStart;
            end
            
            % Charge Pulse
            indxChgPulseStart = find(abs(abs(diff(obj.InputTestData.I)) - obj.ChargePulseCurr) < obj.Tolerance & ...
                                     diff(obj.InputTestData.I) > 0); % include the pulse current portion
            nPulses_charge    = length(indxChgPulseStart);
            disp(strcat('*** Number of charge pulses    = ',num2str(nPulses_charge)));
            if nPulses_charge > 0
                indxChgPulseEnd   = find(abs(abs(diff(obj.InputTestData.I)) - obj.ChargePulseCurr) < obj.Tolerance & ...
                                         diff(obj.InputTestData.I) < 0);
                indxChgPulseEnd   = indxChgPulseEnd(indxChgPulseEnd > indxChgPulseStart(1));
                indxChgPulseMid   = indxChgPulseStart + 1;
                indxChgRelaxStart = indxChgPulseEnd + 1;
            else
                indxChgPulseEnd   = indxChgPulseStart;
                indxChgPulseMid   = indxChgPulseStart;
                indxChgRelaxStart = indxChgPulseStart;
            end
            
            % SOC Sweep
            indxSOCPulseStart = find(abs(abs(diff(obj.InputTestData.I)) - abs(obj.ConstantCurrDischarge)) < obj.Tolerance & ...
                                     diff(obj.InputTestData.I) < 0); % include the pulse current portion
            indxSOCPulseEnd   = find(abs(abs(diff(obj.InputTestData.I)) - abs(obj.ConstantCurrDischarge)) < obj.Tolerance & ...
                                     diff(obj.InputTestData.I) > 0);
            indxSOCPulseEnd   = indxSOCPulseEnd(indxSOCPulseEnd > indxSOCPulseStart(1));
            % 
            if length(indxSOCPulseEnd) < length(indxSOCPulseStart)
                indxSOCPulseStart = indxSOCPulseStart(1:length(indxSOCPulseEnd));
            end
            indxSOCPulseMid   = indxSOCPulseStart + 1;
            indxSOCRelaxStart = indxSOCPulseEnd + 1;
            nPulses_socSweep  = length(indxSOCPulseStart);
            disp(strcat('*** Number of SOC sweep pulses = ',num2str(nPulses_socSweep))); 

            if nPulses_discharge > 0
                tmp_dischg = [indxDischgPulseStart, ...
                              indxDischgPulseEnd, ...
                              indxDischgPulseMid, ...
                              indxDischgRelaxStart, ...
                              -1*ones(nPulses_discharge,1)];
            else
                tmp_dischg = [0 0 0 0 -1];
            end
            if nPulses_charge > 0
                tmp_charge = [indxChgPulseStart, ...
                              indxChgPulseEnd, ...
                              indxChgPulseMid, ...
                              indxChgRelaxStart, ...
                              ones(nPulses_charge,1)];
            else
                tmp_chg = [0 0 0 0 1];
            end
            tmp_sweep  = [indxSOCPulseStart, ...
                          indxSOCPulseEnd, ...
                          indxSOCPulseMid, ...
                          indxSOCRelaxStart, ...
                          zeros(nPulses_socSweep,1)];
            if nPulses_charge > 0 && nPulses_discharge > 0
                hppcSeqSortData = vertcat(tmp_dischg,tmp_charge,tmp_sweep);
            elseif nPulses_charge == 0 && nPulses_discharge > 0
                hppcSeqSortData = vertcat(tmp_dischg,tmp_sweep);
            elseif nPulses_charge > 0 && nPulses_discharge == 0
                hppcSeqSortData = vertcat(tmp_charge,tmp_sweep);
            else
                pm_error('Error in finding pulse indices for charge/discharge');
            end
            hppcSeqSorted   = sortrows(hppcSeqSortData,1); % sort based on start index
            %
            hppcPulseSequence = {hppcSeqSortData,...
                                 hppcSeqSorted,...
                                 nPulses_discharge,...
                                 nPulses_charge,...
                                 nPulses_socSweep};

            % 
            indxOCVpoints = zeros(nPulses_socSweep,1);
            indxOCVpoints(1,1) = hppcSeqSorted(1,1) - 1;
            for i = 1:nPulses_socSweep-1
                % Find data-index when SOC sweep starts
                i1 = hppcSeqSortData(nPulses_discharge+nPulses_charge+i,4);
                % Find sorted position of above data-index
                i2 = find(hppcSeqSorted(:,4)==i1);
                % Find data-index that comes after SOC sweep, choose a
                % point before that.
                i3 = min(nPulses_discharge+nPulses_charge+nPulses_socSweep, i2+1);
                indxOCVpoints(i+1,1) = hppcSeqSorted(i3,1) - 1;
            end
            % Return Data
            data = {indxDischgPulseStart, indxDischgPulseEnd, indxDischgPulseMid, indxDischgRelaxStart,...
                    indxChgPulseStart, indxChgPulseEnd, indxChgPulseMid, indxChgRelaxStart,...
                    indxSOCPulseStart, indxSOCPulseEnd, indxSOCPulseMid, indxSOCRelaxStart,...
                    indxOCVpoints};
        end
        
        function ocv = getOpenCircuitPotentialData(obj)
            ocv = array2table([obj.InputTestData.SOC(obj.InputTestDataIndices{13}),...
                               obj.InputTestData.V(obj.InputTestDataIndices{13})],...
                               'VariableNames',{'SOC', 'OCV'});
        end
        
        function ohmicR = getOhmicResistanceData(obj)
            % Indexing code for obj.InputTestDataIndices{}
            % [1,2,3,4]    indxDischgPulseStart, indxDischgPulseEnd, indxDischgPulseMid, indxDischgRelaxStart 
            % [5,6,7,8]    indxChgPulseStart, indxChgPulseEnd, indxChgPulseMid, indxChgRelaxStart
            % [9,10,11,12] indxSOCPulseStart, indxSOCPulseEnd, indxSOCPulseMid, indxSOCRelaxStart
            %
            % Ohmic Resistance R0
            nChargePulses = obj.HPPCpulseSequence{4};
            nDischargePulses = obj.HPPCpulseSequence{3};
            %
            if nDischargePulses > 0
                Vdischg_relaxStart = obj.InputTestData.V(obj.InputTestDataIndices{4});
                Vdischg_pulseEnd = obj.InputTestData.V(obj.InputTestDataIndices{2});
                Idischg = obj.DischargePulseCurr;
                R0_dischg = abs(Vdischg_relaxStart - Vdischg_pulseEnd) / Idischg;
                SOC_dischg = obj.InputTestData.SOC(obj.InputTestDataIndices{4});
                ohmicR_dischg = array2table([SOC_dischg, R0_dischg],'VariableNames',{'SOC', 'R0_discharge'});
            end
            if nChargePulses > 0
                Vchg_relaxStart = obj.InputTestData.V(obj.InputTestDataIndices{8});
                Vchg_pulseEnd = obj.InputTestData.V(obj.InputTestDataIndices{6});
                Ichg = obj.ChargePulseCurr;
                R0_chg = abs(Vchg_relaxStart - Vchg_pulseEnd) / Ichg;
                SOC_chg = obj.InputTestData.SOC(obj.InputTestDataIndices{8});
                ohmicR_chg = array2table([SOC_chg, R0_chg],'VariableNames',{'SOC', 'R0_charge'});
            end
            % Convert data to tables for charge and discharge scenarios
            if nDischargePulses > 0 && nChargePulses > 0
                ohmicR = {ohmicR_dischg, ohmicR_chg};
            elseif nDischargePulses > 0 && nChargePulses == 0
                ohmicR = {ohmicR_dischg};
            elseif nDischargePulses == 0 && nChargePulses > 0
                ohmicR = {ohmicR_chg};
            else
                pm_error('No charge or discharge pulse detected');
            end
            
        end

        function [RCpairs, fitErr] = getRCparametersData(obj, b_guess, fitMethod)
            N = obj.NumOfRCpairs;   % Num. of RC pairs to be fitted
            fit_rmse = zeros(2, 2); % min/max rmse, for discharge(row1) and charge (row2) 
            % Find number of charge and discharge pulses
            nChargePulses = obj.HPPCpulseSequence{4};
            nDischargePulses = obj.HPPCpulseSequence{3};
            if nDischargePulses > 0
                % Discharge pulse
                SOC_dischg = obj.InputTestData.SOC(obj.HPPCpulseSequence{1}(1:nDischargePulses,4));
                [R_dischg, Tau_dischg, err] = getTimeConstantData(...
                                         1,N,obj.HPPCpulseSequence,...
                                         obj.InputTestData.time,...
                                         obj.InputTestData.V,...
                                         obj.DischargePulseCurr,...
                                         b_guess, fitMethod);
                disp('*** Calculated RC parameters for discharge')
                fit_rmse(1,1) = min(err);
                fit_rmse(1,2) = max(err);
                % Save results in table
                tableVarNames_R = cell(1, N+1);
                tableVarNames_R{1,1} = 'SOC';
                tableVarNames_Tau = cell(1, N+1);
                tableVarNames_Tau{1,1} = 'SOC';
                for j = 1 : N
                    tableVarNames_R{1,j+1} = strcat('R',num2str(j),'_discharge');
                    tableVarNames_Tau{1,j+1} = strcat('Tau',num2str(j),'_discharge');
                end
                nR_dischg = array2table([SOC_dischg, R_dischg],'VariableNames',tableVarNames_R);
                nTau_dischg = array2table([SOC_dischg, Tau_dischg],'VariableNames',tableVarNames_Tau);
            end
            if nChargePulses > 0
                % Charge pulse
                SOC_chg = obj.InputTestData.SOC(obj.HPPCpulseSequence{1}(nDischargePulses+1:nDischargePulses+nChargePulses,4));
                [R_chg, Tau_chg, err] = getTimeConstantData(...
                                         -1,N,obj.HPPCpulseSequence,...
                                         obj.InputTestData.time,...
                                         obj.InputTestData.V,...
                                         obj.DischargePulseCurr,...
                                         b_guess, fitMethod);
                disp('*** Calculated RC parameters for charge')
                fit_rmse(2,1) = min(err);
                fit_rmse(2,2) = max(err);
                % Save results in table
                tableVarNames_R = cell(1, N+1);
                tableVarNames_R{1,1} = 'SOC';
                tableVarNames_Tau = cell(1, N+1);
                tableVarNames_Tau{1,1} = 'SOC';
                for j = 1 : N
                    tableVarNames_R{1,j+1} = strcat('R',num2str(j),'_charge');
                    tableVarNames_Tau{1,j+1} = strcat('Tau',num2str(j),'_charge');
                end
                nR_chg = array2table([SOC_chg, R_chg],'VariableNames',tableVarNames_R);
                nTau_chg = array2table([SOC_chg, Tau_chg],'VariableNames',tableVarNames_Tau);
            end
            % Return computed result
            if nChargePulses > 0 && nDischargePulses > 0
                RCpairs = {nR_dischg, nTau_dischg, nR_chg, nTau_chg};
            elseif nChargePulses > 0 && nDischargePulses == 0
                RCpairs = {nR_chg, nTau_chg};
            elseif nDischargePulses > 0 && nChargePulses == 0
                RCpairs = {nR_dischg, nTau_dischg};
            else
                RCpairs = {};
            end
            fitErr = array2table([max(fit_rmse(1,1),fit_rmse(2,1)), ...
                                  max(fit_rmse(1,2),fit_rmse(2,2))],...
                                  'VariableNames',{'min err','max err'});
            disp('*** Calculated rmse for the fit')
        end
        
        function data = getDataFromFile(obj)
            if isfile(obj.FileFullPath) % check if the data file exists or has a valid path
                fileIdData = fopen(obj.FileFullPath);
                if ~isequal(fileIdData,-1)
                    if obj.FileType == "MAT"
                        dataMAT = load(obj.FileFullPath);
                        signalCellarray = struct2cell(dataMAT);
                        datafile = signalCellarray{1};
                    elseif obj.FileType == "TXT" || obj.FileType == "XLSX"
                        datafile = readtable(obj.FileFullPath);
                    else
                        pm_error('Input data file type not supported. Use MAT / TXT / XLSX file');
                    end
                    
                    if size(datafile,2) > 4 || size(datafile,2) < 3 
                        fclose(fileIdData);
                        pm_error('Input data must be a column vector of time, Current, Voltage, and SOC; SOC column is optional');
                    else
                        if size(datafile,2) == 3
                            data = addSOCvectorToInputData(datafile, obj.InitialCellSOC, obj.CellCapacity);
                        else
                            data = datafile;
                        end
                        data.Properties.VariableNames{1} = 'time'; % renaming table to be consistent
                        data.Properties.VariableNames{2} = 'I';    % renaming table to be consistent
                        data.Properties.VariableNames{3} = 'V';    % renaming table to be consistent
                        data.Properties.VariableNames{4} = 'SOC';  % renaming table to be consistent    
                    end
                    
                    if min(diff(data.time)) < 0
                        pm_error('time data in the first column should be monotonically increasing data');
                    end
                else
                    fclose(fileIdData);
                    pm_error('UnableToOpenDataFile');
                end
            else
                pm_error('Unable to find file or the file directory. Specify a valid file name, path, and file extension');
            end
            fclose(fileIdData);
        end
        
        function batteryParameters = getBatteryParamTable(obj, userSOCpoints)
            nChargePulses = obj.HPPCpulseSequence{4};
            nDischargePulses = obj.HPPCpulseSequence{3};
            OCV = interp1(obj.OpenCircuitPotential.SOC, obj.OpenCircuitPotential.OCV, ...
                           userSOCpoints, 'makima', 'extrap');
            if nDischargePulses > 0
                R0_discharge = interp1(obj.OhmicResistance{1}.SOC, obj.OhmicResistance{1}.R0_discharge, ...
                               userSOCpoints, 'makima', 'extrap');
            end
            if nChargePulses > 0
                R0_charge = interp1(obj.OhmicResistance{2}.SOC, obj.OhmicResistance{2}.R0_charge, ...
                            userSOCpoints, 'makima', 'extrap');
            end
            % Write data to table and export to a file
            % Below is an averaged data for easy import to Battery LUT block
            % 4 for SOC, OCV, R0_charge, R0_discharge, and twice the number of RC pairs
            if nDischargePulses > 0 && nChargePulses > 0
                tableVarNames = cell(1, 4 + 2*obj.NumOfRCpairs);  % was 2; now 4 = charge/discharge RC + longRest RC pairs
            else
                tableVarNames = cell(1, 3 + 2*obj.NumOfRCpairs); % 3 as either charge or discharge might be missing, not both
            end
            tableVarNames{1,1} = 'SOC';
            tableVarNames{1,2} = 'V0';
            if nDischargePulses > 0 && nChargePulses > 0
                tableVarNames{1,3} = 'R0_charge';
                tableVarNames{1,4} = 'R0_discharge';
                idx0 = 4; % =4 as 4 data have been filled above
            elseif nDischargePulses > 0 && nChargePulses == 0
                tableVarNames{1,3} = 'R0_discharge';
                idx0 = 3;
            elseif nDischargePulses == 0 && nChargePulses > 0
                tableVarNames{1,3} = 'R0_charge';
                idx0 = 3;
            else
                pm_error('No charge or discharge pulse detected');
            end
            
            datavec = [];
            for i = 1 : obj.NumOfRCpairs
                idx = idx0 + (2*i-1);
                tableVarNames{1,idx}   = strcat('R',num2str(i)); % R
                tableVarNames{1,idx+1} = strcat('Tau',num2str(i)); % Tau
                % 
                if nDischargePulses > 0
                    R_discharge = interp1(obj.DynamicRC{1}.SOC, ...
                                          obj.DynamicRC{1}.("R"+i+"_discharge"), ...
                                          userSOCpoints, 'makima', 'extrap');
                    Tau_discharge = interp1(obj.DynamicRC{2}.SOC, ...
                                            obj.DynamicRC{2}.("Tau"+i+"_discharge"), ...
                                            userSOCpoints, 'makima', 'extrap');
                end
                if nChargePulses > 0
                    R_charge = interp1(obj.DynamicRC{3}.SOC, ...
                                       obj.DynamicRC{3}.("R"+i+"_charge"), ...
                                       userSOCpoints, 'makima', 'extrap');
                    Tau_charge = interp1(obj.DynamicRC{4}.SOC, ...
                                         obj.DynamicRC{4}.("Tau"+i+"_charge"), ...
                                         userSOCpoints, 'makima', 'extrap');
                end
                if nDischargePulses > 0 && nChargePulses > 0                
                    avgVal_R = (R_discharge+R_charge)/2;
                    avgVal_T = (Tau_discharge+Tau_charge)/2;
                elseif nDischargePulses > 0 && nChargePulses == 0
                    avgVal_R = R_discharge;
                    avgVal_T = Tau_discharge;
                elseif nDischargePulses == 0 && nChargePulses > 0
                    avgVal_R = R_charge;
                    avgVal_T = Tau_charge;
                else
                    avgVal_R = 0;
                    avgVal_T = 0;
                end
                datavec = [datavec, avgVal_R'];
                datavec = [datavec, avgVal_T'];
            end
            %
            if nDischargePulses > 0 && nChargePulses > 0
                batteryParameters = array2table([userSOCpoints', OCV', ...
                    R0_charge', R0_discharge', datavec],'VariableNames',tableVarNames);
            elseif nDischargePulses > 0 && nChargePulses == 0
                batteryParameters = array2table([userSOCpoints', OCV', ...
                    R0_discharge', datavec],'VariableNames',tableVarNames);
            elseif nDischargePulses == 0 && nChargePulses > 0
                batteryParameters = array2table([userSOCpoints', OCV', ...
                    R0_charge', datavec],'VariableNames',tableVarNames);
            else
                pm_error('No charge or discharge pulse detected');
            end
            %
        end
    
        function errMatrix = paramVerificationPlots(obj,delSOC,timeStep)
            nChargePulses = obj.HPPCpulseSequence{4};
            nDischargePulses = obj.HPPCpulseSequence{3};
            userSOCpoints = 0:delSOC:1;
            batteryParameters = obj.getBatteryParamTable(userSOCpoints);
            batteryTestData = obj.InputTestData;
            t = batteryTestData.time;
            V = batteryTestData.V;
            SOC = batteryTestData.SOC;
            Curr = batteryTestData.I;
            
            endTime = t(end);
            newTimeSeries = 0:timeStep:endTime;
            timeSeriesLen = length(newTimeSeries);

            newCurrSeries = interp1(t, Curr, newTimeSeries, 'makima', 'extrap');
            newSOCSeries  = interp1(t, SOC, newTimeSeries, 'makima', 'extrap');
            newVoltSeries = interp1(t, V, newTimeSeries, 'makima', 'extrap');
            newSOCSeries  = newSOCSeries';
            newCurrSeries = (-1)*newCurrSeries';
            newVoltSeries = newVoltSeries';
            
            V_calc = zeros(timeSeriesLen,1);

            for i = 2:timeSeriesLen
                del_tm = timeStep;
                soc_id = max(1,min(timeSeriesLen,round(newSOCSeries(i,1)/delSOC)));
                if nDischargePulses > 0 && nChargePulses > 0
                    if newCurrSeries(i,1) > 0
                        batteryOhmicR0 = batteryParameters.R0_charge(soc_id,1);
                    else
                        batteryOhmicR0 = batteryParameters.R0_discharge(soc_id,1);
                    end
                elseif nDischargePulses > 0 && nChargePulses == 0
                    batteryOhmicR0 = batteryParameters.R0_discharge(soc_id,1);
                elseif nDischargePulses == 0 && nChargePulses > 0
                    batteryOhmicR0 = batteryParameters.R0_charge(soc_id,1);
                else
                    pm_error('No charge or discharge pulse detected');
                end
                
                V_calc(i,1) = V_calc(i,1) + batteryParameters.V0(soc_id,1) - ...
                                            newCurrSeries(i,1)*batteryOhmicR0;
                for j = 1:obj.NumOfRCpairs
                    timeConst = batteryParameters.("Tau"+j);
                    battRes   = batteryParameters.("R"+j);
                    V_calc(i,1) = V_calc(i,1) - newCurrSeries(i,1)*battRes(soc_id,1)*(1-exp(-del_tm/timeConst(soc_id,1)));
                end
            end

            figure('Name', 'Voltage plot for parameter fit verification');
            plot(t',V','r');
            hold on
            plot(newTimeSeries',V_calc','b-');
            hold off
            xlabel("Time (s)");
            ylabel("Voltage (V)");          
            legend('Test Data', 'Fit Data')

            rmsError = sqrt(sum((newVoltSeries-V_calc).^2))/length(newTimeSeries);
            minError = min(abs(newVoltSeries-V_calc));
            maxError = min(abs(newVoltSeries-V_calc));
            meanError= mean(newVoltSeries-V_calc);

            errMatrix = array2table([rmsError, minError, maxError, meanError],...
                                            'VariableNames',{'rms (V)','min (V)','max (V)','mean (V)'});
        end

    end
end

% -------------------------------------------------------------------------
function [R_val, Tau_val, rmseFit] = getTimeConstantData(dischg_chg,N,...
                                     HPPCpulseSequence,...
                                     ts,voltage,current,...
                                     iniGuess,methodUsed)
    hppcSeqSortData   = HPPCpulseSequence{1};
    hppcSeqSorted     = HPPCpulseSequence{2};
    nPulses_discharge = HPPCpulseSequence{3};
    nPulses_charge    = HPPCpulseSequence{4};
    nPulses_socSweep  = HPPCpulseSequence{5};
    totalLenData      = nPulses_discharge + nPulses_charge + nPulses_socSweep;
    % Data in 'hppcSeqSortData' stored as discharge/charge/SOC-sweep data
    if dischg_chg == 1
        % Discharge
        M = nPulses_discharge;
        start_M = 0;
    else
        % Charge
        M = nPulses_charge;
        start_M = nPulses_discharge;
    end    
    
    R_val = zeros(M, N);
    Tau_val = zeros(M, N);
    rmseFit = zeros(M, 1);
    for i = 1 : M
        % Find indices for relaxation curve, ie. what comes after a charge
        % or discharge pulse. Is it long rest or another pulse ?
        %
        % Start at index, i1
        i1 = hppcSeqSortData(start_M+i, 4); % relaxation starts, at index '4th' column
        % Find which index comes next, i2
        i1_sorted = find(hppcSeqSorted(:,4)==i1); % Find 'i1' position in sort order
        if i1_sorted < totalLenData
            i2 = hppcSeqSorted(i1_sorted+1, 1);
            range = i1:i2;
        else
            range = i1:length(ts);
        end
        % Find pulse start and end indices
        j1 = hppcSeqSortData(start_M+i, 1); % pulse start data at column 1
        j2 = hppcSeqSortData(start_M+i, 2); % pulse end data at column 2
        pulseDuration = ts(j2) - ts(j1);
        x = ts(range) - ts(range(1));
        y = dischg_chg * (voltage(range) - voltage(range(1)));
        if methodUsed == "fminsearch"
            options = optimset('MaxIter',40000,'MaxFunEvals',40000);
            [b_min, minErr] = fminsearch(@(b) fit_fminsearch(b,x,y,pulseDuration,N),...
                                                             iniGuess,options);
            rmseFit(i, 1) = minErr;
            Rvec = [];
            tauvec = [];
            for j = 1 : N
                R.("R"+j) = b_min(2*j-1) / current;
                tau.("tau"+j) = b_min(2*j);
                Rvec = [Rvec, R.("R"+j)];
                tauvec = [tauvec, tau.("tau"+j)];
            end
        else % curvefit
            [out,gof] = fit_cfit(x,y,pulseDuration,N,iniGuess);
            rmseFit(i, 1) = gof.rmse;
            Rvec = [];
            tauvec = [];
            for j = 1 : N
                R.("R"+j) = out.("A"+j) / current;
                tau.("tau"+j) = out.("tau"+j);
                Rvec = [Rvec, R.("R"+j)];
                tauvec = [tauvec, tau.("tau"+j)];
            end
        end
        
        R_val(i,1:N) = Rvec;
        Tau_val(i,1:N)  = tauvec;
    end
end

function [fitresult, gof] = fit_cfit(varargin)
    %% Fit: 'multiExponentialFit'.
    t = varargin{1};
    V = varargin{2};
    t0 = varargin{3};
    N = varargin{4};
    b_guess = varargin{5};
    
    [xData, yData] = prepareCurveData(t, V );
    
    % Set up fittype and options.
    v = "";
    if nargin == 5
        for i=1:N
            v = v+"+A"+i+"-A"+i+"*exp(-x/tau"+i+")+A"+i+"*exp(-(x+"+t0+")/tau"+i+")-A"+i+"*exp(-"+t0+"/tau"+i+")";
        end
        ft = fittype(v, 'independent', 'x', 'dependent', 'y');
        
    elseif nargin == 6
        Vss = varargin{6};
        for i=1:N
            v = v+"+A"+i+"-A"+i+"*exp(-x/tau"+i+")+A"+i+"*exp(-(x+"+t0+")/tau"+i+")-A"+i+"*exp(-"+t0+"/tau"+i+")";
        end
        ft = fittype(Vss+v, 'independent', 'x', 'dependent', 'y');
    end
    
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.Lower = zeros(1,2*N);
    opts.Upper = Inf*ones(1,2*N);
    opts.Robust = 'LAR';
    opts.StartPoint = b_guess;
    
    % Fit model to data.
    [fitresult, gof] = fit(xData, yData, ft, opts);
    
end

function minFunc = fit_fminsearch(b,fit_arg_time,fit_arg_volt,pulseDuration,n) 
    val = 0;
    for i = 1 : n
        val = val + b(2*i-1)*(1-exp(-fit_arg_time./b(2*i))) + ...
                    b(2*i-1)*exp(-(fit_arg_time+pulseDuration)./b(2*i)) - ...
                    b(2*i-1)*exp(-pulseDuration/b(2*i));
    end
    val = val +  10^100*any(b<0) + 10^100*any(diff(b(2:2:end))<0); % exclude results for negative params.
    val     = val - fit_arg_volt; % Find error
    minFunc = sum(val.^2);        % Square of errors to be minimized
end

function data = addSOCvectorToInputData(inp_data, initial_soc, cellCapacity)
    current = inp_data(:,2);
    time = inp_data(:,1);
    dataLen = size(inp_data,1);
    socVal = zeros(dataLen,1);
    socVal(1,1) = initial_soc;
    for i = 2 : dataLen
        socTs = socVal(1,1)+sum(current(2:i,1).*diff(time(1:i,1))/(3600*cellCapacity));
        socVal(i,1) = min(1,max(0,socTs));
    end
    data = [inp_data, socVal];
end

function boolVal = checkInputData(data)
    chkNaN = any(any(isnan(data))); 
    chkInf = any(any(isinf(data)));
    boolVal = or(chkNaN,chkInf);
end