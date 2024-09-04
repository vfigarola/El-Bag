%% Victoria Figarola
% This function finds the NaN columns and replaces NaN with 0 
% and it normalizes the data based on Chait et al 2023: Data z-scored 
    % across all trials for each participant

function data = find_nan_in_data(data)

% for i = 1:N_EnvTrials/2
%     data_norm(:,i) = normalize(data(:,i),2);
% 
% end

% data_norm = normalize(data,1);

% data_nan = data(1,:);
% [~,col] = find(isnan(data(1,:)));
% data_norm(:,col) = 0;
% anech_pupil_uninter(i,:,:) = anech_pupil_uninter;

[~,col]  = find(isnan(data(1,:)));

if ~isempty(col)
    data(:,col) = 0;
end
