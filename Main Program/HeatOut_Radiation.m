function [QoutSatRad] = HeatOut_Radiation(EmissSatSides, EmissSolCell, Sigma, AreaSat, Temp, SolarCellRatioOfAreaSat)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates the heat being lost by the satellite due to
% outgoing radiation

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% EmissSatSides: Emissivity of the satellite's outer material not covered
% by solar panels, []
% EmissSolCell: Emissivity of the satellite's solar panels []
% Sigma: Stefen-Boltzman constant, [W/(m^2*K*4)]
% AreaSat: Vector containing the surface areas of each side of the
% satellite, [m^2]
% Temp: Current temperature of the satellite [K]
% SolarCellRatioOfAreaSat: Vector containing the fraction of each side's
% area that is covered by solar cells

% ~~ Outputs ~~
% QoutSatRad: Instantaneous heat being radiated away from the satellite [W]
% ------------------------------------------------------------------------


QoutSatRad = sum((AreaSat.*SolarCellRatioOfAreaSat*EmissSolCell+AreaSat.*(1-SolarCellRatioOfAreaSat)*EmissSatSides)*Sigma*Temp^4);
    
%{

Qenv = alpha*S*(Ap+R*Ar) + epsilonP*IR*Air % Absorbed environmental heat (Not calculating for individual surfaces) 
DispCapSC = sum(epsilonSC.*AreasSC) % Total IR dissipation capability of SC
Qin = % Internal heat generation
Tsteadystate = nthroot(((Qenv+Qin)/(sigma*DispCapSC)), 4) % Steady state temperature of SC, K

R = % Percentage of solar irradiance diffusely reflected from the planet
IR = % Irradiance of infrared energy from the planet
Ap = % Projected area of SC towards the sun
Ar = % Area of SC exposed to diffusely reflected solar energy from the planet
Air = % Area exposed to infrared energy emitted from the planet
epsilonP = % Emissivity of the planet
alpha = % Absorptance of the SC (right now just an average for all surfaces)

%}

