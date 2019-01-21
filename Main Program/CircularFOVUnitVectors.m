function [CircFOVUnitVectors] = CircularFOVUnitVectors(CircularHalfAngle)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function develops 360 unit vectors that define the bounds of a
% conical view

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% CircularHalfAngle: The half-angle that defines the view angle of the
% satellites imager [deg]

% ~~ Outputs ~~
% CircFOVUnitVectors: An array of 360 unit vectors that form the bounds of
% the view from the satellite
% ------------------------------------------------------------------------


eta = CircularHalfAngle; %[deg], Nadir Angle, Angle between target point and nadir
elev = 90-eta;

VectorsArraySpherical = (1:1:360)'; % Create 360 azimuths
VectorsArraySpherical(:,2) = elev; % each will have the same elevation
VectorsArraySpherical(:,3) = 1; % Unit radius

for i = 1:size(VectorsArraySpherical, 1)
    [CircFOVUnitVectors(i,1),CircFOVUnitVectors(i,2),CircFOVUnitVectors(i,3)] ...
        = sph2cart(VectorsArraySpherical(i,1)*pi/180, VectorsArraySpherical(i,2)*pi/180, VectorsArraySpherical(i,3));
end

end