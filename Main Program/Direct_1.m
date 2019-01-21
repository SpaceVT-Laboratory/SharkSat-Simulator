function [DirectIrrPerSide] = Direct_1(Sat2SunBody, NormSat, AreaSat, SolarIrr, EclipseBinary)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function determines the current solar power indicent on each side 
% due to direct solar irradiance


% ~~ Notes ~~
% Assumes sun is at infinite distance from satellite, meaning that all rays
% from the sun are perpendicular to the satellite-sun position vector

% ~~ Inputs ~~
% Sat2SunBody: Position vector from satellite to Sun in body frame, [km]
% NormSat: Unit vectors of satellite sides in body-fixed coordinate frame
% AreaSat: Vector containing the surface areas of each side of the
% satellite, [m^2]
% SolarIrr: Current solar irradiance level, [W/m^2]
% EclipseBinary: Binary, 1 if in Earth's shadow, 0 if sunlit

% ~~ Outputs ~~
% DirectIrrPerSide: Vector containing the power incident on each of the six
% sides of the satellite due to direct solar irradiance, [W]
% ------------------------------------------------------------------------

if EclipseBinary == 1 % If eclipsed by the Earth, no solar irradiance
    DirectIrrPerSide = [0,0,0,0,0,0];
else
    % Initialize the vector containing the angle between the sat-sun vector and
    % the sat-side normal vectors
    Theta = zeros(1,6);
    % Calculate the angles
    for k = 1:6
        Theta(1,k) = acos(dot(Sat2SunBody, NormSat(k,:))/(norm(Sat2SunBody)*norm(NormSat(k,:))));
    end

    % Initialize the vector containing the effective area of each sat side
    % visible to the sun
    AreaEff2Sun = zeros(1,6);
    % Calculate the effective areas
    for k = 1:6 
        if cos(Theta(k)) > 0
            AreaEff2Sun(k) = AreaSat(k)*cos(Theta(k));
        else
            AreaEff2Sun(k) = 0; % The side is facing away from the sun
        end
    end

    % Initialize the vector containing the direct solar irradiance on each
    % side
    DirectIrrPerSide = zeros(1,6);
    % Calculate the direct solar irradiance on each side
    for k = 1:6
        DirectIrrPerSide(k) = AreaEff2Sun(k)*SolarIrr;
    end
end


























