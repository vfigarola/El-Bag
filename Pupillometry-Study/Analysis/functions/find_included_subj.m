%% Victoria Figarola
% This function finds the included subjects

function included_subj = find_included_subj(subj_ID,task_analysis)

included_subj_idx = [];
for i = 1:length(subj_ID)
    new_field_name = append("P",subj_ID(i));
    included_subj_idx = [included_subj_idx;strcmp(task_analysis.(new_field_name).excluded,"included")];
    included_subj = subj_ID(find(included_subj_idx==1))';
end
