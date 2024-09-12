%% Victoria Figarola
% this function interpolates the data based on where the blinks are

function raw_trial_data = interpolate_data(subj_ID, period,raw_trial_data,time_idx,data_col,time_stamps,blink_time_idx)

for iInt = 1:length(time_idx)
    if length(unique(raw_trial_data{iInt,1})) == 1
        raw_trial_data{iInt,3} = zeros(length(raw_trial_data{iInt,1}),1);
        continue
    end

    data_to_interp = data_col(time_idx(iInt,1):time_idx(iInt,2),:); %first trial only
    time_to_interp = time_stamps(time_idx(iInt,1):time_idx(iInt,2),:); %first trial time only

    % now let's create a matrix of the blink time indices relative to the first
    % trial onset
    % let's find where each trial is
    current_blink_time_idx = find(blink_time_idx(:,3) == iInt);
    interp_blink_time_idx = blink_time_idx(current_blink_time_idx,1:2);

    if isempty(interp_blink_time_idx)
        raw_trial_data{iInt,3} = raw_trial_data{iInt,1};
        continue
    end

    new_interp_blink_time_first = [];
    if size(interp_blink_time_idx,1) == 1 %if there is only 1 blink
        new_interp_blink_time_first = [new_interp_blink_time_first ; (interp_blink_time_idx(1,1) - time_idx(iInt,1)) , interp_blink_time_idx(1,2) - time_idx(iInt,1)];
    else
        for i = 1:size(interp_blink_time_idx,1)
            new_interp_blink_time_first = [new_interp_blink_time_first ; (interp_blink_time_idx(i,1) - time_idx(iInt,1)) , interp_blink_time_idx(i,2) - time_idx(iInt,1)];
        end
    end


    if any(new_interp_blink_time_first(:,1) < 0)
        new_interp_blink_time_first(new_interp_blink_time_first(:,1)<0,:) = [];
    end

    % Now that the negative value was removed, if
    % new_interp_blink_time_first, then we will continue! 
    if isempty(new_interp_blink_time_first)
        raw_trial_data{iInt,3} = raw_trial_data{iInt,1};
        continue
    end

    %%%%%%%%%%%%%%%%%%% BELOW IS IT TWO BLINKS NEED TO BE MERGED INTO ONE! %%%%%%%%%%%%%%%%%%%
    if size(new_interp_blink_time_first,1) == 2
        if new_interp_blink_time_first(2,1) < new_interp_blink_time_first(1,2)
            new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
        end
    end
    
    if strcmp(period,"response")
        if subj_ID == "024"
            if iInt == 107
                new_interp_blink_time_first(1,2) = new_interp_blink_time_first(4,2);
                new_interp_blink_time_first(2:end,:) = [];

            end
        end

    end
    if new_interp_blink_time_first(1,1) == 0
        new_interp_blink_time_first(1,1) = 1;
    end

    % now let's make those blinks equal to NaN
    for i = 1:size(new_interp_blink_time_first,1)
        if size(new_interp_blink_time_first,1) <= 1
            data_to_interp(new_interp_blink_time_first(1,1):new_interp_blink_time_first(1,2),:) = NaN;
        else
            data_to_interp(new_interp_blink_time_first(i,1):new_interp_blink_time_first(i,2),:) = NaN;
        end

    end

    interp_samples = isnan(data_to_interp); %find where the blinks are (defined as NaN)


    data_interp = interp1(time_to_interp(~interp_samples),data_to_interp(~interp_samples),time_to_interp(interp_samples),'linear');

    raw_trial_data{iInt,2} = data_to_interp; % data with NaN where blinks occur

    v = data_to_interp;

    if size(new_interp_blink_time_first,1) <=1 %iInt == 132 %this is because there is only 1 blink in entire trial (for p005 only)
        % let's grab the rows that nede to be replaced
        v(new_interp_blink_time_first(1,1):new_interp_blink_time_first(1,2),:) = data_interp;

    else
        differences = [];
        for i = 1:size(new_interp_blink_time_first,1)
            % let's grab the rows that nede to be replaced
            differences = [differences (new_interp_blink_time_first(i,2) - new_interp_blink_time_first(i,1) +1)];
            if i == 1
                v(new_interp_blink_time_first(i,1):new_interp_blink_time_first(i,2),:) = data_interp(1:differences(i),:);
            else
                idx_data_interp = [differences(1)+1, differences(1) + differences(i)];
                v(new_interp_blink_time_first(i,1):new_interp_blink_time_first(i,2),:) = data_interp(idx_data_interp(1):idx_data_interp(2),:);
            end
        end
    end

    raw_trial_data{iInt,3} = v; %interpolated data
end
