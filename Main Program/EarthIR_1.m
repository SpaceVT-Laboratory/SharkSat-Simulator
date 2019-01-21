function [IRPerSide] = EarthIR_1(Earth2SatECEF, NormSatECEF, EarthIRAvg, ASat, RE)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% This function determines the current radiation power indicent on each
% side of the satellite due to Earth's infra-red radiation

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% Earth2SatECEF: Position vector from Earth to satellite in ECEF [km]
% NormSatECEF: Unit vectors of satellite side normal vectors in ECEF
% EarthIRAvg: The average value of Earth's infra-red radiation, [W/m^2]
% ASat: Vector containing the surface areas of each side of the
% satellite, [m^2]
% RE: Mean (circular) radius of the Earth, [m]

% ~~ Outputs ~~
% IRPerSide: Vector containing the power incident on each of the six
% sides of the satellite due to Earth's infra-red radiation, [W]
% ------------------------------------------------------------------------


% The IR from the Earth is between 217 and 261 W/m^2
% We will use the average of 239 W/m^2
d2r = pi/180;
sy = 180;
sx = 288;

[satsph(1), satsph(2), satsph(3)] = cart2sph(Earth2SatECEF(1),Earth2SatECEF(2),Earth2SatECEF(3));
satsph(2) = pi/2 - satsph(2);

SatFOV = zeros(sy,sx);
theta0sat = satsph(1);
phi0sat = satsph(2);

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

IRIrradiance = zeros(sy,sx);
grid = zeros(3,1);
SatSidesCellAng = zeros(6,1);
Aeff2Cell = zeros(6,1);
IRPerSide = zeros(6,1);
dphi = (180/sy)*d2r;
dtheta = (360/sx)*d2r;
for i=1:sy
    for j=1:sx
        if SatFOV(i,j)            
			% Determine the theta and phi of cell i,j
            [theta, phi] = idx2rad(i,j,sy,sx);
            phimax = phi + dphi/2;
            phimin = phi - dphi/2;
            % Calculate the area of the cell i,j
            cellarea = RE^2*dtheta*(cos(phimin)-cos(phimax));
            % IR Radiation coming from each cell
            E_out = cellarea*EarthIRAvg;
			% Vector from center of Earth to cell i,j
			[grid(1), grid(2), grid(3)] = sph2cart(theta,pi/2-phi,RE);
            % Distance to sat from cell i,j
			satdist = norm(Earth2SatECEF'-grid);
            % Angle between cell to sat vector and cell normal vector
			%phi_out = acos(((Earth2SatECEF-grid)/satdist)'*grid/norm(grid));
            phi_out = acos(dot((Earth2SatECEF'-grid),grid)/(norm(Earth2SatECEF'-grid)*norm(grid)));
            % Power arriving at satellite from cell i,j
            P_out = E_out*cos(phi_out)/(pi*satdist^2);
            % Store in array
			IRIrradiance(i,j) = P_out;
            
            % Vector from sat to cell i,j, ECEF
            Sat2Cell = grid-Earth2SatECEF';
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
            %AlbedoPerSide = zeros(1,6);
            for k = 1:6
                IRPerSide(k) = IRPerSide(k)+Aeff2Cell(k)*IRIrradiance(i,j);
            end
        end
    end
end

end

