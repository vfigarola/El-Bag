%% Victoria Figarola
%200ms prestim baseline
% 1 sec past end -- task evoked
% end of trial -- response

%%
function analysis = pupil_analysis_v2(subj_ID,data,behavioral_data,events,N_TotalTrials,N_EnvTrials,fs,preStim_baseline,preBlink,postBlink,fc,N_samples_anech,N_samples_reverb,period)

analysis = struct();

%% remove nans from data
data_find_nan = find(isnan(data.Var1));
data(data_find_nan,:) = [];

%% TASK EVOKED PERIOD: Let's first import all the data and find the trial onsets during 
if strcmp(period,"task")
    [trialid_idx,time_stamps,time_idx,synctime_start_time_idx]= time_trial_indices(N_TotalTrials,events,preStim_baseline,data);
elseif strcmp(period,"response")
    [trialid_idx,time_stamps,time_idx,synctime_start_time_idx]= reponse_trial_indices(N_TotalTrials,events,data,preStim_baseline,"response");
elseif strcmp(period,"trial")
    [trialid_idx,time_stamps,time_idx,synctime_start_time_idx]= reponse_trial_indices(N_TotalTrials,events,data,preStim_baseline,"trial");
end


raw_trial_data = cell(N_TotalTrials,1);
for i = 1:N_TotalTrials
    data_col = double(data.Var4);
    raw_trial_data{i,:} = data_col(time_idx(i,1):time_idx(i,2),:);
end

%% if the trial is empty (they closed their eyes), empty it
for i = 1:N_TotalTrials
    if sum(raw_trial_data{i,1}) == 0
        raw_trial_data{i,1} = zeros(length(raw_trial_data{i,1}),1);
    end
end

%% Now, if it's not empty but they have their eyes closed for more than 50% of trial, empty that trial
for i = 1:N_TotalTrials
    finding_number_of_zeros = nnz(~raw_trial_data{i,1});
    percent_zero = 100*(finding_number_of_zeros/length(raw_trial_data{i,1}));
    if percent_zero >= 50
        raw_trial_data{i,1} = zeros(length(raw_trial_data{i,1}),1); %make entire trial 0
    end
end


% below is if i empty raw_trial_data above
empty_trials_idx = cellfun(@nnz,raw_trial_data); %change nnz to isempty if i empty raw_trial_data
empty_trials_idx = find(empty_trials_idx == 0);

%% Now within each trial, let's find the blinks
% Following Winn et al (2018), we will interpolate 30ms before and 150ms
% after each blink
% We will also count how many blinks occur within each trial to calculate
% blink rate

% let's first find when all the blinks occur
blink_time_idx = find_blinks(events,trialid_idx,preBlink,postBlink,time_stamps,time_idx);
[blink_time_idx,blink_count] = find_blink_count(empty_trials_idx,blink_time_idx,N_TotalTrials);
blink_count(empty_trials_idx,:) = NaN;

%% let's interpolate those blinks!
raw_trial_data = interpolate_data(subj_ID, period,raw_trial_data,time_idx,data_col,time_stamps,blink_time_idx);

for i = 1:N_TotalTrials
    if isempty(raw_trial_data{i, 2})
        interp_perc(i,:) = NaN;
    else
        interp_perc(i,:) = 100*(size(find(raw_trial_data{i, 1} ~= raw_trial_data{i, 3}), 1)/length(raw_trial_data{i, 2})); %compare data_to_interp (col 2) with v (interp data; col 3)
        % blink_perc(i,:) = 100*(size(find(isnan(raw_trial_data{i, 2})),1)/length(raw_trial_data{i, 2})); %compare col 2 with full length length
    end
end

%% Now that it's interpolated, let's LPF at 10Hz
raw_trial_data = filter_pupil_data(fc,fs,N_TotalTrials,raw_trial_data);

%% Now let's seperate further into inter vs uninter for anechoic and reverb! 
[trial_info,anech_pupil_uninter,anech_pupil_inter,reverb_pupil_uninter,reverb_pupil_inter] = pupil_by_condition(behavioral_data,N_EnvTrials,raw_trial_data,N_samples_anech,N_samples_reverb);

%% Now let's remove the trials where >30% of the data is interpolated from blinks above
exclude_trials_idx = find(interp_perc >= 30);
total_trials_excluded = [empty_trials_idx;exclude_trials_idx];
total_trials_excluded = sort(total_trials_excluded);

if ~isempty(total_trials_excluded)
    anech_pupil_uninter = exclude_trials(total_trials_excluded,trial_info.anech_uninter,anech_pupil_uninter,1);
    anech_pupil_inter = exclude_trials(total_trials_excluded,trial_info.anech_inter,anech_pupil_inter,1);

    reverb_pupil_uninter = exclude_trials(total_trials_excluded,trial_info.reverb_uninter,reverb_pupil_uninter,1);
    reverb_pupil_inter = exclude_trials(total_trials_excluded,trial_info.reverb_inter,reverb_pupil_inter,1);
end

%% let's quickly update the blink_count array
% to account for all excluded trials

%% Let's see how many trials were excluded after all
if length(total_trials_excluded) >= N_EnvTrials %greater than 50% of data, we are going to exclude participant
    analysis.total_trials_excluded = total_trials_excluded;
    analysis.excluded = "excluded";
    analysis.raw_trial_data = raw_trial_data;
else

 %%%%%%%%%%%% Let's figure out the time between TRIAL_ID and SYNCTIME triggers
    trial_sync_trig_diff = [];
    for i = 1:N_TotalTrials
        trial_sync_trig_diff = [trial_sync_trig_diff;synctime_start_time_idx(i)-time_idx(i,1)];
    end

    trial_sync_trig_diff = trial_sync_trig_diff - preStim_baseline; %subtracting by baseline to get accurate time delay
    trial_sync_trig_diff = trial_sync_trig_diff / fs;

%%%%%%%%%%%% Now let's see if we can compare the amount of blinks in anech vs reverb and inter vs uninter
    inter_trials = zeros(N_TotalTrials,1);
    env_trials = zeros(N_TotalTrials,1);

    inter_trials(trial_info.inter) = 1;%if intCond = 1, interrupted; if 0, uninterrupted
    env_trials(trial_info.anech,1) = 1; %if envCond = 1, anechoic; if 0, reverb

    inter_idx = find(inter_trials==1);
    uninter_idx = find(inter_trials==0);
    anech_idx = find(env_trials==1);
    reverb_idx = find(env_trials==0);

    blink_count(:,2) = inter_trials;
    blink_count(:,3) = env_trials;


    headers = ["blinkCt","intCond","envCond"];
    blink_count_table = [headers;blink_count];
    blink_count_table(1,:)=[];

    blink_count_table(inter_idx,4) = "inter";
    blink_count_table(uninter_idx,4) = "uninter";
    blink_count_table(anech_idx,5) = "anech";
    blink_count_table(reverb_idx,5) = "reverb";

    blink_count_table(:,6)=append('P',subj_ID);
    blink_count_table(total_trials_excluded,:) = [];
    blink_count_table(:,2:3) = [];

    %%%%%%%%%%%% SAVE EVERYTHING
    analysis.excluded = "included";
    analysis.blink_info = struct();
    analysis.blink_info.blink_time_idx = blink_time_idx;
    analysis.blink_info.blink_count = blink_count;
    analysis.blink_info.blink_count_table = blink_count_table;
    analysis.trial_info = trial_info;
    analysis.interp_perc = interp_perc;
    analysis.raw_trial_data = raw_trial_data;
    analysis.exclude_trials_idx = exclude_trials_idx;
    analysis.total_trials_excluded = total_trials_excluded;
    analysis.anech_pupil_uninter = anech_pupil_uninter;
    analysis.anech_pupil_inter = anech_pupil_inter;
    analysis.reverb_pupil_uninter = reverb_pupil_uninter;
    analysis.reverb_pupil_inter = reverb_pupil_inter;
    analysis.time_btw_trigs = trial_sync_trig_diff;

end
