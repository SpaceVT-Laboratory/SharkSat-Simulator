function [] = Plot_Heat(Time, QinDirSolar, QinAlbedo, QinEarthIR, QoutSatRad, HeatGenerationTotalComponents)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function plots the various heat transfers to and from the satellite
% over the analysis time period

% ~~ Notes ~~
%

% ~~ Inputs ~~
% Time: Vector of time in epoch seconds at each time step, [s]
% QinDirSolar: Vector of instantaneous heat tranfer into the satellite due
% to direct solar radiation at each time step, [W]
% QinAlbedo: Vector of instantaneous heat tranfer into the satellite due
% to direct Earth's albedo at each time step, [W]
% QinEarthIR: Vector of instantaneous heat tranfer into the satellite due
% to direct Earth's infra-red radiation at each time step, [W]
% QoutSatRad: Vector of instantaneous heat tranfer out of the satellite due
% to outgoing thermal radiation at each time step, [W]
% HeatGenerationTotalComponents: Vector containing the instantaneous heat
% generation of all components within the satellite, [W]

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


figure
plot(Time, QinDirSolar, Time, QinAlbedo, Time, QinEarthIR, Time, QoutSatRad, Time, HeatGenerationTotalComponents);
title('Heat Entering/Leaving vs Time')
xlabel('Time (s)');
ylabel('Heat Entering/Leaving (W)');
legend('QinDirSolar','QinAlbedo','QinEarthIR','QoutSatRad', 'QCompGeneration');

end

