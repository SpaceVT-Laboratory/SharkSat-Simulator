function [COEs] = Cartesian2Keplerian(Rvec, Vvec, mu)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function converts six cartesian orbital elements to six classical
% orbital elements

% ~~ Notes ~~
% The cartesian elements, Rvec and Vvec, are in ECEF. Conversion formulas
% can be found in any introductory orbital mechanics text

% ~~ Inputs ~~
% Rvec: Vector of the three position elements, X, Y, and Z 
% Vvec: Vector of the three velocity elements, Vx, Vy, and Vz
% mu: The gravitational constant of the Earth

% ~~ Outputs ~~
% COEs: Vector of the six classical orbital elements
% ------------------------------------------------------------------------


hvec = cross(Rvec, Vvec);
hmag = norm(hvec);

rmag = norm(Rvec);
vmag = norm(Vvec);

E = (vmag^2)/2-mu/rmag;

SemiMajAxis = -mu/(2*E);

Ecc = sqrt(1-(hmag^2)/(mu*SemiMajAxis));

Inc = acos(hvec(3)/hmag);

RAAN = atan2(hvec(3), -hvec(2));

ArgLat = atan2((Rvec(3)/sin(Inc)), (Rvec(1)*cos(RAAN)+Rvec(2)*cos(RAAN)));

p = SemiMajAxis*(1-Ecc^2);

TrueAnom = atan2(sqrt(p/mu)*dot(Vvec, Rvec), p-rmag);

ArgPeri = ArgLat - TrueAnom;

COEs = [SemiMajAxis, Ecc, Inc, RAAN, ArgPeri, TrueAnom];
