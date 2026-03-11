function G = getSatAntennaServG(angleOfInv, angleOfPoi, freq)
% GETSATANTENNASERVG Calculate satellite antenna service gain
%
% Inputs:
%   angleOfInv - Angle of incidence [theta, phi] (radians)
%   angleOfPoi - Angle of pointing [alpha, beta] (radians)
%   freq       - Frequency (Hz)
%
% Output:
%   G - Antenna gain (linear scale, not dB)
%
% This uses a simplified antenna pattern model for satellite communications

% Speed of light
c = 3e8;

% Wavelength
lambda = c / freq;

% Typical satellite antenna parameters
% Assuming a parabolic dish antenna with diameter ~0.5m
D = 0.5;  % Antenna diameter in meters

% Calculate antenna efficiency (typical value 0.55-0.75)
eta = 0.65;

% Calculate maximum gain (on-axis)
G_max = eta * (pi * D / lambda)^2;

% Calculate 3dB beamwidth (half-power beamwidth)
theta_3dB = 1.22 * lambda / D;  % in radians

% Calculate off-axis angle
theta_inv = angleOfInv(1);  % Elevation
phi_inv = angleOfInv(2);    % Azimuth
theta_poi = angleOfPoi(1);  % Pointing elevation
phi_poi = angleOfPoi(2);    % Pointing azimuth

% Angular separation between incident direction and pointing direction
delta_theta = theta_inv - theta_poi;
delta_phi = phi_inv - phi_poi;

% Off-axis angle (simplified)
off_axis = sqrt(delta_theta^2 + delta_phi^2);

% Antenna pattern model using Gaussian approximation
% G(theta) = G_max * exp(-2.77 * (theta/theta_3dB)^2)
if off_axis < 3 * theta_3dB
    % Main lobe region
    G = G_max * exp(-2.77 * (off_axis / theta_3dB)^2);
else
    % Side lobe region (simplified model)
    % Typical side lobe level is -20 to -30 dB below main lobe
    G = G_max * 0.01;  % -20 dB
end

end
