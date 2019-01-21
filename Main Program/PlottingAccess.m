function [] = PlottingAccess(Access2GroundStation, Access2Targets)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function creates a plot that shows when the satellite has access to
% ground station and targets

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% Access2GroundStation: Cell containing the information for all accesses 
% between the ground station and the satellite 
% Access2Targets: Cell containing the information for all accesses 
% between the targets and the satellite 

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


figure
hold on
try
    for i = 1:size(Access2GroundStation,1)
        plot([Access2GroundStation(i,1)/3600 Access2GroundStation(i,2)/3600], [.5 .5], 'k', 'LineWidth', 5);
    end
catch
end

try
    if ~isnan(Access2Targets.Target1)
        for i = 1:size(Access2Targets.Target1,1)
            plot([Access2Targets.Target1(i,1)/3600 Access2Targets.Target1(i,2)/3600], [1 1], 'b', 'LineWidth', 5);
        end
    end
catch
end

try    
    if ~isnan(Access2Targets.Target2)
        for i = 1:size(Access2Targets.Target2)
            plot([Access2Targets.Target2(i,1)/3600 Access2Targets.Target2(i,2)/3600], [1.5 1.5], 'r', 'LineWidth', 5);
        end
    end
catch
end

try    
    if ~isnan(Access2Targets.Target3)
        for i = 1:size(AccessTarget3,1)
        plot([Access2Targets.Target3(i,1)/3600 Access2Targets.Target3(i,2)/3600], [2 2], 'm', 'LineWidth', 5);
        end
    end
catch
end

title('Access Intervals')
ylim([0 2.5])
yticks([.5 1 1.5 2])
yticklabels({'Ground Station','Target 1','Target2','Target3'})
xlabel('Hours Since Scenario Start')
grid on
grid minor

end

