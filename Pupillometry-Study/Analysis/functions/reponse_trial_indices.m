%% Victoria Figarola
% This function outputs the indices of: trial start time, synctime,

function [trialid_idx,time_stamps,time_idx,synctime_start_time_idx]= reponse_trial_indices(N_TotalTrials,events,data,preStim_baseline,period)
time_stamps = double(data.Var1); %in ms
trialid_end_idx=[];
trialid_end_idx = find(strcmp({events.message},'TRIAL_RESULT 0')==1);

%%%%%%%% RESPONSE trial only
if strcmp(period,"response")
    trialid_idx = [];
    for i = 1:N_TotalTrials
        expression = ['RESPONSE_TRIAL ' num2str(i)];
        trialid_idx = [trialid_idx find(strcmp({events.message},expression)==1)];
    end

    synctime_idx = [];
    synctime_idx = find(strcmp({events.message},'SYNCTIME')==1);
    synctime_idx = sort(synctime_idx)';
    synctime_idx = synctime_idx(4:end);
    synctime_idx = synctime_idx(2:2:end); %want every other one to get exact onset of response windows

%%%%%%%% FULL trial
elseif strcmp(period,"trial")
    trialid_idx=[];
    for i = 1:N_TotalTrials
        expression = ['TRIALID ' num2str(i)];
        trialid_idx = [trialid_idx find(strcmp({events.message},expression)==1)];
    end
    trialid_idx = sort(trialid_idx)';
    trialid_idx = trialid_idx(4:end,:); %first three are pupil reactivity

    synctime_idx = [];
    synctime_idx = find(strcmp({events.message},'SYNCTIME')==1);
    synctime_idx = sort(synctime_idx)';
    synctime_idx = synctime_idx(4:end);
    synctime_idx = synctime_idx(1:2:end); %want every other one to avoid response window synctimes


end


st_time = [];
end_time = [];
for i = 1:length(trialid_idx)
    st_time = [st_time;events(trialid_idx(i)).sttime];
    end_time = [end_time;events(trialid_end_idx(i)).sttime];
end

st_time = double(st_time);
st_time = st_time - preStim_baseline; %we only want 1 before onset of response trial
end_time = double(end_time);

time_idx = zeros(N_TotalTrials,2);
for i = 1:length(st_time)
    time_idx(i,1) = find(time_stamps == st_time(i));
    time_idx(i,2) = find(time_stamps == end_time(i));
end

synctime_start_time=[];
for i = 1:N_TotalTrials %getting exact onset of when response window comes on
    synctime_start_time = [synctime_start_time;events(synctime_idx(i)).sttime];
end
synctime_start_time = double(synctime_start_time);

synctime_start_time_idx = [];
for i = 1:N_TotalTrials
    synctime_start_time_idx = [synctime_start_time_idx; find(time_stamps == synctime_start_time(i))];
end

