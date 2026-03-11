% debug_visible_sat.m - Debug script to check VisibleSat calculation
clear; clc;

fprintf('Debugging VisibleSat calculation...\n\n');

% Add paths
addpath(genpath('.'));

% Load configuration
fprintf('[1] Loading configuration...\n');
setConfig;
fprintf('   Configuration loaded successfully\n');
fprintf('   - Simulation duration: %d seconds\n', Config.time);
fprintf('   - Time step: %d seconds\n', Config.step);
fprintf('   - Investigation area: [%.1f, %.1f; %.1f, %.1f]\n', ...
    Config.rangeOfInves(1,1), Config.rangeOfInves(1,2), ...
    Config.rangeOfInves(2,1), Config.rangeOfInves(2,2));
fprintf('   - Number of users: %d\n\n', Config.meanUsrsNum);

% Create controller
fprintf('[2] Creating controller...\n');
controller = simSatSysClass.simController(Config, 1, 1, 0);
fprintf('   Controller created successfully\n\n');

% Check satellite position data
fprintf('[3] Checking satellite position data...\n');
fprintf('   SatPosition size: [%d, %d, %d]\n', size(controller.SatPosition));
fprintf('   First satellite position at step 1: [%.2f, %.2f]\n', ...
    controller.SatPosition(1, 1, 1), controller.SatPosition(1, 1, 2));
fprintf('   Number of time steps: %d\n\n', size(controller.SatPosition, 2));

% Initialize areas (simulate run() initialization)
fprintf('[4] Initializing areas...\n');
if controller.Config.ifWrapAround == 1
    controller.findWrap();
    fprintf('   WrapAround completed\n');
end

controller.DiscrInvesArea();
fprintf('   Area discretization completed\n');
fprintf('   DiscrArea size: [%d, %d, %d]\n', size(controller.DiscrArea));

if controller.Config.ifWrapAround == 1
    controller.getDiscrInNonWrap();
    fprintf('   Core area discretization completed\n');
end
fprintf('\n');

% Calculate visible satellites
fprintf('[5] Calculating visible satellites...\n');
controller.calcuVisibleSat();
fprintf('   VisibleSat calculation completed\n');
fprintf('   VisibleSat size: [%d, %d, %d]\n\n', size(controller.VisibleSat));

% Check visible satellites at first time step
fprintf('[6] Checking visible satellites at time step 1...\n');
NumOfSat = size(controller.VisibleSat, 1);
visible_count = 0;
for i = 1 : NumOfSat
    if controller.VisibleSat(i, 1, 1) ~= 500
        visible_count = visible_count + 1;
        fprintf('   Satellite %d: [%.2f, %.2f]\n', i, ...
            controller.VisibleSat(i, 1, 1), controller.VisibleSat(i, 1, 2));
    end
end
fprintf('   Total visible satellites: %d / %d\n\n', visible_count, NumOfSat);

if visible_count == 0
    fprintf('WARNING: No visible satellites found!\n');
    fprintf('This could be due to:\n');
    fprintf('  1. Satellite orbit data does not cover the investigation area\n');
    fprintf('  2. Beam scanning range is too narrow\n');
    fprintf('  3. Configuration parameters are incorrect\n\n');
    
    fprintf('Checking satellite positions vs investigation area:\n');
    fprintf('Investigation area: lon [%.1f, %.1f], lat [%.1f, %.1f]\n', ...
        Config.rangeOfInves(1,1), Config.rangeOfInves(1,2), ...
        Config.rangeOfInves(2,1), Config.rangeOfInves(2,2));
    
    for i = 1 : min(5, NumOfSat)
        fprintf('Satellite %d at step 1: lon=%.2f, lat=%.2f\n', i, ...
            controller.SatPosition(i, 1, 1), controller.SatPosition(i, 1, 2));
    end
end
