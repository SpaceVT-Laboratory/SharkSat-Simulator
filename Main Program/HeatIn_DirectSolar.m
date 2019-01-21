function [QinDirSolar] = HeatIn_DirectSolar(DirectIrrPerSide, AbsorpSatSides, AbsorpSolCell, SolarCellRatioOfAreaSat)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates the heat being gained by the satellite due to
% direct sunlight

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% DirectIrrPerSide: Instantaneous irradiance on each side of the satellite 
% due to direct sunlight [W/m^2]
% AbsorpSatSides: Absorptivity of the satellite's surface material that is
% not solar panels []
% AbsorpSolCell: Absorptivity of the satellite's solar panel material []
% SolarCellRatioOfAreaSat: Vector containing the fraction of each side's
% area that is covered by solar cells

% ~~ Outputs ~~
% QinDirSolar: Instantaneous heat being gained by the satellite [W]
% ------------------------------------------------------------------------


QinDirSolar = sum(DirectIrrPerSide.*(SolarCellRatioOfAreaSat*AbsorpSolCell+(1-SolarCellRatioOfAreaSat)*AbsorpSatSides));
    
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





























































