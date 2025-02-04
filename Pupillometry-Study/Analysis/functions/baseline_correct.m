%% Victoria Figarola
% this function baseline corrects the data that was normalized to the
% dynamic range


function [uninter_data,inter_data] = baseline_correct(N_samples,fs,N_EnvTrials,combined_data)

t = 0:1/fs:(N_samples-1)/fs;
t = t - 1;

[~,close] = min(abs(t+0.2));
baseline_idx = [close find(t==0)]; %baseline period (-200ms to 0s)

for i = 1:N_EnvTrials
    baseline_period_data(:,i) = combined_data(baseline_idx(1):baseline_idx(2)-1,i);
    baseline_period_avg(:,i) = mean(baseline_period_data(:,i),1);
    baseline_period_std(:,i) = std(baseline_period_data(:,i));
end

for i = 1:N_EnvTrials
    baselined_data(:,i) = (combined_data(:,i) - mean(baseline_period_avg,2));
end

uninter_data = baselined_data(:,1:40);
inter_data = baselined_data(:,41:end);
