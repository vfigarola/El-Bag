%% Victoria Figarola, 2/29/24
% This script generates 160 trials/block. It will be called into X script
% to create X blocks
% Conditions: 2 (anech/reverb) x 2 (inter/uninter) x 2 target (L/R) x 2
% talker gender (same / diff)
% There are 4 syllables/stream. In the interrupted condition, the
% interrupter comes on before the onset of the 2nd syllable

% Functions called into this script:
% 1) creating_condition_matrix: this outputs a matrix of all conditions
% in experiment

% 2) generating_stimuli_v3: this outputs the spatialized syllables as 6 syllables x samples x 2 (1=left; 2=right)
% 6 syllables::: 1 = F ba; 2 = M ba; 3 = F da; 4=M da; 5=F ga; 6=M ga
% Outputs:
% syllable_right_reverb: all 6 spatialized, reverberant syllables (+30)
% syllable_left_reverb:  all 6 spatialized, reverberant syllables (-30)
% syllable_right_anech
% syllable_left_anech

% WANT TO SAVE:
% experimental_trial_order
% stream_counterbalance
% envCond_presented_first
% syllable order


%% Initializing variables
addpath ../StimGen/Functions/
addpath ../StimGen/BRIRs/
addpath ../StimGen/interrupting_stimuli_source/
addpath ../StimGen/syllables/
dir_wavefile = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Code/StimGen/WavFiles/';

subject_ID = "pilot";
fs = 44100;
% N_conditions = 8; %16 conditions
N_trials = 20; %20 trials / condition
N_total_trials = 160;
% N_miniblocks = 4; %4 miniblocks/block
% N_miniblock_trials = 20; %20 trials/mini block
nSyllables = 3;
distractor_sequence_length = 4; 
target_sequence_length = 4; 

stream_counterbalance = "right"; %if left, target is leading left (lagging right); if right, target is leading right (lagging left)
envCond_presented_first = "anech"; %if anech, present anech block first; if reverb, present reverb block first

% Now lets import the trials being presented
experimental_trial_order = creating_final_condition_matrix(N_trials,envCond_presented_first);


%% Now that the trials are set, let's create the streams

% [target_random_sequence,interruper_random_sequence,anech_trial_stream,reverb_trial_stream] = generating_exp_streams(1,nSyllables,fs,distractor_sequence_length,target_sequence_length,stream_counterbalance,anech_block,reverb_block);

trigger=[];
for j = 1:N_total_trials
    [target_random_sequence(j,:),interruper_random_sequence(j,:),trial_stream] = generating_exp_streams(j,nSyllables,fs,distractor_sequence_length,target_sequence_length,stream_counterbalance,experimental_trial_order);

    % sound(trial_stream,fs)

    %Saving wav file
    wave_name = append(dir_wavefile,experimental_trial_order(1,j),'_target-',experimental_trial_order(2,j),'_',experimental_trial_order(3,j),'_trial',num2str(j),'.wav');
    % audiowrite(wave_name,trial_stream,fs)
    trigger = [trigger experimental_trial_order(4,j)];

    trial_stream =[];
end

%% Saving all info 
saving_workspace = struct();
saving_workspace.subjId = subject_ID; 
saving_workspace.envCond_presented = envCond_presented_first;
saving_workspace.trial_order = experimental_trial_order;
saving_workspace.stream_leadlag = stream_counterbalance;
saving_workspace.target_sequence = target_random_sequence;
saving_workspace.distracting_sequence = interruper_random_sequence;
saving_workspace.trigID = trigger;

save("trial_presentation_order.mat","saving_workspace","-mat")


%%
fs = 44100; 
% sample_trial_bggb_0 = trial_stream{1,3}; %anech, target right 
% audiowrite("sample_trial_bggb_0.flac",sample_trial_bggb_0,44100)
% sample_trial_bdbb_1 = trial_stream{1,4}; %anech, target right
% audiowrite("sample_trial_bdbb_1.flac",sample_trial_bdbb_1,44100)


% sample_trial_bdgg_2 = trial_stream{1,1}; %anech, target left
% audiowrite("sample_trial_bdgg_2.flac",sample_trial_bdgg_2,44100)
% sample_trial_bbgb_3 = trial_stream{1,6}; %anech, target left -->REDO
% audiowrite("sample_trial_bbgb_3.flac",sample_trial_bbgb_3,44100)


% sample_trial_bbbb_4 = trial_stream{1,6}; %reverb, target right
% audiowrite("sample_trial_bbbb_4.flac",sample_trial_bbbb_4,44100)
% sample_trial_gggb_5 = trial_stream{1,44}; %reverb, target right
% audiowrite("sample_trial_gggb_5.flac",sample_trial_gggb_5,44100)

% sample_trial_dgbg_6 = trial_stream{1,1}; %reverb, target left
% audiowrite("sample_trial_dgbg_6.flac",sample_trial_dgbg_6,44100)
% sample_trial_bddg_7 = trial_stream{1,4}; %reverb, target left
% audiowrite("sample_trial_bddg_7.flac",sample_trial_bddg_7,44100)






