%% Victoria Figarola
% This script analyzes behavioral responses

%% MACROS
function test = pilot_behavioral_analysis_script(data_filename,subj_ID)

%let's first load in the data. below is specific to pilot data
% dir = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';

% subj_ID = '001';
% data_filename = append('/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/P', subj_ID,'/',subj_ID,'.mat');
behavioral_data = load(data_filename);


N_trials = behavioral_data.N_totaltrials;
N_responses = behavioral_data.target_sequence_length;

% let's grab the answers
target_answers = behavioral_data.target_random_sequence;
responses = behavioral_data.responses;
str = ["!","@","#"];
responses = erase(responses,str);

%% Now let's see how many they got right
% test_trial1 = str2double(responses(2,:));
% test_targetansw1 = cell2mat(target_answers(2))';

correct = zeros(N_trials,N_responses);

for j = 1:N_trials
    current_trial = str2double(responses(j,:));
    for i = 1:N_responses
        current_answers = cell2mat(target_answers(j))';

        if any(current_trial(:,i) == current_answers(:,i))
            correct(j,i) = 1;

        end

    end
end

% correct(:,5) = mean(correct,2); %fifth column is average per trial 

% now let's find the interrupted trials
trial_order = behavioral_data.experimental_trial_order;
inter_trials = zeros(N_trials,1);
env_trials = zeros(N_trials,1);

for i = 1:N_trials
    if any(trial_order(3,i) == "inter")
        inter_trials(i,1) = 1;

    end
    if any(trial_order(1,i) == "anech")
        env_trials(i,1)=1;

    end

end

% inter_trials = find(inter_trials==1);
correct(:,5) = inter_trials; %if intCond = 1, interrupted; if 0, uninterrupted
correct(:,6) = env_trials; %if envCond = 1, anechoic; if 0, reverb


%%
z = find(inter_trials==1);
zz = find(inter_trials==0);
x = find(env_trials==1);
xx = find(env_trials==0);

test = correct;
headers = ["score1","score2","score3","score4","intCond","envCond"]; 
test = [headers;test];
test(1,:)=[];

test(z,5) = "inter";
test(zz,5) = "uninter";
test(x,6) = "anech";
test(xx,6) = "reverb";

test(:,7)=append('P',subj_ID);
% test(1,7)="subjID";




