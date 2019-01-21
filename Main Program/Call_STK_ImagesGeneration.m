function [] = Call_STK_ImagesGeneration(FOV, LLA, Angles, PixelDims, FilePath)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Generates 'realistic' satellite images

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% FOV:
% LLA:
% Angles:
% PixelDims:
% FilePath:

% ~~ Outputs ~~
% 
% ------------------------------------------------------------------------


Lats = LLA(:,1);
Lons = LLA(:,2);
Alts = LLA(:,3);
Angle1 = Angles(1);
Angle2 = Angles(2);
Angle3 = Angles(3);

pixelWidth = PixelDims(1);
pixelHeight = PixelDims(2)+120;
% We will crop 120 pixels later to remove watermarks

app = actxserver('STK11.Application');
root = app.Personality2;
scenario = root.Children.New('escenario','TestingTesting123') ;


StartTime='Now';
StopTime='+1 hrs';
scenario.SetTimePeriod(StartTime,StopTime);
root.ExecuteCommand('Animate * Reset');

cmd1='Setunits / km'; %Sets units to KM
root.ExecuteCommand(cmd1);

sat = scenario.Children.New('esatellite','Sat');
sat.Propagator.InitialState.Representation.AssignSpherical('eCoordinateSystemFixed', Lons(1), Lats(1) , Alts(1)/1000+6371, 90, 270, 7.72576);
sat.Propagator.InitialState.Epoch = scenario.StartTime;
sat.Propagator.Propagate;


cmd9=['VectorTool * Satellite/Sat Create Axes AxesBaseForPhoto "Aligned and Constrained" Cartesian 0 0 1 "Satellite/Sat Nadir(Centric)" Cartesian 0 1 0 "Satellite/Sat North" "X" "Y" "Z"'];
root.ExecuteCommand(cmd9);

cmd11=['VectorTool * Satellite/Sat Create Axes AxesForPhoto "Fixed in Axes" Euler ' num2str(Angle1) ' ' num2str(Angle2) ' ' num2str(Angle3) ' 123 "Satellite/Sat AxesBaseForPhoto" "X" "Y" "Z"'];
root.ExecuteCommand(cmd11);
% 1st angle tilts around X, tilting toward negative lattitudes
% 2nd angle tilts around Y, tilting toward negative longitudes

% Seems like just because you rotate the axes, you aren't rotating the
% photo that is produced

cmd12=['VectorTool * Satellite/Sat Create Vector VectorForPhoto "Fixed in Axes" Cartesian 0 0 1 "Satellite/Sat AxesForPhoto"'];
root.ExecuteCommand(cmd12);
% Create vector to view along. Aligned with Z axes of AxesForPhoto

cmd13=['VO * ViewAlongDirection From Satellite/Sat Direction "Satellite/Sat VectorForPhoto Vector"'];
root.ExecuteCommand(cmd13);
% Sets view to be along the vector specified previously

cmd3='VO * Lighting Show Off'; %Turns off shadows
root.ExecuteCommand(cmd3);

cmd4=['Window3D * InnerSize ' num2str(pixelWidth) ' ' num2str(pixelHeight)];%Sets the window inner size to the image size requested by the GUI
root.ExecuteCommand(cmd4); % May need to change this to take into account that we will crop the photo later
% And that we are only able to set one value for field of view.

cmd5=['Window3D * ViewVolume FieldOfView ' num2str(FOV)];%Sets the field of view to that requested
root.ExecuteCommand(cmd5);
% Will have to be the larger of the two FOVs

cmd74=['VO * View AddReferenceFrame "Satellite/Sat AxesForPhoto Axes" Object Satellite/Sat'];
root.ExecuteCommand(cmd74);

cmd7=['VO * View SetReferenceFrame "Satellite/Sat AxesForPhoto Axes" WindowId 1']; 
root.ExecuteCommand(cmd7);

cmd43=['VO * View Parameters UseUpAxis On UpAxis Y'];
root.ExecuteCommand(cmd43);

cmd6=['VO * ObjectStateInWin Show Off Object Satellite/Sat WindowId All'];
root.ExecuteCommand(cmd6);


for i = 1:length(Lats)
    sat.Propagator.InitialState.Representation.AssignSpherical('eCoordinateSystemFixed', Lons(i), Lats(i) , Alts(i)/1000+6371, 90, 270, 7.72576);
    sat.Propagator.InitialState.Epoch = scenario.StartTime;
    sat.Propagator.Propagate;

    

    FileName = [num2str(Lats(i)) '_' num2str(Lons(i)) '_' num2str(Alts(i)) '-' num2str(Angle1) '_' num2str(Angle2) '_' num2str(Angle3)];


    cmd8=['VO * SnapFrame ToFile "' FilePath '\' FileName '.bmp"'];
    root.ExecuteCommand(cmd8);


    rect = [0 30 pixelWidth (pixelHeight-90)]; % [xmin ymin width height]
    % ymin, I believe, is the top of the image


    I=imread([FilePath '\' FileName '.bmp']);
    I2=imcrop(I,rect);
    imwrite(I2,[FilePath '\' FileName '.bmp'])
end

end

