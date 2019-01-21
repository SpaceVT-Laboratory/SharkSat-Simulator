% Information from TLE
%t0 = 12341.40243075*24*3600 % Epoch/Time, initial (s)
in0 = 67.1494 % Inclination, initial(deg)
O0 = 206.2398 % Right ascension of ascending node, RAAN, initial (deg)
ec0 = 0006511/1e7 % Eccentricity, initial
w0 = 261.0267 % Argument of perigee, initial (deg)
M0 = 99.0085 % Mean anomaly, initial (deg)
npd0 = 13.96674062 % Mean motion, initial (rev/day)

n0 = npd0*(360)/(24*60*60) % Convert units of mean motion to (deg/s)
% M0r = M0*pi()/180 % Convert units of mean anomaly to (rad/s)

% Other relevant parameters already defined
mu = 3.986004418e14 % Mu for Earth = GM, Gravitational Constant * Mass of Earth, (m^3/s^2)
% Re = 6371000 % Radius of Earth (m)
we = 360*(1 + 1/365.25)/(60*60*24) % Rotation rate of Earth (deg/s)
wer = we*(pi()/180) % Rotation rate of Earth (rad/s)

% Start determining other parameters from TLE
EA0 =  Kepler(ec0, M0) % Eccentric anomaly (deg) Call one of the two functions, input eccentricity and mean anomaly in (deg/s)
v0 = 2*atand(sqrt((1+ec0)/(1-ec0))*tand(EA0/2)) % True anomaly (deg)
% v10 = acosd((cosd(EA0)-ec0)/(1-ec0*cosd(EA0))) % needs quadrant check

a0 = (mu/(n0*pi()/180)^2)^(1/3) % Semi-major axis (m)
r0 = a0*(1-ec0*cosd(EA0)) % Radius
h0 = sqrt(mu*a0*(1-ec0^2)) % Specific angular momentum
p0 = r0*(1+ec0*cosd(v0)) % Semilatus rectum
% T = 60*60*24/nd % Period of revolution (s)

% Calculate the initial positions and velocities in cartesian coordinates, Earth
% Centered Inertial coordinate frame
X = r0*(cosd(O0)*cosd(w0+v0)-sind(O0)*sind(w0+v0)*cosd(in0));
Y = r0*(sind(O0)*cosd(w0+v0)+cosd(O0)*sind(w0+v0)*cosd(in0));
Z = r0*(sind(in0)*sind(w0+v0));
Xd = (X*h0*ec0/(r0*p0))*sind(v0)-(h0/r0)*(cosd(O0)*sind(w0+v0)+sind(O0)*cosd(w0+v0)*cosd(in0));
Yd = (Y*h0*ec0/(r0*p0))*sind(v0)-(h0/r0)*(sind(O0)*sind(w0+v0)-cosd(O0)*cosd(w0+v0)*cosd(in0));
Zd = (Z*h0*ec0/(r0*p0))*sind(v0)+(h0/r0)*(sind(in0)*cosd(w0+v0));

State = [X,Y,Z,Xd,Yd,Zd]

format compact
format long

a0
ec0
in0
O0
w0
EA0

% Convert state vector from ECI to ECEF
%t = 12342.40243075*24*3600 % Define end time of measurement period (s)
%T = t - t0 % Elapsed time (s)
%w = wer*T % Angular rotation of the Earth in 
%R_ItoF = [cos(w), sin(w), 0; -sin(w), cos(w), 0; 0, 0, 1]
%StateI = R_ItoF*State 

% Define system of differential equations