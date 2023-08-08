function [SOC] = calcSOC(SOC,capacity, pulse_current, pulse_duration)
    discharged_Ah = (pulse_current * pulse_duration) / 3600;
    SOC = SOC + (discharged_Ah / (capacity)) * 100;
end