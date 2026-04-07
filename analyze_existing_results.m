%% Analyze Existing Experiment Results
% Extract performance metrics from saved result files
% Author: 2026-03-04

clear; clc; close all;

addpath(genpath('.'));

fprintf('========================================\n');
fprintf(' Analyze Existing Experiment Results\n');
fprintf('========================================\n\n');

%% Load TabuSearch results
fprintf('[1] Loading TabuSearch results...\n');
try
    load('results/results_TabuSearch.mat', 'results_Tabu', 'throughputs_Tabu', 'satisfactions_Tabu');
    fprintf('  OK: TabuSearch results loaded\n');

    if exist('throughputs_Tabu', 'var')
        fprintf('  - Throughput data: %d runs\n', length(throughputs_Tabu));
        fprintf('  - Average throughput: %.2f Mbps\n', mean(throughputs_Tabu(~isnan(throughputs_Tabu))));
    end
    if exist('satisfactions_Tabu', 'var')
        fprintf('  - Average satisfaction rate: %.2f%%\n', mean(satisfactions_Tabu(~isnan(satisfactions_Tabu)))*100);
    end
catch ME
    fprintf('  ERROR: %s\n', ME.message);
end

fprintf('\n');

%% Load DQN results
fprintf('[2] Loading DQN results...\n');
try
    load('results/results_DQN.mat', 'results_DQN', 'throughputs_DQN', 'satisfactions_DQN');
    fprintf('  OK: DQN results loaded\n');

    if exist('throughputs_DQN', 'var')
        fprintf('  - Throughput data: %d runs\n', length(throughputs_DQN));
        fprintf('  - Average throughput: %.2f Mbps\n', mean(throughputs_DQN(~isnan(throughputs_DQN))));
    end
    if exist('satisfactions_DQN', 'var')
        fprintf('  - Average satisfaction rate: %.2f%%\n', mean(satisfactions_DQN(~isnan(satisfactions_DQN)))*100);
    end
catch ME
    fprintf('  ERROR: %s\n', ME.message);
end

fprintf('\n');

%% Load DataObj result
fprintf('[3] Loading DataObj...\n');
try
    load('DataObj.mat', 'DataObj');
    fprintf('  OK: DataObj loaded\n');

    if isfield(DataObj, 'InterfFromAll_Down')
        [num_methods, num_slots, num_users, ~] = size(DataObj.InterfFromAll_Down);
        fprintf('  - Methods: %d\n', num_methods);
        fprintf('  - Time slots: %d\n', num_slots);
        fprintf('  - Users: %d\n', num_users);

        sinr_data = squeeze(DataObj.InterfFromAll_Down(:, :, :, 2));
        avg_sinr = mean(sinr_data(:), 'omitnan');
        fprintf('  - Average SINR: %.2f dB\n', avg_sinr);
    end

    if isfield(DataObj, 'UsrsTraffic') && isfield(DataObj, 'UsrsTransPort')
        demand = DataObj.UsrsTraffic(:, 1) + sum(DataObj.UsrsTraffic(:, 2:end), 2);
        transport = squeeze(sum(DataObj.UsrsTransPort, 3));

        if ~isempty(transport)
            satisfaction = mean(transport ./ demand', 'omitnan');
            fprintf('  - Traffic satisfaction rate: %.2f%%\n', satisfaction * 100);
        end
    end
catch ME
    fprintf('  ERROR: %s\n', ME.message);
end

fprintf('\n');

%% Generate comparison charts
fprintf('[4] Generating comparison charts...\n');

figure('Position', [100, 100, 1000, 400]);

% Subplot 1: Throughput comparison
subplot(1, 2, 1);
if exist('throughputs_Tabu', 'var') && exist('throughputs_DQN', 'var')
    tabu_avg = mean(throughputs_Tabu(~isnan(throughputs_Tabu)));
    dqn_avg = mean(throughputs_DQN(~isnan(throughputs_DQN)));
    bar([tabu_avg, dqn_avg]);
    set(gca, 'XTickLabel', {'Tabu Search', 'DQN'});
    ylabel('Throughput (Mbps)');
    title('Throughput Comparison');
    grid on;
    text(1, tabu_avg*1.02, sprintf('%.2f', tabu_avg), 'HorizontalAlignment', 'center');
    text(2, dqn_avg*1.02, sprintf('%.2f', dqn_avg), 'HorizontalAlignment', 'center');
else
    text(0.5, 0.5, 'Data not available', 'HorizontalAlignment', 'center');
end

% Subplot 2: Satisfaction rate comparison
subplot(1, 2, 2);
if exist('satisfactions_Tabu', 'var') && exist('satisfactions_DQN', 'var')
    tabu_sat = mean(satisfactions_Tabu(~isnan(satisfactions_Tabu)))*100;
    dqn_sat = mean(satisfactions_DQN(~isnan(satisfactions_DQN)))*100;
    bar([tabu_sat, dqn_sat], 'FaceColor', [0.8, 0.4, 0.4]);
    set(gca, 'XTickLabel', {'Tabu Search', 'DQN'});
    ylabel('Satisfaction Rate (%)');
    title('Satisfaction Rate Comparison');
    grid on;
    text(1, tabu_sat*1.02, sprintf('%.2f%%', tabu_sat), 'HorizontalAlignment', 'center');
    text(2, dqn_sat*1.02, sprintf('%.2f%%', dqn_sat), 'HorizontalAlignment', 'center');
else
    text(0.5, 0.5, 'Data not available', 'HorizontalAlignment', 'center');
end

% Save
if ~exist('results', 'dir')
    mkdir('results');
end
saveas(gcf, 'results/existing_results_comparison.png');
fprintf('  OK: Saved to results/existing_results_comparison.png\n\n');

fprintf('========================================\n');
fprintf(' Analysis Complete!\n');
fprintf('========================================\n\n');
