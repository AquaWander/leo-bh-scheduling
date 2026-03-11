function angle_3dB = find3dBAgle(freq)
% FIND3DBAGLE Calculate the 3dB beamwidth angle for satellite antenna
%
% Input:
%   freq - Frequency in Hz
%
% Output:
%   angle_3dB - 3dB beamwidth angle in radians
%
% This is a simplified model for beam half-power beamwidth
% Real values should come from antenna specifications

% For LEO satellite communications, typical 3dB beamwidth
% depends on frequency band and antenna design
% This is an approximation

freq_GHz = freq / 1e9;  % Convert to GHz

% Simple empirical formula (this is an approximation)
% Typical Ka-band (20-30 GHz): ~1-3 degrees
% Typical Ku-band (12-18 GHz): ~2-4 degrees
% Typical S-band (2-4 GHz): ~5-10 degrees

if freq_GHz >= 20
    % Ka-band
    angle_deg = 2.5;
elseif freq_GHz >= 12
    % Ku-band
    angle_deg = 3.5;
elseif freq_GHz >= 2
    % S-band
    angle_deg = 6;
else
    % Default
    angle_deg = 5;
end

% Convert to radians
angle_3dB = angle_deg * pi / 180;

end
