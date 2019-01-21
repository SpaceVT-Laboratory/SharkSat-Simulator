function [Phi, EclipseBinary] = Eclipse(Earth2SunECEF, Earth2SatECEF, RE)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function determines if the satellite is currently in sunlight or 
% eclipse (in the shadow of the Earth.

% ~~ Notes ~~
% Uses a simplified cylindrical binary model. Does not take into account
% partial eclipsing

% ~~ Inputs ~~
% Earth2SunECEF: Position vector from the Earth to the Sun in ECEF []
% Earth2SatECEF: Position vector from the Earth to the Satellite in ECEF []
% RE: Average or circular radius of the Earth []

% ~~ Outputs ~~
% Phi: Angle between the Earth to Sun and Earth to Satellite vectors [deg]
% EclipseBinary: 1 if the satellite is in eclipse, 0 if it is sunlit
% ------------------------------------------------------------------------

% Calculate the angle between the Earth2Sat and Earth2Sun vectors, rad
Phi = acos(dot(Earth2SunECEF, Earth2SatECEF)/(norm(Earth2SunECEF)*norm(Earth2SatECEF)));

if cos(Phi) < 0 && norm(Earth2SatECEF)*sqrt(1-cos(Phi)^2) < RE
    EclipseBinary = 1; % Satellite is in eclipse
else
    EclipseBinary = 0; % Satellite is in sunlight
end

