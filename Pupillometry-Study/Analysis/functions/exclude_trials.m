%% Victoria Figarola
% This function removes the trials that have >50% of the data missing

function data = exclude_trials(exclude_trials_idx,trial_info,data,remove_data)
[~,trial_to_remove] = ismember(exclude_trials_idx,trial_info);

if remove_data == 1 %removing columns
    data(:,trial_to_remove(trial_to_remove~=0)) = 0;
elseif remove_data == 2 %removing rows (mainly for blink_count)
    data(trial_to_remove(trial_to_remove~=0),:) = [];
end