function [] = Plot_Doppler(NominalFreq, AERfromGroundStationCell, PassNumber)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function determines and plots the doppler shift experienced at a
% ground station  during a satellite pass

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% NominalFreq: The nominal frequency being broadcast by the satellite, [hz]
% AERfromGroundStationCell: The cell array containing all of the AER data 
% for passes for a given ground station
% PassNumber: Which number pass to be analyzed

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


c = 299792458; % Speed of light in m/s

TimeData = cell2mat(AERfromGroundStationCell{PassNumber, 1});
RangeData = cell2mat(AERfromGroundStationCell{PassNumber, 4});
RangeRateData = cell2mat(AERfromGroundStationCell{PassNumber, 5});
TimeUTCG = AERfromGroundStationCell{PassNumber, 6};

ObservedFreq = (c./(c+RangeRateData))*NominalFreq;
DopplerShift = ObservedFreq-NominalFreq;

figure

subplot(2,2,1)
plot(TimeData-TimeData(1),DopplerShift)
title(['Doppler Shift for Pass: ' num2str(PassNumber)])
ylabel('Hertz')
grid on; grid minor
xlabel(['Sec Past Start of Pass: ', TimeUTCG{1}(1:end-10)])

subplot(2,2,2)
plot(TimeData-TimeData(1),ObservedFreq)
title(['Observed Frequency for Pass: ' num2str(PassNumber)])
ylabel('Hertz')
grid on; grid minor
xlabel(['Sec Past Start of Pass: ', TimeUTCG{1}(1:end-10)])

subplot(2,2,3)
plot(TimeData-TimeData(1),RangeData)
title(['Range for Pass: ' num2str(PassNumber)])
ylabel('m')
grid on; grid minor
xlabel(['Sec Past Start of Pass: ', TimeUTCG{1}(1:end-10)])

subplot(2,2,4)
plot(TimeData-TimeData(1),RangeRateData)
title(['Range Rate for Pass: ' num2str(PassNumber)])
ylabel('m/s')
grid on; grid minor
xlabel(['Sec Past Start of Pass: ', TimeUTCG{1}(1:end-10)])
end

