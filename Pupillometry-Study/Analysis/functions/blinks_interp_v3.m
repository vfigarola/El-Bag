%% Victoria Figarola
% This is version 3 to complement pupil_analysis_v3 -- de-blinking the
% entire data set rather than trials

% This is another method to find and interpolate blinks from the raw data
% rather than eye-link's messages
% blinkWindow = [0.05 0.1]; %50ms before and 100ms after blink
%%

function raw_trial_data = blinks_interp_v3(data,blinkWindow,fs)

data_to_interp = data.Var4; %for each trial
time_stamps = data.Var1;

% mirror signal to avoid border artefacts - if the data starts or ends with a blink, the non linear interpolation can go wild.
% data_to_interp      = [flipud(data_to_interp); data_to_interp; flipud(data_to_interp)];


blink = 0; % data is 0 when blink occurs

sampleLength   = 1 ./ fs;  % how long is one sample in seconds?
blink_samples  = [ceil(blinkWindow(1) ./ sampleLength) ceil(blinkWindow(2) ./ sampleLength)];  % how many samples do we have to remove before and after a blink?

blink_indx     = data_to_interp == blink;
blink_position = [0; blink_indx; 0];  % where is the pupil diameter a blink?

blink_start    = find(diff(blink_position) == 1);  % where do the blinks start?
blink_end     = find(diff(blink_position) == -1) -1;  % where do blinks end?

% blink_idx = [blink_start blink_end];

blink_start    = blink_start - blink_samples(1);  % add window at beginning of blink
blink_end     = blink_end + blink_samples(2);  % add window at end of blink

blink_start(blink_start < 1) = 1;
blink_end(blink_end > length(data_to_interp)) = length(data_to_interp);

[blink_start, blink_end] = MergeBrackets(blink_start, blink_end);  % Merge overlapping blinks (blinks can be overlapping due to the additional window


X = (1 : length(data_to_interp))'; % intext for interpolation

for i_b = 1 : length(blink_start)  % loop through blinks
    X(blink_start(i_b) : blink_end(i_b)) = nan;
end

% xi = find(isnan(X));  % which samples need to be interpolated?
% d(isnan(X)) = [];  % remove to be interpolated data
% X(isnan(X)) = [];  % remove to be interpolated data
% di = interp1(X, d, xi, 'linear');  % interpolate
% X = [X; xi];
% [X, sort_i] = sort(X);
%
% d = [d; di];
% d = d(sort_i);

xi = (isnan(X));  % which samples need to be interpolated?
di = interp1(time_stamps(~xi), data_to_interp(~xi), time_stamps(xi), 'linear');  % interpolate

v = data_to_interp;
differences = [];
idx_data_interp = [];
for j = 1:size(blink_start,1)
    % let's grab the rows that need to be replaced
    differences = [differences (blink_end(j) - blink_start(j) +1)];
    if j == 1 %1:570
        v(blink_start(j):blink_end(j),:) = di(1:differences(j),:);
    elseif j ==2 %571:571+236 (806) ..... 807:807+227
        idx_data_interp = [differences(1)+1, differences(1) + differences(j)];
        v(blink_start(j):blink_end(j),:) = di(idx_data_interp(1):idx_data_interp(2),:);
        idx_data_interp(1,1) = idx_data_interp(1,2);

    else
        idx_data_interp = [idx_data_interp(1,1)+1, idx_data_interp(1,1) + differences(j)];
        v(blink_start(j):blink_end(j),:) = di(idx_data_interp(1):idx_data_interp(2),:);
        idx_data_interp(1,1) = idx_data_interp(1,2);
    end


end


raw_trial_data = v;





