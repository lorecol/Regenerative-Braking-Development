function [CurrDis, VoltDis, t] = DischargeCycles(visaObj, Ts, Vlimreal, IlevDis, Rest, maxReadingsDis, maxReadingsRest, numDisCycles)

% Set the operating mode to CC
writeline(visaObj, ':SOURce:FUNCtion CURRENT');

% Set the voltage limit
writeline(visaObj, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', Vlimreal));
% Set the output current
writeline(visaObj, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', IlevDis));

% Measure the OCV at 100% SOC during the rest phase between charge and
% discharge
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REST PERIOD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("%g minutes rest period ...\n", Rest);

for i = 1:maxReadingsRest

    % Measure current
    dc_IDis = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));

    % Measure voltage
    dc_VDis = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));

    % Update time array
    [CurrDis, VoltDis, t] = DischargeCycles(visaObj, t, CurrDis, VoltDis, Ts, Vlimreal, IlevDis, Rest, maxReadingsDis, maxReadingsRest, numDisCycles);t(i) = (i - 1) * Ts;
    % Update the measurement arrays after each measure
    CurrDis(i) = dc_IDis;
    VoltDis(i) = dc_VDis;

    % Update completion time every 5 minutes
%     if (mod(i, (30/Ts)) == 0) && (mod(i, maxReadingsRest) == 1)
%         % Update rest variable with remaining time until end of operation
%         Rest = Rest - 5;
%         % Print the remaining time until end of operation
%         fprintf("   %g minutes until the end...\n", Rest);
%     elseif mod(i, maxReadingsRest) == 0
%         % Reset rest variable to its original value
%         Rest = 30;
%         % Notify end of operation
%         fprintf("   Rest period terminated !!\n");
%     end

    % Sampling time
    pause(Ts);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start discharge cycles with 10% SOC decrements
%%%%%%%%%%%%%%%%%%%%%%%%%%% DISCHARGE CYCLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cycle = 1:numDisCycles

    fprintf("Discharge cycle number: %g\n", cycle);

    % Enable the output
    writeline(visaObj, ':OUTPut:STATe ON');

    % Measure the voltage
%     dc_VDis = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));
    
%     % Exit if the voltage is below the negative limit
%     if dc_VDis < Vlimlow
%         % Disable the output
%         writeline(visaObj, ':OUTPut:STATe OFF');
%         break;     
%     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DISCHARGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:maxReadingsDis
    
        % Measure current
        dc_IDis = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));
    
        % Measure voltage
        dc_VDis = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));
    
        idx = maxReadingsRest + (cycle - 1) * (maxReadingsDis + maxReadingsRest) + i;

        % Update time array
        t(idx) = (idx - 1) * Ts;
        % Update the measurement arrays after each measure
        CurrDis(idx) = dc_IDis;
        VoltDis(idx) = dc_VDis;
    
        % Sampling time
        pause(Ts);
    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Disable the output
    writeline(visaObj, ':OUTPut:STATe OFF');

    fprintf("%g minutes rest period ...\n", Rest);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% REST PERIOD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:maxReadingsRest

        % Measure current
        dc_IDis = str2double(writeread(visaObj, ':MEASure:SCALar:CURRent:DC?'));
    
        % Measure voltage
        dc_VDis = str2double(writeread(visaObj, ':MEASure:SCALar:VOLTage:DC?'));

        idx = maxReadingsRest + maxReadingsDis + (cycle - 1) * (maxReadingsDis + maxReadingsRest) + i;
        % Update time array
        t(idx) = (idx - 1) * Ts;
        % Update the measurement arrays after each measure
        CurrDis(idx) = dc_IDis;
        VoltDis(idx) = dc_VDis;

%         % Update completion time every 5 minutes
%         if (mod(i, (30/Ts)) == 0) && (mod(i, maxReadingsRest) == 1)
%             % Update rest variable with remaining time until end of operation
%             Rest = Rest - 5;
%             % Print the remaining time until end of operation
%             fprintf("   %g minutes until the end...\n", Rest);
%         elseif mod(i, maxReadingsRest) == 0
%             % Reset rest variable to its original value
%             Rest = 30;
%             % Notify end of operation
%             fprintf("   Rest period terminated !!\n");
%         end

        % Sampling time
        pause(Ts);

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end