
function dxdt = SIHReqs_N3000(t,x)   %

    p_max = 0.95;
%     r_infect = 0.253;
%     d_rw = 0.1265;
    r_infect = 0.08; %
    d_rw = 0.04; %
    tau_sym = 5;
    p_det = 0.7;
    tau_det = 7;
    tau_rec = 7;
    
    k = [0.000860773;0.004020113;1.11766436;1.02962721;1.01629803];
    
dxdt =  ...
    [ 
        -p_max*(k(1)*r_infect+k(2)*d_rw)*x(2)*x(1)                                                         %x(1)   S
        p_max*(k(1)*r_infect+k(2)*d_rw)*x(2)*x(1)-(k(3)/tau_sym)*x(2)-k(4)*(p_det/tau_det)*x(2)            %x(2)   I
        (k(3)/tau_sym)*x(2)+k(4)*(p_det/tau_det)*x(2)-(k(5)/tau_rec)*x(3)                                  %x(3)   H
        (k(5)/tau_rec)*x(3)                                                                                %x(4)   R
        (k(3)/tau_sym)*x(2)+k(4)*(p_det/tau_det)*x(2)                                                      %x(5)   C
    ];

end


