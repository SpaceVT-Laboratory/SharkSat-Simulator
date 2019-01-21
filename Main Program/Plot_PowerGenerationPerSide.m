function [] = Plot_PowerGenerationPerSide(Time, PowerDirectPerSide, PowerAlbedoPerSide)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function plots the power generation of the satellite due to both
% direct solar radiation and Earth's albedo of each side seperately

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% Time: Vector of time in epoch seconds at each time step, [s]
% PowerDirectPerSide: Array containing the instantaneous direct solar
% radiation incident on each side of the satellite at each time step,
% [W/m^2]
% PowerAlbedoPerSide: Array containing the instantaneous albedo
% radiation incident on each side of the satellite at each time step,
% [W/m^2]

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


PowerPerSide = PowerDirectPerSide + PowerAlbedoPerSide;
figure
plot(Time, PowerPerSide);
title('Power Generation vs Time')
xlabel('Time (s)');
ylabel('Power Generating (W)');
legend('Side 1, +X', 'Side 2, +Y', 'Side 3, +Z', 'Side 4, -X', 'Side 5, -Y', 'Side 6, -Z');


end

