%% Victoria Figarola
% This script imports BRIRs, syllables and interrupters, and spatializes
    % them
% Syllables are spatialized +30 & -30; Interrupers are spatialized +90 &
    % -90
% The resulting stimuli are saved as a 3D array:
    % +30 syllables: 6 x 2 x 333333 (3 syllables/gender)
    % -30 syllables: 6 x 2 x 333333 (3 syllables/gender)
    % +90 interrupters: 48 x 2 x 333333
    % -90 interrupters: 48 x 2 x 333333
% Outputs:
    % syllable_right_reverb: all 6 spatialized, reverberant syllables (+30)
    % syllable_left_reverb:  all 6 spatialized, reverberant syllables (-30)
    % syllable_right_anech
    % syllable_left_anech
  
function [syllable_right_reverb,syllable_left_reverb,syllable_right_anech,syllable_left_anech,inter_anech_pos_90,inter_anech_neg_90,inter_reverb_pos_90,inter_reverb_neg_90] = generating_stimuli_v3()
%% Initializing variables
% addpath BRIRs/
% addpath syllables/
% addpath interrupting_stimuli_source/

nSyllables = 6;
nInterrupters = 80;
% syllables_name = ["ba";"da";"ga"];
fs = 44100;

% For pseudo-anechoic, use the following variables 
BRIR_distance = 3; %3=1m distance
BRIR_azimuth = [3 7]; %30 and -30 degrees

%% Importing syllables
syll_directory = "/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Code/StimGen/syllables/";
syllable_files = dir(fullfile(syll_directory,'*.wav'));

for i = 1:numel(syllable_files) %change this depending on location within digits_file
    F = fullfile(syll_directory,syllable_files(i).name);
    [y,fs]=audioread(F); %reading in all audio files
    syllables(:,i)= y(1:15434,:); %adding in audio files to data field in structure   
end
    %1 = F ba; 2 = M ba; 3 = F da; 4=M da; 5=F ga; 6=M ga
clear syll_directory F i y syllable_files


inter_directory = "/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Code/StimGen/interrupting_stimuli_source/";
inter_files = dir(fullfile(inter_directory,'*.wav'));

for i = 1:numel(inter_files) %sorting them in order
    file_names(i,:) = string(inter_files(i).name);
end
sorting_file_names = file_names([1,12,23,34,45,56,67,78,80,2:11,13:22,24:33,35:44,46:55,57:66,68:77,79],:);

[inter_files.name] = sorting_file_names{:};

for i = 1:numel(inter_files) %change this depending on location within digits_file
    F = fullfile(inter_directory,inter_files(i).name);
    [y,fs]=audioread(F); %reading in all audio files
    if size(y,1) >= 11025
        y = y(1:11025,:);
    elseif size(y,1) <= 11025
        y(11015:11025,:) = 0;
    end
    interrupters(:,i) = y; %adding in audio files to data field in structure
end

clear inter_directory F i y file_names sorting_file_names

%% Importing BRIRs from CMU
directory_BRIR = "/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Code/StimGen/BRIRs/";
reverb_BRIR_files = dir(fullfile(directory_BRIR,'*.wav'));

for i = 1:numel(reverb_BRIR_files) %change this depending on location within digits_file
    F = fullfile(directory_BRIR,reverb_BRIR_files(i).name);
    [y,fs]=audioread(F,'native'); %reading in all audio files
    reverb_BRIR(i,:,:)= y; %adding in audio files to data field in structure
        % 2 x 176400 x 2 ==> 1=30 deg, 2=90deg x samples x 1=left ear; 2=rightear
end
clear F directory_BRIR reverb_BRIR_files

anechRev = load("/Users/victoriafigarola/Documents/1_CMU/Barb_Lab/Projects/SA-Reverb/Code/StimGen/BRIRs/anechRev.mat");
clear bin_xcorr FIMP_R FIMP_L

BRIR_Lear_firstrepeatedmeasure_anech = squeeze(anechRev.fimp_l(:,1,:,:));
    %time samples x distance (0.15, 0.40, 1 m) x direction (0:15:90 degrees)
BRIR_Rear_firstrepeatedmeasure_anech = squeeze(anechRev.fimp_r(:,1,:,:));
    %time samples x distance (0.15, 0.40, 1 m) x direction (0:15:90 degrees)

% Getting BRIR for pseudo-anechoic, 30 degrees for Left and Right Ear,
% 1m distance
anech_BRIR_Lear_30deg = squeeze(BRIR_Lear_firstrepeatedmeasure_anech(:,BRIR_distance,BRIR_azimuth(1)));
anech_BRIR_Rear_30deg = squeeze(BRIR_Rear_firstrepeatedmeasure_anech(:,BRIR_distance,BRIR_azimuth(1)));
% Getting BRIR for pseudo-anechoic, 90 degrees for Left and Right Ear,
% 1m distance => interrupter
anech_BRIR_Lear_90deg = squeeze(BRIR_Lear_firstrepeatedmeasure_anech(:,BRIR_distance,BRIR_azimuth(2)));
anech_BRIR_Rear_90deg = squeeze(BRIR_Rear_firstrepeatedmeasure_anech(:,BRIR_distance,BRIR_azimuth(2)));

anech_30_BRIR = [anech_BRIR_Lear_30deg anech_BRIR_Rear_30deg];
anech_90_BRIR = [anech_BRIR_Lear_90deg anech_BRIR_Rear_90deg];

clear anechRev BRIR_Lear_firstrepeatedmeasure_anech BRIR_Rear_firstrepeatedmeasure_anech anech_BRIR_Lear_30deg anech_BRIR_Rear_30deg anech_BRIR_Lear_90deg anech_BRIR_Rear_90deg

%% Now let's convolve syllables with anechoic and reverberant BRIRs
azimuth=1; %1=30deg

for k = 1:nSyllables
    %%%%%%%%%%% +30 DEG REVERB
    Lear_conv_30deg(:,k) = conv(syllables(:,k),squeeze(reverb_BRIR(azimuth,:,1)),'full'); %30 degrees
    Lear_conv_30deg_scaled(:,k) = (Lear_conv_30deg(:,k)-mean(Lear_conv_30deg(:,k)))/(max(Lear_conv_30deg(:,k))-min(Lear_conv_30deg(:,k)));
    Lear_conv_30deg_scaled_ramped(:,k) = rampsound(Lear_conv_30deg_scaled(:,k),fs,0.01);

    Rear_conv_30deg(:,k) = conv(syllables(:,k),squeeze(reverb_BRIR(azimuth,:,2)),'full'); %30 degrees
    Rear_conv_30deg_scaled(:,k) = (Rear_conv_30deg(:,k)-mean(Rear_conv_30deg(:,k)))/(max(Rear_conv_30deg(:,k))-min(Rear_conv_30deg(:,k)));
    Rear_conv_30deg_scaled_ramped(:,k) = rampsound(Rear_conv_30deg_scaled(:,k),fs,0.01);


    %%%%%%%%%%% -30 DEG REVERB
    Lear_conv_Neg_30deg(:,k) = conv(syllables(:,k),squeeze(reverb_BRIR(azimuth,:,2)),'full'); %-30 degrees
    Lear_conv_Neg_30deg_scaled(:,k) = (Lear_conv_Neg_30deg(:,k)-mean(Lear_conv_Neg_30deg(:,k)))/(max(Lear_conv_Neg_30deg(:,k))-min(Lear_conv_Neg_30deg(:,k)));
    Lear_conv_Neg_30deg_scaled_ramped(:,k) = rampsound(Lear_conv_Neg_30deg_scaled(:,k),fs,0.01);
 

    Rear_conv_Neg_30deg(:,k) = conv(syllables(:,k),squeeze(reverb_BRIR(azimuth,:,1)),'full'); %-30 degrees
    Rear_conv_Neg_30deg_scaled(:,k) = (Rear_conv_Neg_30deg(:,k)-mean(Rear_conv_Neg_30deg(:,k)))/(max(Rear_conv_Neg_30deg(:,k))-min(Rear_conv_Neg_30deg(:,k)));
    Rear_conv_Neg_30deg_scaled_ramped(:,k) = rampsound(Rear_conv_Neg_30deg_scaled(:,k),fs,0.01);

    
    %%%%%%%%%%% +30 DEG ANECH
    Lear_anech_conv_30deg(:,k) = conv(syllables(:,k),anech_30_BRIR(:,1),'full'); %30 degrees
    Lear_anech_conv_30deg_scaled(:,k) = (Lear_anech_conv_30deg(:,k)-mean(Lear_anech_conv_30deg(:,k)))/(max(Lear_anech_conv_30deg(:,k))-min(Lear_anech_conv_30deg(:,k)));
    Lear_anech_conv_30deg_scaled_ramped(:,k) = rampsound(Lear_anech_conv_30deg_scaled(:,k),fs,0.01);

    Rear_anech_conv_30deg(:,k) = conv(syllables(:,k),anech_30_BRIR(:,2),'full'); %30 degrees
    Rear_anech_conv_30deg_scaled(:,k) = (Rear_anech_conv_30deg(:,k)-mean(Rear_anech_conv_30deg(:,k)))/(max(Rear_anech_conv_30deg(:,k))-min(Rear_anech_conv_30deg(:,k)));
    Rear_anech_conv_30deg_scaled_ramped(:,k) = rampsound(Rear_anech_conv_30deg_scaled(:,k),fs,0.01);

    %%%%%%%%%%% -30 DEG ANECH
    Lear_anech_neg_conv_30deg(:,k) = conv(syllables(:,k),anech_30_BRIR(:,1),'full'); %30 degrees
    Lear_anech_neg_conv_30deg_scaled(:,k) = (Lear_anech_neg_conv_30deg(:,k)-mean(Lear_anech_neg_conv_30deg(:,k)))/(max(Lear_anech_neg_conv_30deg(:,k))-min(Lear_anech_neg_conv_30deg(:,k)));
    Lear_anech_neg_conv_30deg_scaled_ramped(:,k) = rampsound(Lear_anech_neg_conv_30deg_scaled(:,k),fs,0.01);

    Rear_anech_neg_conv_30deg(:,k) = conv(syllables(:,k),anech_30_BRIR(:,2),'full'); %30 degrees
    Rear_anech_neg_conv_30deg_scaled(:,k) = (Rear_anech_neg_conv_30deg(:,k)-mean(Rear_anech_neg_conv_30deg(:,k)))/(max(Rear_anech_neg_conv_30deg(:,k))-min(Rear_anech_neg_conv_30deg(:,k)));
    Rear_anech_neg_conv_30deg_scaled_ramped(:,k) = rampsound(Rear_anech_neg_conv_30deg_scaled(:,k),fs,0.01);


end
%%%%% reverb
ba_F_reverb_pos_spatialized = [Rear_conv_30deg_scaled_ramped(:,1) Lear_conv_30deg_scaled_ramped(:,1)];
ba_M_reverb_pos_spatialized = [Rear_conv_30deg_scaled_ramped(:,2) Lear_conv_30deg_scaled_ramped(:,2)];
da_F_reverb_pos_spatialized = [Rear_conv_30deg_scaled_ramped(:,3) Lear_conv_30deg_scaled_ramped(:,3)];
da_M_reverb_pos_spatialized = [Rear_conv_30deg_scaled_ramped(:,4) Lear_conv_30deg_scaled_ramped(:,4)];
ga_F_reverb_pos_spatialized = [Rear_conv_30deg_scaled_ramped(:,5) Lear_conv_30deg_scaled_ramped(:,5)];
ga_M_reverb_pos_spatialized = [Rear_conv_30deg_scaled_ramped(:,6) Lear_conv_30deg_scaled_ramped(:,6)];

syllable_right_reverb = zeros(6,length(ba_F_reverb_pos_spatialized),2);
syllable_right_reverb(1,:,:) = ba_F_reverb_pos_spatialized;
syllable_right_reverb(2,:,:) = ba_M_reverb_pos_spatialized;
syllable_right_reverb(3,:,:) = da_F_reverb_pos_spatialized;
syllable_right_reverb(4,:,:) = da_M_reverb_pos_spatialized;
syllable_right_reverb(5,:,:) = ga_F_reverb_pos_spatialized;
syllable_right_reverb(6,:,:) = ga_M_reverb_pos_spatialized;


ba_F_reverb_neg_spatialized = [Rear_conv_Neg_30deg_scaled_ramped(:,1) Lear_conv_Neg_30deg_scaled_ramped(:,1)];
ba_M_reverb_neg_spatialized = [Rear_conv_Neg_30deg_scaled_ramped(:,2) Lear_conv_Neg_30deg_scaled_ramped(:,2)];
da_F_reverb_neg_spatialized = [Rear_conv_Neg_30deg_scaled_ramped(:,3) Lear_conv_Neg_30deg_scaled_ramped(:,3)];
da_M_reverb_neg_spatialized = [Rear_conv_Neg_30deg_scaled_ramped(:,4) Lear_conv_Neg_30deg_scaled_ramped(:,4)];
ga_F_reverb_neg_spatialized = [Rear_conv_Neg_30deg_scaled_ramped(:,5) Lear_conv_Neg_30deg_scaled_ramped(:,5)];
ga_M_reverb_neg_spatialized = [Rear_conv_Neg_30deg_scaled_ramped(:,6) Lear_conv_Neg_30deg_scaled_ramped(:,6)];

syllable_left_reverb = zeros(6,length(ba_F_reverb_pos_spatialized),2);
syllable_left_reverb(1,:,:) = ba_F_reverb_neg_spatialized;
syllable_left_reverb(2,:,:) = ba_M_reverb_neg_spatialized;
syllable_left_reverb(3,:,:) = da_F_reverb_neg_spatialized;
syllable_left_reverb(4,:,:) = da_M_reverb_neg_spatialized;
syllable_left_reverb(5,:,:) = ga_F_reverb_neg_spatialized;
syllable_left_reverb(6,:,:) = ga_M_reverb_neg_spatialized;

%%%%% anech
ba_F_anech_pos_spatialized = [Lear_anech_conv_30deg_scaled_ramped(:,1) Rear_anech_neg_conv_30deg_scaled_ramped(:,1)];
ba_M_anech_pos_spatialized = [Lear_anech_conv_30deg_scaled_ramped(:,2) Rear_anech_neg_conv_30deg_scaled_ramped(:,2)];
da_F_anech_pos_spatialized = [Lear_anech_conv_30deg_scaled_ramped(:,3) Rear_anech_neg_conv_30deg_scaled_ramped(:,3)];
da_M_anech_pos_spatialized = [Lear_anech_conv_30deg_scaled_ramped(:,4) Rear_anech_neg_conv_30deg_scaled_ramped(:,4)];
ga_F_anech_pos_spatialized = [Lear_anech_conv_30deg_scaled_ramped(:,5) Rear_anech_neg_conv_30deg_scaled_ramped(:,5)];
ga_M_anech_pos_spatialized = [Lear_anech_conv_30deg_scaled_ramped(:,6) Rear_anech_neg_conv_30deg_scaled_ramped(:,6)];

syllable_right_anech = zeros(6,length(ba_F_anech_pos_spatialized),2);
syllable_right_anech(1,:,:) = ba_F_anech_pos_spatialized;
syllable_right_anech(2,:,:) = ba_M_anech_pos_spatialized;
syllable_right_anech(3,:,:) = da_F_anech_pos_spatialized;
syllable_right_anech(4,:,:) = da_M_anech_pos_spatialized;
syllable_right_anech(5,:,:) = ga_F_anech_pos_spatialized;
syllable_right_anech(6,:,:) = ga_M_anech_pos_spatialized;


ba_F_anech_neg_spatialized = [Rear_anech_neg_conv_30deg_scaled_ramped(:,1) Lear_anech_neg_conv_30deg_scaled_ramped(:,1)];
ba_M_anech_neg_spatialized = [Rear_anech_neg_conv_30deg_scaled_ramped(:,2) Lear_anech_neg_conv_30deg_scaled_ramped(:,2)];
da_F_anech_neg_spatialized = [Rear_anech_neg_conv_30deg_scaled_ramped(:,3) Lear_anech_neg_conv_30deg_scaled_ramped(:,3)];
da_M_anech_neg_spatialized = [Rear_anech_neg_conv_30deg_scaled_ramped(:,4) Lear_anech_neg_conv_30deg_scaled_ramped(:,4)];
ga_F_anech_neg_spatialized = [Rear_anech_neg_conv_30deg_scaled_ramped(:,5) Lear_anech_neg_conv_30deg_scaled_ramped(:,5)];
ga_M_anech_neg_spatialized = [Rear_anech_neg_conv_30deg_scaled_ramped(:,6) Lear_anech_neg_conv_30deg_scaled_ramped(:,6)];

syllable_left_anech = zeros(6,length(ba_F_anech_neg_spatialized),2);
syllable_left_anech(1,:,:) = ba_F_anech_neg_spatialized;
syllable_left_anech(2,:,:) = ba_M_anech_neg_spatialized;
syllable_left_anech(3,:,:) = da_F_anech_neg_spatialized;
syllable_left_anech(4,:,:) = da_M_anech_neg_spatialized;
syllable_left_anech(5,:,:) = ga_F_anech_neg_spatialized;
syllable_left_anech(6,:,:) = ga_M_anech_neg_spatialized;


%% Generating spatialized interrupters
azimuth=2; %1=90deg

% Spatialize interrupters +90 and 90
    % 
for k = 1:nInterrupters

    %%%%%%%%%%% +90 DEG ANECH
    Lear_anech_inter_conv_90deg(:,k) = conv(interrupters(:,k),anech_90_BRIR(:,1),'full'); %30 degrees
    Lear_anech_inter_conv_90deg_scaled(:,k) = (Lear_anech_inter_conv_90deg(:,k)-mean(Lear_anech_inter_conv_90deg(:,k)))/(max(Lear_anech_inter_conv_90deg(:,k))-min(Lear_anech_inter_conv_90deg(:,k)));
    Lear_anech_inter_conv_90deg_scaled_ramped(:,k) = rampsound(Lear_anech_inter_conv_90deg_scaled(:,k),fs,0.01);

    Rear_anech_inter_conv_90deg(:,k) = conv(interrupters(:,k),anech_90_BRIR(:,2),'full'); %30 degrees
    Rear_anech_inter_conv_90deg_scaled(:,k) = (Rear_anech_inter_conv_90deg(:,k)-mean(Rear_anech_inter_conv_90deg(:,k)))/(max(Rear_anech_inter_conv_90deg(:,k))-min(Rear_anech_inter_conv_90deg(:,k)));
    Rear_anech_inter_conv_90deg_scaled_ramped(:,k) = rampsound(Rear_anech_inter_conv_90deg_scaled(:,k),fs,0.01);

    %%%%%%%%%%% -90 DEG ANECH
    Lear_anech_inter_conv_neg_90deg(:,k) = conv(interrupters(:,k),anech_90_BRIR(:,2),'full'); %30 degrees
    Lear_anech_inter_conv_neg_90deg_scaled(:,k) = (Lear_anech_inter_conv_neg_90deg(:,k)-mean(Lear_anech_inter_conv_neg_90deg(:,k)))/(max(Lear_anech_inter_conv_neg_90deg(:,k))-min(Lear_anech_inter_conv_neg_90deg(:,k)));
    Lear_anech_inter_conv_neg_90deg_scaled_ramped(:,k) = rampsound(Lear_anech_inter_conv_neg_90deg_scaled(:,k),fs,0.01);

    Rear_anech_inter_conv_neg_90deg(:,k) = conv(interrupters(:,k),anech_90_BRIR(:,1),'full'); %30 degrees
    Rear_anech_inter_conv_neg_90deg_scaled(:,k) = (Rear_anech_inter_conv_neg_90deg(:,k)-mean(Rear_anech_inter_conv_neg_90deg(:,k)))/(max(Rear_anech_inter_conv_neg_90deg(:,k))-min(Rear_anech_inter_conv_neg_90deg(:,k)));
    Rear_anech_inter_conv_neg_90deg_scaled_ramped(:,k) = rampsound(Rear_anech_inter_conv_neg_90deg_scaled(:,k),fs,0.01);

    inter_anech_pos_90(k,:,:) = [Rear_anech_inter_conv_90deg_scaled_ramped(:,k) Lear_anech_inter_conv_90deg_scaled_ramped(:,k)];
    inter_anech_neg_90(k,:,:) = [Rear_anech_inter_conv_neg_90deg_scaled_ramped(:,k) Lear_anech_inter_conv_neg_90deg_scaled_ramped(:,k)];
  

    %%%%%%%%%%% +90 DEG REVERB
    Lear_reverb_inter_conv_90deg(:,k) = conv(interrupters(:,k),squeeze(reverb_BRIR(azimuth,:,1)),'full'); %30 degrees
    Lear_reverb_inter_conv_90deg_scaled(:,k) = (Lear_reverb_inter_conv_90deg(:,k)-mean(Lear_reverb_inter_conv_90deg(:,k)))/(max(Lear_reverb_inter_conv_90deg(:,k))-min(Lear_reverb_inter_conv_90deg(:,k)));
    Lear_reverb_inter_conv_90deg_scaled_ramped(:,k) = rampsound(Lear_reverb_inter_conv_90deg_scaled(:,k),fs,0.01);

    Rear_reverb_inter_conv_90deg(:,k) = conv(interrupters(:,k),squeeze(reverb_BRIR(azimuth,:,2)),'full'); %30 degrees
    Rear_reverb_inter_conv_90deg_scaled(:,k) = (Rear_reverb_inter_conv_90deg(:,k)-mean(Rear_reverb_inter_conv_90deg(:,k)))/(max(Rear_reverb_inter_conv_90deg(:,k))-min(Rear_reverb_inter_conv_90deg(:,k)));
    Rear_reverb_inter_conv_90deg_scaled_ramped(:,k) = rampsound(Rear_reverb_inter_conv_90deg_scaled(:,k),fs,0.01);

    %%%%%%%%%%% -90 DEG REVERB
    Lear_reverb_inter_conv_neg_90deg(:,k) = conv(interrupters(:,k),squeeze(reverb_BRIR(azimuth,:,2)),'full'); %30 degrees
    Lear_reverb_inter_conv_neg_90deg_scaled(:,k) = (Lear_reverb_inter_conv_neg_90deg(:,k)-mean(Lear_reverb_inter_conv_neg_90deg(:,k)))/(max(Lear_reverb_inter_conv_neg_90deg(:,k))-min(Lear_reverb_inter_conv_neg_90deg(:,k)));
    Lear_reverb_inter_conv_neg_90deg_scaled_ramped(:,k) = rampsound(Lear_reverb_inter_conv_neg_90deg_scaled(:,k),fs,0.01);

    Rear_reverb_inter_conv_neg_90deg(:,k) = conv(interrupters(:,k),squeeze(reverb_BRIR(azimuth,:,1)),'full'); %30 degrees
    Rear_reverb_inter_conv_neg_90deg_scaled(:,k) = (Rear_reverb_inter_conv_neg_90deg(:,k)-mean(Rear_reverb_inter_conv_neg_90deg(:,k)))/(max(Rear_reverb_inter_conv_neg_90deg(:,k))-min(Rear_reverb_inter_conv_neg_90deg(:,k)));
    Rear_reverb_inter_conv_neg_90deg_scaled_ramped(:,k) = rampsound(Rear_reverb_inter_conv_neg_90deg_scaled(:,k),fs,0.01);


    % Saving all into one 3D matrix
    inter_anech_pos_90(k,:,:) = [Lear_anech_inter_conv_90deg_scaled_ramped(:,k) Rear_anech_inter_conv_90deg_scaled_ramped(:,k)];
    inter_anech_neg_90(k,:,:) = [Lear_anech_inter_conv_neg_90deg_scaled_ramped(:,k) Rear_anech_inter_conv_neg_90deg_scaled_ramped(:,k)];
  
    inter_reverb_pos_90(k,:,:) = [Rear_reverb_inter_conv_90deg_scaled_ramped(:,k) Lear_reverb_inter_conv_90deg_scaled_ramped(:,k)];
    inter_reverb_neg_90(k,:,:) = [Rear_reverb_inter_conv_neg_90deg_scaled_ramped(:,k) Lear_reverb_inter_conv_neg_90deg_scaled_ramped(:,k)];
  

end







