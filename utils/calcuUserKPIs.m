function KPIs = calcuUserKPIs(DataObj)
% Calculate user-centric KPIs from DataObj struct array
% Input: DataObj - struct array from simulation (one element per snapshot)
% Output: KPIs structure with throughput, SINR, satisfaction metrics

KPIs = struct();

numSnapshots = length(DataObj);

% Aggregation arrays
all_user_throughput = [];
all_user_satisfaction = [];
all_SINRs_dB = [];
total_requested = 0;
total_served = 0;

for s = 1 : numSnapshots
    numUsrs = DataObj(s).NumOfInvesUsrs;

    % UsrsTransPort: (numMethods × numUsrs × scheInShot)
    % Select method 1, sum across scheduling periods
    try
        tp = DataObj(s).UsrsTransPort;
        served_per_user = sum(tp(1, 1:numUsrs, :), 3);
        served_per_user = served_per_user(:); % ensure column vector
    catch
        served_per_user = zeros(numUsrs, 1);
    end

    % UsrsTraffic: (numUsrs × (scheInShot+1))
    % Column 1 = initial traffic, columns 2:end = new traffic per period
    try
        tf = DataObj(s).UsrsTraffic;
        requested_per_user = sum(tf(1:numUsrs, :), 2);
        requested_per_user = requested_per_user(:); % ensure column vector
    catch
        requested_per_user = zeros(numUsrs, 1);
    end

    % Per-user throughput (bits)
    all_user_throughput = [all_user_throughput; served_per_user];

    % Per-user satisfaction ratio (capped at 1.0)
    sat_ratio = ones(numUsrs, 1);
    has_demand = requested_per_user > 0;
    sat_ratio(has_demand) = min(served_per_user(has_demand) ./ requested_per_user(has_demand), 1);
    all_user_satisfaction = [all_user_satisfaction; sat_ratio];

    % Aggregate for overall satisfaction
    total_requested = total_requested + sum(requested_per_user);
    total_served = total_served + sum(min(served_per_user, requested_per_user));

    % SINR from InterfFromAll_Down: (numMethods × numSlots × numUsrs × 2)
    % (:,:,:,1) = C/(I+N) in linear
    try
        interf = DataObj(s).InterfFromAll_Down;
        if any(interf(:) > 0)
            sinr_data = squeeze(interf(1, :, 1:numUsrs, 2));
            sinr_pos = sinr_data(sinr_data > 0);
            if ~isempty(sinr_pos)
                all_SINRs_dB = [all_SINRs_dB; 10 * log10(sinr_pos)];
            end
        end
    catch
        % InterfFromAll_Down not available
    end
end

%% 1. Throughput Metrics
% all_user_throughput is in bits; simulation duration per snapshot = 40ms
simDuration_s = 40e-3; % seconds
throughput_bps = all_user_throughput / simDuration_s; % bits/s
throughput_Mbps = throughput_bps / 1e6; % Mbps
KPIs.avg_throughput = mean(throughput_Mbps);
KPIs.p50_throughput = prctile(throughput_Mbps, 50);
KPIs.p90_throughput = prctile(throughput_Mbps, 90);
KPIs.p95_throughput = prctile(throughput_Mbps, 95);
KPIs.min_throughput = min(throughput_Mbps);
KPIs.max_throughput = max(throughput_Mbps);

%% 2. SINR Metrics
if ~isempty(all_SINRs_dB)
    KPIs.avg_SINR = mean(all_SINRs_dB);
    KPIs.p50_SINR = prctile(all_SINRs_dB, 50);
    KPIs.p90_SINR = prctile(all_SINRs_dB, 90);
    KPIs.outage_rate = sum(all_SINRs_dB < 0) / length(all_SINRs_dB);
else
    KPIs.avg_SINR = NaN;
    KPIs.p50_SINR = NaN;
    KPIs.p90_SINR = NaN;
    KPIs.outage_rate = NaN;
end

%% 3. Satisfaction Metrics
KPIs.SS_avg = mean(all_user_satisfaction);
KPIs.SSR_80 = mean(all_user_satisfaction >= 0.8);
KPIs.SSR_90 = mean(all_user_satisfaction >= 0.9);
KPIs.SSR_95 = mean(all_user_satisfaction >= 0.95);

% Overall satisfaction (total served / total requested)
if total_requested > 0
    KPIs.overall_satisfaction = total_served / total_requested;
else
    KPIs.overall_satisfaction = NaN;
end

%% 4. Fairness (Jain's Index based on satisfaction ratios)
n = length(all_user_satisfaction);
sum_x = sum(all_user_satisfaction);
sum_x_sq = sum(all_user_satisfaction.^2);
if sum_x_sq > 0
    KPIs.fairness_index = (sum_x^2) / (n * sum_x_sq);
else
    KPIs.fairness_index = 1;
end

%% 5. Report
fprintf('\n========================================\n');
fprintf('     User-Centric KPI Report\n');
fprintf('========================================\n\n');
fprintf('[Throughput Metrics]\n');
fprintf('  Average:        %10.2f Mbps\n', KPIs.avg_throughput);
fprintf('  Median (p50):   %10.2f Mbps\n', KPIs.p50_throughput);
fprintf('  p90:            %10.2f Mbps\n', KPIs.p90_throughput);
fprintf('  p95:            %10.2f Mbps\n', KPIs.p95_throughput);
fprintf('\n');
fprintf('[SINR Metrics]\n');
fprintf('  Average:        %10.2f dB\n', KPIs.avg_SINR);
fprintf('  p90:            %10.2f dB\n', KPIs.p90_SINR);
fprintf('  Outage (<0dB):  %10.2f%%\n', KPIs.outage_rate*100);
fprintf('\n');
fprintf('[Satisfaction Metrics]\n');
fprintf('  Avg Satisfaction: %10.2f%%\n', KPIs.SS_avg*100);
fprintf('  SSR@80%%:        %10.2f%%\n', KPIs.SSR_80*100);
fprintf('  SSR@90%%:        %10.2f%%\n', KPIs.SSR_90*100);
fprintf('  Overall:        %10.2f%%\n', KPIs.overall_satisfaction*100);
fprintf('\n');
fprintf('[Fairness]\n');
fprintf('  Jain Index:     %10.4f\n', KPIs.fairness_index);
fprintf('========================================\n\n');

end
