function [SOC] = calcSOC(SOC,capacity, pulse_current, pulse_duration)
    %calcSOC Calculate the next SOC
    % Inputs:
    %   SOC: Initial SOC
    %   capacity: Battery nominal capacity
    %   pulse_current: Pulse current [A]
    %   pulse_duration: Pulse duration [s]
    % Outputs: 
    %   SOC: Final SOC
    discharged_Ah = (pulse_current * pulse_duration) / 3600;
    SOC = SOC + (discharged_Ah / (capacity)) * 100;
end