%% Victoria Figarola
% This function outputs the indices of the white and black display
% we want to get the start time, but index 100ms before and 10 seconds
% (display is on for 10 seconds) 

function [whitedisplay_idx,blackdisplay_idx,whitedisplay_time_idx,blackdisplay_time_idx,time_stamps]= dynamic_range_trial_indices(N_TotalTrials,events,data,fs)

whitedisplay_idx=[];
for i = 1:N_TotalTrials
    expression = ['!V TRIAL_VAR WhiteDisplay ' num2str(i)];
    whitedisplay_idx = [whitedisplay_idx find(strcmp({events.message},expression)==1)];
end

blackdisplay_idx=[];
for i = 1:N_TotalTrials
    expression = ['!V TRIAL_VAR BlackDisplay ' num2str(i)];
    blackdisplay_idx = [blackdisplay_idx find(strcmp({events.message},expression)==1)];
end

%%%%%%%%%%% let's start with white display first

whitedisplay_st_time = [];
whitedisplay_end_time = [];
for i = 1:length(whitedisplay_idx)
    whitedisplay_st_time = [whitedisplay_st_time;events(whitedisplay_idx(i)).sttime];
    whitedisplay_end_time = [whitedisplay_end_time;events(blackdisplay_idx(i)).sttime - 0.1*fs]; %end 100 ms before black display
end

whitedisplay_st_time = double(whitedisplay_st_time);
whitedisplay_st_time = whitedisplay_st_time - 100; %we want 100ms before start
whitedisplay_end_time = double(whitedisplay_end_time);
time_stamps = double(data.Var1); %in ms

whitedisplay_time_idx = zeros(3,2); %only 3 trials
for i = 1:length(whitedisplay_st_time)
    whitedisplay_time_idx(i,1) = find(time_stamps == whitedisplay_st_time(i));
    whitedisplay_time_idx(i,2) = find(time_stamps == whitedisplay_end_time(i));
end

%%%%%%%%%%% now the black display first

blackdisplay_st_time = [];
blackdisplay_end_time = [];
for i = 1:length(blackdisplay_idx)
    blackdisplay_st_time = [blackdisplay_st_time;events(blackdisplay_idx(i)).sttime]; %we start when screen appears
    if i == 3
        blackdisplay_end_time = [blackdisplay_end_time;events(blackdisplay_idx(i)).sttime + 9.907*fs]; %we end ~100 ms before recording stops
    else
        blackdisplay_end_time = [blackdisplay_end_time;events(whitedisplay_idx(i+1)).sttime - 0.1*fs]; %we end 100 ms before white screen appears
    end
end

blackdisplay_st_time = double(blackdisplay_st_time);
blackdisplay_st_time = blackdisplay_st_time - 100; %we want 100ms before start
blackdisplay_end_time = double(blackdisplay_end_time);

blackdisplay_time_idx = zeros(3,2); %only 3 trials
for i = 1:length(blackdisplay_st_time)
    blackdisplay_time_idx(i,1) = find(time_stamps == blackdisplay_st_time(i));
    blackdisplay_time_idx(i,2) = find(time_stamps == blackdisplay_end_time(i));
end


