function [ ] = GroundTrackPlot(LatLongAlt, GroundStationLLA, TargetsLLA)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function creates a ground track plot of the satellite that also
% shows the location of the ground station and any defined targets

% ~~ Notes ~~
% There are no variable outputs. The plot will display in a seperate figure

% ~~ Inputs ~~
% LatLongAlt: An array of the latitude, longitude, and altitudes of the
% satellite at the times to plot.
% GroundStationLLA: Vector containing the latitude, longitude, and altitude
% of the ground station.
% TargetsLLA: Vector containing the latitude, longitude, and altitude
% of any targets that were defined.

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------

figure;
hold on;
axis([0 360 -90 90]);
borders('countries', 'k')
axis equal
box on
set(gca,'XLim',[-180 180],'YLim',[-90 90], ...
    'XTick',[-180 -120 -60 0 60 120 180], ...
    'Ytick',[-90 -60 -30 0 30 60 90]);
ylabel('Latitude [deg]');
xlabel('Longitude [deg]');
title('Satellite Ground Track');
scatter(LatLongAlt(:,2),LatLongAlt(:,1),'.r');
plot(LatLongAlt(1,2),LatLongAlt(1,1),'dr','markers',25);
text(LatLongAlt(1,2),LatLongAlt(1,1)-3,'Start')
plot(GroundStationLLA(2), GroundStationLLA(1), '*m','markers', 20);
text(GroundStationLLA(1,2),GroundStationLLA(1,1)-3,'G.S.')
try
    plot(TargetsLLA(:,2), TargetsLLA(:,1), '*c', 'markers', 15);
    text(TargetsLLA(:,2),TargetsLLA(:,1)-3,'Targ')
catch
    
end

%{
% plot ground track
figure;
hold on;
axis([0 360 -90 90]);
load('topo.mat','topo','topomap1');
contour(0:359,-89:90,topo,[0 0],'b')
axis equal
box on
set(gca,'XLim',[-180 180],'YLim',[-90 90], ...
    'XTick',[-180 -120 -60 0 60 120 180], ...
    'Ytick',[-90 -60 -30 0 30 60 90]);
image([-180 180],[-90 90],topo,'CDataMapping', 'scaled');
colormap(topomap1);
ylabel('Latitude [deg]');
xlabel('Longitude [deg]');
title('Satellite Ground Track');
scatter(LatLongAlt(:,2),LatLongAlt(:,1),'.r');
plot(LatLongAlt(1,2),LatLongAlt(1,1),'dr','markers',25);

plot(GroundStationLLA(2), GroundStationLLA(1), '*k','markers', 20);
%}

%{
if TargetsLLA(1,:) ~= [999,999,999]
    plot(TargetsLLA(1,2), TargetsLLA(1,1), '*k','markers', 20);
end
if TargetsLLA(2,:) ~= [999,999,999]
    plot(TargetsLLA(2,2), TargetsLLA(2,1), '*k','markers', 20);
end
if TargetsLLA(3,:) ~= [999,999,999]
    plot(TargetsLLA(3,2), TargetsLLA(3,1), '*k','markers', 20);
end
%}