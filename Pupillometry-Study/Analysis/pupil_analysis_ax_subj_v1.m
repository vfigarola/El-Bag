%% Victoria Figarola
% This script compares subject pupil data 

%% MACROS / Inputs 
addpath /Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/
addpath functions/
addpath errorbar_files/

%% testing single subject
% clear 
% clc

% subj_ID = "003";
% i=1;
% N_TotalTrials = 160;
% N_EnvTrials = 80; %80 trials/env
% fs = 1000;
% preStim_baseline = 0.5*fs;
% preBlink = 0.03*fs;
% postBlink = 0.15*fs;
% fc = 10; %lowpass filter cutoff 
% N_samples_anech = 9776;
% N_samples_reverb = 11534;
% 
% dir = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
% data = readtable(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),'.asc'), 'FileType','text');
% behavioral_data = load(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),"_behavioral.mat"));
% events = behavioral_data.edfstruct_data.FEVENT;

%%
tic;
subj_ID = ["001","003","005","008","010","014","015","016","017","018","019","021","024","025","026","027","029","030","031"];
% subj_ID = ["001","003"];

N_TotalTrials = 160;
N_EnvTrials = 80; %80 trials/env
fs = 1000;
preStim_baseline = 1*fs;
baseline_period = 0.2 * fs; %200 ms for bc and normalization
preBlink = 0.03*fs;
postBlink = 0.15*fs;
fc = 10; %lowpass filter cutoff 
N_samples_anech = 9776;
N_samples_reverb = 11534;

headers = ["blinkCt","intCond","envCond","ID"]; 

blink_table = [];
for i = 1:length(subj_ID)
    dir = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
    data = readtable(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),'.asc'), 'FileType','text');
    combined_behavioral_data = load(append(dir,"P",num2str(subj_ID(i)),'/',num2str(subj_ID(i)),"_behavioral.mat"));
    events = combined_behavioral_data.edfstruct_data.FEVENT;
    new_field_name = append("P",subj_ID(i));
    analysis.(new_field_name) = pupil_analysis_v2(num2str(subj_ID(i)),data,combined_behavioral_data,events,N_TotalTrials,N_EnvTrials,fs,preStim_baseline,preBlink,postBlink,fc,N_samples_anech,N_samples_reverb);

    %%%%%%%%%%%%%%%%% GETTING BLINK INFO FOR R ANALYSIS %%%%%%%%%%%%%%%%%
    if strcmp(analysis.(new_field_name).excluded,"included")
        blink_table = [blink_table;analysis.(new_field_name).blink_info.blink_count_table];
    end
end

%%%%%%%%%%%%%%%%% SAVING BLINK INFO FOR R ANALYSIS %%%%%%%%%%%%%%%%%
blink_table = [headers;blink_table];
% writematrix(blink_table,"blink_count.csv")
toc;

%% Only want to include the subjects that aren't excluded
included_subj_idx = [];
for i = 1:length(subj_ID)
    new_field_name = append("P",subj_ID(i));
    included_subj_idx = [included_subj_idx;strcmp(analysis.(new_field_name).excluded,"included")];
    included_subj = subj_ID(find(included_subj_idx==1))';
end

%% Behavior! Added this in here since we only want behavior from "included" subjects
% dir_recruited = '/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/';
% headers = ["score1","score2","score3","score4","intCond","envCond","subjID"]; 
% 
% combined_behavioral_data =[];
% for i = 1:length(included_subj)
%     behavioral_data_filename = append('/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Data/Recruited/P', included_subj(i),'/',included_subj(i),'_behavioral.mat');
%     behavioral_data = pilot_behavioral_analysis_script(behavioral_data_filename,included_subj(i));
%     combined_behavioral_data = [combined_behavioral_data;behavioral_data];
% end
% 
% combined_behavioral_data_with_headers = [headers;combined_behavioral_data];
% filename = [dir_recruited 'behavioral-responses.csv'];
% writematrix(combined_behavioral_data_with_headers,filename)

%% Normalize the Data! 
for i = 1:length(included_subj)
    new_field_name = append("P",included_subj(i));
    [anech_uninter_data_norm,anech_inter_data_norm, anech_baseline_period(i,:)] = normalize_pupil_data(fs,N_EnvTrials,analysis.(new_field_name).anech_pupil_uninter,analysis.(new_field_name).anech_pupil_inter,N_samples_anech);
    [reverb_uninter_data_norm,reverb_inter_data_norm, reverb_baseline_period(i,:)] = normalize_pupil_data(fs,N_EnvTrials,analysis.(new_field_name).reverb_pupil_uninter,analysis.(new_field_name).reverb_pupil_inter,N_samples_reverb);

    anech_pupil_uninter(i,:,:) = anech_uninter_data_norm;
    anech_pupil_inter(i,:,:) = anech_inter_data_norm;

    reverb_pupil_uninter(i,:,:) = reverb_uninter_data_norm;
    reverb_pupil_inter(i,:,:) = reverb_inter_data_norm;

end



%% Now let's average across conditions! 
for i = 1:size(anech_pupil_uninter,1)
    anech_pupil_uninter_avg(i,:) = mean(squeeze(anech_pupil_uninter(i,:,:)),2);
    anech_pupil_inter_avg(i,:) = mean(squeeze(anech_pupil_inter(i,:,:)),2);
    reverb_pupil_uninter_avg(i,:) = mean(squeeze(reverb_pupil_uninter(i,:,:)),2);
    reverb_pupil_inter_avg(i,:) = mean(squeeze(reverb_pupil_inter(i,:,:)),2);
end

trig_time_ax_subj = [];
for i = 1:length(included_subj)
    new_field_name = append("P",included_subj(i));
    trig_time_ax_subj = [trig_time_ax_subj analysis.(new_field_name).time_btw_trigs];
end

%% Let's find the pupil peak 
%+1 50ms around peak, then average window



%% let's shade the area where the audio is being played

t_anech = linspace(-1000,length(anech_pupil_uninter_avg),length(anech_pupil_uninter_avg));
t_reverb = linspace(-1000,length(reverb_pupil_uninter_avg),length(reverb_pupil_uninter_avg));

fs_stream = 44100;
t_anech_audio = 0:1/fs_stream:(246650-1)/fs_stream;
t_reverb_audio = 0:1/fs_stream:(324132-1)/fs_stream;

%% let's also align when the interrupter comes on 
% interval = floor(0.3*fs_stream); %syllables occur every 300ms
% onset_to_onset = 0.6;
% target_onset_times = [1,onset_to_onset,2*onset_to_onset,3*onset_to_onset]; %0=cue, t_T1=first target syll
% inter_onset = target_onset_times(1) + 0.475;

stream_onsets = [max(mean(trig_time_ax_subj)) (max(mean(trig_time_ax_subj)+0.6)) (max(mean(trig_time_ax_subj))+0.6+0.475)];
    %cue, syllable 1, interrupter

stream_end = 4*0.6+.3+0.45;

%% Plotting
fig1 = figure(1); 
subplot(2,1,1)
sgtitle(['Pupil Area (n=' num2str(length(included_subj)) ')'],'FontSize',16,'FontWeight','bold')

a_uninter = shadedErrorBar(t_anech/1000,mean(anech_pupil_uninter_avg),std(anech_pupil_uninter_avg)/sqrt(length(included_subj)),'lineProps','k');
hold on
a_uninter.mainLine.LineWidth = 1.5;
% a_uninter.mainLine.Color = [0.6 0.6 1];

a_inter = shadedErrorBar(t_anech/1000,mean(anech_pupil_inter_avg),std(anech_pupil_inter_avg)/sqrt(length(included_subj)),'lineProps','g');
a_inter.mainLine.LineWidth = 1.5;

xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
xline(stream_onsets(3),'--b','Interrupter','LineWidth',1.5,'FontWeight','bold','LabelVerticalAlignment','top','LabelHorizontalAlignment','center')
% xline(max(t_anech_audio),'--k','End Trial Stream','LineWidth',1.5,'FontWeight','bold')
rectangle(Position=[max(mean(trig_time_ax_subj)),-10,max(t_anech_audio),2], FaceColor=[0.8 0.8 0.8], EdgeColor=[0.7 0.7 0.7])

% ylim([900 1800])
xlim([-0.5 8])
set(gca,'FontSize',14,'FontWeight','bold');
% xlabel('Time (sec)')
% ylabel('Pupil Area (z)')
title('Anechoic')

subplot(2,1,2)
r_uninter = shadedErrorBar(t_reverb/1000,mean(reverb_pupil_uninter_avg),std(reverb_pupil_uninter_avg)/sqrt(length(subj_ID)),'lineProps','k');
hold on
r_uninter.mainLine.LineWidth = 1.5;

r_inter = shadedErrorBar(t_reverb/1000,mean(reverb_pupil_inter_avg),std(reverb_pupil_inter_avg)/sqrt(length(subj_ID)),'lineProps','g');
r_inter.mainLine.LineWidth = 1.5;

xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
xline(stream_onsets(3),'--b','Interrupter','LineWidth',1.5,'FontWeight','bold','LabelVerticalAlignment','top','LabelHorizontalAlignment','center')
% xline(max(t_reverb_audio),'--k','End Trial Stream','LineWidth',1.5,'FontWeight','bold')
rectangle(Position=[max(mean(trig_time_ax_subj)),-10,max(t_reverb_audio),2], FaceColor=[0.5020 0.5020 0.5020], EdgeColor=[0.7 0.7 0.7])

% ylim([900 1800])
xlim([-0.5 8])
set(gca,'FontSize',14,'FontWeight','bold');
legend('Uninter','Inter')
% xlabel('Time (sec)')
title('Reverb')

han=axes(fig1,'visible','off','FontSize',14,'FontWeight','bold'); 
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Pupil Dilation (z)');
xlabel(han,'Time (sec)');


fig2 = figure(2); 
subplot(2,1,1)
sgtitle(['Pupil Area (n=' num2str(length(included_subj)) ')'],'FontSize',16,'FontWeight','bold')

a_uninter = shadedErrorBar(t_anech/1000,mean(anech_pupil_uninter_avg),std(anech_pupil_uninter_avg)/sqrt(length(included_subj)),'lineProps','r');
hold on
a_uninter.mainLine.LineWidth = 1.5;

r_uninter = shadedErrorBar(t_reverb/1000,mean(reverb_pupil_uninter_avg),std(reverb_pupil_uninter_avg)/sqrt(length(included_subj)),'lineProps','b');
r_uninter.mainLine.LineWidth = 1.5;

% xline(mean(trig_time_ax_subj),'--k','Stream Onset','LineWidth',1.5,'FontWeight','bold')
% xline(max(t_reverb_audio),'--k','End Reverb Stream','LineWidth',1.5,'FontWeight','bold')
% xline(max(t_anech_audio),'--k','End Anech Stream','LineWidth',1.5,'FontWeight','bold')
xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
rectangle(Position=[max(mean(trig_time_ax_subj)),-8,max(t_anech_audio),2], FaceColor=[255 204 204]/255, EdgeColor=[0.7 0.7 0.7])
rectangle(Position=[max(mean(trig_time_ax_subj)),-10,max(t_reverb_audio),2], FaceColor=[204 229 255]/255, EdgeColor=[0.7 0.7 0.7])

% ylim([900 1800])
xlim([-0.5 8])

set(gca,'FontSize',14,'FontWeight','bold');
% xlabel('Time (sec)')
% ylabel('Pupil Area (z)')
title('Uninterrupted')

subplot(2,1,2)
a_inter = shadedErrorBar(t_anech/1000,mean(anech_pupil_inter_avg),std(anech_pupil_inter_avg)/sqrt(length(included_subj)),'lineProps','r');
hold on;
a_inter.mainLine.LineWidth = 1.5;

r_inter = shadedErrorBar(t_reverb/1000,mean(reverb_pupil_inter_avg),std(reverb_pupil_inter_avg)/sqrt(length(included_subj)),'lineProps','b');
r_inter.mainLine.LineWidth = 1.5;

% xline(mean(trig_time_ax_subj),'--k','Stream Onset','LineWidth',1.5,'FontWeight','bold')
% xline(max(t_reverb_audio),'--k','End Reverb Stream','LineWidth',1.5,'FontWeight','bold')
% xline(max(t_anech_audio),'--k','End Anech Stream','LineWidth',1.5,'FontWeight','bold')
xline(stream_onsets(1),'--k','Cue','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
xline(stream_onsets(2),'--k','Stream','LineWidth',1.5,'FontWeight','bold','LabelHorizontalAlignment','center')
xline(stream_onsets(3),'--b','Interrupter','LineWidth',1.5,'FontWeight','bold','LabelVerticalAlignment','top','LabelHorizontalAlignment','center')
rectangle(Position=[max(mean(trig_time_ax_subj)),-8,max(t_anech_audio),2], FaceColor=[255 204 204]/255, EdgeColor=[0.7 0.7 0.7])
rectangle(Position=[max(mean(trig_time_ax_subj)),-10,max(t_reverb_audio),2], FaceColor=[204 229 255]/255, EdgeColor=[0.7 0.7 0.7])

% ylim([900 1800])
xlim([-0.5 8])

set(gca,'FontSize',14,'FontWeight','bold');
legend('Anechoic','Reverb')
% xlabel('Time (sec)')
title('Interrupted')

han=axes(fig2,'visible','off','FontSize',14,'FontWeight','bold'); 
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Pupil Dilation (z)');
xlabel(han,'Time (sec)');
%% 







