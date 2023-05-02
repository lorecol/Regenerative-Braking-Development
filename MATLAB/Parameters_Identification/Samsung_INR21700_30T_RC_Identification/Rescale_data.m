function [HPPC25C, HPPC40C] = Rescale_data(HPPC25C, HPPC40C)

MinSize = min([length(HPPC25C.meas.Time) length(HPPC40C.meas.Time)]);

if (length(HPPC25C.meas.Time) == MinSize) % HPPC25C is the smaller
    % Truncate HPPC40C
    HPPC40C.meas.Time = HPPC40C.meas.Time(1:MinSize);
    HPPC40C.meas.Voltage = HPPC40C.meas.Voltage(1:MinSize);
    HPPC40C.meas.Current = HPPC40C.meas.Current(1:MinSize);
    HPPC40C.meas.Battery_Temp_degC = HPPC40C.meas.Battery_Temp_degC(1:MinSize);
    HPPC40C.meas.Power = HPPC40C.meas.Power(1:MinSize);
    HPPC40C.meas.Ah = HPPC40C.meas.Ah(1:MinSize);
    HPPC40C.meas.Wh = HPPC40C.meas.Wh(1:MinSize);
    HPPC40C.meas.TimeStamp = HPPC40C.meas.TimeStamp(1:MinSize);
elseif (length(HPPC40C.meas.Time) == MinSize) % HPPC40C is the smaller
    % Truncate HPPC25C
    HPPC25C.meas.Time = HPPC25C.meas.Time(1:MinSize);
    HPPC25C.meas.Voltage = HPPC25C.meas.Voltage(1:MinSize);
    HPPC25C.meas.Current = HPPC25C.meas.Current(1:MinSize);
    HPPC25C.meas.Battery_Temp_degC = HPPC25C.meas.Battery_Temp_degC(1:MinSize);
    HPPC25C.meas.Power = HPPC25C.meas.Power(1:MinSize);
    HPPC25C.meas.Ah = HPPC25C.meas.Ah(1:MinSize);
    HPPC25C.meas.Wh = HPPC25C.meas.Wh(1:MinSize);
    HPPC25C.meas.TimeStamp = HPPC25C.meas.TimeStamp(1:MinSize);
end
end