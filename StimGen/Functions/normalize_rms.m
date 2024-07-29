%% Author: Wusheng Liang

% function normalize_rms(doNormalize,doShowRMS)
% this function is used for normalizing RMS for cat and dog sounds to same
% value as syllables (0.05)
% doNormalize and doShowRMS are boolean controling if normalize / show RMS

doNormalize=true;
doShowRMS=true;

desired_rms = 0.05; 

syllable_folder = '../ash/';
% inter_folder = 'interrupting_stimuli_source/';
% SN_sylb_folder = './stimuli/normalized-mono/broadband/';

folders = string(syllable_folder);
% folders = [string(syllable_folder) string(inter_folder)];

if doNormalize
    fprintf("Normalizing files in folders below to RMS = %f:\n",desired_rms)
    disp(folders)
elseif doShowRMS
    fprintf("Showing RMS for files in folders below:\n")
    disp(folders)
end

for folder = folders
    folder = char(folder);
    files = dir([folder '*.wav']);
    for i = 1:numel(files)
        sig_file = [folder files(i).name]; 
        [sig,fs] = audioread(sig_file);
        this_rms = rms(sig);
        if doNormalize
            sig_norm = sig./this_rms.*desired_rms;
            if max(max(sig_norm)) > 1
                fprintf("Peak for normalized signal %s exceed 1!\n",files(i).name)
            end
            audiowrite(sig_file,sig_norm,fs)
        end
        if doShowRMS
            fprintf("RMS for signal %s: %f\n",files(i).name,this_rms)
        end
    end
end

% end