function [theta, phi] = getPointAngleOfUsr(satPos, satNextPos, usrPos, height)
% GETPOINTANGLEOFSR Calculate the pointing angles from satellite to user
%
% Inputs:
%   satPos     - Current satellite position [lon, lat] (degrees)
%   satNextPos - Next satellite position [lon, lat] (degrees)
%   usrPos     - User position [lon, lat] (degrees)
%   height     - Satellite altitude (meters)
%
% Outputs:
%   theta - Elevation angle (radians)
%   phi   - Azimuth angle (radians)

R_earth = 6371.393e3;  % Earth radius in meters

% Convert to radians
sat_lon = satPos(1) * pi / 180;
sat_lat = satPos(2) * pi / 180;
usr_lon = usrPos(1) * pi / 180;
usr_lat = usrPos(2) * pi / 180;

% Calculate angular distance using Haversine formula
dlon = usr_lon - sat_lon;
dlat = usr_lat - sat_lat;

a = sin(dlat/2)^2 + cos(sat_lat) * cos(usr_lat) * sin(dlon/2)^2;
angular_dist = 2 * asin(sqrt(a));

% Calculate ground distance
ground_dist = R_earth * angular_dist;

% Calculate elevation angle (theta)
if ground_dist > 0
    % Elevation angle from satellite to ground user
    theta = atan(height / ground_dist);
else
    % User is directly below satellite
    theta = pi / 2;
end

% Calculate azimuth angle (phi) using bearing formula
y = sin(dlon) * cos(usr_lat);
x = cos(sat_lat) * sin(usr_lat) - sin(sat_lat) * cos(usr_lat) * cos(dlon);
phi = atan2(y, x);

end
