clear all;
clc;

% Genetic algorithm parameter optimization
A = [];
b = [];
Aeq = [];
beq = [];
lb = 1;
ub = 14;
nonlcon = [];
options = gaoptimset('Generations',5000,'StallGenLimit',300,...
     'StallTimeLimit',50,'TolFun',1e-20,'TolCon',1e-20);
[k,fva,reason,output,final_pop]=ga(@Obj_fnc,1,A,b,Aeq,beq,lb,ub,nonlcon,options);

% Output parameter
fprintf('\n\n Parameter values for genetic algorithm optimization:\n');
fprintf('\n\t tau_det = %.9f',k(1));

% Objective function
function O_el = Obj_fnc(k)

    N = 300;
    p_det = 0.7;
    d_rwmax = 1;

    tspan = [1:1:200];
    x0 = [297 3 0 0];
    [t,y] = ode45(@SIHReqs,tspan,x0,[],k);
    
    index = find(y(:,3)>0 & y(:,3)<0.3,1);
    Days = t(1:index);
    SIHR = y(1:index,:);
    
    T = floor(size(Days,1)/k(1));
    num_det = 0;
    for i = 1:1:T
        num_det = num_det + SIHR(floor(i*k(1)),1) + SIHR(floor(i*k(1)),2);
    end

    O_el = (1/10)*p_det*num_det+sum(SIHR(:,3))+ ...
           (1-0.4/d_rwmax)*(sum(SIHR(:,1))+sum(SIHR(:,2))+sum(SIHR(:,4)));

end



function dxdt = SIHReqs(t,x,k)   %

    p_max = 0.95;
    r_infect = 0.8;
    d_rw = 0.4;
    tau_sym = 5;
    p_det = 0.7;
    tau_det = k(1);
    tau_rec = 7;
    
    k1 = 0.000860773;
    k2 = 0.004020113;
    k3 = 1.11766436;
    k4 = 1.02962721;
    k5 = 1.01629803;
    
dxdt =  ...
    [ 
        -p_max*(k1*r_infect+k2*d_rw)*x(2)*x(1)                                                         %x(1)   S
        p_max*(k1*r_infect+k2*d_rw)*x(2)*x(1)-(k3/tau_sym)*x(2)-k4*(p_det/tau_det)*x(2)            %x(2)   I
        (k3/tau_sym)*x(2)+k4*(p_det/tau_det)*x(2)-(k5/tau_rec)*x(3)                                  %x(3)   H
        (k5/tau_rec)*x(3)                                                                                %x(4)   R          
    ];

end