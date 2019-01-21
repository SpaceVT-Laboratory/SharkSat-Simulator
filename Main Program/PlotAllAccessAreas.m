function [] = PlotAllAccessAreas(LatLongAlt)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function plots the instantaneous access area of the satellite at a
% given lat, long, alt

% ~~ Notes ~~
% Both a 2D and 3D representation will be plotted

% ~~ Inputs ~~
% LatLongAlt: Vector of the current lat, long, alt of the satellite to be
% used, [deg, deg, km]

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


RE = 6371;

for j = 1:size(LatLongAlt,1)
    Lat_SSP = LatLongAlt(j,1);
    if Lat_SSP == 90
        Lat_SSP = 89.99999999;
    elseif Lat_SSP == -90
        Lat_SSP = -89.99999999;
    end
    Lon_SSP = LatLongAlt(j,2);
    Alt = LatLongAlt(j,3)/1000;
    LAMBDA0 = acosd(RE/(RE+Alt));
    % Create spherical vectors with Z pointing towards satellite (pretending 
    % satellite is at 0 lat 0 lon from center of the Earth
    SphPoints = [(1:1:360)', ones(360,1)*(90-LAMBDA0), ones(360,1)*RE];
    % Convert to Cartesian
    [CartPoints(:,1), CartPoints(:,2), CartPoints(:,3)] = sph2cart(SphPoints(:,1)*pi/180,SphPoints(:,2)*pi/180,SphPoints(:,3));
    % Switch to X pointing towards spacecraft
    CartPoints = [CartPoints(:,3), CartPoints(:,2), CartPoints(:,1)];
    RLat = [cosd(-Lat_SSP),0,sind(-Lat_SSP);0,1,0;-sind(-Lat_SSP),0,cosd(-Lat_SSP)];
    RLon = [cosd(Lon_SSP),-sind(Lon_SSP),0;sind(Lon_SSP),cosd(Lon_SSP),0;0,0,1];
    for i = 1:size(CartPoints,1)
        HorizonPointsCart(i,:,j) = (RLon*RLat*CartPoints(i,:)')';
        [HorizonPointsLatLon(i,1,j), HorizonPointsLatLon(i,2,j), HorizonPointsLatLon(i,3,j)] = cart2sph(HorizonPointsCart(i,1,j),HorizonPointsCart(i,2,j),HorizonPointsCart(i,3,j));
    end
    HorizonPointsLatLon(:,1,j) = HorizonPointsLatLon(:,1,j)*180/pi;
    HorizonPointsLatLon(:,2,j) = HorizonPointsLatLon(:,2,j)*180/pi;
end

% Plot the scenario on a globe
figure; hold on;
plot_globe()
for i = 1:size(HorizonPointsCart,3)
    scatter3(HorizonPointsCart(:,1,i),HorizonPointsCart(:,2,i),HorizonPointsCart(:,3,i),'.c')
end
% Plot the scenario on a map
figure; hold on; axis([0 360 -90 90]);
for i = 1:size(HorizonPointsCart,3)
    scatter(HorizonPointsLatLon(:,1,i),HorizonPointsLatLon(:,2,i),'.r')
end
borders('countries', 'k')
axis equal; box on;
set(gca,'XLim',[-180 180],'YLim',[-90 90], 'XTick',[-180 -120 -60 0 60 120 180], 'Ytick',[-90 -60 -30 0 30 60 90]);
ylabel('Latitude [deg]');
xlabel('Longitude [deg]');

end

