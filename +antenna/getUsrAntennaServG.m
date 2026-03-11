function G = getUsrAntennaServG(angle, freq, type)
% GETUSRANTENNASERVG Calculate user terminal antenna service gain
%
% Inputs:
%   angle - Elevation angle (radians)
%   freq  - Frequency (Hz)
%   type  - Antenna type (1 = omnidirectional, 2 = directional)
%
% Output:
%   G - Antenna gain (linear scale)

if nargin < 3
    type = 1;  % Default to omnidirectional
end

% User terminal antennas typically have low gain (0-5 dBi)
% For simplicity, assume omnidirectional with small gain
G = 1.0;  % 0 dBi (linear scale)

% For directional user terminals (e.g., VSAT)
if type == 2
    % Higher gain but still much less than satellite antenna
    G = 3.16;  % ~5 dBi
    
    % Gain varies with elevation angle
    % At zenith (angle = pi/2), full gain
    % At horizon (angle = 0), reduced gain
    if angle > 0
        elevation_factor = sin(angle);
        G = G * (0.5 + 0.5 * elevation_factor);
    else
        G = 0.1;  % Very low gain for negative elevation
    end
end

end
