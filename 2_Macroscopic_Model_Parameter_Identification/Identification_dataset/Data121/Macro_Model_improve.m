% Dynamical model
function [dx,y] = Macro_Model_improve(t,x,u,k1,k2,k3,k4,k5,varargin)   % differential equation
    
    p_max = 0.95;
    r_infect = 0.8;
    d_rw = 0.4;
    tau_sym = 5;
    p_det = 0.7;
    tau_det = 7;
    tau_rec = 7;
    
    dx =  ...
      [ 
        -p_max*(k1*r_infect+k2*d_rw)*x(2)*x(1)                                                         %x(1)   S
        p_max*(k1*r_infect+k2*d_rw)*x(2)*x(1)-(k3/tau_sym)*x(2)-k4*(p_det/tau_det)*x(2)                %x(2)   I
        (k3/tau_sym)*x(2)+k4*(p_det/tau_det)*x(2)-(k5/tau_rec)*x(3)                                    %x(3)   H
        (k5/tau_rec)*x(3)                                                                              %x(4)   R          
      ];

    y = [x(1);x(2);x(3);x(4)];

end