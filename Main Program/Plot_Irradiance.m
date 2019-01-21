function [] = Plot_Irradiance(Time, DirectIrrPerSide, EclipseBinary)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function plots the level of direct solar irradiance on each side of
% the satellite over the analysis time period

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% Time: Vector of time in epoch seconds at each time step, [s]
% DirectIrrPerSide: Array containing the instantaneous level of direct
% solar irradiance on each side of the satellite at each time step, [W/m^2]
% EclipseBinary: Vector containing 1's and 0's, representing whether the
% satellite is in eclipse or sunlight at each time step

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


figure
plot(Time, DirectIrrPerSide(:,1), Time, DirectIrrPerSide(:,2), Time, DirectIrrPerSide(:,3), Time, DirectIrrPerSide(:,4), Time, DirectIrrPerSide(:,5), Time, DirectIrrPerSide(:,6));
title('Direct Irradiance per Side vs Time')
xlabel('Time (s)');
ylabel('Direct Irradiance (W/m^2)');
yyaxis right
plot(Time, EclipseBinary, 'k');
ylim([-1 6]);
yticks([0 1]);
yticklabels({'Sunlit', 'Eclipsed'});
legend('1','2','3','4','5','6', 'Eclipse');


end

