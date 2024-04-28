clear all;
clc;

% 
%% Configuring the Gray Box Model
FileName      = 'Macro_Model_of_Infectious_disease_transmission';                % File describing the model structure.
Order         = [4 0 4];                         % Model orders [ny nu nx].
load('state_data.mat');


% Parameters    = [0.000964926;0.00581412;2;1.78926;0.819434];  % Initial parameters.
% Parameters    = [0.0015;0.0015;0.4;1.25;0.87494];  % Initial parameters.
% Parameters    = [0.002;0.005;1.25;1.3;0.5];  % Initial parameters.
% Parameters    = [0.0001;0.0001;0.3;0.5;0.2];  % Initial parameters.
% Parameters    = [rand(1,1);rand(1,1);rand(1,1);rand(1,1);rand(1,1)];  % Initial parameters.
Parameters    = [0.000587199;0.00389267;1.00955;0.903148;1.05146];  % 
% Parameters    = [0.00137886;0.00170304;0.0859567;3.0142;1.14538];  %
% Parameters    = [0.0025;0.0025;1.48349;1.57944;0.96166];  % 
% Parameters    = [0.00145872;0.00485503;1.79774;1.6796;0.925732];  % 


InitialStates = state_data(1,:)';                % Initial value of initial states.
Ts            = 0;                                  % Time-continuous system.

nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts, 'Name', 'SIHR', 'TimeUnit', 's');
        
nlgr.InputName = { };       
nlgr.InputUnit = { };

nlgr.OutputName = {'S';                          ...  % y(1).
                   'I';                          ...  % y(2).
                   'H';                          ...  % y(3).
                   'R';                          ...  % y(4).
                   };                   
nlgr.OutputUnit = {'pcs'; 'pcs'; 'pcs'; 'pcs'};

nlgr = setinit(nlgr, 'Name', {'S';                          ...  % x(1).
                              'I';                          ...  % x(2).
                              'H';                          ...  % x(3).
                              'R';                          ...  % x(4).
                              });                  
nlgr = setinit(nlgr, 'Unit', {'pcs'; 'pcs'; 'pcs'; 'pcs';});

nlgr = setpar(nlgr, 'Name', {'k1';                        ... % k(1).
                             'k2';                        ... % k(2).
                             'k3';                        ... % k(3).
                             'k4';                        ... % k(4).
                             'k5';                        ... % k(5).
                             });            
nlgr = setpar(nlgr, 'Unit', {'non'; 'non'; 'non'; 'non'; 'non'});

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

nlgr.Parameters(5).Fixed = false; 
nlgr.Parameters(5).Minimum = 0;
nlgr.Parameters(5).Maximum = 5;

present(nlgr)

%% Importing input and output data
load('state_data.mat');
z = iddata(state_data, [], 1, 'Name', 'Simulation Data');
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

