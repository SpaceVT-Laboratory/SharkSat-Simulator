function [EnergyUsePerComponent, EnergyUseTotal, HeatGenerationPerComponent, HeatGenerationTotal]...
    = DetermineComponentPowerHistory(LowPower, HighPower, NormPower, Eff, GSPower, TargetPower, ...
    AllPower, Time, TargetsLLA, GroundStationLLA, Access2GroundStation, Access2Targets)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Calculates the power usage and heat generation of components

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% LowPower: Vector of all the low-power usage levels defined in the GUI [W]
% HighPower: Vector of all the high-power usage levels defined in the GUI [W]
% NormPower: Vector of all the norm-power usage levels defined in the GUI [W]
% Eff: Vector of all component efficiencies [fraction]
% GSPower: Vector of which power level to use during access to ground station
% TargetPower: Vector of which power level to use during access to targets
% AllPower: Vector of which power level to use during all other times
% Time: Vector of times in epoch-seconds [s]
% TargetsLLA: Lat, long, and alts of targets
% GroundStationLLA: Lat, long, and alt of ground station
% Access2GroundStation: Cell containing pass information for ground station
% Access2Targets: Cell containing pass information for all of the targets

% ~~ Outputs ~~
% EnergyUsePerComponent: Array containing the instantaneous power usage of
% each component at each time step [W]
% EnergyUseTotal: Vector containing the instantaneous power usage of
% all components combined at each time step [W]
% HeatGenerationPerComponent: Array containing the instantaneous heat
% generation of each component at each time step [W]
% HeatGenerationTotal: Vector containing the instantaneous heat
% generation of all components combined at each time step [W]
% ------------------------------------------------------------------------


for i = 1:size(LowPower,1)

    if strcmp(GSPower(i), "High")
        GSPowerUsage(i,1) = HighPower(i,1);
    elseif strcmp(GSPower(i), "Low")
        GSPowerUsage(i,1) = LowPower(i,1);
    else
        GSPowerUsage(i,1) = NormPower(i,1);
    end

    if strcmp(TargetPower(i), "High")
        TargetPowerUsage(i,1) = HighPower(i,1);
    elseif strcmp(GSPower(i), "Low")
        TargetPowerUsage(i,1) = LowPower(i,1);
    else
        TargetPowerUsage(i,1) = NormPower(i,1);
    end

    if strcmp(AllPower(i), "High")
        AllPowerUsage(i,1) = HighPower(i,1);
    elseif strcmp(AllPower(i), "Low")
        AllPowerUsage(i,1) = LowPower(i,1);
    else
        AllPowerUsage(i,1) = NormPower(i,1);
    end

end

if isstring(TargetsLLA) || ischar(TargetsLLA)
    NumOfTargets = 0;
else
    NumOfTargets = size(TargetsLLA, 1);
end

if isstring(GroundStationLLA) || ischar(GroundStationLLA)
    NumOfGS = 0;
else
    NumOfGS = size(GroundStationLLA, 1);
end

switch NumOfTargets
    case 0
        TargetAccessTimes = [];
    case 1
        TargetAccessTimes = [Access2Targets.Target1(:,1:2)];
    case 2
        TargetAccessTimes = [Access2Targets.Target1(:,1:2); Access2Targets.Target2(:,1:2)];
    case 3
        TargetAccessTimes = [Access2Targets.Target1(:,1:2); Access2Targets.Target2(:,1:2); Access2Targets.Target3(:,1:2)];
    case 4
        TargetAccessTimes = [Access2Targets.Target1(:,1:2); Access2Targets.Target2(:,1:2); Access2Targets.Target3(:,1:2);...
            Access2Targets.Target4(:,1:2)];
    case 5
        TargetAccessTimes = [Access2Targets.Target1(:,1:2); Access2Targets.Target2(:,1:2); Access2Targets.Target3(:,1:2);...
            Access2Targets.Target4(:,1:2); Access2Targets.Target5(:,1:2)];
end

switch NumOfGS
    case 0
        GSAccessTimes = [];
    case 1
        GSAccessTimes = [Access2GroundStation.EpSec(:,1:2)];
end

CurrentGSAccess = zeros(length(Time), 1);
CurrentTargetAccess = zeros(length(Time), 1);

PowerUsage = zeros(size(Time,1),size(LowPower,1));
EnergyUsePerComponent = zeros(size(Time,1),size(LowPower,1));
EnergyUseTotal = zeros(size(Time,1),1);
HeatGenerationPerComponent = zeros(size(Time,1),size(LowPower,1));
HeatGenerationTotal = zeros(size(Time,1),1);

for i = 1:length(Time)

    CurrentTime = Time(i);

    for j = 1:size(GSAccessTimes, 1)
        if CurrentTime >= GSAccessTimes(j,1) && CurrentTime <= GSAccessTimes(j,2)
            CurrentGSAccess(j,1) = 1;
        else
            CurrentGSAccess(j,1) = 0;
        end
    end
    if sum(CurrentGSAccess) >= 1
        GSAccess = 1;
    else
        GSAccess = 0;
    end

    for j = 1:size(TargetAccessTimes, 1)
        if CurrentTime >= TargetAccessTimes(j,1) && CurrentTime <= TargetAccessTimes(j,2)
            CurrentTargetAccess(j,1) = 1;
        else
            CurrentTargetAccess(j,1) = 0;
        end
    end
    if sum(CurrentTargetAccess) >= 1
        TargetAccess = 1;
    else
        TargetAccess = 0;
    end

    if GSAccess == 1 && TargetAccess == 1
        PowerUsage(i,:) = max(GSPowerUsage, TargetPowerUsage);
        try
            PowerUsage(i-1,:) = PowerUsage(i,:);
        catch
        end
    elseif GSAccess == 1 && TargetAccess == 0
        PowerUsage(i,:) = GSPowerUsage;
        try
            PowerUsage(i-1,:) = PowerUsage(i,:);
        catch
        end
    elseif GSAccess == 0 && TargetAccess == 1
        PowerUsage(i,:) = TargetPowerUsage;
        try
            PowerUsage(i-1,:) = PowerUsage(i,:);
        catch
        end
    else
        PowerUsage(i,:) = AllPowerUsage;
    end

    EnergyUsePerComponent(i,:) = PowerUsage(i,:); %Instantaneous Watts
    EnergyUseTotal(i) = sum(EnergyUsePerComponent(i,:)); %Instantaneous Watts
    HeatGenerationPerComponent(i,:) = EnergyUsePerComponent(i,:).*Eff';
    HeatGenerationTotal(i) = sum(HeatGenerationPerComponent(i,:));

end


end

