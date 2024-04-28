clear all;
clc;

% 
%% Configuring the Gray Box Model
FileName      = 'dSIdt_Macro_Model';                % File describing the model structure.
Order         = [2 0 2];                         % Model orders [ny nu nx].
load('state_data.mat');

% Parameters    = [0.901165;3.58642];  % Initial parameters.
% Parameters    = [0.0028;0.0028;2;2];  % Initial parameters.
% Parameters    = [0.0058;0.00050;1.8;1.5;0.8];  % Initial parameters.
% Parameters    = [0.0058;0.0005;1.5;1.5];  % Initial parameters.
% Parameters    = [0.000587199;0.00389267;1.00955;0.903148;1.05146];  % t_rw=1;r_inf=0.8;d_rw=0.4 
Parameters    = [0.000587199;0.00389267;1.00955;0.903148];  % t_rw=1;r_inf=0.8;d_rw=0.4 


InitialStates = state_data(1,1:2)';                % Initial value of initial states.
Ts            = 0;                                  % Time-continuous system.

nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts, 'Name', 'SIHR', 'TimeUnit', 's');
        
nlgr.InputName = { };          % u(1)
nlgr.InputUnit = { };

nlgr.OutputName = {
                   'S';                          ...  % y(1).
                   'I';                          ...  % y(2).
                   };                   
nlgr.OutputUnit = {'pcs'; 'pcs'};

nlgr = setinit(nlgr, 'Name', {
                              'S';                          ...  % x(1).
                              'I';                          ...  % x(2).
                              });                  
nlgr = setinit(nlgr, 'Unit', {'pcs'; 'pcs'});

nlgr = setpar(nlgr, 'Name', {'k1';                        ... % k(1).
                             'k2';                        ... % k(2).
                             'k3';                        ... % k(3).
                             'k4';                        ... % k(4).

                             });            
nlgr = setpar(nlgr, 'Unit', {'non'; 'non'; 'non'; 'non'});

nlgr.Parameters(1).Fixed = false; 
nlgr.Parameters(1).Minimum = 0;
nlgr.Parameters(1).Maximum = 0.1;

nlgr.Parameters(2).Fixed = false; 
nlgr.Parameters(2).Minimum = 0;
nlgr.Parameters(2).Maximum = 0.1;

nlgr.Parameters(3).Fixed = false; 
nlgr.Parameters(3).Minimum = 0;
nlgr.Parameters(3).Maximum = 5;

nlgr.Parameters(4).Fixed = false; 
nlgr.Parameters(4).Minimum = 0;
nlgr.Parameters(4).Maximum = 5;
% 
% nlgr.Parameters(5).Fixed = false; 
% nlgr.Parameters(5).Minimum = 0;
% nlgr.Parameters(5).Maximum = 5;

present(nlgr)

%% Importing input and output data
load('state_data.mat');
z = iddata(state_data(:,1:2), [], 1, 'Name', 'Simulation Data');
z.InputName = nlgr.InputName;
z.InputUnit = nlgr.InputUnit;
z.OutputName = nlgr.OutputName;
z.OutputUnit = nlgr.OutputUnit;
z.Tstart = 0;
z.TimeUnit = 's';

present(z)

%% Figures (1=Actual data input, 2=Actual output, 3=Output figure of initial parameters, 4=Output figure with identified parameters)
% figure(1);           % Actual data input
% for i = 1:z.Nu/2
%    subplot(z.Nu/2, 2, 2*i-1);
%    plot(z.SamplingInstants, z.InputData(:,2*i-1));
%    title(['Input #' num2str(2*i-1) ': ' z.InputName{2*i-1}]);
%    axis tight;
%    if i < z.Nu/2
%        xlabel('');
%    else
%        xlabel([z.Domain ' (' z.TimeUnit ')']);
%    end
%    subplot(z.Nu/2, 2, 2*i);
%    plot(z.SamplingInstants, z.InputData(:,2*i));
%    title(['Input #' num2str(2*i) ': ' z.InputName{2*i}]);
%    axis tight;
%    if i < z.Nu/2
%        xlabel('');
%    else
%        xlabel([z.Domain ' (' z.TimeUnit ')']);
%    end
% end
% 
% figure(2);          % Actual output
% for i = 1:z.Ny/2
%    subplot(z.Ny/2, 2, 2*i-1);
%    plot(z.SamplingInstants, z.OutputData(:,2*i-1));
%    title(['Output #' num2str(2*i-1) ': ' z.OutputName{2*i-1}]);
%    axis tight;
%    if i < z.Ny/2
%        xlabel('');
%    else
%        xlabel([z.Domain ' (' z.TimeUnit ')']);
%    end
%    subplot(z.Ny/2, 2, 2*i);
%    plot(z.SamplingInstants, z.OutputData(:,2*i));
%    title(['Output #' num2str(2*i) ': ' z.OutputName{2*i}]);
%    axis tight;
%    if i < z.Ny/2
%        xlabel('');
%    else
%        xlabel([z.Domain ' (' z.TimeUnit ')']);
%    end
% end

X0init = state_data(1,:)';
nlgr = setinit(nlgr, 'Value', num2cell(X0init));
figure(3)      % Output figure of initial parameters
compare(getexp(z, 1), nlgr, [], compareOptions('InitialCondition', X0init));

%% Parameter estimation
opt = nlgreyestOptions('SearchMethod','lsqnonlin');
opt.Display = 'on';
opt.SearchOptions.StepTolerance = 1e-10;
opt.SearchOptions.MaxIterations = 50;
nlgr = nlgreyest(z, nlgr, opt);
figure(4)     % Output figure with identified parameters
compare(getexp(z, 1), nlgr, [], compareOptions('InitialCondition', X0init));

present(nlgr)
