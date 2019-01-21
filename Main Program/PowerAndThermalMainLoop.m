function [SolarIrr, EclipseBinary, DirectIrrPerSide, AlbedoPerSide, IRPerSide, QinDirSolar, QinAlbedo, QinEarthIR, QoutSatRad, Temp, PowerDirectPerSide, PowerAlbedoPerSide, BatteryCharge, Iterations] = ...
    PowerAndThermalMainLoop(AreaSolarCells, AreaSat, Sat2EarthECEF, Sat2SunECEF, Sat2SunBody, SatRPYAnglesECEF, Time, TimeStep, InitialBatteryCharge, BatteryCapacity,...
    EmissSatSides, AbsorpSatSides, AbsorpIRSatSides, EmissSolCell, AbsorpSolCell, AbsorpIRSolCell, MassSat, SpecificHeat, SolEffcy, EnergyUseTotalComponents, HeatGenerationTotalComponents, TempInitial)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This is the main loop that calculates the power and thermal state of the
% satellite over the analysis time period

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% AreaSolarCells: Vector containing the areas of each of the six sides of 
% the satellite that is covered by solar panels, [m^2]
% AreaSat: Vector containing the areas of each of the six sides of the 
% satellite, [m^2]
% Sat2EarthECEF: Position vector from satellite to Earth in ECEF [km]
% Sat2SunECEF: Position vector from satellite to Sun in ECEF [km]
% Sat2SunBody: Position vector from satellite to Sun in body frame [km]
% SatRPYAnglesECEF: Euler angles defining the satellite's attitude relative
% the the ECEF frame
% Time: Vector of epoch seconds at each time step, [s]
% TimeStep: Granularity for main analysis [s]
% InitialBatteryCharge: Initial battery charge, [W-hr]
% BatteryCapacity: Maximum charge capacity of the battery, [W-hr]
% EmissSatSides: Emissivity of the satellite's outer material not covered
% by solar panels, []
% AbsorpSatSides: Absorptivity of the satellite's surface material that is
% not solar panels []
% AbsorpIRSatSides: Equal to EmissSatSides, []
% EmissSolCell: Emissivity of the satellite's solar panels []
% AbsorpSolCell: Absorptivity of the satellite's solar panel material []
% AbsorpIRSolCell: Equal to EmissSolCell, []
% MassSat: Total mass of the satellite, [kg]
% SpecificHeat: Average specific heat of the satellite, []
% SolEffcy: The ratio of incident radiation on the solar panels that will
% be turned into generated power
% EnergyUseTotalComponents: Vector containing the instantaneous power usage of
% all components combined at each time step [W]
% HeatGenerationTotalComponents: Vector containing the instantaneous heat
% generation of all components combined at each time step [W]
% TempInitial: Initial temperature of the satellite, [K]

% ~~ Outputs ~~
% SolarIrr: Current level of solar irradiance, [W/m^2]
% EclipseBinary: 1 if the satellite is in eclipse, 0 if in sunlight
% DirectIrrPerSide: Instantaneous irradiance on each side of the satellite 
% due to direct sunlight [W/m^2]
% AlbedoPerSide: Instantaneous irradiance on each side of the satellite due
% to Earth's albedo [W/m^2]
% IRPerSide: Instantaneous irradiance on each side of the satellite due
% to Earth's infra-red radiation [W/m^2]
% QinDirSolar: Instantaneous heat being gained by the satellite due to 
% direct solar radiation, [W]
% QinAlbedo: Instantaneous heat being gained by the satellite due to 
% Earth's albedo, [W]
% QinEarthIR: Instantaneous heat being gained by the satellite due to 
% Earth's infra-red radiation, [W]
% QoutSatRad: Instantaneous heat being radiated away from the satellite, [W]
% Temp: Vector of satellite temperatures at each time step, [K]
% PowerDirectPerSide: The instantaneous power generation on each side due 
% to direct solar radiation, [W]
% PowerAlbedoPerSide: The instantaneous power generation on each side due 
% to Earth's albedo, [W]
% BatteryCharge: Vector of the satellite battery's charge at each time
% step, [W-hr]
% Iterations: Total number of time steps
% ------------------------------------------------------------------------


[RE, SolarConst, EarthOrbRad, Sigma, EarthIRAvg, ~, NormSat] = LoadingConstants();

SolarCellRatioOfAreaSat = AreaSolarCells./AreaSat;
% Determine ECEF vectors from Earth to the Satellite and the Sun, m
Earth2SatECEF = -Sat2EarthECEF;
Earth2SunECEF = Sat2SunECEF - Sat2EarthECEF;
% Convert ECEF satellite orientation angles from radians to degrees
NormSatECEFAnglesDeg = SatRPYAnglesECEF*180/pi;
% Perform a coordinate transformation on the satellite side body-fixed
% normal vectors into ECEF coordinates
[NormSatECEF] = SatSideUnitVectorsECEF(NormSatECEFAnglesDeg,NormSat);

Iterations = size(Time,1);
% Initialize the vectors and arrays that will be filled
SolarIrr = zeros(Iterations,1);
Phi = zeros(Iterations,1);
EclipseBinary = zeros(Iterations,1);
DirectIrrPerSide = zeros(Iterations,6);
AlbedoPerSide = zeros(Iterations,6);
IRPerSide = zeros(Iterations,6);
QinDirSolar = zeros(Iterations,1);
QinAlbedo = zeros(Iterations,1);
QinEarthIR = zeros(Iterations,1);
QoutSatRad = zeros(Iterations,1);
Temp = zeros(Iterations+1,1);
Temp(1) = TempInitial;
BatteryCharge = zeros(Iterations,1);
BatteryCharge(1) = InitialBatteryCharge;
PowerDirectPerSide = zeros(Iterations,6);
PowerDirectTotal = zeros(Iterations,1);
PowerAlbedoPerSide = zeros(Iterations,6);
PowerAlbedoTotal = zeros(Iterations,1);

for i = 1:Iterations
    
% Calculate the current solar irradiance at the Earth (and therefore the
% satellite), W/m^2
[SolarIrr(i)] = SolarIrradiance(SolarConst, EarthOrbRad, Earth2SunECEF(i,:));

% Determine the number of components and modes of operation (probably
% should be input from the GUI
%[CompNumber, Modes] = size(PowerUsageofComps);

% What mode of operation are we in now
%CurrentMode = 1;

% Calculate the angle between the Earth2Sat and Earth2Sun vector, rads
% Determine if the satellite is in sunlight or eclipse, binary output
[Phi(i), EclipseBinary(i)] = Eclipse(Earth2SunECEF(i,:), Earth2SatECEF(i,:), RE);
% Calculate the power incident on each side due to direct sunlight, W
[DirectIrrPerSide(i,:)] = Direct_1(Sat2SunBody(i,:), NormSat, AreaSat, SolarIrr(i), EclipseBinary(i));
% Calculate the power incident on each side due to Earth albedo, W
%[AlbedoPerSide(i,:)] = Albedo_2(Sat2EarthBody(i,:), SolarIrr(i), AreaSat, NormSat, EclipseBinary(i)) ;
[AlbedoPerSide(i,:)] = Albedo_1(Earth2SunECEF(i,:), Earth2SatECEF(i,:), RE, SolarIrr(i), AreaSat, NormSatECEF(1,:,:));
% Calculate the power incident on each side due to Earth infrared, W
%[IRPerSide(i,:)] = EarthIR_2(Sat2EarthBody(i,:), AreaSat, NormSat, EarthIRAvg);
[IRPerSide(i,:)] = EarthIR_1(Earth2SatECEF(i,:), NormSatECEF(i,:,:), EarthIRAvg, AreaSat, RE);

% Calculate rate at which heat is entering via direct solar radiation, W
[QinDirSolar(i)] = HeatIn_DirectSolar(DirectIrrPerSide(i,:), AbsorpSatSides, AbsorpSolCell, SolarCellRatioOfAreaSat);
% Calculate rate at which heat is entering via albedo, W
[QinAlbedo(i)] = HeatIn_Albedo(AlbedoPerSide(i,:), AbsorpSatSides, AbsorpSolCell, SolarCellRatioOfAreaSat);
% Calculate rate at which heat is entering via Earth infrared, W
[QinEarthIR(i)] = HeatIn_EarthIR(IRPerSide(i,:), AbsorpIRSatSides, AbsorpIRSolCell, SolarCellRatioOfAreaSat);
% Calculate rate at which heat is exiting via radiation, W
[QoutSatRad(i)] = HeatOut_Radiation(EmissSatSides, EmissSolCell, Sigma, AreaSat, Temp(i), SolarCellRatioOfAreaSat);

% Update the temperature for the new iteration, K
Temp(i+1) = Temp(i) + (TimeStep*(HeatGenerationTotalComponents(i)+(QinDirSolar(i)+QinAlbedo(i)+QinEarthIR(i)-QoutSatRad(i))))/(MassSat*SpecificHeat);

% Calculate power generation due to direct solar irradiance, W
[PowerDirectTotal(i), PowerDirectPerSide(i,:)] = PowerGeneration_Direct(DirectIrrPerSide(i,:), SolarCellRatioOfAreaSat, SolEffcy);
% Calculate power generation due to albedo, W
[PowerAlbedoTotal(i), PowerAlbedoPerSide(i,:)] = PowerGeneration_Albedo(AlbedoPerSide(i,:), SolarCellRatioOfAreaSat, SolEffcy);

% Update the charge state of the battery, Whr
BatteryCharge(i+1) = BatteryCharge(i) + (TimeStep/3600)*(PowerDirectTotal(i)+PowerAlbedoTotal(i)-EnergyUseTotalComponents(i));
if BatteryCharge(i+1) > BatteryCapacity
    BatteryCharge(i+1) = BatteryCapacity;
elseif BatteryCharge(i+1) < 0
    BatteryCharge(i+1) = 0;
end

end

Temp(1,:) = [];
BatteryCharge(1,:) = [];

end

