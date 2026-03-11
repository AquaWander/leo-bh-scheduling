function UsrAntennaConfig = initialUsrAntenna()
% INITIALUSRAINTENNA Initialize user antenna configuration
%
% Output:
%   UsrAntennaConfig - Structure containing user antenna parameters
%
% This function returns default configuration for user terminal antennas

UsrAntennaConfig = struct();

% Antenna type
% 1: Omnidirectional (e.g., mobile phone)
% 2: Directional (e.g., VSAT terminal)
UsrAntennaConfig.type = 1;

% Antenna gain (linear scale, not dB)
% Omnidirectional: ~0 dBi = 1.0
% Directional: ~5-10 dBi
UsrAntennaConfig.gain = 1.0;

% Antenna efficiency
UsrAntennaConfig.efficiency = 0.65;

% Noise temperature (K)
UsrAntennaConfig.noiseTemp = 150;

% Noise figure (dB)
UsrAntennaConfig.noiseFigure = 7;

% Transmit power (dBm)
UsrAntennaConfig.txPower_dBm = 23;

% Antenna height above ground (meters)
UsrAntennaConfig.height = 1.5;

% Polarization (1: linear, 2: circular)
UsrAntennaConfig.polarization = 2;

% Whether to consider gravity deformation (0: no, 1: yes)
UsrAntennaConfig.ifDeGravity = 0;

end
