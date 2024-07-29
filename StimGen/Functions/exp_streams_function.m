%%
% Inputs: syllable left/right, target left/right, stream_counterbalance
%
%%
function [trial_stream_no_cue,trial_stream,distractor_array,interrupter,target_onset_times,cue] = exp_streams_function(stream_counterbalance,fs,dur_of_syl,array_dur,k,target_random_sequence,interruper_random_sequence,mini_block,syllables_right,syllables_left,interrupter_left,interrupter_right)

% mini_block = reverb_block;
% N_trials=1;
% syllables_right = syllable_right_reverb;
% syllables_left = syllable_left_reverb;
% interrupter_left = inter_reverb_neg_90;
% interrupter_right = inter_reverb_pos_90;
% fs = 44100;
% array_dur = 4.5;
% dur_of_syl = 48200;

target_array = zeros(array_dur*fs,2);
distractor_array = zeros(array_dur*fs,2);

nInterrupters = 48;
interval = floor(0.3*fs); %syllables occur every 300ms
onset_to_onset = floor(0.6*fs);
dist_stream_onset = interval;
target_onset_times = [1,onset_to_onset,2*onset_to_onset,3*onset_to_onset]; %0=cue, t_T1=first target syll
dist_stream_times = [dist_stream_onset,dist_stream_onset+onset_to_onset,dist_stream_onset+2*onset_to_onset,dist_stream_onset+3*onset_to_onset];


% If the sequence is interrupter, we are going to randomly generate a
% number from 1-48
% interrupter_chosen = randsample(nInterrupters,1,true);
% interrupter_matrix = randsample(nInterrupters,nInterrupters,false);

% Now that we know the environmental condition & if it's inter/uninter...
% if strcmp(stream_counterbalance,"right") %if stream always starts on the right
% for k = 8 %for each column
% for k = 1:N_col %for each column

if strcmp(mini_block(2,k),'right') %see if it's target right (dist stream left)
    interrupter = interrupter_left;
    % interrupter = squeeze(interrupter_left(interrupter_chosen,:,:));
    for j = 1:length(target_onset_times) %male target right; right stream first; same

        syllables_male_right = syllables_right([2,4,6],:,:); %male target
        syllables_male_left = syllables_left([2,4,6],:,:); %male dist

        cue = squeeze(syllables_male_right(1,:,:));

        if strcmp(stream_counterbalance,"right") %if stream always starts on the right
            target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_right(target_random_sequence(j),:,:)); %target right anech
            distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_left(interruper_random_sequence(j),:,:)); %dist left anech

        elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
            target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_right(target_random_sequence(j),:,:)); %target right anech
            distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_left(interruper_random_sequence(j),:,:)); %dist left anech

        end

    end
   

elseif strcmp(mini_block(2,k),'left') %see if it's target right (dist stream left)
    interrupter = interrupter_right; %
    % interrupter = squeeze(interrupter_right(interrupter_chosen,:,:)); 

    for j = 1:length(target_onset_times) %female target right; right stream first; diff

        syllables_male_left = syllables_left([2,4,6],:,:); %male target
        syllables_male_right = syllables_right([2,4,6],:,:); %male target

        cue = squeeze(syllables_male_left(1,:,:));

        if strcmp(stream_counterbalance,"right") %if stream always starts on the right
            target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_left(target_random_sequence(j),:,:)); %target right anech
            distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_right(interruper_random_sequence(j),:,:)); %dist left anech
        elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
            target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_left(target_random_sequence(j),:,:)); %target right anech
            distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_right(interruper_random_sequence(j),:,:)); %dist left anech

        end

    end

end

trial_stream_no_cue = target_array + distractor_array;
trial_stream = [cue;trial_stream_no_cue];





%% previous version with female and male, same/diff
% if strcmp(mini_block(2,k),'right') %see if it's target right (dist stream left)
    % interrupter = squeeze(interrupter_left(interrupter_chosen,:,:));
    % if strcmp(mini_block(4,k),'diff')
    % if strcmp(mini_block(5,k),'female')
    % for j = 1:length(target_onset_times) %female target right; right stream first; diff
    %     syllables_right_female_target = syllables_right([1,3,5],:,:); %female target
    %     syllables_left_male_dist = syllables_left([2,4,6],:,:); %male dist
    %
    %     cue = squeeze(syllables_right_female_target(1,:,:));
    %
    %     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
    %         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_right_female_target(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_left_male_dist(interruper_random_sequence(j),:,:)); %dist left anech
    %     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
    %         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_right_female_target(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_left_male_dist(interruper_random_sequence(j),:,:)); %dist left anech
    %
    %     end
    %
    % end
    % elseif strcmp(mini_block(5,k),'male')
    % for j = 1:length(target_onset_times) %male target right; right stream first; diff
    %
    %     syllables_right_male_target = syllables_right([2,4,6],:,:); %male target
    %     syllables_left_female_dist = syllables_left([1,3,5],:,:); %male dist
    %
    %     cue = squeeze(syllables_right_male_target(1,:,:));
    %
    %     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
    %         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_right_male_target(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_left_female_dist(interruper_random_sequence(j),:,:)); %dist left anech
    %     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
    %         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_right_male_target(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_left_female_dist(interruper_random_sequence(j),:,:)); %dist left anech
    %
    %     end
    %
    % end
    % end
    % elseif strcmp(mini_block(4,k),'same') %if same talker
    % if strcmp(mini_block(5,k),'female') %if female same talker
    % for j = 1:length(target_onset_times) %female target right; right stream first; diff
    %     syllables_female_right = syllables_right([1,3,5],:,:); %female target
    %     syllables_female_left = syllables_left([1,3,5],:,:); %female dist
    %
    %     cue = squeeze(syllables_female_right(1,:,:));
    %
    %     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
    %         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_female_right(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_female_left(interruper_random_sequence(j),:,:)); %dist left anech
    %     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
    %         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_female_right(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_female_left(interruper_random_sequence(j),:,:)); %dist left anech
    %
    %     end
    %
    % end
    % elseif strcmp(mini_block(5,k),'male')
    % for j = 1:length(target_onset_times) %male target right; right stream first; same
    % 
    %     syllables_male_right = syllables_right([2,4,6],:,:); %male target
    %     syllables_male_left = syllables_left([2,4,6],:,:); %male dist
    % 
    %     cue = squeeze(syllables_male_right(1,:,:));
    % 
    %     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
    %         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_right(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_left(interruper_random_sequence(j),:,:)); %dist left anech
    % 
    %     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
    %         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_right(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_left(interruper_random_sequence(j),:,:)); %dist left anech
    % 
    %     end
    % 
    % end
    % end
    % end

% elseif strcmp(mini_block(2,k),'left') %see if it's target right (dist stream left)
%     interrupter = squeeze(interrupter_right(interrupter_chosen,:,:)); %

    % if strcmp(mini_block(4,k),'diff')
    % if strcmp(mini_block(5,k),'female')
    % for j = 1:length(target_onset_times) %female target right; right stream first; diff
    %     syllables_left_female_target = syllables_left([1,3,5],:,:); %female target
    %     syllables_right_male_dist = syllables_right([2,4,6],:,:); %male dist
    %
    %     cue = squeeze(syllables_left_female_target(1,:,:));
    %
    %     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
    %         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_left_female_target(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_right_male_dist(interruper_random_sequence(j),:,:)); %dist left anech
    %     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
    %         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_left_female_target(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_right_male_dist(interruper_random_sequence(j),:,:)); %dist left anech
    %     end
    %
    % end
    % elseif strcmp(mini_block(5,k),'male')
    % for j = 1:length(target_onset_times) %female target right; right stream first; diff
    %
    %     syllables_left_male_target = syllables_left([2,4,6],:,:); %female target
    %     syllables_right_female_dist = syllables_right([1,3,5],:,:); %male dist
    %
    %     cue = squeeze(syllables_left_male_target(1,:,:));
    %
    %     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
    %         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_left_male_target(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_right_female_dist(interruper_random_sequence(j),:,:)); %dist left anech
    %     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
    %         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_left_male_target(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_right_female_dist(interruper_random_sequence(j),:,:)); %dist left anech
    %
    %     end
    %
    % end
    % end
    % elseif strcmp(mini_block(4,k),'same') %if same talker
    % if strcmp(mini_block(5,k),'female') %if female same talker
    % for j = 1:length(target_onset_times) %female target right; right stream first; diff
    %     syllables_female_left = syllables_left([1,3,5],:,:); %female target
    %     syllables_female_right = syllables_right([1,3,5],:,:); %female target
    %
    %     cue = squeeze(syllables_female_left(1,:,:));
    %
    %     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
    %         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_female_left(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_female_right(interruper_random_sequence(j),:,:)); %dist left anech
    %     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
    %         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_female_left(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_female_right(interruper_random_sequence(j),:,:)); %dist left anech
    %
    %     end
    %
    % end
    % elseif strcmp(mini_block(5,k),'male')
    % for j = 1:length(target_onset_times) %female target right; right stream first; diff
    % 
    %     syllables_male_left = syllables_left([2,4,6],:,:); %male target
    %     syllables_male_right = syllables_right([2,4,6],:,:); %male target
    % 
    %     cue = squeeze(syllables_male_left(1,:,:));
    % 
    %     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
    %         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_left(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_right(interruper_random_sequence(j),:,:)); %dist left anech
    %     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
    %         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_left(target_random_sequence(j),:,:)); %target right anech
    %         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) + squeeze(syllables_male_right(interruper_random_sequence(j),:,:)); %dist left anech
    % 
    %     end
    % 
    % end

% end
% end

% end

% end
% end

% trial_stream_no_cue = target_array + distractor_array;
% trial_stream = [cue;trial_stream_no_cue];

% for k = 1:N_trials %for each column
%     if strcmp(mini_block(3,k),'uninter')
%         trial_stream = target_array + distractor_array;
%         trial_stream_no_inter = [cue;trial_stream];
%     elseif strcmp(mini_block(3,k),'inter')
%         dur_inter_sample = floor(0.993*fs); %dur of entire syll
%         first_syl_onset = target_onset_times(1) + floor(0.475*fs);
%         sample_inter = zeros(length(target_array),2);
%         sample_inter(first_syl_onset:first_syl_onset+dur_inter_sample-1,:) = interrupter;
%
%         trial_stream_with_interrupter_sum = target_array+sample_inter;
%         trial_stream = [cue;(trial_stream_with_interrupter_sum + distractor_array)];
%
%     end
% end




% zeros_difference = length(distractor_array) - length(target_array); %difference between target and interupter sequence length
% empty_array = [empty_array(:,1) empty_array(:,2); zeros(zeros_difference,1) zeros(zeros_difference,1)];



