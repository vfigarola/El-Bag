%% Primary Author: Victoria Figarola
%% Secondary Authors: Wusheng Liang, Abby Noyce 
%% Description 
% This script runs the pupillometry experiment. Section breakdown:
% 1) VARIABLES: initialize all variables. The only three things that need
    % to change are subj_ID, stream_counterbalance (left or right stream
    % leading/lagging), and envCond_presented_first (anech or reverb block
    % first). The stream_counterbalance & envCond_presented_first but be
    % counterbalanced across participants. Since there are 4 ways this
    % could be, I would just go in order starting with right_anech. For
    % example:
        % subj_ID = 1 would have: right stream_counterbalance & anech envCond_presented_first
        % subj_ID = 2 would have: left stream_counterbalance & anech envCond_presented_first
        % subj_ID = 3 would have: right stream_counterbalance & reverb envCond_presented_first
        % subj_ID = 4 would have: right stream_counterbalance & reverb envCond_presented_first
        % subj_ID = 5 would have: right stream_counterbalance & anech envCond_presented_first <-- starting over
% 2) Load in stimuli & target syllable presentation order for each trial: this
    % simply loads in the trial streams, the syllables presented in each trial
    % (target and distracting), and which trial is being presented in the 
    % experimental_trial_order matrix (e.g.anechoic, target left, uninterrupted) 
% 3) PTB MACROS: initializes the screen and selects the second monitor as
    % primary experimental screen. It also has the "instructions" participants
    % would read before the first trial begins
% 4) Initialize Secondary Screen, Keyboard, Eyelink & Sound: as the title
    % states...initializes everything
% 5) Eyelink Calibration & start experiment: first step in this section is to 
% calibrate the pupils! Below walks through each sub-section
    % Calibration steps: press "C" to start calibration. Once the first
        % fixation dot appears on the screen, press "space" to start automatic
        % calibration. Then on the host PC, accept fixation. THEN, press "V"
        % for validation and do the same as above (press space then accept
        % fixation). Once that is done, press "O" or "ESC" to start experiment
    % Pupil Reactivity Screens: This is to measure normal pupil reaction. A
        % white screen with a fixation cross will appear for 10 seconds and
        % then a back screen with a fixation cross will appear for 10 seconds.
        % This is repeated for a total of 3 trials. 
    % Start experiment: This starts the actual experiment. It loops through
        % all 160 trials. Before and after each trial and after the response 
        % screen, there is a 3 second rest to allow pupils to return back to
        % baseline. A message is being sent to the eyelink before the onset of
        % each trial and response period to accurately epoch later on. After 20
        % trials (1 mini-block = 20 trials), participants can rest but are
        % asked to press the "SPACE" bar once they are ready to resume. Once
        % the experiment is over, a screen will say "Experiment complete" which
        % leads us to the next sub-section. 
        % ANOTHER THING TO NOTE: the response period uses the
            % "getResponse.m" script that accurately records subject responses.
            % They are only to respond 4 times (4 syllables) 
    % Experiment Complete: this downloads the edf data file into the
        % current directory (saved as edf_filename in "Load in stimuli & target
        % syllable presentation order for each trial" section), closes the
        % screen, saves the workspace (subjID_behavioral.mat) in the current
        % directory, and closes the link to the host PC. 
% 6) Once above is complete, upload the edf file & workspace onto box

%%
clear all; close all; clc;
commandwindow;
tic;

addpath(genpath('C:\Users\holt lab\Desktop\LiMN lab\Victoria\StimGen'));

%% VARIABLES
subj_ID = 'Pilot3VF';
stream_counterbalance = "right"; %target lead/lad to the right or left --> COUNTERBALANCE ACROSS PARTICIPANTS
envCond_presented_first = "anech"; %anech or reverb miniblock first --> COUNTERBALANCE ACROSS PARTICIPANTS

N_totaltrials = 160;
target_sequence_length = 4; %4 syllables in target stream

responses = repelem("",N_totaltrials,target_sequence_length);
[response_screen_img,~,transparency_response_screen_img] = imread("response_screen.png");

mini_blocks = [20,40,60,80,100,120,140];

%% Load in stimuli & target syllable presentation order for each trial
if envCond_presented_first == "anech"
    if stream_counterbalance == "left"
        load("left_anech.mat")
    elseif stream_counterbalance == "right"
        load("right_anech.mat")
    end
elseif envCond_presented_first == "reverb"
     if stream_counterbalance == "left"
        load("left_reverb.mat")
    elseif stream_counterbalance == "right"
        load("right_reverb.mat")
     end
end

%% PTB MACROS
cfg.screen = 1;
cfg.eyetracker = 1;
cfg.freq = 44100; % Audio device frequency

instruction = ['In this task, you will first hear an auditory cue "ba" coming \n' ...
    'from either the left of right. After a short silence, <b> four </b> \n'...
    'syllables will play from the left, and <b>four</b> from the right, \n'...
    'overlapping in time. Each of the syllables can either be "ba","da", or "ga". \n'...
    'You should focus on the syllables from the side indicated by the auditory \n'...
    'cue, ignoring any sound from the other side. After listneing to the \n'...
    'sounds, you will be asked to indicate the syllables that were played \n'...
    'from the cued side by pressing: 1 for ba, 2 for da, and 3 for ga. \n'...
    'Press <b>[SPACE]</b> to begin!'];

PsychDefaultSetup(2);
screens = Screen('Screens');    % counts the number of screens
Screen('Preference', 'SkipSyncTests', 1);

%% Initialize Secondary Screen, Keyboard, Eyelink & Sound
AssertOpenGL;

% Define black, white and grey
black = BlackIndex(1);
white = WhiteIndex(1);
grey = white / 2;

[window, winRect] = PsychImaging('OpenWindow', 1, black); % 1 = open up black screen on participant monitor
[width, height]=Screen('WindowSize', 1);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(winRect);
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 4;

%%%%%%%%%%%%%%% Initialize Keyboard
KbName('UnifyKeyNames');

% Keys
cfg.exitkey = 'Return';
cfg.spacekey = 'space';
cfg.escapekey = 'ESCAPE'; % Escape key exits the demo
cfg.keysOfInterest=zeros(1,256);
cfg.keysOfInterest(KbName('1'))=1;
cfg.keysOfInterest(KbName('2'))=1;
cfg.keysOfInterest(KbName('3'))=1;
cfg.keysOfInterest(KbName('1!'))=1;
cfg.keysOfInterest(KbName('2@'))=1;
cfg.keysOfInterest(KbName('3#'))=1;

%%%%%%%%%%%%%%% Add in eyetracker details
if cfg.eyetracker
    cfg.vDistance = 32; %  viewing distance w/ eyetracker (inches)
    cfg.dWidth = 20.5; %  display width w/ eyetracker (inches)
end

%%%%%%%%%%%%%%% Initialize Eyelink
% Check it came up. --> this linked to host PC
if ~EyelinkInit(0)
    fprintf('Eyelink Init aborted.\n');
    Eyelink('Shutdown');
    return;
end

% Sanity check connection
connected = Eyelink('IsConnected')
[v vs] = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs);

edf_filename = [subj_ID '.edf'];

InitializePsychSound;
devices=PsychPortAudio('GetDevices');
pahandle = PsychPortAudio('Open', 1, [], 0, cfg.freq,2); %pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
    
%% Eyelink Calibration & Start Experiment
if cfg.eyetracker
    % Initialize
    el = EyelinkInitDefaults(window);
    % Check it came up.
    if ~EyelinkInit(0)
        fprintf('Eyelink Init aborted.\n');
        Eyelink('Shutdown'); 
        return;
    end
  
    % Sanity check connection
    connected = Eyelink('IsConnected')

    % open file to record tracker data
    tempeyefile = Eyelink('Openfile', edf_filename);
    if tempeyefile ~= 0
        fprintf('Cannot create EDF file ''%s'' ', edf_filename);
        Eyelink('Shutdown');
        return;
    end

    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1); % 0,0,width,height; 280*2 170*2
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);

    % 9-target calibration - specify target locations.
    Eyelink('command', 'calibration_type = HV9');
    Eyelink('command', 'generate_default_targets = NO');

    % caloffset=round(4.5*ppd);
    Eyelink('command','calibration_samples = 10');

    Eyelink('command','calibration_sequence = 0,1,2,3,4,5,6,7,8,9');
    Eyelink('command','calibration_targets = %d,%d %d,%d %d,%d %d,%d %d,%d',...
        width/2,height/2,  width/2,height*0.2,  width/2,height - height*0.2,  width*0.2,height/2,  width - width*0.2,height/2 );
    Eyelink('command','validation_samples = 9');
    Eyelink('command','validation_sequence = 0,1,2,3,4,5,6,7,8,9');
    Eyelink('command','validation_targets = %d,%d %d,%d %d,%d %d,%d %d,%d',...
        width/2,height/2,  width/2,height*0.2,  width/2,height - height*0.2,  width*0.2,height/2,  width - width*0.2,height/2 );

    % Set lots of criteria
    Eyelink('command', 'saccade_acceleration_threshold = 8000');
    Eyelink('command', 'saccade_velocity_threshold = 30');
    Eyelink('command', 'saccade_motion_threshold = 0.15');
    Eyelink('command', 'saccade_pursuit_fixup = 60');
    Eyelink('command', 'fixation_update_interval = 0');

    % set EDF file contents
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS');

    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS');

    % make sure we're still connected.
    if Eyelink('IsConnected')~=1
        Eyelink( 'Shutdown');
        return;
    end

    % Initial calibration of the eye tracker
    % Set display colors
    el.backgroundcolour = [0,0,0];
    el.foregroundcolour = [100 100 100];
    el.calibrationtargetcolour = [255,255,255];

    EyelinkUpdateDefaults(el); % Apply the changes set above.

    % Calibrate and validate
    EyelinkDoTrackerSetup(el);
    % PRESS C TO START CALIB; THEN SPACE AT FIRST FIXATION START TO START
    % AUTOMATIC CALIBRATION
    % SAME FOR V TO VALIDATE ^
    % Once done, press output/record on host PC or press "O" or ECS to start
    % experiment

    eye_used = Eyelink('EyeAvailable');
end

%%%%%%%%%%%%%%% Start Experiment
topPriorityLevel = MaxPriority(window); %get max priority number (PS)


%%%%%%%%%%%%%%% Pupil Reactivity Screens
% Let's first start off with a fixation cross
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);
WaitSecs(3)

% -------------
% Eyelink Stuff
% -------------
% Must be offline to draw to EyeLink screen
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
% clear tracker display and draw box at fix point
Eyelink('Command', 'clear_screen 0')
Eyelink('command', 'draw_box %d %d %d %d 15', width/2-50, height/2-50, width/2+50, height/2+50);
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
Eyelink('StartRecording');
WaitSecs(0.1);

i = 1;
while i <= 3
    Eyelink('Command', 'record_status_message "Pupil Reactivity Trial %d"', i);
    Eyelink('Message', 'TRIALID %d', i);

    Eyelink('Message','SYNCTIME'); % mark zero-plot time in data file

    % white screen
    Screen('FillRect',window,[255 255 255]) %fill screen white
    Screen('DrawLines', window, allCoords,lineWidthPix, black, [xCenter yCenter], 2);
    Screen('Flip',window);
    Eyelink('Message', '!V TRIAL_VAR WhiteDisplay %d',i);
    WaitSecs(10) %keep this screen on for 10 sec

    % Black screen
    Screen('FillRect',window,[0 0 0]) %fill screen black
    Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip',window);
    Eyelink('Message', '!V TRIAL_VAR BlackDisplay %d',i);
    WaitSecs(10) %keep this screen on for 10 sec

    i = i+1;
end

WaitSecs(0.1);
Eyelink('StopRecording');

% Back to fixation
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', window);
WaitSecs(3);


% EYELINK -- make sure we're still connected.
if Eyelink('IsConnected')~=1
    Eyelink( 'Shutdown');
    return;
end

%%%%%%%%%%%%%%% Start experimental trials
for j = 1:N_totaltrials
    %%%%%%%%%%%%%%% Instruction Screen
    if j == 1
        Priority(topPriorityLevel);
        Screen('TextSize',window, 60);
        DrawFormattedText(window, instruction, 'center', 'center', [500 500 500]);
        Screen('Flip',window);
        KbStrokeWait; %wait for keystroke to being
    end

    %%%%%%%%%%%%%%% Start Eyelink Recording
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);

    Eyelink('StartRecording');
    WaitSecs(0.1);

    %%%%%%%%%%%%%%% Starting block on fixation
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    WaitSecs(3); %wait 3 seconds

    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    
    %%%%%%%%%%%%%%% Send trigger to eyelink
    Eyelink('Message', 'TRIALID %d', j); %  TRIALID to signal the onset of a trial
    Eyelink('Command', 'record_status_message "TRIALSTREAM %d"', j);


    %%%%%%%%%%%%%%% Generating stimulus audio
    PsychPortAudio('FillBuffer', pahandle, squeeze(trial_stream{:,j})');

    % write out a message to indicate the time of the trial onset
    % this message can be used to create an interest period in EyeLink
    % Data Viewer.
    Eyelink('Message','SYNCTIME');

    PsychPortAudio('Start',pahandle,1,0)
    PsychPortAudio('Stop',pahandle,1)

    %%%%%%%%%%%%%%% Keep fixation on after sound to allow pupils back to baseline
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);

    WaitSecs(3) %wait 3 seconds before response window

    %%%%%%%%%%%%%%% Send trigger to eyelink for response window screen
    Eyelink('Message', 'RESPONSE_TRIAL %d', j);
    Eyelink('Command', 'record_status_message "RESPONSE PERIOD %d"', j);
    WaitSecs(0.1);
    Eyelink('Message','SYNCTIME');

    %%%%%%%%%%%%%%% Response Window Screen 
    puzzle0 = cat(3,response_screen_img,transparency_response_screen_img);
    Texture = Screen('MakeTexture',window,response_screen_img);
    Screen('DrawTexture',window,Texture,[],winRect);
    Screen('Flip', window);

    cfg.respStartTime = GetSecs;
    cfg.respDur = 6;
    for i = 1:target_sequence_length
        [this_resp,~] = getResponse(cfg);
        responses(j,i) = this_resp;
    end

    WaitSecs(4) %keep this screen on for 4 seconds

    Eyelink('Message', 'TRIAL_RESULT 0') % TRIAL_RESULT to signal the end of a trial

    %%%%%%%%%%%%%%% Back to fixation after response to allow pupils back to baseline
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);

    Eyelink('StopRecording');

    if j==N_totaltrials
        Screen('TextSize',window, 60);
        DrawFormattedText(window, 'Experiment Complete!', 'center', 'center', [500 500 500]);
        Screen('Flip',window);
    elseif j==20 || j == 40 || j==60 || j==80 || j==100 || j==120 || j==140 %allow participant to rest after 20 trials
        % EYELINK: make sure we're still connected.
        if Eyelink('IsConnected')~=1
            Eyelink( 'Shutdown');
            return;
        end
        Screen('TextSize',window, 60);
        DrawFormattedText(window, 'Block complete. Feel free to take a break. \nPress <b>[SPACE]<b> to continue', 'center', 'center', [500 500 500]);
        Screen('Flip',window);
        KbStrokeWait; %wait for keystroke to being
    end

end


%%%%%%%%%%%%%%% end of experiment
% ----------------
% Eyelink Stuff
% ----------------
if cfg.eyetracker
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');

    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edf_filename );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edf_filename, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edf_filename, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edf_filename );
    end

    % STEP 9
    % close the eye tracker and window
    Eyelink('ShutDown');
    PsychPortAudio('Close',pahandle);
    sca;
end

runtime=toc;
fprintf('Total time elapsed %d min %d sec.\n',floor(runtime/60),floor(mod(runtime,60)));

save(strcat(subj_ID,'_behavioral'))
