%% Victoria Figarola
% This function determines how many blinks occur within each trial

function [blink_time_idx,blink_count] = find_blink_count(empty_trials_idx,blink_time_idx,N_TotalTrials)

for i = 1:N_TotalTrials
    if ismember(i,empty_trials_idx) %don't count how many blinks there are
        %let's find the rows that contain the trial
        blink_trial_idx = find(blink_time_idx(:,3)==i);
        blink_time_idx(blink_trial_idx,1:2) = NaN; %now let's remove those rows
        blink_count(i,:) = NaN;

    else %then count the amount of blinks
        blink_count(i,:) = sum(blink_time_idx(:,3)==i); 
    end
end