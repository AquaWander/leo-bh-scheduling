% calcuKPIs_direct.m
% Direct KPI calculation from DataObj raw data (bypasses calcuUserKPIs)
% Uses InterfFromAll_Down SINR data and UsrsTraffic

function [throughput_Mbps, satisfaction_pct] = calcuKPIs_direct(DataObj, Config)

Band = Config.BandOfLink * 1e6;  % Hz
bhTime = Config.bhTime;
numSlots = Config.SlotInSche;

numSnapshots = length(DataObj);
total_capacity = 0;
total_requested = 0;
total_served = 0;
total_users = 0;

for s = 1 : numSnapshots
    numUsrs = DataObj(s).NumOfInvesUsrs;
    total_users = total_users + numUsrs;

    % Requested traffic per user
    requested = DataObj(s).UsrsTraffic(1:numUsrs, 1);
    total_requested = total_requested + sum(requested(requested > 0));

    % SINR data: InterfFromAll_Down(method, slot, user, 2) = C/(I+N) linear
    sinr_data = squeeze(DataObj(s).InterfFromAll_Down(1, :, 1:numUsrs, 2));
    % sinr_data is (numSlots x numUsrs)

    for u = 1 : numUsrs
        % Average SINR across time slots for this user
        user_sinr = sinr_data(:, u);
        user_sinr = user_sinr(user_sinr > 0);  % remove zero/negative
        if ~isempty(user_sinr)
            avg_sinr = mean(user_sinr);
            % Shannon capacity for this user
            capacity = Band * log2(1 + avg_sinr) * bhTime;
            served = min(capacity, requested(u));
        else
            served = 0;
        end
        total_served = total_served + served;
        total_capacity = total_capacity + (Band * log2(1 + mean(max(sinr_data(:,u),0)))) * bhTime;
    end
end

throughput_Mbps = total_capacity / total_users / 1e6;
satisfaction_pct = (total_served / total_requested) * 100;

end
