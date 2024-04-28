clear all;
clc;


%% Calculation

tspan = [1:1:55];
x0 = [297 3 0 0 0];
[t,y] = ode45(@SIHReqs_N300_opt,tspan,x0);

delta_S = diff(y(:,1));
delta_C = diff(y(:,5));
Re = -delta_S ./ delta_C;


tspan_b = [1:1:55];
x0_b = [297 3 0 0 0];
[t,y_b] = ode45(@SIHReqs_N300,tspan_b,x0_b);

delta_S_b = diff(y_b(:,1));
delta_C_b = diff(y_b(:,5));
Re_b = -delta_S_b ./ delta_C_b;


