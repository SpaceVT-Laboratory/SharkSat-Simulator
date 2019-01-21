function [PowerAlbedoTotal, PowerAlbedoPerSide] = PowerGeneration_Albedo(AlbedoPerSide, SolarCellRatioOfAreaSat, SolEffcy)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates the power generation due to Earth's albedo

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% AlbedoPerSide: The instantaneous amount of Earth's albedo incident on 
% each side of the satellite, [W/m^2]
% SolarCellRatioOfAreaSat: The ratio of surface area on each side of the
% satellite that is covered by solar cells,
% SolEffcy: The ratio of incident radiation on the solar panels that will
% be turned into generated power,

% ~~ Outputs ~~
% PowerAlbedoTotal: The total instantaneous power generation due to Earth's
% albedo, [W]
% PowerAlbedoPerSide: The instantaneous power generation on each side due 
% to Earth's albedo, [W]
% ------------------------------------------------------------------------


% Create vector of power incident on the solar panels due to albedo, W
AlbedoSol = AlbedoPerSide.*SolarCellRatioOfAreaSat;

% Multiply by solar panel efficiency to determine power generated, W
PowerAlbedoPerSide = AlbedoSol*SolEffcy;
PowerAlbedoTotal = sum(PowerAlbedoPerSide);

end

