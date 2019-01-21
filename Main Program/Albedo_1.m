function [AlbedoPerSide] = Albedo_1(Earth2SunECEF, Earth2SatECEF, RE, SolarIrr, ASat, NormSatECEF)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Calculates the reflected solar irradiance (W/m^2) at a point in space due
% to the Sun's refelction off of the Earth.
% Uses this to calculate the amount of reflected irradiance incident on 
% each side of the satellite(W)
% Assumes all sides reside at same point (one side cannot see further over
% the globe than another).

% ~~ Notes ~~
% This function is to be used only with a 6-sided cube-style
% satellite, and does not take into account any type of self eclipsing
% Vectors need to be in ECEF, as this is how reflectivity data is recorded
% Reflectivity data comes from NASA's TOMS missions

% ~~ Inputs ~~
% Earth2SunECEF: Vector from the Earth to the Sun in ECEF [km]
% Earth2SunECEF: Vector from the Earth to the Satellit in ECEF [km] 
% RE: Circular (average) radius of the Earth [m]
% SolarIrr: Solar irradiance from the Sun on the Earth [W/m^2]
% ASat: Vector of areas of each side of the cube-style satellite [m^2]
% NormSatECEF: Normal vectors for each of the satellites sides in ECEF

% ~~ Outputs ~~
% AlbedoPerSide: Albedo incident on each side of the satellite. [W/m^2]
% ------------------------------------------------------------------------

% Load the average albedo data for the year 2004. This is what will be
% used, as it is the most recent year of data the author could find
 load 'AlbedoAverageValuesData.mat' AlbedoAverageValuesData;

d2r = pi/180; % Factor converting degees to radians

% If row vectors were entered, turn them into column vectors
if length(Earth2SatECEF) > size(Earth2SatECEF,1)
  Earth2SatECEF = Earth2SatECEF';
end
if length(Earth2SunECEF) > size(Earth2SunECEF,1)
  Earth2SunECEF = Earth2SunECEF';
end

% Data size indexing, (should be sy=180 and sx=288)
[sy, sx] = size(AlbedoAverageValuesData);

% Convert the satellite and sun vectors from cartesian to spherical coord
[satsph(1), satsph(2), satsph(3)] = cart2sph(Earth2SatECEF(1),Earth2SatECEF(2),Earth2SatECEF(3));
[sunsph(1), sunsph(2), sunsph(3)] = cart2sph(Earth2SunECEF(1),Earth2SunECEF(2),Earth2SunECEF(3));
% Convert the phi angle in each of the spherical coordinate vectors to 
% polar angle (measured from the North pole down)
satsph(2) = pi/2 - satsph(2);
sunsph(2) = pi/2 - sunsph(2);

% Convert the radian values to NASA TOMS indices (180 by 288)
% (which indices are the sat/sun vectors pointing out of)
[sun_i, sun_j] = rad2idx(sunsph(1),sunsph(2),sy,sx);

% Determine the satellite's field of view of the Earth
SatFOV = zeros(sy,sx);
theta0sat = satsph(1);
phi0sat = satsph(2);

% rhosat is the half-angle of the cone from the center of the Earth that
% defines the circle on the surface of the Earth that is visible to sat
rhosat = acos(RE/satsph(3));
for i = 1:sy
	for j = 1:sx        
		[theta, phi] = idx2rad(i,j,sy,sx);
		% rd is the angular distance of index i,j on the surface of the
		% Earth from the point directly below the satellite
		rd = acos(sin(phi0sat)*sin(phi)*cos(theta0sat-theta)+cos(phi0sat)*cos(phi));
		if rd <= rhosat
			SatFOV(i,j) = 1;
		end
	end
end

% Determine the sunlit area of the Earth
SunFOV = zeros(sy,sx);
theta0sun = sunsph(1);
phi0sun = sunsph(2);
% rhosun is the half-angle of the cone from the center of the Earth that
% defines the circle on the surface of the Earth that is visible to the sun
% should be almost 90 degrees or pi
rhosun = acos(RE/sunsph(3));
for i = 1:sy
	for j = 1:sx        
		[theta,phi] = idx2rad(i,j,sy,sx);
		% rd is the angular distance of index i,j on the surface of the
		% Earth from the point directly below the sun
		rd = acos(sin(phi0sun)*sin(phi)*cos(theta0sun-theta)+cos(phi0sun)*cos(phi));
		if rd <= rhosun
			SunFOV(i,j) = 1;
		end
	end
end

% Determine the sunlight area of the satellite's field of view
union = SatFOV & SunFOV;

index = 1;
% Loop through refl array and select sunlit and satellite visible cells
% for those cells, 
AlbedoIrradiance = zeros(sy,sx);
grid = zeros(3,1);
SatSidesCellAng = zeros(6,1);
Aeff2Cell = zeros(6,1);
AlbedoPerSide = zeros(6,1);
dphi = (180/sy)*d2r;
dtheta = (360/sx)*d2r;
for i=1:sy
    for j=1:sx
        if union(i,j)
            % Determine angle of incident solar irradiance on each index
            [theta1,phi1] = idx2rad(i,j,sy,sx);
            [theta2,phi2] = idx2rad(sun_i,sun_j,sy,sx);
            phi_in = acos(sin(phi1)*sin(phi2)*cos(theta1-theta2)+cos(phi1)*cos(phi2));
            % Account for numerical inaccuracies.
            if phi_in > pi/2
                phi_in = pi/2;
            end
			% Determine the theta and phi of cell i,j
            [theta, phi] = idx2rad(i,j,sy,sx);
            phimax = phi + dphi/2;
            phimin = phi - dphi/2;
            % Calculate the area of the cell i,j
            cellarea = RE^2*dtheta*(cos(phimin)-cos(phimax));
            % How much energy is incident on the cell i,j
			E_in = SolarIrr*cellarea*cos(phi_in);
			% Vector from center of Earth to cell i,j
			[grid(1), grid(2), grid(3)] = sph2cart(theta,pi/2-phi,RE);
            % Distance to sat from cell i,j
			satdist = norm(Earth2SatECEF-grid);
            % Angle between cell to sat vector and cell normal vector
			% phi_out = acos(((Earth2SatECEF-grid)/satdist)'*grid/norm(grid));
            phi_out = acos(dot((Earth2SatECEF-grid),grid)/(norm(Earth2SatECEF-grid)*norm(grid)));
            % Power arriving at satellite from cell i,j
            P_out = E_in*AlbedoAverageValuesData(i,j)*cos(phi_out)/(pi*satdist^2);
            % Store in array
			AlbedoIrradiance(i,j) = P_out;
            
            % Vector from sat to cell i,j, ECEF
            Sat2Cell = grid-Earth2SatECEF;
            % Calculate angle between Sat2Cell and the normal vector for each satellite side. 
            for k = 1:6
                SatSidesCellAng(k,1) = acos(dot(Sat2Cell, NormSatECEF(:,:,k))/(norm(Sat2Cell)*norm(NormSatECEF(:,:,k))));
            end
            % Calculate effective area of each side as seen by cell i,j
            for k = 1:6 
                if cos(SatSidesCellAng(k)) > 0
                    Aeff2Cell(k) = ASat(1,k)*cos(SatSidesCellAng(k,1));
                else
                    Aeff2Cell(k) = 0; % The side is not visible to cell
                end
            end
            for k = 1:6
                AlbedoPerSide(k) = AlbedoPerSide(k)+Aeff2Cell(k)*AlbedoIrradiance(i,j);
            end
            index = index + 1;
        end
    end
end

























































