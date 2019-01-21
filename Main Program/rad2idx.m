% Transform radians to TOMS REFL matrix indices.
%
% [i,j] = rad2idx(theta,phi,sy,sx)
%
% $Id: rad2idx.m,v 1.5 2006/05/17 14:39:18 danji Exp $

function [i,j] = rad2idx(theta,phi,sy,sx);

CONST.d2r = pi/180;

dx = 2*pi/sx;
dy = pi/sy;

i = round((pi-dy/2-phi)/dy)+1;
j = round((theta+pi-dx/2)/dx)+1;

% Fix such that 180/-180 is included in interval.
if i == 0
  i = 1;
end
if j == 0
  j = 1;
end

return
