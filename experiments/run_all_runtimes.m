% run_all_runtimes.m
% Run ALL algorithms once and collect runtime + performance data
% Algorithms: TS+SA, Greedy, Greedy+Dist, GA
% Each algorithm runs a full simulation via simController

clear; clc;

%% Setup paths
projectRoot = fullfile(fileparts(mfilename('fullpath')), '..');
cd(projectRoot);
addpath(genpath('.'));

fprintf('========================================================\n');
fprintf('  Runtime Comparison for ALL Algorithms\n');
fprintf('========================================================\n\n');

%% Load configuration
setConfig;

% Algorithm definitions
algo_names = {'TS_SA', 'Greedy', 'GreedyAndDist', 'GA'};
algo_labels = {'TS+SA', 'Greedy', 'Greedy+Dist', 'GA'};
num_algos = length(algo_names);

% Result storage
runtimes = zeros(num_algos, 1);
throughputs = zeros(num_algos, 1);
satisfactions = zeros(num_algos, 1);
success = false(num_algos, 1);

fprintf('Configuration:\n');
fprintf('  - Number of users: %d\n', Config.meanUsrsNum);
fprintf('  - Number of beams: %d\n', Config.numOfServbeam);
fprintf('  - Algorithms to test: %d\n\n', num_algos);

%% Run each algorithm
for a = 1:num_algos
    fprintf('========================================================\n');
    fprintf('  [%d/%d] Running: %s\n', a, num_algos, algo_labels{a});
    fprintf('========================================================\n\n');

    % Set algorithm
    Config.algorithm = algo_names{a};

    tic;
    try
        % Run full simulation
        controller = simSatSysClass.simController(Config, 1, 1, 0);
        DataObj = controller.run();

        runtimes(a) = toc;
        success(a) = true;

        % Calculate KPIs
        KPIs = calcuUserKPIs(DataObj);

        throughputs(a) = KPIs.avg_throughput;
        satisfactions(a) = KPIs.SS_avg;

        fprintf('\n  %s completed in %.2f seconds\n', algo_labels{a}, runtimes(a));
        fprintf('  - Throughput: %.4f Mbps\n', throughputs(a)/1e6);
        fprintf('  - Satisfaction: %.2f%%\n\n', satisfactions(a)*100);

    catch ME
        runtimes(a) = toc;
        fprintf('\n  %s FAILED: %s\n', algo_labels{a}, ME.message);
        fprintf('  Location: %s (line %d)\n\n', ME.stack(1).name, ME.stack(1).line);
    end
end

%% Print Summary Table
fprintf('\n');
fprintf('========================================================\n');
fprintf('  RUNTIME COMPARISON SUMMARY TABLE\n');
fprintf('========================================================\n\n');

fprintf('%-15s %12s %15s %15s %10s\n', ...
    'Algorithm', 'Runtime(s)', 'Throughput(Mbps)', 'Satisfaction(%)', 'Status');
fprintf('%-15s %12s %15s %15s %10s\n', ...
    '---------------', '------------', '---------------', '---------------', '----------');

for a = 1:num_algos
    if success(a)
        status_str = 'OK';
    else
        status_str = 'FAILED';
    end
    fprintf('%-15s %12.2f %15.4f %15.2f %10s\n', ...
        algo_labels{a}, runtimes(a), throughputs(a)/1e6, satisfactions(a)*100, status_str);
end

fprintf('\n');

%% Speedup relative to GA (if both succeeded)
ga_idx = find(strcmp(algo_names, 'GA'), 1);
if ~isempty(ga_idx) && success(ga_idx) && runtimes(ga_idx) > 0
    fprintf('--- Speedup relative to GA ---\n');
    for a = 1:num_algos
        if success(a)
            speedup = runtimes(ga_idx) / runtimes(a);
            fprintf('  %s: %.2fx\n', algo_labels{a}, speedup);
        end
    end
    fprintf('\n');
end

%% Save results
if ~exist('results', 'dir')
    mkdir('results');
end

dateStr = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
results_filename = sprintf('results/runtime_comparison_%s.mat', dateStr);

try
    save(results_filename, 'algo_names', 'algo_labels', 'runtimes', ...
        'throughputs', 'satisfactions', 'success', 'Config', '-v7.3');
    fprintf('Results saved to: %s\n', results_filename);
catch ME
    fprintf('Save failed: %s\n', ME.message);
end

fprintf('\n========================================================\n');
fprintf('  Runtime Comparison Completed!\n');
fprintf('========================================================\n');
