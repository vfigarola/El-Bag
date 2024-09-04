%% Victoria Figarola
% This function finds the blink start and end time indices during the
% dynamic range

function [white_display_blink_time_idx,black_display_blink_time_idx] = find_blinks_dynamicrange(events,whitedisplay_idx,preBlink,postBlink,time_stamps,whitedisplay_time_idx,blackdisplay_time_idx)

ending_blink_string = [find(strcmp({events.codestring},'ENDEVENTS')==1)]; %lets find where the eyelink stops recording
ending_blink_string = ending_blink_string(1); %we only want the first one since that includes the dynamic range recording

events_as_of_first_trial = events(whitedisplay_idx(1):ending_blink_string); %now let's grab all those events within the dynamic range
find_blink_string = [find(strcmp({events_as_of_first_trial.codestring},'ENDBLINK')==1)]; %now let's find the blinks within the dynamic range trials
find_blink_string = find_blink_string + whitedisplay_idx(1)-1; %now let's align the indices back to the original events 

for i = 1:length(find_blink_string)
    find_blink_string(2,i) = double(events(find_blink_string(1,i)).sttime); %second row is start time of blink
    find_blink_string(3,i) = double(events(find_blink_string(1,i)).entime); %third row is end time of blink
end

blink_times = [(find_blink_string(2,:) - preBlink);(find_blink_string(3,:) + postBlink)]; %first row is start time to interpolate (30ms before blink started); second row is end time (150ms after blink finished)

blink_time_idx = [];
for i = 1:length(blink_times)

    check_zero_blinktime_st_idx = find(time_stamps == blink_times(1,i)); %seeing if zero or not
    if isempty(check_zero_blinktime_st_idx) %if you cannot find the last timing because it's at the end of the trial, only use 30ms post blink
        blink_times(1,i) = find_blink_string(2,i);
        blink_time_idx(i,1) = find(time_stamps == blink_times(1,i)); %first column is start idx
    else
        blink_time_idx(i,1) = find(time_stamps == blink_times(1,i)); %first column is start idx
    end

    check_zero_blinktime_end_idx = find(time_stamps == blink_times(2,i)); %seeing if zero or not
    if isempty(check_zero_blinktime_end_idx) %if you cannot find the last timing because it's at the end of the trial, only use 30ms post blink
        blink_times(2,i) = find_blink_string(3,i);
        blink_time_idx(i,2) = find(time_stamps == blink_times(2,i)); %first column is start idx
    else
        blink_time_idx(i,2) = find(time_stamps == blink_times(2,i)); %first column is start idx
    end
end

% now that we have the start and end time of each blink "epoch", let's see
% if any of these times fall within the whitedisplay_time_idx && blackdisplay_time_idx

% for each blink time, find if end time if within white
valid_blink_indices = 1:length(blink_time_idx);
for j = 1:length(whitedisplay_time_idx) %for each start and end trial time index
    for k = valid_blink_indices %and for each start and end blink time index

        % if the blink end time is within the start and end time, place the
        % trial number in the third column
        if blink_time_idx(k,2)>whitedisplay_time_idx(j,1) && blink_time_idx(k,2)<whitedisplay_time_idx(j,2)
            blink_time_idx(k,3) = j;
            valid_blink_indices(valid_blink_indices == k) =[];
        % elseif blink_time_idx(k,2)>blackdisplay_time_idx(j,1) && blink_time_idx(k,2)<blackdisplay_time_idx(j,2)
        %     blink_time_idx(k,3) = j;
        %     valid_blink_indices(valid_blink_indices == k) =[];
        end

    end

end

white_display_blink_time_idx = blink_time_idx(find(blink_time_idx(:,3)),:);
black_display_blink_time_idx = blink_time_idx(find(~blink_time_idx(:,3)),:);

valid_blink_indices = 1:length(black_display_blink_time_idx);
for j = 1:length(blackdisplay_time_idx) %for each start and end trial time index
    for k = valid_blink_indices %and for each start and end blink time index
        % if the blink end time is within the start and end time, place the
        % trial number in the third column
        if black_display_blink_time_idx(k,2)>blackdisplay_time_idx(j,1) && black_display_blink_time_idx(k,2)<blackdisplay_time_idx(j,2)
            black_display_blink_time_idx(k,3) = j;
            valid_blink_indices(valid_blink_indices == k) =[];
        end

    end

end









