function [xyzECEF] = LLA2xyzECEF(LLA)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function converts between lat, long, alt and cartesian x, y, and z
% coordinates in the ECEF.

% ~~ Notes ~~
% Takes into account the WGS84 ellipsoid. In other words, does not assume a
% circular Earth.

% ~~ Inputs ~~
% LLA: Lat, long, alt of the point, [deg, deg, km]

% ~~ Outputs ~~
% xyzECEF: Cartesian x, y, and z in ECEF, [km, km, km]
% ------------------------------------------------------------------------


lat = LLA(1);
lon = LLA(2);
alt = LLA(3);

% WGS84 ellipsoid constants:
a = 6378137;
e = 8.1819190842622e-2;

% intermediate calculation
% (prime vertical radius of curvature)
N = a ./ sqrt(1 - e^2 .* sin(lat).^2);

% results:
x = (N+alt) .* cos(lat) .* cos(lon);
y = (N+alt) .* cos(lat) .* sin(lon);
z = ((1-e^2) .* N + alt) .* sin(lat);

xyzECEF = [x, y, z];

end

