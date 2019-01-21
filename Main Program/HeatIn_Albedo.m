function [QinAlbedo] = HeatIn_Albedo(AlbedoPerSide, AbsorpSatSides, AbsorpSolCell, SolarCellRatioOfAreaSat)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates the heat being gained by the satellite due to
% the Earth's albedo

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% AlbedoPerSide: Instantaneous irradiance on each side of the satellite due
% to Earth's albedo [W/m^2]
% AbsorpSatSides: Absorptivity of the satellite's surface material that is
% not solar panels []
% AbsorpSolCell: Absorptivity of the satellite's solar panel material []
% SolarCellRatioOfAreaSat: Vector containing the fraction of each side's
% area that is covered by solar cells

% ~~ Outputs ~~
% QinAlbedo: Instantaneous heat being gained by the satellite [W]
% ------------------------------------------------------------------------


QinAlbedo = sum(AlbedoPerSide.*(SolarCellRatioOfAreaSat*AbsorpSolCell+(1-SolarCellRatioOfAreaSat)*AbsorpSatSides));

end

