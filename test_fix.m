% test_fix.m - Test the fix for VisibleSat initialization issue
clear; clc;

fprintf('Testing the fix...\n\n');

% Add paths
addpath(genpath('.'));

% Load configuration
fprintf('[1] Loading configuration...\n');
setConfig;
fprintf('   Configuration loaded successfully\n');
fprintf('   - Simulation duration: %d seconds\n', Config.time);
fprintf('   - Time step: %d seconds\n', Config.step);
fprintf('   - Number of users: %d\n\n', Config.meanUsrsNum);

% Run simulation
fprintf('[2] Creating controller and running simulation...\n');
try
    controller = simSatSysClass.simController(Config, 1, 1, 0);
    fprintf('   Controller created successfully\n');
    
    DataObj = controller.run();
    fprintf('   Simulation completed successfully!\n\n');
    
    % Calculate KPIs
    fprintf('[3] Calculating KPIs...\n');
    KPIs = calcuUserKPIs(DataObj);
    
    fprintf('\n========================================\n');
    fprintf('   Test PASSED! Fix is working correctly.\n');
    fprintf('========================================\n\n');
    
catch ME
    fprintf('\n========================================\n');
    fprintf('   Test FAILED!\n');
    fprintf('========================================\n\n');
    fprintf('Error: %s\n', ME.message);
    fprintf('File: %s\n', ME.stack(1).name);
    fprintf('Line: %d\n', ME.stack(1).line);
    rethrow(ME);
end
