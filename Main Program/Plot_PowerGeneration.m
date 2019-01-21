function [] = Plot_PowerGeneration(Time, PowerDirectPerSide, PowerAlbedoPerSide)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function plots the total power generation of the satellite due to both
% direct solar radiation and Earth's albedo.

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


PowerDirect = sum(PowerDirectPerSide, 2);
PowerAlbedo = sum(PowerAlbedoPerSide, 2);

PowerTotal = PowerDirect + PowerAlbedo;
figure
plot(Time, PowerDirect, Time, PowerAlbedo, Time, PowerTotal);
title('Power Generation vs Time')
xlabel('Time (s)');
ylabel('Power Generating (W)');
legend('Direct Power', 'Albedo Power', 'Total Power');


end

