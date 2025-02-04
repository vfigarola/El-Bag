%% Victoria Figarola
% This function finds the blinks and makes the data NaN

function [saving_blinks, trial_cell] = microsaccade_blink(N_TotalTrials,preBlink,postBlink,fs,trial_cell)

saving_blinks = cell(N_TotalTrials/4,1);
for i = 1:N_TotalTrials/4
    blinkWindow = [preBlink postBlink]; %50ms before and 100ms after blinkd
    blink = 0; % data is 0 when blink occurs

    sampleLength   = 1 ./ fs;  % how long is one sample in seconds?
    blink_samples  = [ceil(blinkWindow(1) ./ sampleLength) ceil(blinkWindow(2) ./ sampleLength)];  % how many samples do we have to remove before and after a blink?

    blink_indx     = trial_cell{i,1}(:,1) == blink;
    blink_position = [0; blink_indx; 0];  % where is the pupil diameter a blink?

    blink_start    = find(diff(blink_position) == 1);  % where do the blinks start?
    blink_end     = find(diff(blink_position) == -1) -1;  % where do blinks end?

    % blink_idx = [blink_start blink_end];

    blink_start    = blink_start - blink_samples(1);  % add window at beginning of blink
    blink_end     = blink_end + blink_samples(2);  % add window at end of blink

    blink_start(blink_start < 1) = 1;
    blink_end(blink_end > length(trial_cell{i,1}(:,1))) = length(trial_cell{i,1}(:,1));

    [blink_start, blink_end] = MergeBrackets(blink_start, blink_end);  % Merge overlapping blinks (blinks can be overlapping due to the additional window
    
    saving_blinks{i,1} = [blink_start blink_end];
end

%% Let's zero pad the blinks 100ms before and after
blink_zero_pad_duration = [];

for j = 1:N_TotalTrials/4
    zero_pad_blinks = trial_cell{j,1};
    Nsamples_blink = size(saving_blinks{j,1},1);
    for i = 1:Nsamples_blink
        zero_pad_blinks(saving_blinks{j,1}(i,1):saving_blinks{j,1}(i,2),:) = NaN;
        blink_zero_pad_duration = [blink_zero_pad_duration saving_blinks{j,1}(i,2) - saving_blinks{j,1}(i,1)];
        
    end

    trial_cell{j,2} = zero_pad_blinks;
    saving_blinks{j,2} = blink_zero_pad_duration;
    blink_zero_pad_duration = [];
end



% figure; 
% plot(trial_cell{1,2}(:,1),trial_cell{1,2}(:,2),'o');
% hold on;
% plot(dva_center_x,dva_center_y,'or','MarkerSize',12,'LineWidth',14)
% title(['raw (deg), trial ' num2str(i)]);