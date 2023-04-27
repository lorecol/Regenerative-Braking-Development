classdef vehicle_data < matlab.System
    
    properties (Constant)
        % All the data here summarized refer to the Formula SAE vehicle FENICE

        % ----------------------------------------------------------------------------
        %  ___                           _            ___       _        
        % / __|_  _ ____ __  ___ _ _  __(_)___ _ _   |   \ __ _| |_ __ _ 
        % \__ \ || (_-< '_ \/ -_) ' \(_-< / _ \ ' \  | |) / _` |  _/ _` |
        % |___/\_,_/__/ .__/\___|_||_/__/_\___/_||_| |___/\__,_|\__\__,_|
        %             |_|                                               
        % ----------------------------------------------------------------------------
                    
        % REAR
        rear_suspension = struct('Ks_r'         , ((26000)^(-1) + (100*10^3)^(-1))^(-1), ...% [N/m] Rear suspension+tire 
                                 'Cs_r'         , 1544,                                  ...% [N*s/m] Rear suspension damping (mean for state space tuning)
                                 'Cs_r_b'       , 930,                                   ...% [N*s/m] Rear suspension damping bound
                                 'Cs_r_b_hs'    , 740,                                   ...% [N*s/m] Rear suspension damping high speed bound
                                 'Cs_r_b_ls'    , 1121,                                  ...% [N*s/m] Rear suspension damping low speed bound
                                 'vC_r_b'       , -0.048829,                             ...% [m/s] rear suspension treshold speed bound
                                 'Cs_r_r'       , 1000,                                  ...% [N*s/m] Rear suspension damping rebound
                                 'Cs_r_r_hs'    , 841,                                   ...% [N*s/m] Rear suspension damping high speed rebound
                                 'Cs_r_r_ls'    , 1107,                                  ...% [N*s/m] Rear suspension damping low speed rebound
                                 'vC_r_r'       , 0.05451,                               ...% [m/s] rear suspension treshold speed rebound
                                 'Karb_r'       , 0,...%530832,                                ...% [Nm/rad] anti-roll bar stiffness
                                 'stroke_r'     , 0.052,                                 ...% [m] maximum rear damper stroke
                                 'K_es_r'       , 50000,                                 ...% [N/m] rear damper's end-stops stiffness
                                 'C_es_r'       , 2000,                                  ...% [N*s/m] rear damper's end-stops damping
                                 'h_rc_r'       , 0.055,    ...%0.548                    ...% [m] rear roll center height       
                                 'z__rlx_r'     , 0.335,                                 ...% [m] spring free length
                                 'reg_fact'     , 1e5,                                   ...% [m] [1/m] regularized sign steepness factor (equal for front and rear)
                                 'anti_lift'    , 0.12,  ...%-0.08,                      ...% [%] anti lift
                                 'anti_squat_r' , 0.31    ...%-0.32                      ...% [%] rear anti squat    
                                );
        % FRONT
        front_suspension = struct('Ks_f'        , ((20000)^(-1) + (100*10^3)^(-1))^(-1), ...% [N/m] front suspension+tire 
                                 'Cs_f'         , 1544,                                  ...% [N*s/m] front suspension damping (mean for state space tuning)
                                 'Cs_f_b'       , 800,                                   ...% [N*s/m] front suspension damping bound
                                 'Cs_f_b_hs'    , 569,                                   ...% [N*s/m] front suspension damping high speed bound
                                 'Cs_f_b_ls'    , 921,                                   ...% [N*s/m] front suspension damping low speed bound
                                 'vC_f_b'       , -0.045733,                             ...% [m/s] front suspension treshold speed bound
                                 'Cs_f_r'       , 1800,                                  ...% [N*s/m] front suspension damping rebound
                                 'Cs_f_r_hs'    , 1443,                                  ...% [N*s/m] front suspension damping high speed rebound
                                 'Cs_f_r_ls'    , 2167,                                  ...% [N*s/m] front suspension damping low speed rebound
                                 'vC_f_r'       , 0.043852,                              ...% [m/s] front suspension treshold speed rebound
                                 'Karb_f'       , 0,                                     ...% [Nm/rad] anti-roll bar stiffness
                                 'stroke_f'     , 0.052,                                 ...% [m] maximum front damper stroke
                                 'K_es_f'       , 50000,                                 ...% [N/m] rear damper's end-stops stiffness
                                 'C_es_f'       , 2000,                                  ...% [N*s/m] front damper's end-stops damping
                                 'h_rc_f'       , 0.024,  ...%0.248                      ...% [m] front roll center height   
                                 'z__rlx_f'     , 0.335,                                 ...% [m] spring free length
                                 'anti_dive'    , 0.31, ...%-0.13                        ...% [%] anti dive
                                 'anti_squat_f' , 0.225  ...%0                           ...% [%] front anti squat
                                );
        % SUSPENSIONS
        suspension = struct('camber_gain'       , 0.72                                  ...% [-] camber gain constant (linear fitting from suspension kinematic model)
                                );
                            
        % ----------------------------------------------------------------------------
        %   ___ _               _      ___       _        
        %  / __| |_  __ _ _____(_)___ |   \ __ _| |_ __ _ 
        % | (__| ' \/ _` (_-<_-< (_-< | |) / _` |  _/ _` |
        %  \___|_||_\__,_/__/__/_/__/ |___/\__,_|\__\__,_|
        %                                                 
        % ----------------------------------------------------------------------------
        % CHASSIS IS THE SPRUNG BODY

        % CHASSIS
        % is =  |  is_xx   0   -is_xz |
        %       |    0   is_yy    0   |
        %       | -is_xz   0    is_zz |
        chassis = struct( 'is_xx' ,18.66,          ...% [kg*m^2] chassis moment of inertia about x axis
                          'is_yy' ,74.26,          ...% [kg*m^2] chassis moment of inertia about y axis
                          'is_zz' ,72.75, 	       ...% [kg*m^2] chassis moment of inertia about z axis
                          'is_xz' ,6.72            ...% [kg*m^2] chassis product of inertia xz
                          );

        % ----------------------------------------------------------------------------
        %  _   _                                   ___       _        
        % | | | |_ _  ____ __ _ _ _  _ _ _  __ _  |   \ __ _| |_ __ _ 
        % | |_| | ' \(_-< '_ \ '_| || | ' \/ _` | | |) / _` |  _/ _` |
        %  \___/|_||_/__/ .__/_|  \_,_|_||_\__, | |___/\__,_|\__\__,_|
        %               |_|                |___/                      
        % ----------------------------------------------------------------------------
        % UNSRPUNG BODY IS MADE OF THE 4 WHEELS AND THE SUSPENSION, TRANSMISSION AND BRAKE MASSES ATTACHED TO WHEELS

        % WHEEL
        % iwd = | iwd   0  0  |
        %       |  0  iwa  0  |
        %       |  0   0  iwd |

        % REAR
        rear_wheel = struct( 'mass'             , 8,                                     ...% [kg] mass of the whole wheel assembly
                             'iwd_r'            , 0.137,                                 ...% [kg*m^2] inertia of the wheel
                             'iwa_r'            , 0.094,                                 ...% [kg*m^2] inertia of the whole wheel assembly
                             'static_camber'	, 2.34,                                  ...% [deg] Static camber for rear wheels
                             'Rr'               , 0.203,                                 ...% [m] rolling radious
                             'width'            , 0.15                                   ...% [m] wheel width
                            );
        rear_unsprung = struct('mass' , 2*8)  % [kg] Rear unsprung mass 

        % FRONT
        front_wheel = struct( 'mass'            , 8,                                    ...% [kg] mass of the whole wheel assembly
                              'iwd_f'           , 0.145,                                ...% [kg*m^2] inertia of the wheel
                              'iwa_f'           , 0.079,                                ...% [kg*m^2] inertia of the whole wheel assembly
                              'static_camber'   , 1.17,                                 ...% [deg] Static camber for front wheels
                              'Rf'              , 0.203,                                ...% [m] rolling radius
                              'width'           , 0.124                                 ...% [m] wheel width
                            );
        front_unsprung = struct('mass' , 2*8)  % [kg] Front unsprung mass 
 

        % ----------------------------------------------------------------------------
        %    ___                   _ _  __   __   _    _    _       ___       _        
        %   / _ \__ _____ _ _ __ _| | | \ \ / /__| |_ (_)__| |___  |   \ __ _| |_ __ _ 
        %  | (_) \ V / -_) '_/ _` | | |  \ V / -_) ' \| / _| / -_) | |) / _` |  _/ _` |
        %   \___/ \_/\___|_| \__,_|_|_|   \_/\___|_||_|_\__|_\___| |___/\__,_|\__\__,_|
        %                                                                     
        % ----------------------------------------------------------------------------

        % VEHICLE
        vehicle = struct( 'Lf'      , 0.857,                            ...% [m] Distance between vehicle CoM and front wheels axle
                          'Lr'      , 0.673,                            ...% [m] Distance between vehicle CoM and rear wheels axle
                          'L'       , 1.53,                             ...% [m] Vehicle wheelbase
                          'hGs'     , 0.179,                            ...% [m] CoM vertical position from the roll axis
                          'h__pc'   , 0.077,                            ...% [m] pitch center height
                          'Wf'      , 1.27,                             ...% [m] Front track width
                          'Wr'      , 1.21,                             ...% [m] Rear track width
                          'hG0'     , 0.221,                            ...% [m] Total vertical position of CoM
                          'z_static', 0.042,                            ...% [m] hG0 - hGs
                          'm'       , 277,                              ...% [kg] Total mass of the vehicle + driver of 75kg
                          'i_xx'    , 27.96,                            ...% [kg*m^2] Moment of inertia of the vehicle w.r.t. x axis
                          'i_yy'    , 89.74,                            ...% [kg*m^2] Moment of inertia of the vehicle w.r.t. y axis
                          'i_zz'    , 96.13,                            ...% [kg*m^2] Moment of inertia of the vehicle w.r.t. z axis
                          'i_xz'    , 7.50,                             ...% [kg*m^2] Product of inertia of the vehicle
                          'g'       , 9.81,                             ...% [m/s^2] acceleration due to gravity
                          'dM'      , 1.8 * 9.81,                       ...% [m/s^2] maximum allowable deceleration 
                          'ms'      , 234,                              ...% [kg] Sprung Mass with 75 kg of driver
                          'Vlow'    , 1,                                ...% [m/s] Threshold velocity
                          'tyre_f'  ,'Hoosier_18x6_10',                 ...% Front Tires   
                          'tyre_r'  ,'Hoosier_18x6_10',                 ...% Rear Tires
                          'lx'      , 0.3,                              ...% [m] Tire relaxation length, for longitudinal slip dynamics
                          'ly'      , 0.3,                              ...% [m] Tire relaxation length, for lateral slip dynamics 
                          'mu_tr'   , 1.8                               ...% Friction coefficient between tyres and road
                         );
                      
        % ----------------------------------------------------------------------------
        %     _                   _                      _
        %    /_\  ___ _ _ ___  __| |_  _ _ _  __ _ _ __ (_)__ ___
        %   / _ \/ -_) '_/ _ \/ _` | || | ' \/ _` | '  \| / _(_-
        %  /_/ \_\___|_| \___/\__,_|\_, |_||_\__,_|_|_|_|_\__/__/
        %                          |__/
        % ----------------------------------------------------------------------------
        
        % Note: check always with MT wich type of coefficients they give:
        % for Fenice they must be multiplied (remembering the formula) 
        % F = 1/2*ro*C*A*u^2 (present in aeromodel file as: CA*u^2 but attention that the 1/2 factor is later present in the LoadTransferModel)
        % by ro*A
        %                    
        % In this way we define for example: CAx = Cx*1.2*1.034

        aerodynamics = struct('A'     , 1.034,              ...%[m^2] frontal ara
                              'rho'   , 1.034,              ...%[kg/m^3] air density
                              'CLf'   , 0.36,               ...% [ - ] Aero drag coefficient (Cx = 1.1517 with aero kit)                (Cx = 0.36  without aero kit)
                              'CLr'   , 0,            ...% [ - ] Aero downforce coeff at rear axle (Czr = 1.6761 with aero kit)   (Czr = -0.0171   without aero kit)
                              'CD'    , 0.36                ...% [ - ] Aero drag coefficient (Cx = 1.1517 with aero kit)                (Cx = 0.36  without aero kit)
                              );
                         
        % ----------------------------------------------------------------------------
        %   _____                       _       _            ___       _        
        %  |_   _| _ __ _ _ _  ____ __ (_)_____(_)___ _ _   |   \ __ _| |_ __ _ 
        %    | || '_/ _` | ' \(_-< '  \| (_-<_-< / _ \ ' \  | |) / _` |  _/ _` |
        %    |_||_| \__,_|_||_/__/_|_|_|_/__/__/_\___/_||_| |___/\__,_|\__\__,_|
        %                                                                      
        % ----------------------------------------------------------------------------

        transmission = struct('tau_red' , 4.5,                  ...% [-] Transmission ratio of the gearbox
                              'eff_red' , 0.989                 ...% [-] Efficiency of the gearbox
                             );

        % ----------------------------------------------------------------------------
        %   ___ _               _             ___             ___       _        
        %  / __| |_ ___ ___ _ _(_)_ _  __ _  / __|_  _ ___   |   \ __ _| |_ __ _ 
        %  \__ \  _/ -_) -_) '_| | ' \/ _` | \__ \ || (_-<_  | |) / _` |  _/ _` |
        %  |___/\__\___\___|_| |_|_||_\__, | |___/\_, /__(_) |___/\__,_|\__\__,_|
        %                             |___/       |__/                           
        % ----------------------------------------------------------------------------
        
        steering_system = struct('tau_D' , 4.23,                ...% [-] Steering angle ratio
                                 'tau_H' , 0.05,                ...% [s] Time constant steering wheel
                                 'scrub' , 0.043,               ...% [m] Scrub
                                 'mec_trail', 0.044 ...%0.037   ...% [m] Mechanical trail
                                );

        % ----------------------------------------------------------------------------
        %  ___          _   _           
        % ||) )_ _ __ _| |_(_)_ _  __ _    
        % ||) \ '_/ _` | / / | ' \/ _` |
        % |___/_| \__,_|_\_\_|_||_\__, |
        %                         |___/ 
        % ----------------------------------------------------------------------------
        
        braking = struct('brakeRatio'             , 0.74,   ...% brake balance (%front)
                         'max_brake_torque_front' , 750,    ...% [Nm] max front braking torque that the hydraulic system can provide
                         'max_brake_torque_rear'  , 260,    ...% [Nm] max rear braking torque that the hydraulic system can provide
                         'totBrakeTorque'         , 750,    ...% [Nm] max total brake torque that the braking system can develop (it is then split btween front/rear axles) 
                         'tau_br'                 , 0.03,   ...% [s] time constant for brake actuation dynamics
                         'prop_valve_cut_torque'  , 130,    ...% [Nm] rear braking torque corresponding to proportioning valve cut-off 
                         'prop_valve_cut_factor'  , 4,      ...%  cut-off strength factor
                         'regularSignScale'       , 1,      ...% [rad/s] scale parameter for the regularized sign function
                         'd_p'                    , 0.026,  ...% [m] gripper pistons diameter
                         'n_p'                    , 4,      ...% gripper pistons number
                         'R_pp'                   , 0.0756, ...% pressure point arm
                         'mu'                     , 0.42    ...% friction coefficient
                         );

        % ----------------------------------------------------------------------------
        %  __  __     _               ___
        % |  \/  |___| |_  ___  _ _  |   \ __ _| |_ __ _
        % | |\/| / _ |  _|/ _ \| '_| | |) / _` |  _/ _` |
        % |_|  |_\___/\_ |\___/|_|   |___/\__,_|\__\__,_|
        % 
        % ----------------------------------------------------------------------------
        % Electric motor Lookup Table parameters (Emrax 188 motor-medium V-LC)
        motor = struct('maxTorque'         , 55,        ...% [Nm] max torque that the motor can provide
                       'speedForTorqueCut' , 5000,      ...% [rpm] motor rotational speed at which torque is decreased a lot
                       'maxRotSpeed'       , 6500,      ...% [rpm]
                       'k_torque'          , 0.39,      ...% [-] motor torque constant
                       'I_max'             , 150,       ...% [A] max motor current
                       'maxMotPower'       , 52e3,      ...% [W] max motor Power
                       'tau_mot'           , 0.024      ...% [s] time constant for motor actuation dynamics
                   );

        % ----------------------------------------------------------------------------
        %  ___       _   _                  ___       _
        % | |)) __ _| |_| |_ ___ _ _ _  _  |   \ __ _| |_ __ _
        % | |)\/ _` |  _|  _/ -_) '_| || | | |) / _` |  _/ _` |
        % |___/\__,_|\__\\__\___|_|  \_, | |___/\__,_|\__\__,_|
        %                            |__/ 
        % ----------------------------------------------------------------------------
        accumulator = struct('maxPower' , 80)  % [kW] max output power for the battery pack

        
    end
    
    methods
    end
end

