%% Victoria Figarola
% this function interpolates the data based on where the blinks are
% subj_ID = "001";
% time_idx = whitedisplay_time_idx;
% blink_time_idx = white_display_blink_time_idx;
% raw_trial_data = white_raw_dynamic_range_data;

function raw_trial_data = interpolate_dynamicrange(subj_ID,raw_trial_data,time_idx,data_col,time_stamps,blink_time_idx)


for iInt = 1:length(time_idx)
    if length(unique(raw_trial_data{iInt,1})) == 1
        raw_trial_data{iInt,2} = zeros(length(raw_trial_data{iInt,1}),1);
        continue
    end

    data_to_interp = data_col(time_idx(iInt,1):time_idx(iInt,2),:); %first trial only
    time_to_interp = time_stamps(time_idx(iInt,1):time_idx(iInt,2),:); %first trial time only

    % now let's create a matrix of the blink time indices relative to the first
    % trial onset
    % let's find where each trial is
    current_blink_time_idx = find(blink_time_idx(:,3) == iInt);
    interp_blink_time_idx = blink_time_idx(current_blink_time_idx,1:2);

    % if strcmp(subj_ID,'010')
    %     if iInt == 28 %only for P010; removing because only first 100 samples
    %         data_to_interp(1:104,:) = 0;
    %         interp_blink_time_idx = [];
    %     end
    % elseif strcmp(subj_ID,'001')
    %     if iInt == 129
    %         data_to_interp(1:63,:) = 0;
    %         interp_blink_time_idx = [];
    %     end
    % end

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


  
        %%%%%%%%%%%%%%%%%%% BELOW IS IF THERE IS 1 BLINK AT THE VERY START OF THE TRIAL %%%%%%%%%%%%%%%%%%%
    % if strcmp(subj_ID,'015')
    %     if iInt == 60
    %         new_interp_blink_time_first(1,1) = 1;
    %     end
    % elseif strcmp(subj_ID,'017')
    %     if iInt == 96
    %         new_interp_blink_time_first(1,1) = 10;
    %     end
    % elseif strcmp(subj_ID,'031')
    %     if iInt == 159
    %         new_interp_blink_time_first(1,1) = 15;
    %     end
    % 
    % end

    if any(new_interp_blink_time_first(:,1) < 0)
        new_interp_blink_time_first(new_interp_blink_time_first(:,1)<0,:) = [];
    end

    %%%%%%%%%%%%%%%%%%% BELOW IS IT TWO BLINKS NEED TO BE MERGED INTO ONE! %%%%%%%%%%%%%%%%%%%
    % if strcmp(subj_ID,'008')
    %     if iInt == 18 || iInt == 26 %subj P008 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % elseif strcmp(subj_ID,'001')
    %     if iInt == 48  || iInt == 68 %subj P008 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % elseif strcmp(subj_ID,'010')
    %     if iInt == 20  || iInt == 30 || iInt == 44 || iInt == 97 || iInt == 98 || iInt == 142 || iInt == 148 %subj P010 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % elseif strcmp(subj_ID,'015')
    %      if iInt == 40  %subj P015 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %      elseif iInt == 49
    %          new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(3,2)];
    %     end
    % elseif strcmp(subj_ID,'017')
    %     if iInt == 47 || iInt == 57 || iInt == 148 || iInt == 158 %subj P008 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % elseif strcmp(subj_ID,'019')
    %     if iInt == 45  %subj P008 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % elseif strcmp(subj_ID,'024')
    %     if iInt == 55  %subj P008 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % elseif strcmp(subj_ID,'025')
    %     if iInt == 32  || iInt == 82 || iInt == 84 || iInt == 91 || iInt == 135 %subj P008 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % elseif strcmp(subj_ID,'026')
    %     if iInt == 1   %subj P008 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % elseif strcmp(subj_ID,'027')
    %     if iInt == 41   %subj P008 only (two blinks but should only be 1)
    %         new_interp_blink_time_first = [new_interp_blink_time_first(1,1) new_interp_blink_time_first(2,2)];
    %     end
    % end

    % now let's make those blinks equal to NaN

        for i = 1:size(new_interp_blink_time_first,1)
            if size(new_interp_blink_time_first,1) <= 1
                data_to_interp(new_interp_blink_time_first(1,1):new_interp_blink_time_first(1,2),:) = NaN;
            else
                data_to_interp(new_interp_blink_time_first(i,1):new_interp_blink_time_first(i,2),:) = NaN;
            end

            % if strcmp(subj_ID,'005')
            %     if i == 8 %closed eyes for last 2 seconds
            %         data_to_interp(new_interp_blink_time_first(i,1):new_interp_blink_time_first(i,2),:) = 0;
            %     end
            % elseif strcmp(subj_ID,'003')
            %     if iInt == 1
            %         data_to_interp(1:418,:) = 0; 
            %     end
            % elseif strcmp(subj_ID,'016') %trial begins with eye blink 
            %     if iInt == 96
            %         data_to_interp(1:330,:) = 0;
            %     elseif iInt == 109
            %         data_to_interp(1:1793,:) = 0;
            %     elseif   iInt == 116
            %         data_to_interp(1:296,:) = 0;
            %     elseif   iInt == 119
            %         data_to_interp(1:79,:) = 0;
            %     elseif   iInt == 122
            %         data_to_interp(1:120,:) = 0;
            %     elseif   iInt == 124
            %         data_to_interp(1:50,:) = 0;
            %     elseif   iInt == 134
            %         data_to_interp(1:90,:) = 0;
            %     elseif   iInt == 136
            %         data_to_interp(1:800,:) = 0;
            %     end
            % end

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
