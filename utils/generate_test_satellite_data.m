function generate_test_satellite_data()
% GENERATE_TEST_SATELLITE_DATA Generate synthetic satellite orbit data for testing
%
% This function creates satellite orbit data with guaranteed coverage of investigation area.
% For actual simulations, use real STK-generated orbit data.
%
% Output:
%   Creates '5400.mat' file with synthetic satellite positions

fprintf('Generating test satellite orbit data...\n');

% Configuration
num_satellites = 54;        % Number of satellites
altitude = 508e3;           % Orbital altitude (m)
earth_radius = 6371.393e3;  % Earth radius (m)
orbital_period = 5683;      % Orbital period (s)
time_step = 1;              % Time step (s)
total_steps = orbital_period + 1;

% Investigation area (from setConfig.m)
target_lon_center = 105;  % Center of [102, 108]
target_lat_center = 28;   % Center of [26, 30]

fprintf('Target area center: [%.1f, %.1f]\n', target_lon_center, target_lat_center);

LLAresult = zeros(num_satellites, total_steps, 2);

% Generate satellite orbits
% We'll place several satellites directly over the target area at t=0
% and let them orbit from there

for sat = 1:num_satellites
    % Distribute satellites across orbital planes
    plane = floor((sat-1) / 9);  % 6 orbital planes with 9 satellites each
    sat_in_plane = mod(sat-1, 9);
    
    % Orbital parameters
    inclination = 53;  % All satellites have same inclination for simplicity
    
    % Spread satellites across different orbital positions
    % First 3 satellites in each plane will pass over target area at different times
    if sat_in_plane < 3
        % These satellites will be positioned to pass through target area
        % Calculate the orbital position that corresponds to target lat/lon
        raan = target_lon_center + plane * 20 - 40;  % Spread in longitude
        
        % Initial mean anomaly to place satellite at target latitude
        % For a given latitude, the mean anomaly is: M = asin(lat / sin(inclination))
        target_lat_rad = target_lat_center * pi / 180;
        inc_rad = inclination * pi / 180;
        mean_anomaly_offset = asin(sin(target_lat_rad) / sin(inc_rad));
        
        % Add offset to spread satellites
        initial_phase = mean_anomaly_offset + sat_in_plane * 0.1;
    else
        % Other satellites spread across the globe
        raan = plane * 60 + sat_in_plane * 20;
        initial_phase = sat_in_plane * (2*pi/9);
    end
    
    % Normalize RAAN to [-180, 180]
    raan = mod(raan + 180, 360) - 180;
    
    for step = 1:total_steps
        time = (step - 1) * time_step;
        mean_anomaly = mod(initial_phase + 2 * pi * time / orbital_period, 2*pi);
        
        % Circular orbit: convert orbital elements to lat/lon
        % Simplified conversion
        lat = asin(sin(inc_rad) * sin(mean_anomaly)) * 180/pi;
        
        % Longitude depends on RAAN and orbital position
        lon = raan + atan2(cos(inc_rad) * sin(mean_anomaly), cos(mean_anomaly)) * 180/pi;
        lon = mod(lon + 180, 360) - 180;
        
        LLAresult(sat, step, 1) = lon;
        LLAresult(sat, step, 2) = lat;
    end
end

% Post-processing: Force first few satellites to be at target area at t=0
% This is a brute-force approach for testing
fprintf('\nAdjusting satellite positions to ensure coverage...\n');
for sat = 1:6  % First 6 satellites
    % Position them in a grid around the target area
    row = floor((sat-1) / 3);
    col = mod(sat-1, 3);
    
    lon_offset = (col - 1) * 2;  % -2, 0, +2 degrees
    lat_offset = (row - 0.5) * 2;  % -1, +1 degrees
    
    base_lon = target_lon_center + lon_offset;
    base_lat = target_lat_center + lat_offset;
    
    % Set position at t=0 and let satellite orbit from there
    % We'll create a simple linear motion for testing
    for step = 1:total_steps
        time = (step - 1) * time_step;
        
        % Simple linear motion (not physically accurate, but good for testing)
        % Satellite moves in longitude direction
        lon_speed = 0.05;  % degrees per second (approximate LEO speed)
        lat_speed = 0.02;  % degrees per second
        
        lon = base_lon + time * lon_speed;
        lat = base_lat + time * lat_speed * sin(time * 2*pi / orbital_period);
        
        % Wrap longitude
        lon = mod(lon + 180, 360) - 180;
        
        LLAresult(sat, step, 1) = lon;
        LLAresult(sat, step, 2) = lat;
    end
    
    fprintf('  Satellite %d: initial position [%.2f, %.2f]\n', sat, ...
        LLAresult(sat, 1, 1), LLAresult(sat, 1, 2));
end

% Verify coverage at t=0
fprintf('\nVerifying coverage at t=0...\n');
target_lon_min = 102; target_lon_max = 108;
target_lat_min = 26; target_lat_max = 30;

visible_count = 0;
for sat = 1:num_satellites
    lon = LLAresult(sat, 1, 1);
    lat = LLAresult(sat, 1, 2);
    
    % Check if satellite is in or near the investigation area
    % Use a larger range for "near" to account for beam footprint
    lon_range = 20;  % degrees
    lat_range = 10;  % degrees
    
    if abs(lon - target_lon_center) < lon_range && abs(lat - target_lat_center) < lat_range
        visible_count = visible_count + 1;
        if visible_count <= 10
            fprintf('  Satellite %d: [%.2f, %.2f] - near target area\n', sat, lon, lat);
        end
    end
end

fprintf('Total satellites near target area: %d\n', visible_count);

% Save to file
save('5400.mat', 'LLAresult');

fprintf('\nTest data generated successfully!\n');
fprintf('  - Number of satellites: %d\n', num_satellites);
fprintf('  - Total time steps: %d\n', total_steps);
fprintf('  - Orbital period: %d seconds\n', orbital_period);
fprintf('  - File saved: 5400.mat\n\n');
fprintf('Note: This is synthetic data optimized for testing.\n');
fprintf('For actual simulations, use real STK-generated orbit data.\n\n');

end
