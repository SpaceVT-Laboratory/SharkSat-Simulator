function [OE, GregorianDateElements, L2c, L3c] = Read_TLE(fname)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function reads in a TLE file and converts it to classical orbital
% elements

% ~~ Notes ~~
% The TLE file must be in the current directory, and should be in the same
% format as shown in the example TLE file named 'TLEexample.txt'

% ~~ Inputs ~~
% fname: A vector of characters or a string containing the name of the text 
% file withe the TLE

% ~~ Outputs ~~
% OE: Vector of the six classical orbital elements, 
% GregorianDateElements: Vector containing the gregorian date and time
% elements
% L2c: Characters of the 2nd line of the TLE (3 line version)
% L3c: Characters of the 3rd line of the TLE (3 line version)
% ------------------------------------------------------------------------


mu = 398600; %  Standard gravitational parameter for the earth
% TLE file name 
% fname = 'TLEexample.txt';
% Open the TLE file and read TLE elements
fid = fopen(fname, 'rb');
L1c = fscanf(fid,'%24c%',1);
fscanf(fid,'%2c%',1);
L2c = fscanf(fid,'%69c%',1);
fscanf(fid,'%2c%',1);
L3c = fscanf(fid,'%69c%',1);
fprintf(L1c);
fprintf(L2c);
fprintf([L3c,'\n']);
fclose(fid);
% Open the TLE file and read TLE elements
fid = fopen(fname, 'rb');
L1 = fscanf(fid,'%24c%*s',1);
L2 = fscanf(fid,'%d%6d%*c%5d%*3c%*2f%f%f%5d%*c%*d%5d%*c%*d%d%5d',[1,9]);
L3 = fscanf(fid,'%d%6d%f%f%f%f%f%f%f',[1,8]);
fclose(fid);

epoch = L2c(21:34);
Db    = L2(1,5);                % Ballistic Coefficient
inc   = L3(1,3);                % Inclination [deg]
RAAN  = L3(1,4);                % Right Ascension of the Ascending Node [deg]
e     = L3(1,5)/1e7;            % Eccentricity 
w     = L3(1,6);                % Argument of periapsis [deg]
M     = L3(1,7);                % Mean anomaly [deg]
n     = L3(1,8);                % Mean motion [Revs per day]


% Converting to Gregorian Date elements
Year = str2double(epoch(1:2));
doy = str2double(epoch(3:end));
if Year >= 57
    Year = Year + 1900;
else
    Year = Year + 2000;
end
[yy, mm, dd, HH, MM, SS] = datevec(datenum(Year,1,doy));
GregorianDateElements = [yy, mm, dd, HH, MM, SS];
   
% Calculating remaining orbital elements
a = (mu/(n*2*pi/(24*3600))^2)^(1/3);     % Semi-major axis [km]    
% Calculate the eccentric anomaly using Mean anomaly
err = 1e-10;            %Calculation Error
E0 = M; t =1;
itt = 0;
while(t) 
       E =  M + e*sind(E0);
      if ( abs(E - E0) < err)
          t = 0;
      end
      E0 = E;
      itt = itt+1;
end

v = acosd((cosd(E)-e)/(1-e*cosd(E)));

% Six orbital elements 
OE = [a, e, inc, RAAN, w, v];