%% Victoria Figarola
% This function separates the data into the different conditions

function [trial_info,anech_pupil_uninter_trials_collapsed,anech_pupil_inter_trials_collapsed,reverb_pupil_uninter_trials_collapsed,reverb_pupil_inter_trials_collapsed] = pupil_by_condition(behavioral_data,N_EnvTrials,raw_trial_data,N_samples_anech,N_samples_reverb)

anech_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"anech"));
reverb_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"reverb"));

inter_trials = find(matches(behavioral_data.experimental_trial_order(3,:),"inter"));


anech_uninter_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"anech") & matches(behavioral_data.experimental_trial_order(3,:),"uninter"));
anech_inter_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"anech") & matches(behavioral_data.experimental_trial_order(3,:),"inter"));
reverb_uninter_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"reverb") & matches(behavioral_data.experimental_trial_order(3,:),"uninter"));
reverb_inter_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"reverb") & matches(behavioral_data.experimental_trial_order(3,:),"inter"));

trial_info = struct();
trial_info.anech = anech_trials;
trial_info.reverb = reverb_trials;
trial_info.inter = inter_trials;

trial_info.anech_uninter = anech_uninter_trials;
trial_info.anech_inter = anech_inter_trials;
trial_info.reverb_uninter = reverb_uninter_trials;
trial_info.reverb_inter = reverb_inter_trials;


anech_pupil_uninter_trials = cell(N_EnvTrials/2,1);
anech_pupil_inter_trials = cell(N_EnvTrials/2,1);
reverb_pupil_uninter_trials = cell(N_EnvTrials/2,1);
reverb_pupil_inter_trials = cell(N_EnvTrials/2,1);

for i = 1:N_EnvTrials/2
    anech_pupil_uninter_trials{i,1} = raw_trial_data{anech_uninter_trials(i),4};
    anech_pupil_inter_trials{i,1} = raw_trial_data{anech_inter_trials(i),4};

    reverb_pupil_uninter_trials{i,1} = raw_trial_data{reverb_uninter_trials(i),4};
    reverb_pupil_inter_trials{i,1} = raw_trial_data{reverb_inter_trials(i),4};
end

anech_pupil_uninter_trials = same_trial_length(N_samples_anech,N_EnvTrials,anech_pupil_uninter_trials);
anech_pupil_inter_trials = same_trial_length(N_samples_anech,N_EnvTrials,anech_pupil_inter_trials);

reverb_pupil_uninter_trials = same_trial_length(N_samples_reverb,N_EnvTrials,reverb_pupil_uninter_trials);
reverb_pupil_inter_trials = same_trial_length(N_samples_reverb,N_EnvTrials,reverb_pupil_inter_trials);

%% Now let's collapse across the 4 primary conditions and plot after!
anech_pupil_uninter_trials_collapsed = [];
anech_pupil_inter_trials_collapsed = [];
reverb_pupil_uninter_trials_collapsed = [];
reverb_pupil_inter_trials_collapsed = [];

for i = 1:N_EnvTrials/2
    anech_pupil_uninter_trials_collapsed = [anech_pupil_uninter_trials_collapsed anech_pupil_uninter_trials{i,2}];
    anech_pupil_inter_trials_collapsed = [anech_pupil_inter_trials_collapsed anech_pupil_inter_trials{i,2}];

    reverb_pupil_uninter_trials_collapsed = [reverb_pupil_uninter_trials_collapsed reverb_pupil_uninter_trials{i,2}];
    reverb_pupil_inter_trials_collapsed = [reverb_pupil_inter_trials_collapsed reverb_pupil_inter_trials{i,2}];

end