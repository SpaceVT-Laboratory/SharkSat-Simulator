function [NormSatECEF] = SatSideUnitVectorsECEF(NormSatECEFAnglesDeg,NormSat)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function determines the unit vectors normal to the sides of the
% satellite in ECEF

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% NormSatECEFAnglesDeg: Vector of euler angles describing the attitude of
% the satellite in respect to the Earth, [deg]
% NormSat: Unit vectors normal to the satellite sides in body frame

% ~~ Outputs ~~
% NormSatECEF: Unit vectors normal to the satellite sides in ECEF
% ------------------------------------------------------------------------


Iterations = size(NormSatECEFAnglesDeg,1);

NormSatECEFAnglesRads = NormSatECEFAnglesDeg*pi/180;
NS = NormSatECEFAnglesRads;
RotationMats = zeros(3,3,Iterations);
Yaw = zeros(3,3,Iterations);
Pitch = zeros(3,3,Iterations);
Roll = zeros(3,3,Iterations);
NormSatECEF = zeros(3,Iterations,6);

for i = 1:Iterations
    Yaw(:,:,i) = [cos(NS(i,1)),-sin(NS(i,1)),0;sin(NS(i,1)),cos(NS(i,1)),0;0,0,1];
    Pitch(:,:,i) = [cos(NS(i,2)),0,sin(NS(i,2));0,1,0;-sin(NS(i,2)),0,cos(NS(i,2))];
    Roll(:,:,i) = [1,0,0;0,cos(NS(i,3)),-sin(NS(i,3));0,sin(NS(i,3)),cos(NS(i,3))];
    RotationMats(:,:,i) = Yaw(:,:,i)*Pitch(:,:,i)*Roll(:,:,i);
end

for i = 1:Iterations
    for k = 1:6
        NormSatECEF(:,i,k) = RotationMats(:,:,i)*NormSat(k,:)';
    end
end

NormSatECEF = permute(NormSatECEF,[2 1 3]);

end

