%%
% Inputs: syllable left/right, target left/right, stream_counterbalance
%
%%
function [trial_stream_no_cue,trial_stream,distractor_array,interrupter,target_onset_times,cue] = reverb_exp_streams_function(stream_counterbalance,fs,dur_of_syl,array_dur,k,target_random_sequence,interruper_random_sequence,mini_block,syllables_right,syllables_left,interrupter_left,interrupter_right)
% [syllable_right_reverb,syllable_left_reverb,syllable_right_anech,syllable_left_anech,inter_anech_pos_90,inter_anech_neg_90,inter_reverb_pos_90,inter_reverb_neg_90] = generating_stimuli_v3();

% mini_block = reverb_mini_block1;
% N_trials=1;
% syllables_right = syllable_right_reverb;
% syllables_left = syllable_left_reverb;
% interrupter_left = inter_reverb_neg_90;
% interrupter_right = inter_reverb_pos_90;
% fs = 44100;
% array_dur = 4.5;
% dur_of_syl = 191833;

target_array = zeros(array_dur*fs,2);
distractor_array = zeros(array_dur*fs,2);

nInterrupters = 80;
interval = floor(0.3*fs); %syllables occur every 300ms
onset_to_onset = floor(0.6*fs);
dist_stream_onset = interval;
target_onset_times = [1,onset_to_onset,2*onset_to_onset,3*onset_to_onset]; %0=cue, t_T1=first target syll
dist_stream_times = [dist_stream_onset,dist_stream_onset+onset_to_onset,dist_stream_onset+2*onset_to_onset,dist_stream_onset+3*onset_to_onset];


% If the sequence is interrupter, we are going to randomly generate a
% number from 1-80
% interrupter_matrix = randsample(nInterrupters,nInterrupters,false);
% interrupter_chosen = randsample(nInterrupters,1,false);

if strcmp(mini_block(2,k),'right') %see if it's target right (dist stream left)
    interrupter = interrupter_left;
    % interrupter = squeeze(interrupter_left(interrupter_chosen,:,:));

    for j = 1:length(target_onset_times) %male target right; right stream first; same

        syllables_male_right = syllables_right([2,4,6],:,:); %male target
        syllables_male_left = syllables_left([2,4,6],:,:); %male dist
        cue = squeeze(syllables_male_right(1,:,:));
        if strcmp(stream_counterbalance,"right") %if stream always starts on the right
            target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) =  squeeze(syllables_male_right(target_random_sequence(j),:,:)); %target right anech
            distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_left(interruper_random_sequence(j),:,:)); %dist left anech
        elseif strcmp(stream_counterbalance,"left") %if stream always starts on the left
            target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) =  squeeze(syllables_male_right(target_random_sequence(j),:,:)); %target right anech
            distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_left(interruper_random_sequence(j),:,:)); %dist left anech

        end
    end


elseif strcmp(mini_block(2,k),'left') %see if it's target right (dist stream left)
    interrupter = interrupter_right; %
    % interrupter = squeeze(interrupter_right(interrupter_chosen,:,:)); %
    for j = 1:length(target_onset_times) %female target right; right stream first; diff

        syllables_male_left = syllables_left([2,4,6],:,:); %male target
        syllables_male_right = syllables_right([2,4,6],:,:); %male target

        cue = squeeze(syllables_male_left(1,:,:));

        if strcmp(stream_counterbalance,"right") %if stream always starts on the right
            target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_left(target_random_sequence(j),:,:)); %target right anech
            distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_right(interruper_random_sequence(j),:,:)); %dist left anech

        elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
            target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_left(target_random_sequence(j),:,:)); %target right anech
            distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_right(interruper_random_sequence(j),:,:)); %dist left anech

        end
    end


end


zeros_difference = length(distractor_array) - length(target_array); %difference between target and interupter sequence length
if zeros_difference < 0
    distractor_array = [distractor_array(:,1) distractor_array(:,2); zeros(abs(zeros_difference),1) zeros(abs(zeros_difference),1)];
else
    target_array = [target_array(:,1) target_array(:,2); zeros(abs(zeros_difference),1) zeros(abs(zeros_difference),1)];
end

trial_stream_no_cue = target_array + distractor_array;
trial_stream = [cue(1:ceil(0.9*fs),:);trial_stream_no_cue];


%% old code
% Now that we know the environmental condition & if it's inter/uninter...
% for k = 1:N_col %for each column
%     if strcmp(mini_block(2,k),'right') %see if it's target right (dist stream left)
%         interrupter = squeeze(interrupter_left(interrupter_chosen,:,:));
%         if strcmp(mini_block(4,k),'diff')
%             if strcmp(mini_block(5,k),'female')
%                 for j = 1:length(target_onset_times) %female target right; right stream first; diff
%                     syllables_right_female_target = syllables_right([1,3,5],:,:); %female target
%                     syllables_left_male_dist = syllables_left([2,4,6],:,:); %male dist
%                     cue = squeeze(syllables_right_female_target(1,:,:));
%
%                     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
%                         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_right_female_target(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_left_male_dist(interruper_random_sequence(j),:,:)); %dist left anech
%                     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the left
%                         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_right_female_target(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_left_male_dist(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     end
%
%                 end
%             elseif strcmp(mini_block(5,k),'male')
%                 for j = 1:length(target_onset_times) %male target right; right stream first; diff
%
%                     syllables_right_male_target = syllables_right([2,4,6],:,:); %male target
%                     syllables_left_female_dist = syllables_left([1,3,5],:,:); %male dist
%                     cue = squeeze(syllables_right_male_target(1,:,:));
%                     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
%                         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_right_male_target(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_left_female_dist(interruper_random_sequence(j),:,:)); %dist left anech
%                     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the left
%                         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_right_male_target(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_left_female_dist(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     end
%
%                 end
%             end
%         elseif strcmp(mini_block(4,k),'same') %if same talker
%             if strcmp(mini_block(5,k),'female') %if female same talker
%                 for j = 1:length(target_onset_times) %female target right; right stream first; diff
%                     syllables_female_right = syllables_right([1,3,5],:,:); %female target
%                     syllables_female_left = syllables_left([1,3,5],:,:); %female dist
%                     cue = squeeze(syllables_female_right(1,:,:));
%                     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
%                         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) =  squeeze(syllables_female_right(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_female_left(interruper_random_sequence(j),:,:)); %dist left anech
%                     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
%                         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) =  squeeze(syllables_female_right(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_female_left(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     end
%                 end
%             elseif strcmp(mini_block(5,k),'male')
%                 for j = 1:length(target_onset_times) %male target right; right stream first; same
%
%                     syllables_male_right = syllables_right([2,4,6],:,:); %male target
%                     syllables_male_left = syllables_left([2,4,6],:,:); %male dist
%                     cue = squeeze(syllables_male_right(1,:,:));
%                     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
%                         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) =  squeeze(syllables_male_right(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_left(interruper_random_sequence(j),:,:)); %dist left anech
%                     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the left
%                         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) =  squeeze(syllables_male_right(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_left(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     end
%                 end
%             end
%         end
%
%     elseif strcmp(mini_block(2,k),'left') %see if it's target right (dist stream left)
%         interrupter = squeeze(interrupter_right(interrupter_chosen,:,:)); %
%
%         if strcmp(mini_block(4,k),'diff')
%             if strcmp(mini_block(5,k),'female')
%                 for j = 1:length(target_onset_times) %female target right; right stream first; diff
%                     syllables_left_female_target = syllables_left([1,3,5],:,:); %female target
%                     syllables_right_male_dist = syllables_right([2,4,6],:,:); %male dist
%                     cue = squeeze(syllables_left_female_target(1,:,:));
%
%                     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
%                         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_left_female_target(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_right_male_dist(interruper_random_sequence(j),:,:)); %dist left anech
%                     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the left
%                         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_left_female_target(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_right_male_dist(interruper_random_sequence(j),:,:)); %dist left anech
%                     end
%
%                 end
%             elseif strcmp(mini_block(5,k),'male')
%                 for j = 1:length(target_onset_times) %female target right; right stream first; diff
%
%                     syllables_left_male_target = syllables_left([2,4,6],:,:); %female target
%                     syllables_right_female_dist = syllables_right([1,3,5],:,:); %male dist
%
%                     cue = squeeze(syllables_left_male_target(1,:,:));
%
%                     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
%                         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_left_male_target(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) =  squeeze(syllables_right_female_dist(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
%                         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_left_male_target(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) =  squeeze(syllables_right_female_dist(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     end
%                 end
%             end
%         elseif strcmp(mini_block(4,k),'same') %if same talker
%             if strcmp(mini_block(5,k),'female') %if female same talker
%                 for j = 1:length(target_onset_times) %female target right; right stream first; diff
%                     syllables_female_left = syllables_left([1,3,5],:,:); %female target
%                     syllables_female_right = syllables_right([1,3,5],:,:); %female target
%
%                     cue = squeeze(syllables_female_left(1,:,:));
%
%                     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
%                         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) =  squeeze(syllables_female_left(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) =  squeeze(syllables_female_right(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
%                         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) =  squeeze(syllables_female_left(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) =  squeeze(syllables_female_right(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     end
%                 end
%             elseif strcmp(mini_block(5,k),'male')
%                 for j = 1:length(target_onset_times) %female target right; right stream first; diff
%
%                     syllables_male_left = syllables_left([2,4,6],:,:); %male target
%                     syllables_male_right = syllables_right([2,4,6],:,:); %male target
%
%                     cue = squeeze(syllables_male_left(1,:,:));
%
%                     if strcmp(stream_counterbalance,"right") %if stream always starts on the right
%                         target_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_left(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_right(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     elseif strcmp(stream_counterbalance,"left") %if stream always starts on the right
%                         target_array(target_onset_times(j):target_onset_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_left(target_random_sequence(j),:,:)); %target right anech
%                         distractor_array(dist_stream_times(j):dist_stream_times(j)+dur_of_syl-1,:) = squeeze(syllables_male_right(interruper_random_sequence(j),:,:)); %dist left anech
%
%                     end
%                 end
%
%             end
%         end
%
%     end
%
% % end
% % end
%
% zeros_difference = length(distractor_array) - length(target_array); %difference between target and interupter sequence length
% if zeros_difference < 0
%     distractor_array = [distractor_array(:,1) distractor_array(:,2); zeros(abs(zeros_difference),1) zeros(abs(zeros_difference),1)];
% else
%     target_array = [target_array(:,1) target_array(:,2); zeros(abs(zeros_difference),1) zeros(abs(zeros_difference),1)];
% end
%
% trial_stream_no_cue = target_array + distractor_array;
% trial_stream = [cue(1:ceil(0.9*fs),:);trial_stream_no_cue];




