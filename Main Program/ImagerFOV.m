function [BoundingLatLons] = ImagerFOV(HalfAngle1, HalfAngle2, RectOrCirc, LLA, OrientationAngles, PlotsBinary)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function calculates a number of points on the surface of the Earth
% that together form the bounds of the satellites field of view

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% HalfAngle1: Half of the angular 'width' of a rectangular field of view,
% or half of the angular radius of a circular field of view, [deg]
% HalfAngle2: Half of the angular 'height' of a rectangular field of view,
% will not be used for a circular field of view, [deg]
% RectOrCirc: 'Rectangle' for a rectangular field of view, 'Circle' for a
% circular field of view
% LLA: Lat, long, and alt of the satellite, [deg, deg, km]
% OrientationAngles: Three Euler angles defining the orientation of the
% satellite's imager with respect to the Earth, [deg, deg. deg]
% PlotsBinary: 1 to show plots, 0 otherwise

% ~~ Outputs ~~
% BoundingLatLons: Array containing latitude/longitude pairs that together
% form the bounds of the imager's field of view, [deg, deg]
% ------------------------------------------------------------------------


RE = 6371; %[km] Radius of Earth
Alt = LLA(3); %[km] Satellite Alitutude
Lat_SSP = LLA(1); % Sub Satellite Point Latitude
Lon_SSP = LLA(2); %Sub Satellite Point Longitude
if Lat_SSP == 90 % Singularity at 90, so make it a little less
    Lat_SSP = 89.99999999;
elseif Lat_SSP == -90
    Lat_SSP = -89.99999999;
end
[X_SSP,Y_SSP,Z_SSP] = sph2cart(Lon_SSP*pi/180,Lat_SSP*pi/180,RE);
[X_Sat,Y_Sat,Z_Sat] = sph2cart(Lon_SSP*pi/180,Lat_SSP*pi/180,RE+Alt);

% Rotation of satellite from nadir
Ax = OrientationAngles(1);
Ay = OrientationAngles(2); 
Az = OrientationAngles(3);

if strcmp(RectOrCirc, 'Rectangle')
    RectangularHalfAngle1 = HalfAngle1; %[deg] Height of image
    RectangularHalfAngle2 = HalfAngle2; %[deg] Length of image
    [FOVUnitVectors] = RectangularFOVUnitVectors(RectangularHalfAngle1, RectangularHalfAngle2);
else
    CircularHalfAngle = HalfAngle1; %[deg]
    [FOVUnitVectors] = CircularFOVUnitVectors(CircularHalfAngle);
end

% --- Now we account for the fact that the satellite sensor may not be 
% pointed straight down at the Earth (Nadir/X-axis). There may be both a
% horizontal angle offset (X/towards negative longitudes), vertical offset 
% (Y/towards positive latitudes), as well rotation about the sensor 
% 'boresite' (Z/clockwise looking at Earth).
% We also convert to spherical in the function, and get the Azimuths of the
% FOV unit vectors (relative Nadir), which are  equal but opposite in sign 
% to the the azimuths of the points on the surface of the Earth in the local frame
Rx = [1,0,0;0,cosd(Ax),-sind(Ax);0,sind(Ax),cosd(Ax)];
Ry = [cosd(Ay),0,sind(Ay);0,1,0;-sind(Ay),0,cosd(Ay)];
Rz = [cosd(Az),-sind(Az),0;sind(Az),cosd(Az),0;0,0,1];
for i = 1:size(FOVUnitVectors,1)
    FOVUnitVectorsRotated(i,:) = (Rx*Ry*Rz*FOVUnitVectors(i,:)')';
end
[SatFOVAzimuths(:,1), ~, ~] = cart2sph(FOVUnitVectorsRotated(:,1),FOVUnitVectorsRotated(:,2),FOVUnitVectorsRotated(:,3));
SatFOVAzimuths(:,1) = SatFOVAzimuths(:,1)*180/pi;
chg = SatFOVAzimuths(:,1)<0;
SatFOVAzimuths(chg,1) = SatFOVAzimuths(chg,1)+360;

% --- Now we want to put this vector into the same coordinate system as the
% Earth. For earth we will use a system centered at the center, with X
% pointing towards spacecraft, and Y is aligned with out current spacecraft
% Y. So the change will be that our Z axis turns into -X, and X becomes Z
FOVUnitVectorsTransformed = [-FOVUnitVectorsRotated(:,3),FOVUnitVectorsRotated(:,2),FOVUnitVectorsRotated(:,1)];



S = [RE+Alt, 0, 0]; % Vector from earth to spacecraft
for i = 1:size(FOVUnitVectorsTransformed,1)
    D1(i,1) = -dot(S,FOVUnitVectorsTransformed(i,:))+sqrt(dot(S,FOVUnitVectorsTransformed(i,:))^2-norm(S)^2+RE^2);
    if isreal(D1(i,1)) == 0
        D1(i,1) = NaN;
    end
    D2(i,1) = -dot(S,FOVUnitVectorsTransformed(i,:))-sqrt(dot(S,FOVUnitVectorsTransformed(i,:))^2-norm(S)^2+RE^2);
    if isreal(D2(i,1)) == 0
        D2(i,1) = NaN;
    end
end
D = min(D1,D2);
ObservationVectors = D.*FOVUnitVectorsTransformed;

% --- Now we convert these full ObservationVectors into latitude and 
% longitudes on the surface of the Earth
P = S+ObservationVectors;
O = ObservationVectors;
LatSSPd = 90-Lat_SSP;
PHIE = -SatFOVAzimuths;
unitS = S/norm(S);
for i = 1:size(ObservationVectors,1)
    unitO = O(i,:)/norm(O(i,:));
    unitP(i,:) = P(i,:)/norm(P(i,:));
    LAMBDA(i,1) = acosd(dot(unitS,unitP(i,:)));
end
for i = 1:length(PHIE)
    cng(i,1) = mod(PHIE(i),360);
    if cng(i,1) >= 0 && cng(i,1) < 180
        Hphi(i,1) = 1;
    else
        Hphi(i,1) = -1;
    end
end
for i = 1:length(LAMBDA)
    Latd(i,1) = acosd(cosd(LAMBDA(i,1))*cosd(LatSSPd)+sind(LAMBDA(i,1))*cosd(PHIE(i,1))*sind(LatSSPd));
    a = (cosd(LAMBDA(i,1))-cosd(Latd(i,1))*cosd(LatSSPd))/(Hphi(i,1)*sind(LatSSPd)*sind(Latd(i,1)));
    if a < -1
        a = -1;
    elseif a > 1
        a = 1;
    end
    Lons(i,1) = -acosd(a)+90*(Hphi(i,1)-1)+Lon_SSP;
    while Lons(i,1) < -180
        Lons(i,1) = Lons(i,1) + 360;
    end
end
Lats = 90-Latd;
BoundingLatLons = [Lats, Lons];
[X,Y,Z] = sph2cart(Lons*pi/180,Lats*pi/180,RE);

% Determine the Viewable Horizon Pointrs
LAMBDA0 = acosd(RE/(RE+Alt));
SphPoints = [(1:1:360)', ones(360,1)*(90-LAMBDA0), ones(360,1)*RE];
[CartPoints(:,1), CartPoints(:,2), CartPoints(:,3)] = sph2cart(SphPoints(:,1)*pi/180,SphPoints(:,2)*pi/180,SphPoints(:,3));
CartPoints = [CartPoints(:,3), CartPoints(:,2), CartPoints(:,1)];
RLat = [cosd(-Lat_SSP),0,sind(-Lat_SSP);0,1,0;-sind(-Lat_SSP),0,cosd(-Lat_SSP)];
RLon = [cosd(Lon_SSP),-sind(Lon_SSP),0;sind(Lon_SSP),cosd(Lon_SSP),0;0,0,1];
for i = 1:size(CartPoints,1)
    HorizonPointsCart(i,:) = (RLon*RLat*CartPoints(i,:)')';
    [HorizonPointsLatLon(i,1), HorizonPointsLatLon(i,2), HorizonPointsLatLon(i,3)] = cart2sph(HorizonPointsCart(i,1),HorizonPointsCart(i,2),HorizonPointsCart(i,3));
end
HorizonPointsLatLon(:,1) = HorizonPointsLatLon(:,1) *180/pi;
HorizonPointsLatLon(:,2) = HorizonPointsLatLon(:,2) *180/pi;

% Move observation vectors over the correct sub satellite point
for i = 1:size(ObservationVectors,1)
    ObservationVectorsRotated(i,:) = (RLon*RLat*ObservationVectors(i,:)')';
end

if PlotsBinary == 1
    % Plot the instantaneous view
    % Plot the scenario on a globe
    figure; hold on;
    plot_globe()
    scatter3(X,Y,Z, 'r')
    scatter3(X_SSP,Y_SSP,Z_SSP, 'c', 'filled')
    scatter3(X_Sat,Y_Sat,Z_Sat, 'c', 'filled')
    scatter3(HorizonPointsCart(:,1),HorizonPointsCart(:,2),HorizonPointsCart(:,3),'w')
    a = size(ObservationVectors(1:20:end,1),1);
    quiver3(ones(a,1)*X_Sat,ones(a,1)*Y_Sat,ones(a,1)*Z_Sat,ObservationVectorsRotated(1:20:end,1),ObservationVectorsRotated(1:20:end,2),ObservationVectorsRotated(1:20:end,3), 'AutoScale', 'off', 'Color', 'c')

    % Plot the scenario on a map
    figure; hold on; axis([0 360 -90 90]);
    grid on; grid minor;
    plot(Lons(1),Lats(1),'xm','markers', 15)
    plot(Lon_SSP, Lat_SSP, 'xc', 'markers', 15)
    scatter(Lons(:),Lats(:),'.r');
    scatter(HorizonPointsLatLon(:,1),HorizonPointsLatLon(:,2),'.k')
    borders('countries', 'k')
    axis equal; box on;
    set(gca,'XLim',[-180 180],'YLim',[-90 90], 'XTick',[-180 -120 -60 0 60 120 180], 'Ytick',[-90 -60 -30 0 30 60 90]);
    ylabel('Latitude [deg]');
    xlabel('Longitude [deg]');
    legend('Top Of Image', 'Sub-Satellite Point', 'Imager FOV', 'Horizon')
end

end

