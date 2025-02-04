%% After meeting with Matt
addpath /Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/P003/
addpath functions/

subj_ID = '003';
data = readtable([subj_ID '.asc'], 'FileType','text');
behavioral_data = load(append(convertCharsToStrings(subj_ID),"_behavioral.mat"));
events = behavioral_data.edfstruct_data.FEVENT;
N_TotalTrials = 160;
fs = 1000;
preStim_baseline = 0.5*fs; %1 = normal; 0.1 for blinks during trials only
preBlink = 0.1; %100ms
postBlink = 0.1; %100ms
width = behavioral_data.width; %pixels
height = behavioral_data.height; %pixels
end_samples = 4000; %only want 4.5 sec since we're only interested in MS around interrupter
degree = 1; %we only want the data that is within 1 degree of center
data_find_nan = find(isnan(data.Var1));
data(data_find_nan,:) = [];

%% let's convert the data from pixels to degrees
[x_deg,y_deg,dva_center_x,dva_center_y] = pix2deg(data.Var2,data.Var3,width,height);

%% Seperate data via trial (we're starting w 1 trial for now)
% We're only epoching -500ms to 4sec (want MS relative to the interrupter
[~,~,time_idx,synctime_start_time_idx]= time_trial_indices(subj_ID,N_TotalTrials,events,preStim_baseline,data,end_samples);

% anech_uninter_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"anech") & matches(behavioral_data.experimental_trial_order(3,:),"uninter"));
% anech_inter_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"anech") & matches(behavioral_data.experimental_trial_order(3,:),"inter"));
% reverb_uninter_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"reverb") & matches(behavioral_data.experimental_trial_order(3,:),"uninter"));
% reverb_inter_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"reverb") & matches(behavioral_data.experimental_trial_order(3,:),"inter"));

trial_info = find(matches(behavioral_data.experimental_trial_order(1,:),"anech") & matches(behavioral_data.experimental_trial_order(3,:),"uninter"));

trial_cell = cell(N_TotalTrials/4,1);
for i = 1:N_TotalTrials/4
    trial_data = [x_deg(time_idx(trial_info(i),1):time_idx(trial_info(i),2),:) y_deg(time_idx(trial_info(i),1):time_idx(trial_info(i),2),:)];
    nan_idx = find(isnan(trial_data(:,1))); %find where the NaNs are (blinks)
    trial_data(nan_idx,1:2)=0; %make the blinks zero instead of NaN
    trial_cell{i,1} = trial_data; 

end


%%%%%%%%%% FIGURE OUT A WAY TO STOP IF TRIAL LOOKS BAD AND JOT IT DOWN
% figure; 
% for i = 1:N_TotalTrials/4
%     plot(trial_cell{i,1}(:,1),trial_cell{i,1}(:,2),'o');
%     hold on;
%     plot(dva_center_x,dva_center_y,'or','MarkerSize',12,'LineWidth',14)
%     title(['raw (deg), trial ' num2str(i)]);
%     pause(1) %pause 0.5 seconds between plots
%     hold off;
% end

%% Let's find and label those blinks times before we look at fixation; make blinks NaN
[saving_blinks, trial_cell] = microsaccade_blink(N_TotalTrials,preBlink,postBlink,fs,trial_cell);


%% Now let's see if fixation was >1deg (not including blink windows)
trial_cell = microsaccade_find_fixation(N_TotalTrials,trial_cell,dva_center_x,saving_blinks,degree);

%%
% velocity_engbert = vecvel(trial_cell{2,2},fs,2);
% 
% [sac_engbert, ~] = microsacc(trial_cell{2,2},velocity_engbert,6,10,0);
    %  sac(1:num,1)   onset of saccade
    %  sac(1:num,2)   end of saccade
    %  sac(1:num,3)   peak velocity of saccade (vpeak)
    %  sac(1:num,4)   horizontal component     (dx)
    %  sac(1:num,5)   vertical component       (dy)
    %  sac(1:num,6)   horizontal amplitude     (dX)
    %  sac(1:num,7)   vertical amplitude       (dY)


%% if more than 50% of the trial is missing (eg blinks, no fixation), then exclude
for i = 1:N_TotalTrials/4
    %let's first find where the NaN's are
    nan_idx = find(isnan(trial_cell{i,2}(:,1))==1); 

    missing_perc(i,:) = 100 *  (size(nan_idx,1) / size(trial_cell{i,2}(:,1),1));

end

% if more than 50% of the data is missing, exclude that trial 
total_trials_excluded = find(missing_perc >= 50);

%%%%%%%%%% ADD IN IF MORE THAN 50%, EXCLUDE!!! (NEED TO FIND EXAMPLE TRIAL
%%%%%%%%%% FROM A PARTICIPANT)

%% Let's get the absolute velocity and microsaccades! 
t = 0:1/fs:(end_samples-1)/fs;
t = t-0.5;

for i = 1:N_TotalTrials/4
    input_data_for_ms = [t' trial_cell{i,2}(:,1) trial_cell{i,2}(:,2)];
    [velocity{i,1},microsacc{i,1}] = micsaccdeg(input_data_for_ms, fs);
        % Outputs:
        %    microsaccades - Column one: Time of onset of microsaccades
        %                    Column two: Time at which the microsaccdes terminate
        %                    Column three: Peak velocity of microsaccades
        %                    Column four: Peak amplitude of microsaccades                    
end


%% Let's remove the microsaccades if the amplitude is greater than 1-deg and a velocity greater than 100 deg/s
for i = 1: N_TotalTrials/4
    velocity_idx_to_remove{i,1} = [find(microsacc{i,1}(:,3) > 100)];
    amplitude_idx_to_remove{i,1} = [find(microsacc{i,1}(:,4) > 1)];
    idx_to_remove = [velocity_idx_to_remove{i,1};amplitude_idx_to_remove{i,1}];
    idx_to_remove = unique(idx_to_remove);
    microsacc{i,1}(unique(idx_to_remove),:) = [];

    idx_to_remove = [];
end

%% Let's remove microsaccades if their duration was shorter than 5 ms or larger than 100 ms

for i = 1:N_TotalTrials/4
    ms_duration = microsacc{i,1}(:,2) - microsacc{i,1}(:,1);
    duration_idx_to_remove{i,1} = find(ms_duration <= 5); % find(any(ms_duration(i,1) >= 100))
    duration_idx_to_remove{i,2} = find(ms_duration > 100); % find(any(ms_duration(i,1) >= 100))
    idx_to_remove = [duration_idx_to_remove{i,1} duration_idx_to_remove{i,2}];
    microsacc{i,1}(unique(idx_to_remove),:) = [];

    idx_to_remove = [];
end

%% Let's remove the microsaccades if they're not separated by 20ms in time (minimum intersaccadic interval of 100 ms to the previous microsaccade)
% this value varies ax papers: 20ms, 50ms, or 100ms (adjust according to experiment)
% we're starting with 100ms to be conservative

for j = 1:N_TotalTrials/4
    for i = 1:size(microsacc{j,1},1)-1
        difference = abs(microsacc{j,1}(i,2) - microsacc{j,1}(i+1,1));
        if difference <= 100
            diff_to_remove_idx{j,1}(i,1) = 1;
        else
            diff_to_remove_idx{j,1}(i,1) = 0;
        end

    end
    microsacc{j,1}(find(diff_to_remove_idx{j,1}(:,1)==1),:) = []; %remove that information

end
% microsacc(find(diff_to_remove_idx==1),:) = []; %remove that information

%% Let's convert the microsaccade onsets from ms to sec
for i = 1:N_TotalTrials/4
    microsacc{i,1}(:,1:2) =  (microsacc{i,1}(:,1:2) - preStim_baseline ) / 1000;

end


%% Let's plot the correlation between microsaccade amplitude and peak velocity
figure;
for i = 1:N_TotalTrials/4
    hold on;
    plot(microsacc{i,1}(:,4),microsacc{i,1}(:,3),'o')
    xlabel('Peak amplitude (deg)')
    ylabel('Peak velocity (deg/s)')
    title({'Correlation between the microsaccadic amplitude','and peak velocity of all the detected microsaccades','(Anechoic, Uninter trials)'})
    set(gca,'FontSize',14,'FontWeight','bold');
    % [R,P] = corrcoef(microsacc{i,1}(:,4),microsacc{i,1}(:,3));
    % correlation_coef(i,:) = R(2,1);
    % P_value_correlation(i,:) = P(2,1);
end

% average correlation = 0.7683
% average p =  0.0673

%% Let's try plotting the microsaccades
figure;
hold on;
for i = 1:N_TotalTrials/4
    plot(microsacc{i,1}(:,1),1*ones(size(microsacc{i,1}(:,1),1),1),'*','MarkerSize',12)
    xline(0,'Label','Cue')
    xline(0.6,'Label','Stream')
    xline(1.675,'Label','Inter')
end
xlabel('Time of Microsaccade Onset (sec)')

%% Now let's start to grab the microsaccades within 500ms windows to get the rate
% To compute the rate, the sum of MS was normalized by the number of trials 
% and the sampling rate for each condition and each participant. Because it is 
% assumed that a maximum exists, which would degrade the impact of a MS on the 
% MS rate before the respective time point, a causal smoothing kernel 
% ω(τ) = α2 τ exp(−ατ) was applied with a decay parameter of α = 1/20 ms


% mean rate during a 500ms sliding window stepped every 500ms



%% plot to check 
% ms_v2_plotting = (microsacc(:,1)-500)/fs; %shifting back 500ms bc aligning to pre-stim epoch
% 
% figure;
% plot(t,x_trial1_withoutblinks)
% hold on;
% plot(t,y_trial1_withoutblinks)
% plot(t,velocity)
% plot(ms_v2_plotting,20*ones(size(ms_v2_plotting,1),1),'*','MarkerSize',12)
% yline(8,'LineWidth',2)
% xline(0,'Label','Cue')
% xline(0.6,'Label','Stream')
% xline(1.675,'Label','Inter')
% legend('x','y','velocity','ms')
% 
% 
% adjust_trial = [];
% figure; 
% for i = 1:N_TotalTrials/4
%     plot(t,x_trial1_withoutblinks)
%     hold on;
%     plot(t,y_trial1_withoutblinks)
%     plot(t,velocity)
%     plot(ms_v2_plotting,20*ones(size(ms_v2_plotting,1),1),'*','MarkerSize',12)
%     yline(8,'LineWidth',2)
%     xline(0,'Label','Cue')
%     xline(0.6,'Label','Stream')
%     xline(1.675,'Label','Inter')
%     legend('x','y','velocity','ms')
% 
%     title(['raw (deg), trial ' num2str(i)]);
%     hold off;
%     pause(1) %pause 0.5 seconds between plots
% 
%     loop = input('Continue? (1/0) : '); % 1 to continue 0 to break loop
%     if loop == 1
%         trial_to_adjust = input('Enter trial # : ');
%         adjust_trial = [adjust_trial trial_to_adjust];
%     else
%         continue
%     end
% 
% end









