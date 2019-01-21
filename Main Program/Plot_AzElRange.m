function [] = Plot_AzElRange(AERCell, PassNumber)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Creates plots of azimuth, elevation, range, and range-rate for a given
% satellite pass over either a ground station or a target

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% AERCell: The cell array containing all of the AER data for passes for a
% given ground station or target
% PassNumber: Which number pass to be analyzed

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


a = 12; % Font size

% Pull data for the specific pass out of the larger cell array
TimeData = cell2mat(AERCell{PassNumber, 1});
AzimuthData = cell2mat(AERCell{PassNumber, 2});
ElevationData = cell2mat(AERCell{PassNumber, 3});
RangeData = cell2mat(AERCell{PassNumber, 4});
RangeRateData = cell2mat(AERCell{PassNumber, 5});
TimeUTCG = AERCell{PassNumber, 6};

% Plot all of the data for the pass
figure

subplot(2,2,1)
plot(TimeData-TimeData(1),AzimuthData)
title(['Azimuth for Pass: ' num2str(PassNumber)])
ylabel('deg')
grid on; grid minor
xlabel(['Sec Past Start of Pass: ', TimeUTCG{1}(1:end-10)])
set(gca,'FontSize',a)

subplot(2,2,2)
plot(TimeData-TimeData(1),ElevationData)
title(['Elevation for Pass: ' num2str(PassNumber)])
ylabel('deg')
grid on; grid minor
xlabel(['Sec Past Start of Pass: ', TimeUTCG{1}(1:end-10)])
set(gca,'FontSize',a)

subplot(2,2,3)
plot(TimeData-TimeData(1),RangeData)
title(['Range for Pass: ' num2str(PassNumber)])
ylabel('m')
grid on; grid minor
xlabel(['Sec Past Start of Pass: ', TimeUTCG{1}(1:end-10)])
set(gca,'FontSize',a)

subplot(2,2,4)
plot(TimeData-TimeData(1),RangeRateData)
title(['Range Rate for Pass: ' num2str(PassNumber)])
ylabel('m/s')
grid on; grid minor
xlabel(['Sec Past Start of Pass: ', TimeUTCG{1}(1:end-10)])
set(gca,'FontSize',a)

end

