% run_visualization.m
% Run all visualization scripts

clear; clc;

% Ensure project root is on the path
projectRoot = fullfile(fileparts(mfilename('fullpath')), '..');
cd(projectRoot);
addpath(genpath('.'));

fprintf('=== Running All Visualization Scripts ===\n\n');

% Throughput comparison
fprintf('1. Generating throughput comparison chart...\n');
try
    plot_Throughput_Comparison;
    fprintf('[OK] Throughput comparison chart generated\n\n');
catch ME
    fprintf('  Throughput chart generation failed: %s\n\n', ME.message);
end

% Satisfaction rate comparison
fprintf('2. Generating satisfaction rate comparison chart...\n');
try
    plot_Satisfaction_Rate;
    fprintf('[OK] Satisfaction rate chart generated\n\n');
catch ME
    fprintf('  Satisfaction rate chart generation failed: %s\n\n', ME.message);
end

% SINR CDF comparison
fprintf('3. Generating SINR CDF comparison chart...\n');
try
    plot_SINR_CDF;
    fprintf('[OK] SINR CDF comparison chart generated\n\n');
catch ME
    fprintf('  SINR CDF chart generation failed: %s\n\n', ME.message);
end

% Time comparison
fprintf('4. Generating time comparison chart...\n');
try
    plot_Time_Comparison;
    fprintf('[OK] Time comparison chart generated\n\n');
catch ME
    fprintf('  Time comparison chart generation failed: %s\n\n', ME.message);
end

fprintf('=== Visualization Scripts Completed ===\n');
fprintf('Check the generated images in the visualize/ directory\n');
