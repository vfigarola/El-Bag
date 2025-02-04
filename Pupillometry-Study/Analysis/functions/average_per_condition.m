%% Victoria Figarola
% this function averages the data for each condition

function output = average_per_condition(task_analysis,included_subj,task_anech_pupil_uninter,task_anech_pupil_inter,task_reverb_pupil_uninter,task_reverb_pupil_inter)

for i = 1:length(included_subj)
    anech_pupil_uninter_avg(i,:) = mean(squeeze(task_anech_pupil_uninter(i,:,:)),2);
    anech_pupil_inter_avg(i,:) = mean(squeeze(task_anech_pupil_inter(i,:,:)),2);
    reverb_pupil_uninter_avg(i,:) = mean(squeeze(task_reverb_pupil_uninter(i,:,:)),2);
    reverb_pupil_inter_avg(i,:) = mean(squeeze(task_reverb_pupil_inter(i,:,:)),2);
end

trig_time_ax_subj = [];
for i = 1:length(included_subj)
    new_field_name = append("P",included_subj(i));
    trig_time_ax_subj = [trig_time_ax_subj task_analysis.(new_field_name).time_btw_trigs];
    
end

output = struct();
output.anech_pupil_uninter_avg= anech_pupil_uninter_avg;
output.anech_pupil_inter_avg= anech_pupil_inter_avg;
output.reverb_pupil_uninter_avg =reverb_pupil_uninter_avg;
output.reverb_pupil_inter_avg = reverb_pupil_inter_avg;
output.trig_time_ax_subj = trig_time_ax_subj;
