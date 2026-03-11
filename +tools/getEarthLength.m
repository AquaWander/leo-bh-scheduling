function length_on_earth = getEarthLength(angle_rad, height)
% GETEARTHLENGTH Calculate the length on Earth's surface for a given angle from satellite
%
% Inputs:
%   angle_rad - Angle in radians (e.g., beam half-angle)
%   height    - Satellite altitude (meters)
%
% Output:
%   length_on_earth - Length on Earth's surface (meters)
%
% This calculates the diameter of the coverage area on Earth's surface
% for a given beam angle from the satellite

R_earth = 6371.393e3;  % Earth radius in meters

% Calculate the distance from satellite to Earth surface point
% Using simple trigonometry for small angles
% For a cone with half-angle 'angle_rad' from satellite at height 'height'
% The diameter on Earth's surface is approximately 2 * height * tan(angle_rad)

length_on_earth = 2 * height * tan(angle_rad / 2);

end
