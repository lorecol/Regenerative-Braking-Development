function [HPPC25C, HPPC40C, Mixed10C] = Resample_data(HPPC25C, HPPC40C, Mixed10C)

T_sample = 1;
timeM = 0:T_sample:(Mixed10C.meas.Time(end) - 1); timeM = timeM';

if (HPPC25C.meas.Time(end) > HPPC40C.meas.Time(end)) % HPPC25C ends after
    time = 0:T_sample:(HPPC40C.meas.Time(end) - 1); time = time';
    % 25C
    timeseries1_25 = timeseries(HPPC25C.meas.Current, HPPC25C.meas.Time);
    timeseries2_25 = timeseries(HPPC25C.meas.Voltage, HPPC25C.meas.Time);
    timeseries1_25_new = resample(timeseries1_25, time);
    timeseries2_25_new = resample(timeseries2_25, time);
    
    % 40C
    timeseries1_40 = timeseries(HPPC40C.meas.Current, HPPC40C.meas.Time);
    timeseries2_40 = timeseries(HPPC40C.meas.Voltage, HPPC40C.meas.Time);
    timeseries1_40_new = resample(timeseries1_40, time);
    timeseries2_40_new = resample(timeseries2_40, time);
    
    % 10C Mixed
    timeseries1_10M = timeseries(Mixed10C.meas.Current, Mixed10C.meas.Time);
    timeseries2_10M = timeseries(Mixed10C.meas.Voltage, Mixed10C.meas.Time);
    timeseries3_10M = timeseries(Mixed10C.meas.Battery_Temp_degC, Mixed10C.meas.Time);
    timeseries1_10M_new = resample(timeseries1_10M, timeM);
    timeseries2_10M_new = resample(timeseries2_10M, timeM);
    timeseries3_10M_new = resample(timeseries3_10M, timeM);
    
    % New HPPC25C
    field11 = 'Time';  value11 = timeseries1_25_new.Time;
    field21 = 'Voltage';  value21 = timeseries2_25_new.Data;
    field31 = 'Current';  value31 = timeseries1_25_new.Data;
    HPPC25C = struct(field11, value11, field21, value21, field31, value31);
    
    field41 = 'meas';  value41 = HPPC25C;
    HPPC25C = struct(field41, value41);
    
    % New HPPC40C
    field12 = 'Time';  value12 = timeseries1_40_new.Time;
    field22 = 'Voltage';  value22 = timeseries2_40_new.Data;
    field32 = 'Current';  value32 = timeseries1_40_new.Data;
    HPPC40C = struct(field12, value12, field22, value22, field32, value32);
    
    field42 = 'meas';  value42 = HPPC40C;
    HPPC40C = struct(field42, value42);

    clear field11 field21 field31 field41 value11 value21 value31 value41 field12 field22 field32 field42 value12 value22 value32 value42 
    clear timeseries1_25 timeseries2_25 timeseries1_25_new timeseries2_25_new timeseries1_40 timeseries2_40 timeseries1_40_new timeseries2_40_new

else % HPPC40C ends after
    % 25C
    timeseries1_25 = timeseries(HPPC25C.meas.Current, HPPC25C.meas.Time);
    timeseries2_25 = timeseries(HPPC25C.meas.Voltage, HPPC25C.meas.Time);
    timeseries1_25_new = resample(timeseries1_25, time);
    timeseries2_25_new = resample(timeseries2_25, time);
    
    % 40C
    timeseries1_40 = timeseries(HPPC40C.meas.Current, HPPC40C.meas.Time);
    timeseries2_40 = timeseries(HPPC40C.meas.Voltage, HPPC40C.meas.Time);
    timeseries1_40_new = resample(timeseries1_40, time);
    timeseries2_40_new = resample(timeseries2_40, time);
    
    % 10C Mixed
    timeseries1_10M = timeseries(Mixed10C.meas.Current, Mixed10C.meas.Time);
    timeseries2_10M = timeseries(Mixed10C.meas.Voltage, Mixed10C.meas.Time);
    timeseries3_10M = timeseries(Mixed10C.meas.Battery_Temp_degC, Mixed10C.meas.Time);
    timeseries1_10M_new = resample(timeseries1_10M, timeM);
    timeseries2_10M_new = resample(timeseries2_10M, timeM);
    timeseries3_10M_new = resample(timeseries3_10M, timeM);
    
    % New HPPC25C
    field11 = 'Time';  value11 = timeseries1_25_new.Time;
    field21 = 'Voltage';  value21 = timeseries2_25_new.Data;
    field31 = 'Current';  value31 = timeseries1_25_new.Data;
    HPPC25C = struct(field11, value11, field21, value21, field31, value31);
    
    field41 = 'meas';  value41 = HPPC25C;
    HPPC25C = struct(field41, value41);
    
    % New HPPC40C
    field12 = 'Time';  value12 = timeseries1_40_new.Time;
    field22 = 'Voltage';  value22 = timeseries2_40_new.Data;
    field32 = 'Current';  value32 = timeseries1_40_new.Data;
    HPPC40C = struct(field12, value12, field22, value22, field32, value32);
    
    field42 = 'meas';  value42 = HPPC40C;
    HPPC40C = struct(field42, value42);

    clear field11 field21 field31 field41 value11 value21 value31 value41 field12 field22 field32 field42 value12 value22 value32 value42 
    clear timeseries1_25 timeseries2_25 timeseries1_25_new timeseries2_25_new timeseries1_40 timeseries2_40 timeseries1_40_new timeseries2_40_new

end

% New Mixed10C
field13 = 'Time';  value13 = timeseries1_10M_new.Time;
field23 = 'Voltage';  value23 = timeseries2_10M_new.Data;
field33 = 'Current';  value33 = timeseries1_10M_new.Data;
field43 = 'Battery_Temp_degC';  value43 = timeseries3_10M_new.Data;
Mixed10C = struct(field13, value13, field23, value23, field33, value33, field43, value43);

field53 = 'meas';  value53 = Mixed10C;
Mixed10C = struct(field53, value53);

clear value12 value22 value32 value42 field13 field23 field33 field43 field53 value13 value23 value33 value43 value53
clear timeseries1_10M timeseries2_10M timeseries3_10M timeseries1_10M_new timeseries2_10M_new timeseries3_10M_new
clear time T_sample MinSize

end