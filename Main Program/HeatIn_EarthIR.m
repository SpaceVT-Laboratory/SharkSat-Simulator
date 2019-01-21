function [QinEarthIR] = HeatIn_EarthIR(IRPerSide, AbsorpIRSatSides, AbsorpIRSolCell, SolarCellRatioOfAreaSat)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates the heat being gained by the satellite due to
% Earth's infra-red radiation

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% IRPerSide: Instantaneous irradiance on each side of the satellite due
% to Earth's infra-red radiation [W/m^2]
% AbsorpSatSides: Absorptivity of the satellite's surface material that is
% not solar panels []
% AbsorpSolCell: Absorptivity of the satellite's solar panel material []
% SolarCellRatioOfAreaSat: Vector containing the fraction of each side's
% area that is covered by solar cells

% ~~ Outputs ~~
% QinEarthIR: Instantaneous heat being gained by the satellite [W]
% ------------------------------------------------------------------------


QinEarthIR = sum(IRPerSide.*(SolarCellRatioOfAreaSat*AbsorpIRSolCell+(1-SolarCellRatioOfAreaSat)*AbsorpIRSatSides));

end

