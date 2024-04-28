% Dynamical model
function [dx,y] = dSIHdt_Macro_Model(t,x,u,k1,varargin)   % differential equation
    
    p_max = 0.95;
    r_infect = 0.8;
    d_rw = 0.4;
    tau_sym = 5;
    p_det = 0.7;
    tau_det = 7;
    tau_rec = 7;
    
%     p1 = 0.00281141;
%     p2 = 0.00281142;
%     p3 = 1.86387;
%     p4 = 1.86464;

    p1 = 0.00124482;
    p2 = 0.00559116;
    p3 = 1.98364;
    p4 = 1.91748;
    
    dx =  ...
      [ 
        -p_max*(p1*r_infect+p2*d_rw)*x(2)*x(1)                                                         %x(1)   S
        p_max*(p1*r_infect+p2*d_rw)*x(2)*x(1)-(p3/tau_sym)*x(2)-p4*(p_det/tau_det)*x(2)                %x(2)   I
        (p3/tau_sym)*x(2)+p4*(p_det/tau_det)*x(2)-(k1/tau_rec)*x(3)                                    %x(3)   H
%         (k5/tau_rec)*x(3)                                                                              %x(4)   R          
      ];
  
  
    y = [x(1);x(2);x(3)];

end