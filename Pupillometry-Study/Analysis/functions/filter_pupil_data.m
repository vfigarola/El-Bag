%% Victoria Figarola
% This function filters/denoises data

function raw_trial_data = filter_pupil_data(fc,fs,N_TotalTrials,raw_trial_data)

[b,a] = butter(4,fc/(fs/2));
for i = 1:N_TotalTrials
    if length(unique(raw_trial_data{i,3})) == 1
        raw_trial_data{i,4} = zeros(length(raw_trial_data{i,3}),1);
    else
        raw_trial_data{i,4} = filtfilt(b, a, raw_trial_data{i, 3}); % zero-phase filtering, to avoid time lag
    end
end