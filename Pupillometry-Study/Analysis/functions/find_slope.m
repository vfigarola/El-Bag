%% Victoria Figarola
% this script finds the slope from the onset to the peak

function [fitting,eval_fit,window_idx] = find_slope(included_subj,t,data,pks,pre_peak_baseline,data_condition,pk_condition,cue_onset)

if strcmp(data_condition,"individual")
    window_idx = [];
    for i = 1:length(included_subj)
        % z = anech_pupil_uninter_avg(1,:);
        window_idx = [window_idx;find(t==0) find(data(i,:) == pks(i))];

        fitting(i,:) = polyfit(t(:,window_idx(i,1):window_idx(i,2)),data(i,window_idx(i,1):window_idx(i,2)),1 );
        eval_fit{i,:} = polyval(fitting(i,:),t(:,window_idx(i,1):window_idx(i,2)));

    end



elseif strcmp(data_condition,"group")
    data = mean(data);
    output = find_task_evoked_peaks(included_subj,data,t,pre_peak_baseline,pk_condition);

    window_idx = [];

    window_idx = [window_idx;find(t==cue_onset) find(data == output.max_pk)]; %t=0 (cue onset) or t=1.08 (inter onset)

    fitting = polyfit(t(:,window_idx(1):window_idx(2)),data(:,window_idx(1):window_idx(2)),1 );
    eval_fit = polyval(fitting,t(:,window_idx(1):window_idx(2)));


end