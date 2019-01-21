function [OrbitsLifetime] = Call_STK_Lifetime(COEs, EpochDate, Mass, DragArea, DecayAlt) 
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Calls STK only to generate several lifetime estimations

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% COEs: A vector of the 6 classical orbital elements
% EpochDate: String containing the epoch date, the date at which the COEs
% are valid. ex '4 January 2018 08:43:15'
% Mass: Mass of the satellite [kg]
% DragArea: Average forward facing drag area of the satellite [m^2]
% DecayAlt: Altitude at which the satellite is considered decayed, or that
% the satellite's mission is over [km]

% ~~ Outputs ~~
% OrbitsLifetime: A structure that contains three 'parts', each 'part'
% containing lifetime estimation data using a different atmospheric model
% ------------------------------------------------------------------------


sma = COEs(1); % km = semi-major axis
ecc = COEs(2); % eccentricity
inc = COEs(3); % degrees = inclination
argper = COEs(4); % degrees = argument of perigee
RAAN = COEs(5); % degrees = right ascension of the ascending node
truan = COEs(6); % degrees = true anomaly

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

root = app.Personality2;
app.Visible = 1; % Shows [1] or hides [0] STK screen
root.NewScenario('Sim'); % Names scenario 'Sim'
scen = root.CurrentScen;
scen.SetTimePeriod(EpochDate,'+1 Day');
%scen.Epoch = scen.StartTime;
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');
root.Rewind;

% Insert satellite object, named 'Sat', choose propogator and step size
sat = scen.Children.New(18,'Sat'); 
sat.SetPropagatorType('ePropagatorHPOP');
sat.Propagator.InitialState.Representation.AssignClassical('eCoordinateSystemJ2000',sma,ecc,inc,argper,RAAN,truan);
sat.Propagator.InitialState.Epoch = EpochDate;

% Propogate the satellite
sat.Propagator.Propagate;

% Set the first density model, run the lifetime analysis, and generate the
% data
root.ExecuteCommand(['SetLifetime */Satellite/sat DensityModel "1976 Standard" OrbPerCalc 1 DragArea ', num2str(DragArea), ' SunArea .01 Mass ', num2str(Mass), ' DecayAltitude ', num2str(DecayAlt)])
root.ExecuteCommand('Lifetime */Satellite/sat')
OrbitsDP = sat.DataProviders.Item('Lifetime').Exec(scen.StartTime,scen.StopTime,60);
OrbitsTime = OrbitsDP.DataSets.GetDataSetByName('Time').GetValues;
Orbits = OrbitsDP.DataSets.GetDataSetByName('Orbit Count').GetValues;
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
OrbitsDP = sat.DataProviders.Item('Lifetime').Exec(scen.StartTime,scen.StopTime,60);
OrbitsTimeEpSec = OrbitsDP.DataSets.GetDataSetByName('Time').GetValues;
OrbitsLifetime.Min = [OrbitsTime, OrbitsTimeEpSec, Orbits];

root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');

% Set the second density model, run the lifetime analysis, and generate the
% data
root.ExecuteCommand(['SetLifetime */Satellite/sat DensityModel "DTM 2012" OrbPerCalc 1 DragArea ', num2str(DragArea), ' SunArea .01 Mass ', num2str(Mass)])
root.ExecuteCommand('Lifetime */Satellite/sat')
OrbitsDP = sat.DataProviders.Item('Lifetime').Exec(scen.StartTime,scen.StopTime,60);
OrbitsTime = OrbitsDP.DataSets.GetDataSetByName('Time').GetValues;
Orbits = OrbitsDP.DataSets.GetDataSetByName('Orbit Count').GetValues;
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
OrbitsDP = sat.DataProviders.Item('Lifetime').Exec(scen.StartTime,scen.StopTime,60);
OrbitsTimeEpSec = OrbitsDP.DataSets.GetDataSetByName('Time').GetValues;
OrbitsLifetime.Max = [OrbitsTime, OrbitsTimeEpSec, Orbits];

root.UnitPreferences.Item('DateFormat').SetCurrentUnit('UTCG');

% Set the last density model, run the lifetime analysis, and generate the
% data
root.ExecuteCommand(['SetLifetime */Satellite/sat DensityModel "Jacchia-Roberts" OrbPerCalc 1 DragArea ', num2str(DragArea), ' SunArea .01 Mass ', num2str(Mass)])
root.ExecuteCommand('Lifetime */Satellite/sat')
OrbitsDP = sat.DataProviders.Item('Lifetime').Exec(scen.StartTime,scen.StopTime,60);
OrbitsTime = OrbitsDP.DataSets.GetDataSetByName('Time').GetValues;
Orbits = OrbitsDP.DataSets.GetDataSetByName('Orbit Count').GetValues;
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
OrbitsDP = sat.DataProviders.Item('Lifetime').Exec(scen.StartTime,scen.StopTime,60);
OrbitsTimeEpSec = OrbitsDP.DataSets.GetDataSetByName('Time').GetValues;
OrbitsLifetime.Mid = [OrbitsTime, OrbitsTimeEpSec, Orbits];

end

 
 
 
 
 
 
 
 
 
 
 
 
 
 