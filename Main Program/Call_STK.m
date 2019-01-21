function [Sat2EarthECEF, Sat2SunECEF, SatRPYAnglesECEF, Sat2EarthBody,...
    Sat2SunBody, LatLongAlt, Time, TimeUTCG, Access2GroundStation, AERfromGroundStationCell,... 
    Access2Targets, AERfromTargets, AccessGSNote] = Call_STK(StartDate, EndDate, EpochDate, TimeStep, COEs, TLElines, ...
    GroundStationLLA, TargetsLLA, AttitudeParameters, MinElevations, AccessTimeStep)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Main function that calls to STK and imports data for analysis

% ~~ Notes ~~
% This is the function that is called when the 'RUN STK' button is pressed
% on the main GUI, after all input GUIs have been used

% ~~ Inputs ~~
% StartDate: Character array containing the start date/time for the analysis
% EndDate: Character array containing the end date/time for the analysis
% EpochDate: Character array containing the date/time at which time the
% orbital parameters are valid
%               ex for all dates: '4 January 2018 08:43:15'
% TimeStep: Granularity for main analysis [s]
% COEs: Vector containing the classical orbital elements
% TLElines: Either a single value = 0 if a TLE was not used, or a character
% array containing the TLE lines if a TLE was used
% GroundStationLLA: Lat, Long, Alt of the ground station [deg, deg, m]
% TargetsLLA: Lat, Long, Alt of the targets [deg, deg, m]
% AttitudeParameters: Vector containing various parameters defining the
% standard attitude profiles available in STK
% MinElevations: Vector containing the minimum elevation angles for access
% to the ground station and targets [deg, deg]
% AccessTimeStep: Granularity for access and pass data analysis [s]

% ~~ Outputs ~~
% Sat2EarthECEF: Position vector from satellite to Earth in ECEF [km]
% Sat2SunECEF: Position vector from satellite to Sun in ECEF [km]
% SatRPYAnglesECEF: Euler angles defining the satellite's attitude relative
% the the ECEF frame
% Sat2EarthBody: Position vector from satellite to Earth in body frame [km]
% Sat2SunBody: Position vector from satellite to Sun in body frame [km]
% LatLongAlt: Lat Long and Alt of satellite at every time step
% Time: Time in seconds since the beginning of the scenario at every time
% step
% TimeUTCG: Time in UTCG since the beginning of the scenario at every time
% step
% Access2GroundStation: Structure containing the access information for the
% satellite and ground station in both epoch seconds ands UTCG time
% AERfromGroundStationCell: Cell containing the azimuth, elevation, range, 
% and range-rate information for the ground station passes
% Access2Targets: Structure containing the access information for the
% satellite and targets in both epoch seconds ands UTCG time
% AERfromTargets: Structure containing the azimuth, elevation, range, 
% and range-rate information for the target passes
% AccessGSNote: If = 'Note', there is access, otherwise, the note will tell
% you that there was no access to the ground station during the analysis
% time period

% ------------------------------------------------------------------------

% Pull the individual classical orbital elements out of the COE vector
sma = COEs(1); % semi-major axis, [km]
ecc = COEs(2); % eccentricity
inc = COEs(3); % inclination, [deg]
argper = COEs(4); % argument of perigee, [deg]
RAAN = COEs(5); % right ascension of the ascending node, [deg]
truan = COEs(6); % true anomaly, [deg]

% Pull the lat, long, and alt for the ground station
lat = GroundStationLLA(1); % geodetic, [deg]
lon = GroundStationLLA(2); % geodetic, [deg]
alt = GroundStationLLA(3); % [m]

% Open the connection with STK. Try multiple versions
try
    app = actxserver('STK11.application');
catch
    try
        app = actxserver('STK10.application');
    catch
        try
            app = actxserver('STK12.application');
        catch
            disp('Could not reach either STK10, STK11, or STK12')
            return
        end
    end
end

root = app.Personality2; % No idea what this does, but it is necessary
app.Visible = 1; % Shows [1] or hides [0] STK screen

% Create the new STK scenario
root.NewScenario('Sim'); % Names scenario 'Sim'
scen = root.CurrentScen;
scen.SetTimePeriod(StartDate,EndDate); % Set start and end date of scenario
scen.Epoch = scen.StartTime; % Sets animation start time to start date
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
root.Rewind;

% Insert facility object, named 'GS' and assign defined lat, long, alt
gs = scen.Children.New('eFacility','GS');
gs.Position.AssignGeodetic(lat,lon,alt);
gsMinEl = gs.AccessConstraints.AddConstraint('eCstrElevationAngle');
gsMinEl.EnableMin = true;
gsMinEl.Min = MinElevations(1);

% Insert target objects, 
if isstring(TargetsLLA) == 0
    [m,~] = size(TargetsLLA);
    if m == 5
        Target1 = scen.Children.New('eTarget','Target1');
        Target1.Position.AssignGeodetic(TargetsLLA(1,1),TargetsLLA(1,2),TargetsLLA(1,3));
        Target1MinEl = Target1.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target1MinEl.EnableMin = true;
        Target1MinEl.Min = MinElevations(2);
        Target2 = scen.Children.New('eTarget','Target2');
        Target2.Position.AssignGeodetic(TargetsLLA(2,1),TargetsLLA(2,2),TargetsLLA(2,3));
        Target2MinEl = Target2.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target2MinEl.EnableMin = true;
        Target2MinEl.Min = MinElevations(2);
        Target3 = scen.Children.New('eTarget','Target3');
        Target3.Position.AssignGeodetic(TargetsLLA(3,1),TargetsLLA(3,2),TargetsLLA(3,3));
        Target3MinEl = Target3.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target3MinEl.EnableMin = true;
        Target3MinEl.Min = MinElevations(2);
        Target4 = scen.Children.New('eTarget','Target4');
        Target4.Position.AssignGeodetic(TargetsLLA(4,1),TargetsLLA(4,2),TargetsLLA(4,3));
        Target4MinEl = Target4.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target4MinEl.EnableMin = true;
        Target4MinEl.Min = MinElevations(2);
        Target5 = scen.Children.New('eTarget','Target5');
        Target5.Position.AssignGeodetic(TargetsLLA(5,1),TargetsLLA(5,2),TargetsLLA(5,3));
        Target5MinEl = Target5.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target5MinEl.EnableMin = true;
        Target5MinEl.Min = MinElevations(2);
    elseif m == 4
        Target1 = scen.Children.New('eTarget','Target1');
        Target1.Position.AssignGeodetic(TargetsLLA(1,1),TargetsLLA(1,2),TargetsLLA(1,3));
        Target1MinEl = Target1.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target1MinEl.EnableMin = true;
        Target1MinEl.Min = MinElevations(2);
        Target2 = scen.Children.New('eTarget','Target2');
        Target2.Position.AssignGeodetic(TargetsLLA(2,1),TargetsLLA(2,2),TargetsLLA(2,3));
        Target2MinEl = Target2.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target2MinEl.EnableMin = true;
        Target2MinEl.Min = MinElevations(2);
        Target3 = scen.Children.New('eTarget','Target3');
        Target3.Position.AssignGeodetic(TargetsLLA(3,1),TargetsLLA(3,2),TargetsLLA(3,3));
        Target3MinEl = Target3.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target3MinEl.EnableMin = true;
        Target3MinEl.Min = MinElevations(2);
        Target4 = scen.Children.New('eTarget','Target4');
        Target4.Position.AssignGeodetic(TargetsLLA(4,1),TargetsLLA(4,2),TargetsLLA(4,3));
        Target4MinEl = Target4.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target4MinEl.EnableMin = true;
        Target4MinEl.Min = MinElevations(2);
    elseif m == 3
        Target1 = scen.Children.New('eTarget','Target1');
        Target1.Position.AssignGeodetic(TargetsLLA(1,1),TargetsLLA(1,2),TargetsLLA(1,3));
        Target1MinEl = Target1.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target1MinEl.EnableMin = true;
        Target1MinEl.Min = MinElevations(2);
        Target2 = scen.Children.New('eTarget','Target2');
        Target2.Position.AssignGeodetic(TargetsLLA(2,1),TargetsLLA(2,2),TargetsLLA(2,3));
        Target2MinEl = Target2.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target2MinEl.EnableMin = true;
        Target2MinEl.Min = MinElevations(2);
        Target3 = scen.Children.New('eTarget','Target3');
        Target3.Position.AssignGeodetic(TargetsLLA(3,1),TargetsLLA(3,2),TargetsLLA(3,3));
        Target3MinEl = Target3.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target3MinEl.EnableMin = true;
        Target3MinEl.Min = MinElevations(2);
    elseif m == 2
        Target1 = scen.Children.New('eTarget','Target1');
        Target1.Position.AssignGeodetic(TargetsLLA(1,1),TargetsLLA(1,2),TargetsLLA(1,3));
        Target1MinEl = Target1.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target1MinEl.EnableMin = true;
        Target1MinEl.Min = MinElevations(2);
        Target2 = scen.Children.New('eTarget','Target2');
        Target2.Position.AssignGeodetic(TargetsLLA(2,1),TargetsLLA(2,2),TargetsLLA(2,3));
        Target2MinEl = Target2.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target2MinEl.EnableMin = true;
        Target2MinEl.Min = MinElevations(2);
    elseif m ==1
        Target1 = scen.Children.New('eTarget','Target1');
        Target1.Position.AssignGeodetic(TargetsLLA(1,1),TargetsLLA(1,2),TargetsLLA(1,3));
        Target1MinEl = Target1.AccessConstraints.AddConstraint('eCstrElevationAngle');
        Target1MinEl.EnableMin = true;
        Target1MinEl.Min = MinElevations(2);
    end
end

% Insert satellite object, named 'Sat', choose propogator and step size
sat = scen.Children.New(18,'Sat');
if ischar(TLElines) % If TLElines shows that a TLE was entered, use SGP4
    sat.SetPropagatorType('ePropagatorSGP4');
    L2c = TLElines(1,:);
    L3c = TLElines(2,:);
    root.ExecuteCommand(['SetState */Satellite/Sat TLE "', L2c, '" "', L3c, '"'])
    set(sat.Propagator,'Start',StartDate);
    set(sat.Propagator,'Stop',EndDate);
else % If orbital elements were entered, used HPOP
    sat.SetPropagatorType('ePropagatorHPOP');
    set(sat.Propagator,'Step',TimeStep);
    sat.Propagator.InitialState.Representation.AssignClassical('eCoordinateSystemJ2000',sma,ecc,inc,argper,RAAN,truan);
    sat.Propagator.InitialState.Epoch = EpochDate;
end
 
%sat.Propagator.Propagate;

% Set the attitude of the satellite
basic = sat.Attitude.Basic;
AttitudeOptionNumber = AttitudeParameters(1);
AttitudeConstraintAngle = AttitudeParameters(2);
AttitudeAlignmentAngle = AttitudeParameters(3);
AttitudeBodyX = AttitudeParameters(4);
AttitudeBodyY = AttitudeParameters(5);
AttitudeBodyZ = AttitudeParameters(6);
AttitudeInertialX = AttitudeParameters(7);
AttitudeInertialY = AttitudeParameters(8);
AttitudeInertialZ = AttitudeParameters(9);
AttitudeSpinRate = AttitudeParameters(10);
AttitudePrecessionRate = AttitudeParameters(11);
AttitudeNutationAngle = AttitudeParameters(12);
try
switch AttitudeOptionNumber
    case 1
        basic.SetProfileType('eProfileNadiralignmentwithECFvelocityconstraint')
        basic.Profile.ConstraintOffset = AttitudeConstraintAngle;
    case 2
        basic.SetProfileType('eProfileNadiralignmentwithECIvelocityconstraint')
        basic.Profile.ConstraintOffset = AttitudeConstraintAngle;
    case 3
        basic.SetProfileType('eProfileNadiralignmentwithSunconstraint')
        basic.Profile.ConstraintOffset = AttitudeConstraintAngle;
    case 4
        basic.SetProfileType('eProfileECFvelocityalignmentwithradialconstraint')
        basic.Profile.ConstraintOffset = AttitudeConstraintAngle;
    case 5
        basic.SetProfileType('eProfileECFvelocityalignmentwithnadirconstraint')
        basic.Profile.ConstraintOffset = AttitudeConstraintAngle;
    case 6
        basic.SetProfileType('eProfileECIvelocityalignmentwithnadirconstraint')
        basic.Profile.ConstraintOffset = AttitudeConstraintAngle;
    case 7
        basic.SetProfileType('eProfileECIvelocityalignmentwithSunconstraint')
        basic.Profile.AlignmentOffset = AttitudeAlignmentAngle;
    case 8
        basic.SetProfileType('eProfileSunalignmentwithnadirconstraint')
        basic.Profile.AlignmentOffset = AttitudeAlignmentAngle;
    case 9
        basic.SetProfileType('eProfileYawtonadir')
        basic.Profile.Inertial.AssignXYZ(AttitudeInertialX,AttitudeInertialY,AttitudeInertialZ);
    case 10
        basic.SetProfileType('eProfileSpinning')
        basic.Profile.Body.AssignXYZ(AttitudeBodyX,AttitudeBodyY,AttitudeBodyZ)
        basic.Profile.Inertial.AssignXYZ(AttitudeInertialX,AttitudeInertialY,AttitudeInertialZ);
        basic.Profile.Rate = AttitudeSpinRate*6;
    case 11
        basic.SetProfileType('eProfileSpinaboutnadir')
        basic.Profile.Rate = AttitudeSpinRate*6;
    case 12
        basic.SetProfileType('eProfileSpinaboutSunvector')
        basic.Profile.Rate = AttitudeSpinRate*6;
    case 13
        basic.SetProfileType('eProfilePrecessingSpin')
        basic.Profile.Body.AssignXYZ(AttitudeBodyX,AttitudeBodyY,AttitudeBodyZ)
        basic.Profile.Inertial.AssignXYZ(AttitudeInertialX,AttitudeInertialY,AttitudeInertialZ);
        basic.Profile.Precession.Rate = AttitudePrecessionRate*6;
        basic.Profile.Spin.Rate = AttitudeSpinRate*6;
        basic.Profile.NutationAngle = AttitudeNutationAngle;
end
catch
end

% Propogate the satellite
sat.Propagator.Propagate;

% Change unit preferences
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
root.UnitPreferences.Item('Distance').SetCurrentUnit('m');
root.UnitPreferences.Item('Angle').SetCurrentUnit('rad');

% Generate data for the vector from the satellite to the Earth
% in ECEF coordinates, at each time step
sat2earthfixedDP = sat.DataProviders.Item('Vectors(Fixed)').Group.Item('Earth').Exec(scen.StartTime,scen.StopTime,TimeStep);
sat2earthfixedx = cell2mat(sat2earthfixedDP.DataSets.GetDataSetByName('x').GetValues);
sat2earthfixedy = cell2mat(sat2earthfixedDP.DataSets.GetDataSetByName('y').GetValues);
sat2earthfixedz = cell2mat(sat2earthfixedDP.DataSets.GetDataSetByName('z').GetValues);
Sat2EarthECEF = [sat2earthfixedx,sat2earthfixedy,sat2earthfixedz];

% Get a vector of times, both in epoch seconds and UTCG, at each time step
Time = cell2mat(sat2earthfixedDP.DataSets.GetDataSetByName('Time').GetValues);
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
TimeUTCG = sat2earthfixedDP.DataSets.GetDataSetByName('Time').GetValues;
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');

% Generate data for the vector from the satellite to the Sun
% in ECEF coordinates, at each time step
sat2sunfixedDP = sat.DataProviders.Item('Vectors(Fixed)').Group.Item('Sun').Exec(scen.StartTime,scen.StopTime,TimeStep);
sat2sunfixedx = cell2mat(sat2sunfixedDP.DataSets.GetDataSetByName('x').GetValues);
sat2sunfixedy = cell2mat(sat2sunfixedDP.DataSets.GetDataSetByName('y').GetValues);
sat2sunfixedz = cell2mat(sat2sunfixedDP.DataSets.GetDataSetByName('z').GetValues);
Sat2SunECEF = [sat2sunfixedx,sat2sunfixedy,sat2sunfixedz];

% Generate data for the vector that defines the orientation of the
% satellite with respect to the Eath's coordinate frame
satorientationfixedDP = sat.DataProviders.Item('Body Axes Orientation').Group.Item('Earth Fixed').Exec(scen.StartTime,scen.StopTime,TimeStep);
satorientationfixedyaw = cell2mat(satorientationfixedDP.DataSets.GetDataSetByName('YPR321 yaw').GetValues);
satorientationfixedpitch = cell2mat(satorientationfixedDP.DataSets.GetDataSetByName('YPR321 pitch').GetValues);
satorientationfixedroll = cell2mat(satorientationfixedDP.DataSets.GetDataSetByName('YPR321 roll').GetValues);
SatRPYAnglesECEF = [satorientationfixedyaw,satorientationfixedpitch,satorientationfixedroll];

% Generate data for the vector from the satellite to the Earth
% in satellite-body-fixed coordinates, at each time step
sat2earthbodyDP = sat.DataProviders.Item('Vectors(Body)').Group.Item('Earth').Exec(scen.StartTime,scen.StopTime,TimeStep);
sat2earthbodyx = cell2mat(sat2earthbodyDP.DataSets.GetDataSetByName('x').GetValues);
sat2earthbodyy = cell2mat(sat2earthbodyDP.DataSets.GetDataSetByName('y').GetValues);
sat2earthbodyz = cell2mat(sat2earthbodyDP.DataSets.GetDataSetByName('z').GetValues);
Sat2EarthBody = [sat2earthbodyx,sat2earthbodyy,sat2earthbodyz];

% Generate data for the vector from the satellite to the Sun
% in satellite-body-fixed coordinates, at each time step
sat2sunbodyDP = sat.DataProviders.Item('Vectors(Body)').Group.Item('Sun').Exec(scen.StartTime,scen.StopTime,TimeStep);
sat2sunbodyx = cell2mat(sat2sunbodyDP.DataSets.GetDataSetByName('x').GetValues);
sat2sunbodyy = cell2mat(sat2sunbodyDP.DataSets.GetDataSetByName('y').GetValues);
sat2sunbodyz = cell2mat(sat2sunbodyDP.DataSets.GetDataSetByName('z').GetValues);
Sat2SunBody = [sat2sunbodyx,sat2sunbodyy,sat2sunbodyz];

% Generate data for theLat, Long, Alt of satellite at each time step
LLAStateDP = sat.DataProviders.Item('LLA State').Group.Item('Fixed').Exec(scen.StartTime,scen.StopTime,TimeStep);
LLAStateLat = cell2mat(LLAStateDP.DataSets.GetDataSetByName('Lat').GetValues);
LLAStateLong = cell2mat(LLAStateDP.DataSets.GetDataSetByName('Lon').GetValues);
LLAStateAlt = cell2mat(LLAStateDP.DataSets.GetDataSetByName('Alt').GetValues);
LatLongAlt = [LLAStateLat, LLAStateLong, LLAStateAlt];

% Access to ground station. Will print out a message if there is no access
try
    access = gs.GetAccessToObject(sat);
    access.ComputeAccess;
    accessDP = access.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
    AccessStartTimes = cell2mat(accessDP.DataSets.GetDataSetByName('Start Time').GetValues);
    AccessStopTimes = cell2mat(accessDP.DataSets.GetDataSetByName('Stop Time').GetValues);
    AccessDuration = cell2mat(accessDP.DataSets.GetDataSetByName('Duration').GetValues);
    Access2GroundStation.EpSec = [AccessStartTimes, AccessStopTimes, AccessDuration];
    
    root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
    root.UnitPreferences.Item('Angle').SetCurrentUnit('deg');
    accessAER = access.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
    AERTimes{1} = accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
    Az{1} = accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
    El{1} = accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
    Range{1} = accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
    RangeRate{1} = accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
    
    for i = 1:1:accessAER.Interval.Count-1
        AERTimes{i+1} = accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
        Az{i+1} = accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
        El{i+1} = accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
        Range{i+1} = accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
        RangeRate{i+1} = accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
    end
        
    % Change units to UTCG and create reports again
    
    root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');

    accessDP = access.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
    AccessStartTimes = accessDP.DataSets.GetDataSetByName('Start Time').GetValues;
    AccessStopTimes = accessDP.DataSets.GetDataSetByName('Stop Time').GetValues;
    AccessDuration = accessDP.DataSets.GetDataSetByName('Duration').GetValues;
    Access2GroundStation.UTCG = [AccessStartTimes, AccessStopTimes, AccessDuration];

    accessAER = access.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
    AERTimesUTCG{1} = accessAER.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
   
    for i = 1:1:accessAER.Interval.Count-1
        AERTimesUTCG{i+1} = accessAER.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
    end
    
    AERfromGroundStationCell = [AERTimes',Az',El',Range',RangeRate',AERTimesUTCG'];
    AccessGSNote = 'Note';
catch
    disp('There is no access to the ground station during this interval')
    AccessGSNote = "No access to ground station during this interval";
    Access2GroundStation.EpSec = "NoAccessToGroundStation";
    AERfromGroundStationCell = "NoAccessToGroundStation";
    Access2GroundStation.UTCG = "NoAccessToGroundStation";
end

% Change back to Epoch Seconds
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');

% Access to targets. Will print out a message if there is no access
if isstring(TargetsLLA) == 0
    [m,~] = size(TargetsLLA);
    if m == 5
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try
            accessTarget1 = Target1.GetAccessToObject(sat);
            accessTarget1.ComputeAccess;
            accessTarget1DP = accessTarget1.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget1StartTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget1StopTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget1Duration = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget1 = [AccessTarget1StartTimes, AccessTarget1StopTimes, AccessTarget1Duration];
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimes1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimesUTCG1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget1Cell = [AERTimes1',Az1',El1',Range1',RangeRate1',AERTimesUTCG1'];
        catch
            disp('There is no access to Target 1 during this interval')
            AccessTarget1 = [NaN,NaN,NaN];
            AERfromTarget1Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try            
            accessTarget2 = Target2.GetAccessToObject(sat);
            accessTarget2.ComputeAccess;
            accessTarget2DP = accessTarget2.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget2StartTimes = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget2StopTimes = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget2Duration = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget2 = [AccessTarget2StartTimes, AccessTarget2StopTimes, AccessTarget2Duration];
            accessAER2 = accessTarget2.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER2.Interval.Count-1
                AERTimes2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER2 = accessTarget2.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER2.Interval.Count-1
                AERTimesUTCG2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget2Cell = [AERTimes2',Az2',El2',Range2',RangeRate2',AERTimesUTCG2'];            
        catch
            disp('There is no access to Target 2 during this interval')
            AccessTarget2 = [NaN,NaN,NaN];
            AERfromTarget2Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try            
            accessTarget3 = Target3.GetAccessToObject(sat);
            accessTarget3.ComputeAccess;
            accessTarget3DP = accessTarget3.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget3StartTimes = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget3StopTimes = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget3Duration = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget3 = [AccessTarget3StartTimes, AccessTarget3StopTimes, AccessTarget3Duration];
            accessAER3 = accessTarget3.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER3.Interval.Count-1
                AERTimes3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER3 = accessTarget3.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER3.Interval.Count-1
                AERTimesUTCG3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget3Cell = [AERTimes3',Az3',El3',Range3',RangeRate3',AERTimesUTCG3'];
        catch
            disp('There is no access to Target 3 during this interval')
            AccessTarget3 = [NaN,NaN,NaN];
            AERfromTarget3Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try
            accessTarget4 = Target4.GetAccessToObject(sat);
            accessTarget4.ComputeAccess;
            accessTarget4DP = accessTarget4.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget4StartTimes = cell2mat(accessTarget4DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget4StopTimes = cell2mat(accessTarget4DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget4Duration = cell2mat(accessTarget4DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget4 = [AccessTarget4StartTimes, AccessTarget4StopTimes, AccessTarget4Duration];
            accessAER4 = accessTarget4.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER4.Interval.Count-1
                AERTimes4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER4 = accessTarget4.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER4.Interval.Count-1
                AERTimesUTCG4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget4Cell = [AERTimes4',Az4',El4',Range4',RangeRate4',AERTimesUTCG4'];
        catch
            disp('There is no access to Target 4 during this interval')
            AccessTarget4 = [NaN,NaN,NaN];
            AERfromTarget4Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try
            accessTarget5 = Target5.GetAccessToObject(sat);
            accessTarget5.ComputeAccess;
            accessTarget5DP = accessTarget5.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget5StartTimes = cell2mat(accessTarget5DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget5StopTimes = cell2mat(accessTarget5DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget5Duration = cell2mat(accessTarget5DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget5 = [AccessTarget5StartTimes, AccessTarget5StopTimes, AccessTarget5Duration];
            accessAER5 = accessTarget5.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes5{1} = accessAER5.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az5{1} = accessAER5.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El5{1} = accessAER5.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range5{1} = accessAER5.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate5{1} = accessAER5.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER5.Interval.Count-1
                AERTimes5{i+1} = accessAER5.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az5{i+1} = accessAER5.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El5{i+1} = accessAER5.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range5{i+1} = accessAER5.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate5{i+1} = accessAER5.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER5 = accessTarget5.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG5{1} = accessAER5.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER5.Interval.Count-1
                AERTimesUTCG5{i+1} = accessAER5.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget5Cell = [AERTimes5',Az5',El5',Range5',RangeRate5',AERTimesUTCG5'];
        catch
            disp('There is no access to Target 5 during this interval')
            AccessTarget5 = [NaN,NaN,NaN];
            AERfromTarget5Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        Access2Targets.Target1 = AccessTarget1;
        Access2Targets.Target2 = AccessTarget2;
        Access2Targets.Target3 = AccessTarget3;
        Access2Targets.Target4 = AccessTarget4;
        Access2Targets.Target5 = AccessTarget5;
        AERfromTargets.Target1 = AERfromTarget1Cell;
        AERfromTargets.Target2 = AERfromTarget2Cell;
        AERfromTargets.Target3 = AERfromTarget3Cell;
        AERfromTargets.Target4 = AERfromTarget4Cell;
        AERfromTargets.Target5 = AERfromTarget5Cell;
    elseif m == 4
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try
            accessTarget1 = Target1.GetAccessToObject(sat);
            accessTarget1.ComputeAccess;
            accessTarget1DP = accessTarget1.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget1StartTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget1StopTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget1Duration = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget1 = [AccessTarget1StartTimes, AccessTarget1StopTimes, AccessTarget1Duration];
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimes1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimesUTCG1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget1Cell = [AERTimes1',Az1',El1',Range1',RangeRate1',AERTimesUTCG1'];
        catch
            disp('There is no access to Target 1 during this interval')
            AccessTarget1 = [NaN,NaN,NaN];
            AERfromTarget1Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try            
            accessTarget2 = Target2.GetAccessToObject(sat);
            accessTarget2.ComputeAccess;
            accessTarget2DP = accessTarget2.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget2StartTimes = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget2StopTimes = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget2Duration = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget2 = [AccessTarget2StartTimes, AccessTarget2StopTimes, AccessTarget2Duration];
            accessAER2 = accessTarget2.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER2.Interval.Count-1
                AERTimes2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER2 = accessTarget2.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER2.Interval.Count-1
                AERTimesUTCG2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget2Cell = [AERTimes2',Az2',El2',Range2',RangeRate2',AERTimesUTCG2'];            
        catch
            disp('There is no access to Target 2 during this interval')
            AccessTarget2 = [NaN,NaN,NaN];
            AERfromTarget2Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try            
            accessTarget3 = Target3.GetAccessToObject(sat);
            accessTarget3.ComputeAccess;
            accessTarget3DP = accessTarget3.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget3StartTimes = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget3StopTimes = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget3Duration = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget3 = [AccessTarget3StartTimes, AccessTarget3StopTimes, AccessTarget3Duration];
            accessAER3 = accessTarget3.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER3.Interval.Count-1
                AERTimes3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER3 = accessTarget3.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER3.Interval.Count-1
                AERTimesUTCG3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget3Cell = [AERTimes3',Az3',El3',Range3',RangeRate3',AERTimesUTCG3'];
        catch
            disp('There is no access to Target 3 during this interval')
            AccessTarget3 = [NaN,NaN,NaN];
            AERfromTarget3Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try
            accessTarget4 = Target4.GetAccessToObject(sat);
            accessTarget4.ComputeAccess;
            accessTarget4DP = accessTarget4.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget4StartTimes = cell2mat(accessTarget4DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget4StopTimes = cell2mat(accessTarget4DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget4Duration = cell2mat(accessTarget4DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget4 = [AccessTarget4StartTimes, AccessTarget4StopTimes, AccessTarget4Duration];
            accessAER4 = accessTarget4.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER4.Interval.Count-1
                AERTimes4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER4 = accessTarget4.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG4{1} = accessAER4.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER4.Interval.Count-1
                AERTimesUTCG4{i+1} = accessAER4.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget4Cell = [AERTimes4',Az4',El4',Range4',RangeRate4',AERTimesUTCG4'];
        catch
            disp('There is no access to Target 4 during this interval')
            AccessTarget4 = [NaN,NaN,NaN];
            AERfromTarget4Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        Access2Targets.Target1 = AccessTarget1;
        Access2Targets.Target2 = AccessTarget2;
        Access2Targets.Target3 = AccessTarget3;
        Access2Targets.Target4 = AccessTarget4;
        AERfromTargets.Target1 = AERfromTarget1Cell;
        AERfromTargets.Target2 = AERfromTarget2Cell;
        AERfromTargets.Target3 = AERfromTarget3Cell;
        AERfromTargets.Target4 = AERfromTarget4Cell;
    elseif m == 3
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try
            accessTarget1 = Target1.GetAccessToObject(sat);
            accessTarget1.ComputeAccess;
            accessTarget1DP = accessTarget1.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget1StartTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget1StopTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget1Duration = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget1 = [AccessTarget1StartTimes, AccessTarget1StopTimes, AccessTarget1Duration];
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimes1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimesUTCG1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget1Cell = [AERTimes1',Az1',El1',Range1',RangeRate1',AERTimesUTCG1'];
        catch
            disp('There is no access to Target 1 during this interval')
            AccessTarget1 = [NaN,NaN,NaN];
            AERfromTarget1Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try            
            accessTarget2 = Target2.GetAccessToObject(sat);
            accessTarget2.ComputeAccess;
            accessTarget2DP = accessTarget2.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget2StartTimes = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget2StopTimes = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget2Duration = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget2 = [AccessTarget2StartTimes, AccessTarget2StopTimes, AccessTarget2Duration];
            accessAER2 = accessTarget2.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER2.Interval.Count-1
                AERTimes2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER2 = accessTarget2.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER2.Interval.Count-1
                AERTimesUTCG2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget2Cell = [AERTimes2',Az2',El2',Range2',RangeRate2',AERTimesUTCG2'];            
        catch
            disp('There is no access to Target 2 during this interval')
            AccessTarget2 = [NaN,NaN,NaN];
            AERfromTarget2Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try            
            accessTarget3 = Target3.GetAccessToObject(sat);
            accessTarget3.ComputeAccess;
            accessTarget3DP = accessTarget3.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget3StartTimes = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget3StopTimes = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget3Duration = cell2mat(accessTarget3DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget3 = [AccessTarget3StartTimes, AccessTarget3StopTimes, AccessTarget3Duration];
            accessAER3 = accessTarget3.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER3.Interval.Count-1
                AERTimes3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER3 = accessTarget3.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG3{1} = accessAER3.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER3.Interval.Count-1
                AERTimesUTCG3{i+1} = accessAER3.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget3Cell = [AERTimes3',Az3',El3',Range3',RangeRate3',AERTimesUTCG3'];  
        catch
            disp('There is no access to Target 3 during this interval')
            AccessTarget3 = [NaN,NaN,NaN];
            AERfromTarget3Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        Access2Targets.Target1 = AccessTarget1;
        Access2Targets.Target2 = AccessTarget2;
        Access2Targets.Target3 = AccessTarget3;
        AERfromTargets.Target1 = AERfromTarget1Cell;
        AERfromTargets.Target2 = AERfromTarget2Cell;
        AERfromTargets.Target3 = AERfromTarget3Cell;
    elseif m == 2
        try
            accessTarget1 = Target1.GetAccessToObject(sat);
            accessTarget1.ComputeAccess;
            accessTarget1DP = accessTarget1.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget1StartTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget1StopTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget1Duration = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget1 = [AccessTarget1StartTimes, AccessTarget1StopTimes, AccessTarget1Duration];
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimes1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimesUTCG1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget1Cell = [AERTimes1',Az1',El1',Range1',RangeRate1',AERTimesUTCG1'];
        catch
            disp('There is no access to Target 1 during this interval')
            AccessTarget1 = [NaN,NaN,NaN];
            AERfromTarget1Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try            
            accessTarget2 = Target2.GetAccessToObject(sat);
            accessTarget2.ComputeAccess;
            accessTarget2DP = accessTarget2.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget2StartTimes = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget2StopTimes = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget2Duration = cell2mat(accessTarget2DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget2 = [AccessTarget2StartTimes, AccessTarget2StopTimes, AccessTarget2Duration];
            accessAER2 = accessTarget2.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER2.Interval.Count-1
                AERTimes2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER2 = accessTarget2.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG2{1} = accessAER2.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER2.Interval.Count-1
                AERTimesUTCG2{i+1} = accessAER2.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget2Cell = [AERTimes2',Az2',El2',Range2',RangeRate2',AERTimesUTCG2'];            
        catch
            disp('There is no access to Target 2 during this interval')
            AccessTarget2 = [NaN,NaN,NaN];
            AERfromTarget2Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        Access2Targets.Target1 = AccessTarget1;
        Access2Targets.Target2 = AccessTarget2;
        AERfromTargets.Target1 = AERfromTarget1Cell;
        AERfromTargets.Target2 = AERfromTarget2Cell;
    elseif m ==1
        root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
        try
            accessTarget1 = Target1.GetAccessToObject(sat);
            accessTarget1.ComputeAccess;
            accessTarget1DP = accessTarget1.DataProviders.Item('Access Data').Exec(scen.StartTime, scen.StopTime);
            AccessTarget1StartTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Start Time').GetValues);
            AccessTarget1StopTimes = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Stop Time').GetValues);
            AccessTarget1Duration = cell2mat(accessTarget1DP.DataSets.GetDataSetByName('Duration').GetValues);
            AccessTarget1 = [AccessTarget1StartTimes, AccessTarget1StopTimes, AccessTarget1Duration];
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimes1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            Az1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
            El1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
            Range1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Range').GetValues;
            RangeRate1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimes1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
                Az1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Azimuth').GetValues;
                El1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Elevation').GetValues;
                Range1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Range').GetValues;
                RangeRate1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('RangeRate').GetValues;
            end
            root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
            accessAER1 = accessTarget1.DataProviders.Item('AER Data').Group.Item('Default').Exec(scen.StartTime, scen.StopTime, AccessTimeStep);
            AERTimesUTCG1{1} = accessAER1.Interval.Item(cast(0,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            for i = 1:1:accessAER1.Interval.Count-1
                AERTimesUTCG1{i+1} = accessAER1.Interval.Item(cast(i,'int32')).DataSets.GetDataSetByName('Time').GetValues;
            end
            AERfromTarget1Cell = [AERTimes1',Az1',El1',Range1',RangeRate1',AERTimesUTCG1'];
        catch
            disp('There is no access to Target 1 during this interval')
            AccessTarget1 = [NaN,NaN,NaN];
            AERfromTarget1Cell = [NaN,NaN,NaN,NaN,NaN,NaN];
        end
        Access2Targets.Target1 = AccessTarget1;
        AERfromTargets.Target1 = AERfromTarget1Cell;
    end
else
    Access2Targets.Target1 = "NoTargets";
end
 
end


 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 