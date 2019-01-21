function [IRPerSide] = EarthIR_2(Sat2EarthBody, ASat, NormSat, EarthIRAvg)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function determines the current radiation power indicent on each
% side of the satellite due to Earth's infra-red radiation in a less
% accurate, but also les computationally demanding, way than EarthIR_2.m

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% Earth2SatECEF: Position vector from Earth to satellite in ECEF [km]
% ASat: Vector containing the surface areas of each side of the
% satellite, [m^2]
% NormSatECEF: Unit vectors of satellite side normal vectors in ECEF
% EarthIRAvg: The average value of Earth's infra-red radiation, [W/m^2]


% ~~ Outputs ~~
% IRPerSide: Vector containing the power incident on each of the six
% sides of the satellite due to Earth's infra-red radiation, [W]
% ------------------------------------------------------------------------



% Output the power incident on each side due to Earth infrared, W

SatSidesEarthAng = zeros(1,6);
IRPerSide = zeros(1,6);

for k = 1:6
    SatSidesEarthAng(k) = acos(dot(Sat2EarthBody, NormSat(k,:))/(norm(Sat2EarthBody)*norm(NormSat(k,:))));
end
for k = 1:6
    if cos(SatSidesEarthAng(k)) >= 0
        IRPerSide(k) = 0;
    else
        IRPerSide(k) = -ASat(k)*cos(SatSidesEarthAng(k))*EarthIRAvg;
    end
end

end

