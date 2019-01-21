function [SolarIrrad] = SolarIrradiance(SolarConst, EarthOrbRad, Earth2SunECEF)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates the current solar irradiance on the Earth

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% SolarConst: The Solar Constant, which is the average solar irradiance 
% throughout the year. In other words, it is the solar irradiance when the
% Earth is at its average distance from the Sun
% EarthOrbRad: The average distance from the Earth to the Sun
% Earth2SunECEF: The current vector from the Earth to the Sun

% ~~ Outputs ~~
% SolarIrrad: The current level of solar irradiance.
% ------------------------------------------------------------------------


% Take the solar constant, the average distance from the Earth to the Sun,
% and the current distance from the Earth to the sun to output the current
% value of the Sun's irradiance at the Earth

% [W/m^2]  = [W/m^2]*[(m)/(m)]^2
SolarIrrad = SolarConst*(EarthOrbRad/norm(Earth2SunECEF))^2;

end

