%% This script creates the experimental trial streams!
% Inputs:
% generating_stimuli_v3 function
% stream_counterbalance
% experimental_trial_order
% Outputs

% Functions used in this script:
% generating_stimuli_v3
% exp_streams_function --> anechoic
% reverb_exp_streams_function

% When generating random stream, ba=1, da=2, ga=3
function [target_random_sequence,interruper_random_sequence,trial_stream] = generating_exp_streams(j,nSyllables,fs,distractor_sequence_length,target_sequence_length,stream_counterbalance,experimental_trial_order)
% function [target_random_sequence,interruper_random_sequence,anech_trial_stream,reverb_trial_stream] = generating_exp_streams(j,nSyllables,fs,distractor_sequence_length,target_sequence_length,stream_counterbalance,experimental_trial_order)
%% Now that the trials are set, let's create the streams
% N_trials = 1; %10 trials / condition
% nSyllables = 3;
% fs = 44100;
% distractor_sequence_length = 4;
% target_sequence_length = 4;
% stream_counterbalance = "left";

nInterrupters = 80;
% interrupter_matrix = randsample(nInterrupters,nInterrupters,false);

% Make target sequence (randsample 10 from 1:8)
target_random_sequence = randsample(nSyllables,target_sequence_length,true);
% Make interrupter sequence (randsample 6 from 1:8)
interruper_random_sequence = randsample(nSyllables,distractor_sequence_length,true);

i = 1;
while i <= size(target_random_sequence,1) %if there are multiple repeats of the same syllable, regenerate new order
    if size(unique(target_random_sequence),1) <= 2 | size(unique(interruper_random_sequence),1) <=2
        target_random_sequence = randsample(nSyllables,target_sequence_length,true);
        interruper_random_sequence = randsample(nSyllables,distractor_sequence_length,true);

    end
    i=i+1;
end


%% Now let's grab the anech/reverb and inter syllables if condition meets it
% This big loop/condition statement will grab the corresponding syllables
% needed to create the stream
%It is primarily getting the anech/reverb and inter syllables

interrupter_matrix = randsample(nInterrupters,nInterrupters,false);

if strcmp(experimental_trial_order(1,j),'anech') %see if it's anech
    array_dur = 4.5;
    dur_of_syl = 48200;
    [~,~,syllable_right_anech,syllable_left_anech,inter_anech_pos_90,inter_anech_neg_90,~,~] = generating_stimuli_v3();
    if strcmp(experimental_trial_order(3,j),'inter') %see if it's inter
        % [~,~,~,~,inter_anech_pos_90,inter_anech_neg_90,~,~] = generating_stimuli_v3();
        
        [anech_trial_stream_no_cue,~,distractor_array,anech_interrupter,target_onset_times,anech_cue] = exp_streams_function(stream_counterbalance,fs,dur_of_syl,array_dur,j,target_random_sequence,interruper_random_sequence,experimental_trial_order,syllable_right_anech,syllable_left_anech,inter_anech_neg_90,inter_anech_pos_90);
        
        interrupter_chosen = randsample(interrupter_matrix,1,false);
        anech_interrupter = squeeze(anech_interrupter(interrupter_chosen,:,:));

        anech_dur_inter_sample = floor(0.993*fs); %dur of entire syll
        first_syl_onset = target_onset_times(1) + floor(0.475*fs);
        anech_sample_inter = zeros(length(anech_trial_stream_no_cue),2);
        anech_sample_inter(first_syl_onset:first_syl_onset+anech_dur_inter_sample-1,:) = anech_sample_inter(first_syl_onset:first_syl_onset+anech_dur_inter_sample-1,:) + anech_interrupter;

        anech_trial_stream_with_interrupter_sum = anech_trial_stream_no_cue+anech_sample_inter;
        trial_stream = [anech_cue;anech_trial_stream_with_interrupter_sum];
        % trial_stream = [anech_cue;(anech_trial_stream_with_interrupter_sum + distractor_array)];

    elseif strcmp(experimental_trial_order(3,j),'uninter')
        [~,trial_stream,~,~,~,~] = exp_streams_function(stream_counterbalance,fs,dur_of_syl,array_dur,j,target_random_sequence,interruper_random_sequence,experimental_trial_order,syllable_right_anech,syllable_left_anech,inter_anech_neg_90,inter_anech_pos_90);

    end


    %% reverb trials
elseif strcmp(experimental_trial_order(1,j),'reverb') %see if it's reverb
    array_dur = 4.5;
    dur_of_syl = 191833;

    [syllable_right_reverb,syllable_left_reverb,~,~,~,~,inter_reverb_pos_90,inter_reverb_neg_90] = generating_stimuli_v3();

    if strcmp(experimental_trial_order(3,j),'inter') %see if it's inter
        [trial_stream_no_cue,~,distractor_array,reverb_interrupter,target_onset_times,cue] = reverb_exp_streams_function(stream_counterbalance,fs,dur_of_syl,array_dur,j,target_random_sequence,interruper_random_sequence,experimental_trial_order,syllable_right_reverb,syllable_left_reverb,inter_reverb_neg_90,inter_reverb_pos_90);

        interrupter_chosen = randsample(interrupter_matrix,1,false);
        reverb_interrupter = squeeze(reverb_interrupter(interrupter_chosen,:,:));

        dur_inter_sample = floor(4.25*fs); %dur of entire syll
        first_syl_onset = target_onset_times(1) + floor(0.475*fs);
        sample_inter = zeros(length(trial_stream_no_cue),2);
        sample_inter(first_syl_onset:first_syl_onset+dur_inter_sample-2,:) = reverb_interrupter;

        trial_stream_with_interrupter_sum = trial_stream_no_cue+sample_inter;
        trial_stream = [cue(1:ceil(0.9*fs),:);trial_stream_with_interrupter_sum];
        % trial_stream = [cue(1:ceil(0.9*fs),:);(trial_stream_with_interrupter_sum + distractor_array)];

    elseif  strcmp(experimental_trial_order(3,j),'uninter') %see if it's inter
        [~,trial_stream,~,~,~,~] = reverb_exp_streams_function(stream_counterbalance,fs,dur_of_syl,array_dur,j,target_random_sequence,interruper_random_sequence,experimental_trial_order,syllable_right_reverb,syllable_left_reverb,inter_reverb_neg_90,inter_reverb_pos_90);

    end

end





