%% Victoria Figarola
% This function finds the average task evoked peak PD between 3 and 6
% seconds


function output = find_task_evoked_peaks(included_subj,data,t,pre_peak_baseline,pk_condition)

output = struct();
if strcmp(pk_condition,"individual")
    for i = 1:length(included_subj)
        %+1 50ms around peak, then average window
        %let's window between 3 and 6 seconds
        peak_time_window = [find(t == 3) (find(t == 3) + 3000)];

        window_peak_data = data(i,peak_time_window(1):peak_time_window(2)-1);
        % now let's find the peaks
        [pks,locs] = findpeaks(window_peak_data);
        max_peak_idx = find(data(i,:) == max(pks)); %let's get the index of where the peak is found
        max_pk(i,:) = max(pks);
        %now let's grab +/- 50ms around the peak
        cluster_peak_window = data(i,max_peak_idx-pre_peak_baseline:max_peak_idx+pre_peak_baseline);
        cluster_peak_avg(i,:) = mean(cluster_peak_window);
        cluster_peak_std(i,:) = std(cluster_peak_window);

        output.max_pk = max_pk;
        output.cluster_peak_avg = cluster_peak_avg;
        output.cluster_peak_std = cluster_peak_std;
    end


elseif strcmp(pk_condition,"group")
    % data = mean(data);
    peak_time_window = [find(t == 3) (find(t == 3) + 3000)];
    window_peak_data = data(:,peak_time_window(1):peak_time_window(2)-1);
    [pks,locs] = findpeaks(window_peak_data);
    max_pk = max(pks);
    output.max_pk = max_pk;

end