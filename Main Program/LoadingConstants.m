function [RE, SolarConst, EarthOrbRad, Sigma, EarthIRAvg, muEarth, NormSat] = LoadingConstants()
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Loads several constants

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% 

% ~~ Outputs ~~
% RE: Mean (circular) radius of the Earth, [m]
% SolarConst: Mean solar constant, [W/m^2]
% EarthOrbRad: Mean distance from Earth to the Sun, [m]
% Sigma: Stefen-Boltzman constant, [W/(m^2*K*4)]
% EarthIRAvg: IR flux from the Earth, [W/m^2]
% muEarth: Gravitational Constant of the Earth, [m^3/s^2]
% NormSat: Unit vectors of satellite sides in body-fixed coordinate frame
% ------------------------------------------------------------------------

RE = 6371000;
SolarConst = 1367;
EarthOrbRad = 149.6e9;
Sigma = 0.0000000567051;
EarthIRAvg = 239;
muEarth = 3.986004415e14;
NormSat = [1, 0, 0; 0, 1, 0; 0, 0, 1; -1, 0, 0; 0, -1, 0; 0, 0, -1];


end

