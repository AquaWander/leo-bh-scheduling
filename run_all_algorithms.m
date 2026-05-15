% run_all_algorithms.m - Run all algorithms and generate KPI comparison table
% This script runs TS+SA, GA, GBH-AIC, GBH-WIC with identical parameters
% and produces a formatted KPI table for the paper
clear; clc;
addpath(genpath('.'));

fprintf('========================================\n');
fprintf('  Full Algorithm Comparison\n');
fprintf('========================================\n\n');

setConfig;
algorithms = {'SA', 'GA', 'greedy', 'greedyAndDist'};
algo_names = {'Tabu+SA', 'GA', 'GBH-AIC', 'GBH-WIC'};
num_algos = length(algorithms);

results = struct();
for a = 1 : num_algos
    results(a).name = algo_names{a};
    results(a).avg_throughput = NaN;
    results(a).p50_throughput = NaN;
    results(a).p90_throughput = NaN;
    results(a).avg_SINR = NaN;
    results(a).satisfaction = NaN;
    results(a).SSR_90 = NaN;
    results(a).fairness = NaN;
    results(a).runtime = NaN;
end

for a = 1 : num_algos
    fprintf('\n===== Running %s =====\n', algo_names{a});
    cfg = Config;
    cfg.algorithm = algorithms{a};
    cfg.numOfMethods_BeamGenerate = 1;
    cfg.numOfMethods_BeamHopping = 1;
    if strcmp(algorithms{a}, 'SA')
        cfg = rmfield(cfg, 'algorithm');
    end

    tic;
    try
        controller = simSatSysClass.simController(cfg, 1, 1, 0);
        DataObj = controller.run();
        results(a).runtime = toc;

        KPIs = calcuUserKPIs(DataObj);
        results(a).avg_throughput = KPIs.avg_throughput;
        results(a).p50_throughput = KPIs.p50_throughput;
        results(a).p90_throughput = KPIs.p90_throughput;
        results(a).avg_SINR = KPIs.avg_SINR;
        results(a).satisfaction = KPIs.SS_avg * 100;
        results(a).SSR_90 = KPIs.SSR_90 * 100;
        results(a).fairness = KPIs.fairness_index;

        fprintf('  Done (%.1fs): throughput=%.2f Mbps, satisfaction=%.1f%%\n', ...
            results(a).runtime, results(a).avg_throughput, results(a).satisfaction);
    catch ME
        fprintf('  FAILED: %s (line %d)\n', ME.message, ME.stack(1).line);
        results(a).runtime = toc;
    end
end

% Print comparison table
fprintf('\n========================================\n');
fprintf('  KPI Comparison Table\n');
fprintf('========================================\n');
fprintf('%-15s', 'Metric');
for a = 1 : num_algos
    fprintf('%12s', algo_names{a});
end
fprintf('\n');
fprintf('%-15s', 'Avg Thrput(Mbps)');
for a = 1 : num_algos
    fprintf('%12.1f', results(a).avg_throughput);
end
fprintf('\n');
fprintf('%-15s', 'p50 Thrput(Mbps)');
for a = 1 : num_algos
    fprintf('%12.1f', results(a).p50_throughput);
end
fprintf('\n');
fprintf('%-15s', 'p90 Thrput(Mbps)');
for a = 1 : num_algos
    fprintf('%12.1f', results(a).p90_throughput);
end
fprintf('\n');
fprintf('%-15s', 'Avg SINR(dB)');
for a = 1 : num_algos
    fprintf('%12.1f', results(a).avg_SINR);
end
fprintf('\n');
fprintf('%-15s', 'Satisfaction(%%)');
for a = 1 : num_algos
    fprintf('%12.1f', results(a).satisfaction);
end
fprintf('\n');
fprintf('%-15s', 'SSR@90(%%)');
for a = 1 : num_algos
    fprintf('%12.1f', results(a).SSR_90);
end
fprintf('\n');
fprintf('%-15s', 'Fairness');
for a = 1 : num_algos
    fprintf('%12.4f', results(a).fairness);
end
fprintf('\n');
fprintf('%-15s', 'Runtime(s)');
for a = 1 : num_algos
    fprintf('%12.1f', results(a).runtime);
end
fprintf('\n========================================\n');

% Save results
if ~exist('results', 'dir')
    mkdir('results');
end
dateStr = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
save(sprintf('results/full_comparison_%s.mat', dateStr), 'results', '-v7.3');
fprintf('Results saved.\n');
