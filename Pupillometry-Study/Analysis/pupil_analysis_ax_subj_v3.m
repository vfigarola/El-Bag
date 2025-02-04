%% Victoria Figarola
% This script compares pupil data across all subjects

%%%%%%%%%%%%%
% re-check subject 43, 49, 55
%% testing single subject
% clear 
% clc
% 
% subj_ID = "040";
% i=1;
% N_TotalTrials = 160;
% N_EnvTrials = 80; %80 trials/env
% fs = 1000;
% period = "response";
% preStim_baseline = 0.2*fs;
% preBlink = 0.03*fs;
% postBlink = 0.15*fs;
% fc = 10; %lowpass filter cutoff 
% dir = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
% data = readtable(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),'.asc'), 'FileType','text');
% behavioral_data = load(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),"_behavioral.mat"));
% events = behavioral_data.edfstruct_data.FEVENT;

%%
%if threshold 50%, i have 24 included subjects; if threshold 30%, i have 18

addpath /Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/
addpath functions/
addpath errorbar_files/

tic;

% subj_ID = ["001","003","005","008","010","014","015","016","017","018",...
%     "019","021","024","025","026","027","029","030","031","038",...
%     "039","040","041","043","045","047r","048","049","051","052",...
%     "053","054","055","060"]; %all subjects

subj_ID = ["001","003","008","010","014","016","017","018",...
    "019","021","024","025","026","027","029","031","038",...
    "039","040","041","043","045","047r","048","049","051",...
    "052","053","054","055","056","060","061","062","064",...
    "065"]; %included subjects only

% subj_ID = "048";

N_TotalTrials = 160;
N_EnvTrials = 80; %80 trials/env
fs = 1000; %Hz
preStim_baseline = 1*fs; %1 = normal; 0.1 for blinks during trials only
pre_peak_baseline = 0.05*fs; %50ms before and after peak
preBlink = 0.05;
postBlink = 0.15;
fc = 10; %lowpass filter cutoff 
N_samples_task_anech = 9776;
N_samples_task_reverb = 11534;


for i = 1:length(subj_ID) %stopped at i=13 (subj 24, response)
    dir = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
    data = readtable(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),'.asc'), 'FileType','text');
    combined_behavioral_data = load(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),"_behavioral.mat"));
    events = combined_behavioral_data.edfstruct_data.FEVENT;
    new_field_name = append("P",subj_ID(i));

    if subj_ID(i) == "060"
        N_TotalTrials = 152;
        task_analysis.(new_field_name) = pupil_analysis_v3(data,combined_behavioral_data,events,N_TotalTrials,N_EnvTrials,fs,preStim_baseline,preBlink,postBlink,fc,subj_ID(i));
    end

    task_analysis.(new_field_name) = pupil_analysis_v3(data,combined_behavioral_data,events,N_TotalTrials,N_EnvTrials,fs,preStim_baseline,preBlink,postBlink,fc,subj_ID(i));

end

toc;

%% Only want to include the subjects that aren't excluded
included_subj_idx = [];
for i = 1:length(subj_ID)
    new_field_name = append("P",subj_ID(i));
    included_subj_idx = [included_subj_idx;strcmp(task_analysis.(new_field_name).excluded,"included")];
    included_subj = subj_ID(find(included_subj_idx==1))';
end

task_included_subj = find_included_subj(subj_ID,task_analysis);

%% Normalize the Data via baseline
[task_anech_pupil_uninter,task_anech_pupil_inter,task_reverb_pupil_uninter,task_reverb_pupil_inter,anech_baseline_period,reverb_baseline_period ] = combine_normalized_data(task_included_subj,fs,N_EnvTrials,task_analysis);


%% Now let's average across conditions! 

task_pd = average_per_condition(task_analysis,task_included_subj,task_anech_pupil_uninter,task_anech_pupil_inter,task_reverb_pupil_uninter,task_reverb_pupil_inter);

%% let's shade the area where the audio is being played

t_anech = 0:1/fs:(length(task_pd.anech_pupil_inter_avg)-1)/fs;
t_anech = t_anech - 1; %subtracting by 1 because indexed trial 1sec b4 onset
t_reverb = 0:1/fs:(length(task_pd.reverb_pupil_inter_avg)-1)/fs;
t_reverb = t_reverb - 1;

fs_stream = 44100;
t_anech_audio = 0:1/fs_stream:(246650-1)/fs_stream;
t_reverb_audio = 0:1/fs_stream:(324132-1)/fs_stream;

%%% let's also align when the interrupter comes on 
mean_trig = mean(task_pd.trig_time_ax_subj);
stream_onsets = [max(mean(task_pd.trig_time_ax_subj)) (max(mean(task_pd.trig_time_ax_subj)+0.6)) (max(mean(task_pd.trig_time_ax_subj))+0.6+0.475)]; %cue, syllable 1, interrupter
 

%% Let's find the pupil peak 
anech_pupil_uninter_max_pks = find_task_evoked_peaks(task_included_subj,task_pd.anech_pupil_uninter_avg,t_anech,pre_peak_baseline,"individual");
anech_pupil_inter_max_pks = find_task_evoked_peaks(task_included_subj,task_pd.anech_pupil_inter_avg,t_anech,pre_peak_baseline,"individual");
reverb_pupil_uninter_max_pks = find_task_evoked_peaks(task_included_subj,task_pd.reverb_pupil_uninter_avg,t_reverb,pre_peak_baseline,"individual");
reverb_pupil_inter_max_pks = find_task_evoked_peaks(task_included_subj,task_pd.reverb_pupil_inter_avg,t_reverb,pre_peak_baseline,"individual");

% pk_headers = ["subjID" "envCond" "intCond" "pk"];
% peaks_table = [];
% peaks_table = [pk_headers;peaks_table];
% peaks_table(1,:)=[];
% 
% peaks_table([1:14,29:42],2) = "anech";
% peaks_table([15:28,43:56],2) = "reverb";
% peaks_table(1:28,3) = "uninter";
% peaks_table(29:end,3) = "inter";
% 
% subject_names = append("P",subj_ID(included_subj_idx==1)');
% peaks_table(:,1) = [subject_names;subject_names;...
%     subject_names;subject_names];
% peaks_table(:,4) = [anech_pupil_uninter_pks;reverb_pupil_uninter_pks;anech_pupil_inter_pks;reverb_pupil_inter_pks];
% 
% peaks_table = [pk_headers;peaks_table];

% now that we have the peaks, let's create an array to save as a table for
% further analysis on R
% filename = [dir 'peaks_ax_conditions.csv'];
% writematrix(peaks_table,filename)


%% Now let's find time to peak/slope!
cue_onset = 0;
[anech_uninter_group_fitting,anech_uninter_group_eval_fit,anech_uninter_group_window_idx] = find_slope(included_subj,t_anech,task_pd.anech_pupil_uninter_avg,anech_pupil_uninter_max_pks,pre_peak_baseline,"group","group",cue_onset);
[anech_inter_group_fitting,anech_inter_group_eval_fit,anech_inter_group_window_idx] = find_slope(included_subj,t_anech,task_pd.anech_pupil_inter_avg,anech_pupil_inter_max_pks,pre_peak_baseline,"group","group",cue_onset);

[reverb_uninter_group_fitting,reverb_uninter_group_eval_fit,reverb_uninter_group_window_idx] = find_slope(included_subj,t_reverb,task_pd.reverb_pupil_uninter_avg,reverb_pupil_uninter_max_pks,pre_peak_baseline,"group","group",cue_onset);
[reverb_inter_group_fitting,reverb_inter_group_eval_fit,reverb_inter_group_window_idx] = find_slope(included_subj,t_reverb,task_pd.reverb_pupil_inter_avg,reverb_pupil_inter_max_pks,pre_peak_baseline,"group","group",cue_onset);


%% Behavior! Added this in here since we only want behavior from "included" subjects
% dir_recruited = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
% headers = ["score1","score2","score3","score4","intCond","envCond","subjID"]; 
% 
% combined_behavioral_data =[];
% for i = 1:length(included_subj)
%     behavioral_data_filename = append('/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/P', included_subj(i),'/',included_subj(i),'_behavioral.mat');
%     behavioral_data = pilot_behavioral_analysis_script(behavioral_data_filename,included_subj(i));
% 
%     % behavioral_data = pilot_behavioral_analysis_script(behavioral_data_filename,included_subj(i));
%     % behavioral_data_filename = append('/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/P', subj_ID,'/',subj_ID,'_behavioral.mat');
%     % behavioral_data = pilot_behavioral_analysis_script(behavioral_data_filename,subj_ID);
%     combined_behavioral_data = [combined_behavioral_data;behavioral_data];
% end
% 
% combined_behavioral_data_with_headers = [headers;combined_behavioral_data];

% filename = [dir_recruited 'behavioral-responses_allsubj.csv'];
% writematrix(combined_behavioral_data_with_headers,filename)


%% Behavior separated by lead/lag
% tic;
% % subj_ID = ["001","003","005","008","010","014","015","016","017","018",...
% %     "019","021","024","025","026","027","029","030","031","038",...
% %     "039","040","041","043","045","047r","048","049","051","052",...
% %     "053"];
% subj_ID = ["001","003","008","010","014","016","017","018",...
%     "019","021","024","025","026","027","029","031","038",...
%     "039","040","041","043","045","047r","048","049","051",...
%     "052","053"];
% 
% N_TotalTrials = 160;
% N_EnvTrials = 80; %80 trials/env
% fs = 1000; %Hz
% preStim_baseline = 1*fs; %1 = normal; 0.1 for blinks during trials only
% pre_peak_baseline = 0.05*fs; %50ms before and after peak
% preBlink = 0.03*fs;
% postBlink = 0.15*fs;
% fc = 10; %lowpass filter cutoff 
% N_samples_task_anech = 9776;
% N_samples_task_reverb = 11534;
% % N_samples_trial_anech = 16000;
% % N_samples_trial_reverb = 17400;
% % N_samples_response_anech = 8000;
% % N_samples_response_reverb = 8000; 
% % N_dynamic_range_trials = 3;
% 
% for i = 1:length(subj_ID) %stopped at i=13 (subj 24, response)
%     dir = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
%     data = readtable(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),'.asc'), 'FileType','text');
%     mat_file_data = load(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),"_behavioral.mat"));
%     events = mat_file_data.edfstruct_data.FEVENT;
%     new_field_name = append("P",subj_ID(i));
% 
%     task_analysis.(new_field_name) = pupil_analysis_behavior(num2str(subj_ID(i)),data,mat_file_data,events,N_TotalTrials,N_EnvTrials,fs,preStim_baseline,preBlink,postBlink,fc,N_samples_task_anech,N_samples_task_reverb,"task");
% end
% 
% 
% dir_recruited = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
% headers = ["score1","score2","score3","score4","intCond","envCond","subjID","stream"]; 
% 
% combined_behavioral_data =[];
% leading_trials = [];
% for i = 1:length(subj_ID)
%     % for i = 1:length(included_subj)
%     behavioral_data_filename = append('/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/P', subj_ID(i),'/',subj_ID(i),'_behavioral.mat');
%     behavioral_data = pilot_behavioral_analysis_script(behavioral_data_filename,subj_ID(i));
% 
%     new_field_name = append("P",subj_ID(i));
%     if strcmp(task_analysis.(new_field_name).stream_counterbalance,"right") %if right stream leading (target right lead; target left lag)
%         % then let's grab the trials that are target right and call them
%         % lead
%         leading_trials = [leading_trials; task_analysis.(new_field_name).trial_info.ari_trials task_analysis.(new_field_name).trial_info.aru_trials task_analysis.(new_field_name).trial_info.rri_trials task_analysis.(new_field_name).trial_info.rru_trials];
%         leading_trials = sort(leading_trials);
%         behavioral_data(leading_trials,8) = "lead";
%         behavioral_data(find(behavioral_data(:,8)==num2str(0)),8) = "lag";
% 
%     elseif strcmp(task_analysis.(new_field_name).stream_counterbalance,"left") %if left stream leading (target left lead; target right lag)
%         leading_trials = [leading_trials; task_analysis.(new_field_name).trial_info.ali_trials task_analysis.(new_field_name).trial_info.alu_trials task_analysis.(new_field_name).trial_info.rli_trials task_analysis.(new_field_name).trial_info.rlu_trials];
%         leading_trials = sort(leading_trials);
%         behavioral_data(leading_trials,8) = "lead";
%         behavioral_data(find(behavioral_data(:,8)==num2str(0)),8) = "lag";
%     end
% 
%     combined_behavioral_data = [combined_behavioral_data;behavioral_data];
%     leading_trials = [];
% end
% 
% combined_behavioral_data_with_headers = [headers;combined_behavioral_data];
% filename = [dir_recruited 'behavioral-responses_allsubj.csv'];
% writematrix(combined_behavioral_data_with_headers,filename)
% 
% toc;

%% Let's grab that average baseline data for each participant from above and create an array
% want to compare baseline range in anech vs reverb, and see how it
% correlates with behavior
% baseline_headers = ["subjID","anech","reverb"];
% baseline_table(:,1) = included_subj;
% baseline_table(:,2) = anech_baseline_period;
% baseline_table(:,3) = reverb_baseline_period;
% baseline_table = [baseline_headers;baseline_table];
% filename = [dir 'avg_baseline_period.csv'];
% writematrix(baseline_table,filename)

% for i = 1:length(included_subj)
%     names{i} = included_subj(i);
% end

% figure;
% plot(1:length(included_subj),anech_baseline_period,'o')
% hold on;
% plot(1:length(included_subj),reverb_baseline_period,'o')
% legend('Anech','Reverb')
% xlabel('Subject')
% ylabel('Average Pupil during Baseline Period (px)')
% xlim([0 15])
% set(gca,'xtick',1:length(included_subj),'xticklabel',names)
% base_and_behav = readtable("baseline_and_behavior.csv");
% anech_base_and_behav = find(strcmp(base_and_behav.envCond,'anech')==1);
% reverb_base_and_behav = find(strcmp(base_and_behav.envCond,'reverb')==1);


%% uninter vs inter plots SLOPE
% fig2 = figure;
% subplot(2,1,1)
% 
% a_uninter = shadedErrorBar(t_anech,mean(task_pd.anech_pupil_uninter_avg),std(task_pd.anech_pupil_uninter_avg)/sqrt(length(included_subj)),'lineProps','r');
% hold on;
% a_uninter.mainLine.LineWidth = 1.5;
% 
% r_uninter = shadedErrorBar(t_reverb,mean(task_pd.reverb_pupil_uninter_avg),std(task_pd.reverb_pupil_uninter_avg)/sqrt(length(subj_ID)),'lineProps','b');
% r_uninter.mainLine.LineWidth = 1.5;
% 
% 
% plot(t_anech(:,anech_uninter_group_window_idx(1):anech_uninter_group_window_idx(2)),anech_uninter_group_eval_fit,'--','LineWidth',1.5,'Color',[0.5 0 0]) %plotting the slope
% str = ['Slope: ' num2str(anech_uninter_group_fitting(1))];
% text(5,27,str,'Color','red','FontSize',14)
% 
% 
% plot(t_reverb(:,reverb_uninter_group_window_idx(1):reverb_uninter_group_window_idx(2)),reverb_uninter_group_eval_fit,'--','LineWidth',1.5,'Color',[0 0 0.7]) %plotting the slope
% str = ['Slope: ' num2str(reverb_uninter_group_fitting(1))];
% text(5,24,str,'Color','blue','FontSize',14)
% 
% xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% 
% xlim([-0.3 8])
% set(gca,'FontSize',14,'FontWeight','bold');
% title('Uninterrupted')
% 
% %%%%%%%%%%%%%% SECOND SUBPLOT
% subplot(2,1,2)
% hold on;
% a_inter = shadedErrorBar(t_anech,mean(task_pd.anech_pupil_inter_avg),std(task_pd.anech_pupil_inter_avg)/sqrt(length(included_subj)),'lineProps','r');
% a_inter.mainLine.LineWidth = 1.5;
% 
% r_inter = shadedErrorBar(t_reverb,mean(task_pd.reverb_pupil_inter_avg),std(task_pd.reverb_pupil_inter_avg)/sqrt(length(subj_ID)),'lineProps','b');
% r_inter.mainLine.LineWidth = 1.5;
% 
% 
% plot(t_anech(:,anech_inter_group_window_idx(1):anech_inter_group_window_idx(2)),anech_inter_group_eval_fit,'--','LineWidth',1.5,'Color',[0.5 0 0]) %plotting the slope
% str = ['Slope: ' num2str(anech_inter_group_fitting(1))];
% text(5,27,str,'Color','red','FontSize',14)
% 
% plot(t_reverb(:,reverb_inter_group_window_idx(1):reverb_inter_group_window_idx(2)),reverb_inter_group_eval_fit,'--','LineWidth',1.5,'Color',[0 0 0.7]) %plotting the slope
% str = ['Slope: ' num2str(reverb_inter_group_fitting(1))];
% text(5,24,str,'Color','blue','FontSize',14)
% 
% 
% xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(3),'--b','Interrupter','LineWidth',1.5,'FontWeight','bold','LabelVerticalAlignment','top','LabelHorizontalAlignment','center')
% 
% xlim([-0.3 8])
% set(gca,'FontSize',14,'FontWeight','bold');
% legend('Anechoic','Reverb')
% title('Interrupted')
% 
% han=axes(fig2,'visible','off','FontSize',14,'FontWeight','bold'); 
% han.XLabel.Visible='on';
% han.YLabel.Visible='on';
% ylabel(han,'Pupil Dilation (z)');
% xlabel(han,'Time (sec)');
% sgtitle('Comparing Slopes from Cue Onset','FontSize',16,'FontWeight','bold')

%%
% fig3 = figure;
% subplot(2,1,1)
% 
% a_uninter = shadedErrorBar(t_anech,mean(task_pd.anech_pupil_uninter_avg),std(task_pd.anech_pupil_uninter_avg)/sqrt(length(included_subj)),'lineProps','g');
% hold on;
% a_uninter.mainLine.LineWidth = 1.5;
% 
% plot(t_anech(:,anech_uninter_group_window_idx(1):anech_uninter_group_window_idx(2)),anech_uninter_group_eval_fit,'--','LineWidth',1.5,'Color',[0 0.3 0.1]) %plotting the slope
% str = ['Slope: ' num2str(anech_uninter_group_fitting(1))];
% text(5,27,str,'Color','green','FontSize',14)
% 
% a_inter = shadedErrorBar(t_anech,mean(task_pd.anech_pupil_inter_avg),std(task_pd.anech_pupil_inter_avg)/sqrt(length(included_subj)),'lineProps','k');
% a_inter.mainLine.LineWidth = 1.5;
% plot(t_anech(:,anech_inter_group_window_idx(1):anech_inter_group_window_idx(2)),anech_inter_group_eval_fit,'--','LineWidth',1.5,'Color',[0.3 0.4 0.5]) %plotting the slope
% str = ['Slope: ' num2str(anech_inter_group_fitting(1))];
% text(5,24,str,'Color','black','FontSize',14)
% 
% 
% xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% 
% xlim([-0.3 8])
% set(gca,'FontSize',14,'FontWeight','bold');
% title('Anechoic')
% 
% %%%%%%%%%%%%%% SECOND SUBPLOT
% subplot(2,1,2)
% hold on;
% 
% r_uninter = shadedErrorBar(t_reverb,mean(task_pd.reverb_pupil_uninter_avg),std(task_pd.reverb_pupil_uninter_avg)/sqrt(length(subj_ID)),'lineProps','g');
% r_uninter.mainLine.LineWidth = 1.5;
% plot(t_reverb(:,reverb_uninter_group_window_idx(1):reverb_uninter_group_window_idx(2)),reverb_uninter_group_eval_fit,'--','LineWidth',1.5,'Color',[0 0.3 0.1]) %plotting the slope
% str = ['Slope: ' num2str(reverb_uninter_group_fitting(1))];
% text(5,27,str,'Color','green','FontSize',14)
% 
% 
% r_inter = shadedErrorBar(t_reverb,mean(task_pd.reverb_pupil_inter_avg),std(task_pd.reverb_pupil_inter_avg)/sqrt(length(subj_ID)),'lineProps','k');
% r_inter.mainLine.LineWidth = 1.5;
% plot(t_reverb(:,reverb_inter_group_window_idx(1):reverb_inter_group_window_idx(2)),reverb_inter_group_eval_fit,'--','LineWidth',1.5,'Color',[0.3 0.4 0.5]) %plotting the slope
% str = ['Slope: ' num2str(reverb_inter_group_fitting(1))];
% text(5,24,str,'Color','black','FontSize',14)
% 
% 
% xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(3),'--b','Interrupter','LineWidth',1.5,'FontWeight','bold','LabelVerticalAlignment','top','LabelHorizontalAlignment','center')
% 
% xlim([-0.3 8])
% set(gca,'FontSize',14,'FontWeight','bold');
% legend('Uninterrupted','Interrupted')
% title('Reverb')
% 
% han=axes(fig3,'visible','off','FontSize',14,'FontWeight','bold'); 
% han.XLabel.Visible='on';
% han.YLabel.Visible='on';
% ylabel(han,'Pupil Dilation (z)');
% xlabel(han,'Time (sec)');
% sgtitle('Comparing Slopes from Cue Onset','FontSize',16,'FontWeight','bold')


%% anech vs reverb SLOPE
% fig4 = figure;
% subplot(2,1,1)
% 
% a_uninter = shadedErrorBar(t_anech,mean(task_pd.anech_pupil_uninter_avg),std(task_pd.anech_pupil_uninter_avg)/sqrt(length(included_subj)),'lineProps','k');
% hold on;
% a_uninter.mainLine.LineWidth = 1.5;
% 
% a_inter = shadedErrorBar(t_anech,mean(task_pd.anech_pupil_inter_avg),std(task_pd.anech_pupil_inter_avg)/sqrt(length(included_subj)),'lineProps','g');
% a_inter.mainLine.LineWidth = 1.5;
% 
% 
% plot(t_anech(:,anech_uninter_group_window_idx(1):anech_uninter_group_window_idx(2)),anech_uninter_group_eval_fit,'--','LineWidth',1.5,'Color','black') %plotting the slope
% str = ['Slope: ' num2str(anech_uninter_group_fitting(1))];
% text(5,27,str,'Color','black','FontSize',14)
% 
% plot(t_anech(:,anech_inter_group_window_idx(1):anech_inter_group_window_idx(2)),anech_inter_group_eval_fit,'--','LineWidth',1.5,'Color',[3 125 80]/256) %plotting the slope
% str = ['Slope: ' num2str(anech_inter_group_fitting(1))];
% text(5,24,str,'Color','green','FontSize',14)
% 
% 
% xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(3),'--b','Interrupter','LineWidth',1.5,'FontWeight','bold','LabelVerticalAlignment','top','LabelHorizontalAlignment','center')
% 
% xlim([-0.3 8])
% set(gca,'FontSize',14,'FontWeight','bold');
% title('Anechoic')
% 
% %%%%%%%%%%%%%% SECOND SUBPLOT REVERB
% subplot(2,1,2)
% hold on;
% r_uninter = shadedErrorBar(t_reverb,mean(task_pd.reverb_pupil_uninter_avg),std(task_pd.reverb_pupil_uninter_avg)/sqrt(length(subj_ID)),'lineProps','k');
% r_uninter.mainLine.LineWidth = 1.5;
% 
% r_inter = shadedErrorBar(t_reverb,mean(task_pd.reverb_pupil_inter_avg),std(task_pd.reverb_pupil_inter_avg)/sqrt(length(subj_ID)),'lineProps','g');
% r_inter.mainLine.LineWidth = 1.5;
% 
% 
% plot(t_reverb(:,reverb_uninter_group_window_idx(1):reverb_uninter_group_window_idx(2)),reverb_uninter_group_eval_fit,'--','LineWidth',1.5,'Color','black') %plotting the slope
% str = ['Slope: ' num2str(reverb_uninter_group_fitting(1))];
% text(5,27,str,'Color','black','FontSize',14)
% 
% plot(t_reverb(:,reverb_inter_group_window_idx(1):reverb_inter_group_window_idx(2)),reverb_inter_group_eval_fit,'--','LineWidth',1.5,'Color',[3 125 80]/256) %plotting the slope
% str = ['Slope: ' num2str(reverb_inter_group_fitting(1))];
% text(5,24,str,'Color','green','FontSize',14)
% 
% 
% xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
% xline(stream_onsets(3),'--b','Interrupter','LineWidth',1.5,'FontWeight','bold','LabelVerticalAlignment','top','LabelHorizontalAlignment','center')
% 
% xlim([-0.3 8])
% set(gca,'FontSize',14,'FontWeight','bold');
% legend('Uninterrupted','Interrupted')
% title('Reverb')
% 
% han=axes(fig4,'visible','off','FontSize',14,'FontWeight','bold');
% han.XLabel.Visible='on';
% han.YLabel.Visible='on';
% ylabel(han,'Pupil Dilation (z)');
% xlabel(han,'Time (sec)');
% sgtitle('Comparing Slopes from Cue Onset','FontSize',16,'FontWeight','bold')






% then let's find it from the onset of the interrupter













