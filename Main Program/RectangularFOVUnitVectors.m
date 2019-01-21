function [RectFOVUnitVectors] = RectangularFOVUnitVectors(RectangularHalfAngle1, RectangularHalfAngle2)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function develops a number of  unit vectors that define the bounds 
% of a rectangular view

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% RectangularHalfAngle1: Half of the angular 'width' of the view, [deg]
% RectangularHalfAngle2: Half of the angular 'height' of the view, [deg]

% ~~ Outputs ~~
% RectFOVUnitVectors: An array of unit vectors that form the bounds of
% the view from the satellite
% ------------------------------------------------------------------------


eta1 = RectangularHalfAngle1;
eta2 = RectangularHalfAngle2;

MiddlePoints = [0,90-eta1,1;90,90-eta2,1;180,90-eta1,1;270,90-eta2,1];
CornerAzimuths = [90-atand(eta1/eta2), 90+atand(eta1/eta2), 270-atand(eta1/eta2), 270+atand(eta1/eta2)];
CornerElevations = 90-acosd(cosd(eta1)*cosd(eta2));
CornerPoints = [CornerAzimuths(1), CornerElevations, 1; CornerAzimuths(2), CornerElevations, 1; CornerAzimuths(3), CornerElevations, 1; CornerAzimuths(4), CornerElevations, 1];
% First eighth (upper upper right)
for i = 1:1:floor(CornerAzimuths(1))
    Az = i;
    Length = tand(Az)*eta1;
    El = 90-acosd(cosd(eta1)*cosd(Length));
    UpperUpperRightPoints(i*1,:) = [Az,El,1];
end
% Second eighth (upper right right)
for i = ceil(CornerAzimuths(1)):1:89
    Az = i;
    Length = tand(90-Az)*eta2;
    El = 90-acosd(cosd(eta2)*cosd(Length));
    try
        UpperRightRightPoints(i*1-floor(CornerAzimuths(1)),:) = [Az,El,1];
    catch
    end
end
% Third eighth (lower right right)
for i = 91:1:floor(CornerAzimuths(2))
    Az = i;
    Length = tand(Az-90)*eta2;
    El = 90-acosd(cosd(eta2)*cosd(Length));
    try
        LowerRightRightPoints(i*1-90,:) = [Az,El,1];
    catch
    end
end
% Fourth eighth (lower lower right)
for i = ceil(CornerAzimuths(2)):1:179
    Az = i;
    Length = tand(180-Az)*eta1;
    El = 90-acosd(cosd(eta1)*cosd(Length));
    try
        LowerLowerRightPoints(i*1-floor(CornerAzimuths(2)),:) = [Az,El,1];
    catch
    end
end

% Fifth eighth (lower lower left)
for i = 181:1:floor(CornerAzimuths(3))
    Az = i;
    Length = tand(Az-180)*eta1;
    El = 90-acosd(cosd(eta1)*cosd(Length));
    try
        LowerLowerLeftPoints(i*1-180,:) = [Az,El,1];
    catch
    end
end
% Sixth eighth (lower left left)
for i = ceil(CornerAzimuths(3)):1:269
    Az = i;
    Length = tand(270-Az)*eta2;
    El = 90-acosd(cosd(eta2)*cosd(Length));
    try
        LowerLeftLeftPoints(i*1-floor(CornerAzimuths(3)),:) = [Az,El,1];
    catch
    end
end
% Seventh eighth (upper left left)
for i = 271:1:floor(CornerAzimuths(4))
    Az = i;
    Length = tand(Az-270)*eta2;
    El = 90-acosd(cosd(eta2)*cosd(Length));
    try
        UpperLeftLeftPoints(i*1-270,:) = [Az,El,1];
    catch
    end
end
% Eigth eighth (upper upper left)
for i = ceil(CornerAzimuths(4)):1:359
    Az = i;
    Length = tand(360-Az)*eta1;
    El = 90-acosd(cosd(eta1)*cosd(Length));
    try
        UpperUpperLeftPoints(i*1-floor(CornerAzimuths(4)),:) = [Az,El,1];
    catch
    end
end

% Assemble points into one big array
Points = [MiddlePoints(1,:); UpperUpperRightPoints; CornerPoints(1,:); UpperRightRightPoints;...
    MiddlePoints(2,:); LowerRightRightPoints; CornerPoints(2,:); LowerLowerRightPoints;...
    MiddlePoints(3,:); LowerLowerLeftPoints; CornerPoints(3,:); LowerLeftLeftPoints;...
    MiddlePoints(4,:); UpperLeftLeftPoints; CornerPoints(4,:); UpperUpperLeftPoints];

[RectFOVUnitVectors(:,1),RectFOVUnitVectors(:,2),RectFOVUnitVectors(:,3)] = sph2cart(Points(:,1)*pi/180,Points(:,2)*pi/180,Points(:,3));

end

