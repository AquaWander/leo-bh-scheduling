function [x, y, z] = findPointXY(interface, lat, lon)
% FINDPOINTXY Convert latitude/longitude to Cartesian coordinates
%
% Inputs:
%   interface - Interface object containing configuration
%   lat       - Latitude (degrees)
%   lon       - Longitude (degrees)
%
% Outputs:
%   x, y, z - Cartesian coordinates (meters)
%
% This converts geographic coordinates to Earth-Centered Earth-Fixed (ECEF)
% Cartesian coordinates

R_earth = 6371.393e3;  % Earth radius in meters

% Convert to radians
lat_rad = lat * pi / 180;
lon_rad = lon * pi / 180;

% ECEF coordinates (assuming spherical Earth)
x = R_earth * cos(lat_rad) * cos(lon_rad);
y = R_earth * cos(lat_rad) * sin(lon_rad);
z = R_earth * sin(lat_rad);

end
