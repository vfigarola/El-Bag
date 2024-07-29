%% Victoria Figarola
% This function creates the order trials are presented in and called in
% generating_experimental_trials

% There are 160 trials, where 50% are:
    % reverb/anech
    % target left/right
    % uninterrupted/interrupted
% There are 20 trials/condition, separated into 4 mini blocks per block (1
    % full block = 60 trials)
% Functions it calls on: creating_condition_matrix()

% Inputs: N_trials, envCond_presented_first
% Output: experimental_trial_order (3 sub-conditions x 160 trials) 


%% 
function experimental_trial_order = creating_final_condition_matrix(N_trials,envCond_presented_first)
% N_trials = 20; %20 trials / condition

[anech_condition_matrix, reverb_condition_matrix] = creating_condition_matrix(); %pulling in condition matrix

% now i'm going to repmat conditions so there are 3 trials/condition (20
% trials/condition)
anech_condition_matrix_total = repmat(anech_condition_matrix,1,N_trials); %3 (sub-conditions) x 20 (# of trials)
reverb_condition_matrix_total = repmat(reverb_condition_matrix,1,N_trials); %3 (sub-conditions) x 20 (# of trials)

% Now that we have the trials/block, let's randomize which trials are
% presented in 
anechoic_choose_random_columns = randsample(size(anech_condition_matrix_total,2),size(anech_condition_matrix_total,2),false);
anechoic_choose_random_columns_reorganized = reshape(anechoic_choose_random_columns,20,4); %reshaping it so it's a 10x8

reverb_choose_random_columns = randsample(size(reverb_condition_matrix_total,2),size(reverb_condition_matrix_total,2),false);
reverb_choose_random_columns_reorganized = reshape(reverb_choose_random_columns,20,4); %reshaping it so it's a 10x8

% now let's make one big matrix that contains all trials in order,
% separated into 20 trials / mini block (total of 8 mini blocks) depending
% on if anech or reverb is presented first 
if envCond_presented_first == "anech"
    experimental_trial_order = [anech_condition_matrix_total(:,anechoic_choose_random_columns(1:20,:)) reverb_condition_matrix_total(:,reverb_choose_random_columns(1:20,:)),...
        anech_condition_matrix_total(:,anechoic_choose_random_columns(21:40,:)) reverb_condition_matrix_total(:,reverb_choose_random_columns(21:40,:)),...
        anech_condition_matrix_total(:,anechoic_choose_random_columns(41:60,:)) reverb_condition_matrix_total(:,reverb_choose_random_columns(41:60,:)),...
        anech_condition_matrix_total(:,anechoic_choose_random_columns(61:80,:)) reverb_condition_matrix_total(:,reverb_choose_random_columns(61:80,:))];
elseif envCond_presented_first == "reverb"
    experimental_trial_order = [reverb_condition_matrix_total(:,reverb_choose_random_columns(1:20,:)) anech_condition_matrix_total(:,anechoic_choose_random_columns(1:20,:)),...
        reverb_condition_matrix_total(:,reverb_choose_random_columns(21:40,:)) anech_condition_matrix_total(:,anechoic_choose_random_columns(21:40,:)),...
        reverb_condition_matrix_total(:,reverb_choose_random_columns(41:60,:)) anech_condition_matrix_total(:,anechoic_choose_random_columns(41:60,:)),...
        reverb_condition_matrix_total(:,reverb_choose_random_columns(61:80,:)) anech_condition_matrix_total(:,anechoic_choose_random_columns(61:80,:))];
end











