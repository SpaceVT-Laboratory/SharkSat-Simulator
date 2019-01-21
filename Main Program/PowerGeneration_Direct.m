function [PowerDirectTotal, PowerDirectPerSide] = PowerGeneration_Direct(DirectIrrPerSide, SolarCellRatioOfAreaSat, SolEffcy)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates the power generation due to direct solar
% radiation

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% DirectIrrPerSide: The instantaneous amount of direct solar radiation
% incident on each side of the satellite, [W/m^2]
% SolarCellRatioOfAreaSat: The ratio of surface area on each side of the
% satellite that is covered by solar cells,
% SolEffcy: The ratio of incident radiation on the solar panels that will
% be turned into generated power,

% ~~ Outputs ~~
% PowerDirectTotal: The total instantaneous power generation due to direct
% solar radiation, [W]
% PowerDirectPerSide: The instantaneous power generation on each side due 
% to direct solar radiation, [W]
% ------------------------------------------------------------------------


% Create vector of power due to direct irradiance on the solar panels, W
DirIrrSol = DirectIrrPerSide.*SolarCellRatioOfAreaSat;

% Multiply by the solar panel efficiency to determine power generation, W
PowerDirectPerSide = DirIrrSol*SolEffcy;
PowerDirectTotal = sum(PowerDirectPerSide);

end


