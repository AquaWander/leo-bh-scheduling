% run_GA.m
% Run Genetic Algorithm baseline and extract KPIs using calcuUserKPIs
clear; clc;

projectRoot = fullfile(fileparts(mfilename('fullpath')), '..');
cd(projectRoot);
addpath(genpath('.'));

fprintf('========================================\n');
fprintf('  Genetic Algorithm Baseline Test\n');
fprintf('========================================\n\n');

setConfig;
Config.algorithm = 'GA';
Config.numOfMethods_BeamGenerate = 1;
Config.numOfMethods_BeamHopping = 1;

num_runs = 1; % reduced for faster initial test
throughputs_GA = zeros(num_runs, 1);
satisfactions_GA = zeros(num_runs, 1);
times_GA = zeros(num_runs, 1);

for run = 1 : num_runs
    fprintf('===== GA Run %d/%d =====\n', run, num_runs);
    tic;
    try
        controller = simSatSysClass.simController(Config, 1, 1, 0);
        DataObj = controller.run();
        times_GA(run) = toc;

        % Extract KPIs using corrected calcuUserKPIs
        KPIs = calcuUserKPIs(DataObj);
        throughputs_GA(run) = KPIs.avg_throughput; % already in Mbps
        satisfactions_GA(run) = KPIs.SS_avg * 100;

        fprintf('GA run %d done (%.2fs): throughput=%.2f Mbps, satisfaction=%.1f%%\n', ...
            run, times_GA(run), throughputs_GA(run), satisfactions_GA(run));

        % Diagnostic: check if results are all zeros
        if throughputs_GA(run) == 0
            fprintf('  WARNING: Throughput is zero. Checking simulation outputs...\n');
            numSnaps = length(DataObj);
            for s = 1 : numSnaps
                numUsrs = DataObj(s).NumOfInvesUsrs;
                numServSat = length(DataObj(s).OrderOfServSatCur);
                fprintf('    Snapshot %d: %d users, %d serving satellites\n', s, numUsrs, numServSat);
                try
                    maxTransport = max(DataObj(s).UsrsTransPort(:));
                    fprintf('    Max UsrsTransPort value: %g\n', maxTransport);
                catch
                    fprintf('    UsrsTransPort not accessible\n');
                end
            end
        end
    catch ME
        fprintf('  Run %d failed: %s\n', run, ME.message);
        fprintf('  Stack: %s (line %d)\n', ME.stack(1).name, ME.stack(1).line);
        times_GA(run) = NaN;
        throughputs_GA(run) = NaN;
        satisfactions_GA(run) = NaN;
    end
end

% Statistics
valid = ~isnan(throughputs_GA);
fprintf('\n========================================\n');
fprintf('  GA Results (%d/%d valid runs)\n', sum(valid), num_runs);
fprintf('========================================\n');
if sum(valid) > 0
    fprintf('Throughput: %.2f +/- %.2f Mbps\n', mean(throughputs_GA(valid)), std(throughputs_GA(valid)));
    fprintf('Satisfaction: %.1f +/- %.1f%%\n', mean(satisfactions_GA(valid)), std(satisfactions_GA(valid)));
    fprintf('Runtime: %.2f +/- %.2f s\n', mean(times_GA(valid)), std(times_GA(valid)));
else
    fprintf('No valid runs completed.\n');
end

% Save
dateStr = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
if ~exist('results', 'dir')
    mkdir('results');
end
save(sprintf('results/results_GA_%s.mat', dateStr), ...
    'throughputs_GA', 'satisfactions_GA', 'times_GA', 'Config', '-v7.3');
fprintf('Results saved.\n');
