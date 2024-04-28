%Code description
%This code include microscopic model of infectious diseases in a closed environment.
%Written by Xinchen Yu.

clear;
clc;
tic;
close all;
rng("shuffle");

%% Microscopic model

N = 3000;  % number of agents(people)
day_max = 200;  % Maximum number of simulation days.

% Initialize agent
for i = 1:N    
    agents(i).pos(1) = 15*rand(1,1);   
    if agents(i).pos(1) >= 10
        agents(i).pos(2) = 7*rand(1,1);
    else
        agents(i).pos(2) = 10*rand(1,1);   % The position of each agent. Each agent is randomly distributed in a 15*10 activity area.
    end
    agents(i).state = 0;  % The state of each agent. 0 = S, 1 = I, 2 = H, 3 = R. The initial state of each agent is susceptible.
    agents(i).infectday = 0;  % The day when the agent began to infect.
    agents(i).symptoms = false;  % Agents that if infected show symptoms, if true, it will be quarantined.
    agents(i).hospitalday = 0;  % The day when the agent began to hospitalized.
    agents(i).recoverday = 0;  % The day when the agent began to recovered.
    agents(i).detectionday = 0;  % Number of days since the last nucleic acid test.
end

% Initialize parameters
% % Assuming constant parameters
init_infected_percentage = 0.01;
goto_central_percentage = 0.03;  %Probability of a agent going to central area.

i0 = randperm(N,N*init_infected_percentage);
for i = 1:length(i0)
    agents(i0(i)).state = 1;  %Initially randomly generated infected
    agents(i0(i)).infectday = 1;
end

timesteps_per_day = 1;  % Move times of agents in a day. 4

% % Variable parameters
different_speeds = false;  % Whether to consider the different moving speeds of different groups of agents.
go_fast_percentage = 0.2;
go_slow_percentage = 0.7;

central_hub = false;  % Whether to set the center hub. 

symptoms_days = 5;  % The days from infected to show symptoms.
recovery_days = 7;  % The days to get recovery.

infect_radius = 0.253;
max_infect_chance = 0.95;  % The highest infection rate of the virus.
p_infected = @(x)(-max_infect_chance/infect_radius)*x+max_infect_chance;  % Linear representation of infection probability versus distance within a infected radius.

walking_dis = 0.1265;  % The maximum walk distance for each agent per random walk.

quarantine = true;

nucleic_acid_detection = true;  % Whether to consider nucleic acid detection.
detection_cycle_days = 7;  % Nucleic acid detection cycle days.
detection_rate = 0.7;  % Not everyone can get nucleic acid testing on time.

total_days = zeros(day_max,1);
total_susceptible = zeros(day_max,1);
total_infected = zeros(day_max,1);
total_hospitalized = zeros(day_max,1);
total_recovered = zeros(day_max,1);  %Store the total number of susceptible, infected, hospitalized, recovered.

% Figures display. Subfigure 1 shows individual movements, and subfigure 2 shows changes in the total number of people in various states.
% fig1 = figure(1);
% clf;
% fig_flag = 1;  % Set plot figure flag

for t = 1:day_max
    
    for k = 1:timesteps_per_day
        
        index_of_infected = find([agents.state]==1);
        index_of_hospitalized = find([agents.state]==2);
                       
%         if fig_flag
%             clf;
%             set(gcf, 'unit', 'centimeters', 'position', [25 4 25 15]);
%             ax1 = axes('position', [0.05 0.1 0.5 0.8]);
%             axis square; axis([0 15 0 10]);
%             set(gca,'xtick',[],'xticklabel',[],'ytick',[],'yticklabel',[]);
%             title('Day '+string(t),'Fontsize',15);
%             hold on;
%             ax2 = axes('position', [0.605 0.18 0.35 0.55]);
%             axis square; axis([0 t 0 N]);
%             hold on;
%         end
        
        total_days(t) = t;
        total_susceptible(t) = sum([agents.state] == 0);
        total_infected(t) = sum([agents.state] == 1);
        total_hospitalized(t) = sum([agents.state] == 2);
        total_recovered(t) = sum([agents.state] == 3);
            
%         plot(ax2,total_days(1:t),total_susceptible(1:t),'b-','linewidth',1.3);
%         plot(ax2,total_days(1:t),total_infected(1:t),'-','color',[1 0.65 0],'linewidth',1.3);
%         plot(ax2,total_days(1:t),total_hospitalized(1:t),'r-','linewidth',1.3);
%         plot(ax2,total_days(1:t),total_recovered(1:t),'g-','linewidth',1.3);
%         xlabel('Days');
%         ylabel('Cases');
%         leg = legend('susceptible','infected','hospitalized','recovered','location','North','NumColumns',2,'Box','off');
%         leg_pos = get(leg,'Position');
%         set(leg,'Position',[leg_pos(1),leg_pos(2)+0.1,leg_pos(3),leg_pos(4)]);
        
        for i = 1:N
            % Consider the central hub, if someone enters the central hub, he will have greater randomness to other areas
            if central_hub == true && 6.5<=agents(i).pos(1) && agents(i).pos(1)<=8.5 && 4<=agents(i).pos(2) && agents(i).pos(2)<=6
                agents(i).pos(1) = 15*rand(1,1);   
                if agents(i).pos(1) >= 10
                    agents(i).pos(2) = 7*rand(1,1);
                else
                    agents(i).pos(2) = 10*rand(1,1);   % The position of each agent. Each agent is randomly distributed in a 15*10 activity area.
                end
            end
            
            if central_hub == true && rand(1,1) < goto_central_percentage
                agents(i).pos = [6.5 4] + 2*rand(1,2);  % There are also some people who enter the central hub with a certain probability.
            end
            
            % Random walk agents. Considering different speeds, the speed of each agent is determined by random points.
            theta = 2*pi*rand;
            if different_speeds == true && rand < go_fast_percentage
                r = 0.8*rand;
                agents(i).pos = [agents(i).pos] + r*[cos(theta) sin(theta)];
            elseif different_speeds == true && rand >= go_fast_percentage
                r = 0.1*rand;
                agents(i).pos = [agents(i).pos] + r*[cos(theta) sin(theta)];
            end
            
            if different_speeds == false
%                 r = walking_dis*rand;
                r = walking_dis;
                agents(i).pos = [agents(i).pos] + r*[cos(theta) sin(theta)];
            end
            
            % % Make sure the agent is in the active area and quarantine area.
            if agents(i).state ~= 2
                
                if agents(i).pos(1) < 0 && agents(i).pos(2) < 0
                    agents(i).pos(1) = 15 + agents(i).pos(1);
                    agents(i).pos(2) = 10 + agents(i).pos(2);
                elseif agents(i).pos(1) < 0 && agents(i).pos(2) > 0 && agents(i).pos(2) <= 7
                    agents(i).pos(1) = 15 + agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) < 0 && agents(i).pos(2) > 7 && agents(i).pos(2) <= 10
                    agents(i).pos(1) = 10 + agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) < 0 && agents(i).pos(2) > 10
                    agents(i).pos(1) = 15 + agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2) - 10;
                    
                elseif agents(i).pos(1) >= 0 && agents(i).pos(1) < 10 && agents(i).pos(2) < 0
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = 10 + agents(i).pos(2);
                elseif agents(i).pos(1) >= 0 && agents(i).pos(1) < 10 && agents(i).pos(2) > 0 && agents(i).pos(2) <= 10
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) >= 0 && agents(i).pos(1) < 10 && agents(i).pos(2) > 10
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2) - 10;
                    
                elseif agents(i).pos(1) >= 10 && agents(i).pos(1) < 15 && agents(i).pos(2) < 0
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = 7 + agents(i).pos(2);
                elseif agents(i).pos(1) >= 10 && agents(i).pos(1) < 15 && agents(i).pos(2) > 0 && agents(i).pos(2) <= 7
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) >= 10 && agents(i).pos(1) < 15 && agents(i).pos(2) > 7
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2) - 7;
                    
                elseif agents(i).pos(1) > 15 && agents(i).pos(2) < 0
                    agents(i).pos(1) = 15 - agents(i).pos(1);
                    agents(i).pos(2) = 7 + agents(i).pos(2);
                elseif agents(i).pos(1) > 15 && agents(i).pos(2) > 0 && agents(i).pos(2) <= 7
                    agents(i).pos(1) = 15 - agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) > 15 && agents(i).pos(2) > 7
                    agents(i).pos(1) = agents(i).pos(1) - 15;
                    agents(i).pos(2) = agents(i).pos(2) - 7;
                end
                
            else
                
                if agents(i).pos(1) < 0 && agents(i).pos(2) < 0
                    agents(i).pos(1) = 10 + abs(agents(i).pos(1));
                    agents(i).pos(2) = 7 + abs(agents(i).pos(2));
                elseif agents(i).pos(1) < 0 && agents(i).pos(2) > 0 && agents(i).pos(2) <= 7
                    agents(i).pos(1) = 10 + abs(agents(i).pos(1));
                    agents(i).pos(2) = 7 + agents(i).pos(2)/(7/3);
                elseif agents(i).pos(1) < 0 && agents(i).pos(2) > 7 && agents(i).pos(2) <= 10
                    agents(i).pos(1) = 10 + abs(agents(i).pos(1));
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) < 0 && agents(i).pos(2) > 10 
                    agents(i).pos(1) = 10 + abs(agents(i).pos(1));
                    agents(i).pos(2) = 10 - (agents(i).pos(2)-10);
                   
                elseif agents(i).pos(1) >= 0 && agents(i).pos(1) < 10 && agents(i).pos(2) < 0
                    agents(i).pos(1) = 10 + agents(i).pos(1)/2;
                    agents(i).pos(2) = 7 + abs(agents(i).pos(2));
                elseif agents(i).pos(1) >= 0 && agents(i).pos(1) < 10 && agents(i).pos(2) > 0 && agents(i).pos(2) <= 7
                    agents(i).pos(1) = 10 + agents(i).pos(1)/2;
                    agents(i).pos(2) = 7 + agents(i).pos(2)/(7/3);
                elseif agents(i).pos(1) >= 0 && agents(i).pos(1) < 10 && agents(i).pos(2) > 7 && agents(i).pos(2) <= 10
                    agents(i).pos(1) = 10 + agents(i).pos(1)/2;
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) >= 0 && agents(i).pos(1) < 10 && agents(i).pos(2) > 10
                    agents(i).pos(1) = 10 + agents(i).pos(1)/2;
                    agents(i).pos(2) = 10 - (agents(i).pos(2)-10);
                    
                elseif agents(i).pos(1) >= 10 && agents(i).pos(1) < 15 && agents(i).pos(2) < 0
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = 7 + abs(agents(i).pos(2));
                elseif agents(i).pos(1) >= 10 && agents(i).pos(1) < 15 && agents(i).pos(2) > 0 && agents(i).pos(2) <= 7
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = 7 + agents(i).pos(2)/(7/3);
                elseif agents(i).pos(1) >= 10 && agents(i).pos(1) < 15 && agents(i).pos(2) > 7 && agents(i).pos(2) <= 10
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) >= 10 && agents(i).pos(1) < 15 && agents(i).pos(2) > 10
                    agents(i).pos(1) = agents(i).pos(1);
                    agents(i).pos(2) = 10 - (agents(i).pos(2)-10);
                    
                elseif agents(i).pos(1) > 15 && agents(i).pos(2) < 0
                    agents(i).pos(1) = 15 - (agents(i).pos(1)-15);
                    agents(i).pos(2) = 7 + abs(agents(i).pos(2));
                elseif agents(i).pos(1) > 15 && agents(i).pos(2) > 0 && agents(i).pos(2) <= 7
                    agents(i).pos(1) = 15 - (agents(i).pos(1)-15);
                    agents(i).pos(2) = 7 + agents(i).pos(2)/(7/3);
                elseif agents(i).pos(1) > 15 && agents(i).pos(2) > 7 && agents(i).pos(2) <= 10
                    agents(i).pos(1) = 15 - (agents(i).pos(1)-15);
                    agents(i).pos(2) = agents(i).pos(2);
                elseif agents(i).pos(1) > 15 && agents(i).pos(2) > 10
                    agents(i).pos(1) = 15 - (agents(i).pos(1)-15);
                    agents(i).pos(2) = 10 - (agents(i).pos(2)-10);
                
                end
            end
                      
            % The infected person is sent to the quarantine area and returned to the active area after the quarantine is recovered.
            if agents(i).state == 1
                if t >= agents(i).infectday + symptoms_days
                    agents(i).symptoms = true;
                    agents(i).hospitalday = t;
                end    
            end
            
            if agents(i).symptoms == true
                agents(i).state = 2;
                agents(i).infectday = 0;
                if t >= agents(i).hospitalday + recovery_days
                    agents(i).symptoms = false;
%                     agents(i).infectday = 0;
                    agents(i).hospitalday = 0;
                    agents(i).state = 3;
                    agents(i).recoverday = t;
                end
            end
            
            % Infected by infected person
            if agents(i).state == 0
                for j = 1:length(index_of_infected)
                    if distance(agents(i).pos, agents(index_of_infected(j)).pos) < infect_radius && rand < p_infected(distance(agents(i).pos, agents(index_of_infected(j)).pos))
                        agents(i).state = 1;
                        agents(i).infectday = t;
                        break
                    end
                end
                
            end
            
            % When the date for nucleic acid testing arrives, a certain proportion of people will be tested. If the test is I, it will be changed to H for isolation, and the rest of the status will remain unchanged.
            agents(i).detectionday = mod(t,detection_cycle_days);
            if k == 1 && nucleic_acid_detection == true && agents(i).detectionday == 0 
                if rand(1,1) < detection_rate
                    if agents(i).state == 1
                        agents(i).symptoms = true;
                        agents(i).hospitalday = t;
                    end    
                end
            end
            
%             if agents(i).state == 0
%                 plot(ax1,agents(i).pos(1),agents(i).pos(2),'b.','Markersize',10,'Markerfacecolor','b')  
%             elseif agents(i).state == 1
%                 plot(ax1,agents(i).pos(1),agents(i).pos(2),'^','color',[1 0.65 0],'Markersize',4.5,'Markerfacecolor',[1 0.65 0])  
%             elseif agents(i).state == 2
%                 plot(ax1,agents(i).pos(1),agents(i).pos(2),'r.','Markersize',10,'Markerfacecolor','r')
%             elseif agents(i).state == 3
%                 plot(ax1,agents(i).pos(1),agents(i).pos(2),'g.','Markersize',10,'Markerfacecolor','g')
%             end
            
        end
        
%         % % Set up area
%         x_city = [0 15 15 0 0];
%         y_city = [0 0 10 10 0];
%         plot(ax1,x_city,y_city,'k','linewidth',2);
%         hold on;
% 
%         % % Set up Quarantine zone
%         x_qua = [10 15 15 10 10];
%         y_qua = [7 7 10 10 7];
%         plot(ax1,x_qua,y_qua,'r','linewidth',1.2);
% 
% %         % % Set up central hub
% %         x_cen = [6.5 8.5 8.5 6.5 6.5];
% %         y_cen = [4 4 6 6 4];
% %         plot(ax1,x_cen,y_cen,'k','linewidth',1.2)
%         
%         if fig_flag
%             set(fig1,'visible','on');
%             drawnow;
%         end    
 
    end
    
    if isempty(index_of_infected) && isempty(index_of_hospitalized) && t>max([agents.recoverday])+5  % Stop the simulation when no infected agents.
        break
    end
    
end

state_data = zeros(t,4);
state_data(:,1) = total_susceptible(1:t);
state_data(:,2) = total_infected(1:t);
state_data(:,3) = total_hospitalized(1:t);
state_data(:,4) = total_recovered(1:t);

toc;

