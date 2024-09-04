%% Victoria Figarola
% This script normalizes the pupil data by subtracting the mean pupil
% dilation in the baseline period by the raw trial data, divided by the
% variance of the baseline period 
% the baseline period is 200ms before the onset of the cue 

function [uninter_data_norm,inter_data_norm,baseline_period_avg] = normalize_pupil_data(fs,N_EnvTrials,uninter_data,inter_data,N_samples)
% get time_btw_trigs 
% N_samples = N_samples_anech;

t = 0:1/fs:(N_samples-1)/fs;
t = t - 1;

[~,close] = min(abs(t+0.2));
baseline_idx = [close find(t==0)]; %baseline period (-200ms to 0s)

% uninter_data = analysis.P008.anech_pupil_uninter;
% inter_data = analysis.P008.anech_pupil_inter;

% if strcmp(new_field_name,"P008")
%     inter_data(:,17) = 0;
% end

combined_data = [uninter_data inter_data];

for i = 1:N_EnvTrials
    baseline_period_data(:,i) = combined_data(baseline_idx(1):baseline_idx(2)-1,i);
    baseline_period_avg(:,i) = mean(baseline_period_data(:,i),1);
    baseline_period_std(:,i) = std(baseline_period_data(:,i));

  
    % normalizing_data(:,i) = (combined_data(:,i) - mean(baseline_period_data(:,i),1)) / (std(baseline_period_data(:,i))) ;
end
for i = 1:N_EnvTrials
    normalizing_data_v2(:,i) = (combined_data(:,i) - mean(baseline_period_avg,2)) / (std(baseline_period_std,[],2)) ;
end

uninter_data_norm = normalizing_data_v2(:,1:40);
inter_data_norm = normalizing_data_v2(:,41:end);

uninter_data_norm = find_nan_in_data(uninter_data_norm);
inter_data_norm = find_nan_in_data(inter_data_norm);

baseline_period_avg = mean(baseline_period_avg,2);

%%
% uninter_data_norm = normalizing_data(:,1:40);
% inter_data_norm = normalizing_data(:,41:end);
% 
% uninter_data_norm = find_nan_in_data(uninter_data_norm);
% inter_data_norm = find_nan_in_data(inter_data_norm);

% sum over threshold (3*std) and if it's 
