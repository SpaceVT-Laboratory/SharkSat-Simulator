function [EA] = Kepler(ec,M)
% Jeremy Ogorzalek, 2019

% ~~ Description ~~
% Solves Kepler's equation for eccentric anomaly given eccentricity and
% mean anomaly. This function is used in the conversion between cartesian
% and classical orbital elements

% ~~ Notes ~~
% 

% ~~ Inputs ~~
% ec: Eccentricity of the orbit
% M: Mean anomaly, [deg]

% ~~ Outputs ~~
% EA: Eccentric anomaly, [deg]
% ------------------------------------------------------------------------

    EA = M;
    Mr = M*2*pi()/360;
    kepler_equation = @(EA)EA - ec*sin(EA) - Mr;
    EAr = fzero(kepler_equation, Mr);
    EA = EAr*360/(2*pi());
end

