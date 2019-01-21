function [HorizonPointsCart, HorizonPointsLatLon] = HorizonPoints(RE, Alt, Lat_SSP, Lon_SSP)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates 360 points on the Earth that together form the
% boundary of the horizon that can be seen by the satellite

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% RE: Mean (circular) radius of the Earth, [m]
% Alt: Altitude of the satellite, [km]
% Lat_SSP: Latitude of the sub-satellite-point, [deg]
% Lon_SSP: Longitude of the sub-satellite-point, [deg]

% ~~ Outputs ~~
% HorizonPointsCart: Array containing the points as vectors in cartesian
% ECEF, [km]
% HorizonPointsLatLon: Array containing the points as vectors in latitude
% and longitude
% ------------------------------------------------------------------------


LAMBDA0 = acosd(RE/(RE+Alt));

% Create spherical vectors with Z pointing towards satellite (pretending 
% satellite is at 0 lat 0 lon from center of the Earth
SphPoints = [(1:1:360)', ones(360,1)*(90-LAMBDA0), ones(360,1)*RE];

% Convert to Cartesian
[CartPoints(:,1), CartPoints(:,2), CartPoints(:,3)] = sph2cart(SphPoints(:,1)*pi/180,SphPoints(:,2)*pi/180,SphPoints(:,3));

% Switch to X pointing towards spacecraft
CartPoints = [CartPoints(:,3), CartPoints(:,2), CartPoints(:,1)];

%{
figure; hold on;
plot_globe()
quiver3(0,0,0,(RE+Alt),0,0, 'LineWidth', 2, 'Color', 'c', 'AutoScale', 'off')
for i = 1:size(CartPoints,1)
    quiver3(0,0,0, CartPoints(i,1), CartPoints(i,2), CartPoints(i,3), 'AutoScale', 'off')
end
zlabel('Z'); ylabel('Y'); xlabel('X');
%}




RLat = [cosd(-Lat_SSP),0,sind(-Lat_SSP);0,1,0;-sind(-Lat_SSP),0,cosd(-Lat_SSP)];
RLon = [cosd(Lon_SSP),-sind(Lon_SSP),0;sind(Lon_SSP),cosd(Lon_SSP),0;0,0,1];
%{
S = [RE+Alt,0,0]'
S2 = [0,(RE+Alt),0]'

SL = ((RLon*RLat)*S)';
[SLL(1), SLL(2), SLL(3)] = cart2sph(S(1), S(2), S(3));
slat = SLL(2)*180/pi
slon = SLL(1)*180/pi 

SL2 = ((RLon*RLat)*S2)';
[SLL2(1), SLL2(2), SLL2(3)] = cart2sph(S2(1), S2(2), S2(3));
s2lat = SLL2(2)*180/pi
s2lon = SLL2(1)*180/pi 
%}

for i = 1:size(CartPoints,1)
    HorizonPointsCart(i,:) = (RLon*RLat*CartPoints(i,:)')';
    [HorizonPointsLatLon(i,1), HorizonPointsLatLon(i,2), HorizonPointsLatLon(i,3)] = cart2sph(HorizonPointsCart(i,1),HorizonPointsCart(i,2),HorizonPointsCart(i,3));
end
%{
figure; hold on;
plot_globe()
quiver3(0,0,0,(RE+Alt),0,0, 'LineWidth', 2, 'Color', 'c', 'AutoScale', 'off')
quiver3(0,0,0,S(1),S(2),S(3), 'LineWidth', 2, 'Color', 'r', 'AutoScale', 'off')
for i = 1:size(CartPoints,1)
    quiver3(0,0,0, HorizonPointsCart(i,1), HorizonPointsCart(i,2), HorizonPointsCart(i,3), 'AutoScale', 'off')
end
zlabel('Z'); ylabel('Y'); xlabel('X');
%}
HorizonPointsLatLon(:,1) = HorizonPointsLatLon(:,1) *180/pi;
HorizonPointsLatLon(:,2) = HorizonPointsLatLon(:,2) *180/pi;


%{
figure; hold on;
scatter3(HorizonPointsCart(:,1),HorizonPointsCart(:,2),HorizonPointsCart(:,3), '*r')
scatter3(CartPoints(:,1),CartPoints(:,2),CartPoints(:,3), 'b')
[x,y,z] = sphere(50); mesh(x*RE,y*RE,z*RE, 'FaceAlpha', 0, 'EdgeAlpha', .25)
zlabel('Z'); ylabel('Y'); xlabel('X');
%}

end

