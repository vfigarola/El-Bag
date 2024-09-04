%% Victoria Figarola
% this script grabs the pupil reactivity to white and black screens for
% each subject, following the same preprocessing as pupil_analysis_v2

function [white_raw_dynamic_range_data,black_raw_dynamic_range_data ] = grab_pupil_reactivity_data(N_TotalTrials,events,data,fs,N_dynamic_range_trials,preBlink,postBlink,subj_ID,fc)
%%%%%%%%%%% import data to find dynamic range trial onsets
[whitedisplay_idx,~,whitedisplay_time_idx,blackdisplay_time_idx,time_stamps]= dynamic_range_trial_indices(N_TotalTrials,events,data,fs);

white_raw_dynamic_range_data = cell(N_dynamic_range_trials,1); %column 1 = white display; column 2 = black display
for i = 1:N_dynamic_range_trials
    data_col = double(data.Var4);
    white_raw_dynamic_range_data{i,1} = data_col(whitedisplay_time_idx(i,1):whitedisplay_time_idx(i,2),:);
end

black_raw_dynamic_range_data = cell(N_dynamic_range_trials,1); %column 1 = white display; column 2 = black display
for i = 1:N_dynamic_range_trials
    black_raw_dynamic_range_data{i,1} = data_col(blackdisplay_time_idx(i,1):blackdisplay_time_idx(i,2),:);
end

% Let's find the blinks
[white_display_blink_time_idx,black_display_blink_time_idx] = find_blinks_dynamicrange(events,whitedisplay_idx,preBlink,postBlink,time_stamps,whitedisplay_time_idx,blackdisplay_time_idx);

% now let's interpolate those blinks! 
white_raw_dynamic_range_data = interpolate_dynamicrange(subj_ID,white_raw_dynamic_range_data,whitedisplay_time_idx,data_col,time_stamps,white_display_blink_time_idx);
black_raw_dynamic_range_data = interpolate_dynamicrange(subj_ID,black_raw_dynamic_range_data,blackdisplay_time_idx,data_col,time_stamps,black_display_blink_time_idx);

% now let's filter it! 
white_raw_dynamic_range_data = filter_pupil_data(fc,fs,N_dynamic_range_trials,white_raw_dynamic_range_data);
black_raw_dynamic_range_data = filter_pupil_data(fc,fs,N_dynamic_range_trials,black_raw_dynamic_range_data);