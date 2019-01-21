function [AlbedoPerSide] = Albedo_2(Sat2EarthBody, SolarIrr, ASat, NormSatECEF, EclipseBinary) 
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% An alternative to Albedo_1 function, this function provides the same
% output, but with much less precision and computation time. Instead of
% using historical NASA reflectivity data, it simply assumes that the
% albedo is equal to 1/3 the solar irradiance

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% Sat2EarthBody: Vector from the satellite to the Earth in satellite
% body-frame, [km]
% Earth2SunECEF: Vector from the Earth to the Satellit in ECEF, [km] 
% SolarIrr: Solar irradiance from the Sun on the Earth, [W/m^2]
% ASat: Area of each side of the cube-style satellite, [m^2]
% NormSatECEF: Normal vectors for each of the satellites sides in ECEF
% EclipseBinary: 1 if the satellite is currently in darkness, 0 if not

% ~~ Outputs ~~
% AlbedoPerSide: Albedo incident on each side of the satellite, [W/m^2]
% ------------------------------------------------------------------------

AlbedoConst = .33;
SatSidesEarthAng = zeros(1,6);
AlbedoPerSide = zeros(1,6);

if EclipseBinary == 1 % If satellite is eclipsed, assume no albedo
    AlbedoPerSide = [0,0,0,0,0,0];
else
    % Calculate angle between E2Sat and the normal vector for each satellite side. 
    for k = 1:6
        SatSidesEarthAng(k) = acos(dot(Sat2EarthBody, NormSatECEF(k,:))/(norm(Sat2EarthBody)*norm(NormSatECEF(k,:))));
    end
    for k = 1:6
        if cos(SatSidesEarthAng(k)) <= 0
            AlbedoPerSide(k) = 0; % If side is facing away from Earth, no albedo
        else
            AlbedoPerSide(k) = ASat(k)*cos(SatSidesEarthAng(k))*SolarIrr*AlbedoConst;
        end
    end
end
