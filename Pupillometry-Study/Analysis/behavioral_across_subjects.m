%% Victoria Figarola
% This script calls the pilot_behavioral_analysis_script to average across
% multiple subjects and saves the csv file for further analysis on R


%% MACROS

% dir_pilot = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Pilot/';
dir_recruited = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
headers = ["score1","score2","score3","score4","intCond","envCond","subjID"]; 


%% Importing behavioral data --> for loop here 
% subj_ID = 'Pilot3VF';
% pilot_data_filename = append('/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Pilot/', subj_ID,'_behavioral.mat');
% 
% pilot_data = pilot_behavioral_analysis_script(pilot_data_filename,subj_ID);

subj_ID = ["001","003","008","010","014","015","016","017","018","019","021","024","025","026","027","029","030"];
nSubj = length(subj_ID);
combined_data =[];
for i = 1:nSubj
    % if i == 1
    %     recruited_data_filename = append('/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/P', subj_ID(i),'/',subj_ID(i),'.mat');
    % else
    recruited_data_filename = append('/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/P', subj_ID(i),'/',subj_ID(i),'_behavioral.mat');

    % end
    recruited_data = pilot_behavioral_analysis_script(recruited_data_filename,subj_ID(i));
    combined_data = [combined_data;recruited_data];
end

% behavioral_data = [headers;behavioral_data];

% combine_data = [pilot_data;recruited_data];
combine_data = [headers;combined_data];

%% Saving csv file
filename = [dir_recruited 'behavioral-responses.csv'];
writematrix(combine_data,filename)


