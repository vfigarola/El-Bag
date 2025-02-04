%% Victoria Figarola
% This function finds the indices where fixation is more than 1deg away
% from center and makes those indices NaN

function trial_cell = microsaccade_find_fixation(N_TotalTrials,trial_cell,dva_center_x,saving_blinks,degree)


indices_x = cell(N_TotalTrials/4,1);

for i = 1:N_TotalTrials/4
    indices_x{i,1} = find(abs(trial_cell{i,2}(:,1) - dva_center_x) >= degree); % Find indices of elements outside +/- 1 degree of the center x-coord of the fixation cross
end


% Now let's double check if any of the indices are included in the blink.
% if they are, add it onto the indices that need to be "excluded"
for i = 1:N_TotalTrials/4
    if isempty(saving_blinks{i,1})
        continue
    else
        for j = 1:size(saving_blinks{i,1},1)
            indices_x{i,2} = find(ismember(indices_x{i,1},(saving_blinks{i,1}(1,j)+saving_blinks{i,2}(1,j)))==1);
        end
    end
end

for i = 1:N_TotalTrials/4
    if isempty( indices_x{i,2} )
        continue
    else
        indices_x{i,1} = [indices_x{i,1};indices_x{i,2}];
        indices_x{i,1} = sort(indices_x{i,1});
    end

end

%% Now, let's make those indices that are not within 1-deg NaN
for i = 1:N_TotalTrials/4
    trial_cell{i,2}(indices_x{i,1},:) = NaN;
end