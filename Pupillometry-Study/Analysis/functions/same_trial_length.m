%% Victoria Figarola
% This function makes the data the same length since there is a delay due
% to eyelink (~20ms)

function pupil_trials = same_trial_length(N_samples,N_EnvTrials,pupil_trials)
% N_samples_anech = 9776; 

for i = 1:N_EnvTrials/2
% for i = 1:N_TotalTrials
    if isempty(pupil_trials{i,1})
        continue
    end 

    if length(pupil_trials{i,1}) < N_samples
        pupil_trials{i,2} = pupil_trials{i,1};
        pupil_trials{i,2}(end:N_samples,:) = NaN;

    elseif length(pupil_trials{i,1}) > N_samples
        pupil_trials{i,2} = pupil_trials{i,1};
        pupil_trials{i,2}(N_samples+1:end,:) = [];
    else
        pupil_trials{i,2} = pupil_trials{i,1};

    end

end

% reverb_trials = find(matches(behavioral_data.experimental_trial_order(1,:),"reverb"));
% for i = 1:length(raw_trial_data)
    % z(i) = length(raw_trial_data{i,4});
% end
% z_rev = z(reverb_trials);
% min(z_Rev)