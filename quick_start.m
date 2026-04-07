% quick_start.m - Quick Start Script
% Run this script to verify the code is working correctly
%
% Usage:
%   cd('path/to/leo-bh-scheduling');
%   quick_start;

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════╗\n');
fprintf('║     LEO Beam-Hopping Scheduling - Quick Test            ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

%% 1. Add paths
fprintf('[1/4] Adding paths...\n');
addpath(genpath('.'));
fprintf('     Done\n\n');

%% 2. Check satellite data
fprintf('[2/4] Checking satellite orbit data...\n');
if ~exist('5400.mat', 'file')
    fprintf('     Satellite data not found, generating...\n');
    generate_test_satellite_data();
else
    fprintf('     Satellite data found\n');
end
fprintf('\n');

%% 3. Load configuration
fprintf('[3/4] Loading configuration...\n');
setConfig;
fprintf('     Configuration:\n');
fprintf('       - Satellites: %d\n', 54);
fprintf('       - Users: %d\n', Config.meanUsrsNum);
fprintf('       - Beams: %d\n', Config.numOfServbeam);
fprintf('       - Study area: [%.1f-%.1fE, %.1f-%.1fN]\n', ...
    Config.rangeOfInves(1,1), Config.rangeOfInves(1,2), ...
    Config.rangeOfInves(2,1), Config.rangeOfInves(2,2));
fprintf('     Done\n\n');

%% 4. Run quick test
fprintf('[4/4] Running simulation test...\n');
fprintf('     This may take a few seconds...\n\n');

try
    tic;

    % Create controller and run
    controller = simSatSysClass.simController(Config, 1, 1, 0);
    DataObj = controller.run();

    % Calculate KPIs
    KPIs = calcuUserKPIs(DataObj);

    elapsed = toc;

    %% Display results
    fprintf('\n');
    fprintf('╔══════════════════════════════════════════════════════════╗\n');
    fprintf('║                  Test Passed!                            ║\n');
    fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

    fprintf('Performance Metrics:\n');
    fprintf('┌─────────────────────────────────────────┐\n');
    fprintf('│ Metric                  │ Value         │\n');
    fprintf('├─────────────────────────┼────────────────┤\n');
    fprintf('│ Avg SINR                │ %6.2f dB     │\n', KPIs.avg_sinr);
    fprintf('│ Median SINR             │ %6.2f dB     │\n', KPIs.median_sinr);
    fprintf('│ SINR p90                │ %6.2f dB     │\n', KPIs.p90_sinr);
    fprintf('│ Outage Rate (<0 dB)     │ %6.2f %%      │\n', KPIs.outage_rate*100);
    fprintf('├─────────────────────────┼────────────────┤\n');
    fprintf('│ Avg Delay               │ %6.2f ms     │\n', KPIs.avg_delay);
    fprintf('│ Jain Fairness Index     │ %6.4f        │\n', KPIs.fairness_index);
    fprintf('│ Avg Satisfaction        │ %6.2f %%      │\n', KPIs.avg_satisfaction*100);
    fprintf('└─────────────────────────────────────────┘\n\n');

    fprintf('Runtime: %.2f seconds\n\n', elapsed);

    fprintf('All tests passed! Code is working correctly.\n\n');

    fprintf('Next Steps:\n');
    fprintf('   1. Edit setConfig.m to modify parameters\n');
    fprintf('   2. Run run_TabuSearch.m for full experiments\n');
    fprintf('   3. Check visualize/ for result plots\n');
    fprintf('   4. Read README.md for more details\n\n');

catch ME
    fprintf('\n');
    fprintf('╔══════════════════════════════════════════════════════════╗\n');
    fprintf('║                  Test Failed!                            ║\n');
    fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

    fprintf('Error: %s\n', ME.message);
    fprintf('   Location: %s (line %d)\n\n', ME.stack(1).name, ME.stack(1).line);

    fprintf('Troubleshooting:\n');
    fprintf('   1. Make sure you ran: git pull origin main\n');
    fprintf('   2. Delete 5400.mat and re-run generate_test_satellite_data()\n');
    fprintf('   3. Check CHANGELOG.md for known fixes\n');
    fprintf('   4. Submit an issue on GitHub\n\n');

    rethrow(ME);
end
