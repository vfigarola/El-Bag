%% Victoria Figarola
% This function filters/denoises data

function raw_trial_data = filter_pupil_data(fc,fs,N_TotalTrials,raw_trial_data)

% If there are any NaNs in data, change to zero
for i = 1:N_TotalTrials
    total_nan = find(isnan(raw_trial_data{i,2})==1);
    if isempty(total_nan)
        continue
    else
        for j = 1:length(total_nan)
            raw_trial_data{i,2}(total_nan(j),:) = 0;
        end
    end
end

[b,a] = butter(4,fc/(fs/2));
for i = 1:N_TotalTrials
    if length(unique(raw_trial_data{i,2})) == 1
        raw_trial_data{i,3} = zeros(length(raw_trial_data{i,2}),1);
    else
        raw_trial_data{i,3} = filter(b, a, raw_trial_data{i, 2}); % zero-phase filtering, to avoid time lag
    end
end


