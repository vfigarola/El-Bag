%% Victoria Figarola
% this function normalizes and organizes the data by condition

function [anech_pupil_uninter,anech_pupil_inter,reverb_pupil_uninter,reverb_pupil_inter,anech_baseline_period,reverb_baseline_period ] = combine_normalized_data(included_subj,fs,N_EnvTrials,task_analysis)

for i = 1:length(included_subj)
    new_field_name = append("P",included_subj(i));

    %%%%%%%%%%%%%%%% TASK EVOKED
    [anech_uninter_data_norm_task,anech_inter_data_norm_task, anech_baseline_period(i,:)] = normalize_pupil_data(fs,N_EnvTrials,task_analysis.(new_field_name).anech_pupil_uninter,task_analysis.(new_field_name).anech_pupil_inter);
    [reverb_uninter_data_norm_task,reverb_inter_data_norm_task, reverb_baseline_period(i,:)] = normalize_pupil_data(fs,N_EnvTrials,task_analysis.(new_field_name).reverb_pupil_uninter,task_analysis.(new_field_name).reverb_pupil_inter);

    anech_pupil_uninter(i,:,:) = anech_uninter_data_norm_task;
    anech_pupil_inter(i,:,:) = anech_inter_data_norm_task;
    reverb_pupil_uninter(i,:,:) = reverb_uninter_data_norm_task;
    reverb_pupil_inter(i,:,:) = reverb_inter_data_norm_task;

    new_field_name = append("P",included_subj(i));
    %%%%%%%%%%%%%%%% RESPONSE PERIOD
    % [anech_uninter_data_norm_response,anech_inter_data_norm_response, ~] = normalize_pupil_data(fs,N_EnvTrials,response_analysis.(new_field_name).anech_pupil_uninter,response_analysis.(new_field_name).anech_pupil_inter,N_samples_response_anech);
    % [reverb_uninter_data_norm_response,reverb_inter_data_norm_response, ~] = normalize_pupil_data(fs,N_EnvTrials,response_analysis.(new_field_name).reverb_pupil_uninter,response_analysis.(new_field_name).reverb_pupil_inter,N_samples_response_reverb);
    % 
    % response_anech_pupil_uninter(i,:,:) = anech_uninter_data_norm_response;
    % response_anech_pupil_inter(i,:,:) = anech_inter_data_norm_response;
    % response_reverb_pupil_uninter(i,:,:) = reverb_uninter_data_norm_response;
    % response_reverb_pupil_inter(i,:,:) = reverb_inter_data_norm_response;
    % 
    % 
    % %%%%%%%%%%%%%%%% WHOLE TRIAL
    % [anech_uninter_data_norm_trial,anech_inter_data_norm_trial, ~] = normalize_pupil_data(fs,N_EnvTrials,whole_trial_task_analysis.(new_field_name).anech_pupil_uninter,whole_trial_task_analysis.(new_field_name).anech_pupil_inter,N_samples_trial_anech);
    % [reverb_uninter_data_norm_trial,reverb_inter_data_norm_trial, ~] = normalize_pupil_data(fs,N_EnvTrials,whole_trial_task_analysis.(new_field_name).reverb_pupil_uninter,whole_trial_task_analysis.(new_field_name).reverb_pupil_inter,N_samples_trial_reverb);
    % 
    % trial_anech_pupil_uninter(i,:,:) = anech_uninter_data_norm_trial;
    % trial_anech_pupil_inter(i,:,:) = anech_inter_data_norm_trial;
    % trial_reverb_pupil_uninter(i,:,:) = reverb_uninter_data_norm_trial;
    % trial_reverb_pupil_inter(i,:,:) = reverb_inter_data_norm_trial;

end