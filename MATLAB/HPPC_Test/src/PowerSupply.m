classdef PowerSupply
    % This is the PowerSupply class needed to used to interface with the
    % Keysight RP7963A tool
    % (https://www.keysight.com/it/en/assets/9018-04512/service-manuals/9018-04512.pdf)
    properties (Access = private)
        power_supply 
    end
    
    methods
        function obj = PowerSupply(address)
            %PowerSupply Initialize the power supply and set the power supply to the default settings
            % Outputs:
            %   obj: the power supply object
                                    
            % Load VISA library
            Instrlist = visadevlist;
            
            % Connect to the instrument
            try 
                % If the address is not provided select the first address in the list
                if nargin < 1
                    obj.power_supply = visadev(Instrlist.ResourceName);
                else
                    obj.power_supply = visadev(Instrlist.ResourceName{address});
                end
            catch ex
                disp('  Failed to connect to the instrument.');
                return;
            end

            % Reset the instrument to pre-defined values
            writeline(obj.power_supply, '*RST');
            % Clear status command
            writeline(obj.power_supply, '*CLS');
            % Enable voltage measurements
            writeline(obj.power_supply, ':SENSe:FUNCtion:VOLTage ON');
            % Enable current measurements
            writeline(obj.power_supply, ':SENSe:FUNCtion:CURRent ON');
            % Initialize acquisition
            writeline(obj.power_supply, ':INITiate:IMMediate:ACQuire');
            disp('  Initialization done.');
            
        end

        function turnON(obj)
            %turnON Set the output to ON
            writeline(obj.power_supply, ':OUTPut ON'); 
        end

        function turnOFF(obj) 
            %turnOFF Set the output to OFF
            writeline(obj.power_supply, ':OUTPut OFF');
        end

        function measure = measureVoltage(obj)
            %measureVoltage Return the measured voltage [V]
            % Outputs:
            %   measure: the measured voltage [V]
            measure = str2double(writeread(obj.power_supply, ':MEASure:SCALar:VOLTage:DC?')); 
        end

        function measure = measureCurrent(obj)
            %measureCurrent Return the measured current [A]
            % Outputs:
            %   measure: the measured current [A]
            measure = str2double(writeread(obj.power_supply, ':MEASure:SCALar:CURRent:DC?')); 
        end
    

        function CCmode(obj, voltage_limit, current_level )
            %CCmode Set the power supply to the constant current mode
            % Inputs:
            %   voltage_limit: the maximum voltage that the power supply can output
            %   current_level: the current that the power supply will output

            % Set the power supply to current priority mode
            writeline(obj.power_supply, ':SOURce:FUNCtion CURRENT');
            % Set the voltage limit
            writeline(obj.power_supply, sprintf(':SOURce:VOLTage:LIMit:POSitive:IMMediate:AMPLitude %g', voltage_limit));
            % Set the output current
            writeline(obj.power_supply, sprintf(':SOURce:CURRent:LEVel:IMMediate:AMPLitude %g', current_level));
        end

        function CVmode(obj,current_limit_neg, current_limit_pos, voltage_level)
            %CVmode Set the power supply to the constant voltage mode
            % Inputs:
            %   current_limit_neg: the cut-off current
            %   current_limit_pos: the maximum current
            %   voltage_level: the voltage that the power supply will output

            % Set the power supply to voltage priority mode
            writeline(obj.power_supply, ':SOURce:FUNCtion VOLTage');
            % Set the negative current limit
            writeline(obj.power_supply, sprintf(':SOURce:CURRent:LIMit:NEGative:IMMediate:AMPLitude %g', current_limit_neg));
            % Set the positive current limit
            writeline(obj.power_supply, sprintf(':SOURce:CURRent:LIMit:POSitive:IMMediate:AMPLitude %g', current_limit_pos));
            % Set the output voltage
            writeline(obj.power_supply, sprintf(':SOURce:VOLTage:LEVel:IMMediate:AMPLitude %g', voltage_level));
        end



    end
end
    