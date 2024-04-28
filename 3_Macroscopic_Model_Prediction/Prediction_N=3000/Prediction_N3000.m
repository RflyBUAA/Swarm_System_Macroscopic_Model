clear all;
clc;
tic;

%% Calculation

tspan = [1:1:85];
x0 = [2970 30 0 0 0];
[t,y] = ode45(@SIHReqs_N3000,tspan,x0);

delta_S = diff(y(:,1));
delta_C = diff(y(:,5));
Re = -delta_S ./ delta_C;

toc;
