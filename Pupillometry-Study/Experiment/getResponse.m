%% Abby's function
function [responses,responseTime] = getResponse(cfg)

% This subfunction uses KbQueue to wait for participants to press a key; it
% checks whether it's a legal key and records the key and the time it was
% pressed.

% keyboard_responses = cell(1,N_totaltrials);

% KbQueueCreate(-1);
% KbQueueStart(-1);
deviceIndex=-1;
KbQueueCreate(deviceIndex,cfg.keysOfInterest);
KbQueueStart(deviceIndex);

anyPressed=0;

% Look for keypresses
while GetSecs - cfg.respStartTime < cfg.respDur
    [pressed, firstPress]=KbQueueCheck(deviceIndex);
    % If a key is pressed
    if pressed
        kidx = find(firstPress); % Keycode of pressed key
        disp(kidx)
        kstr = KbName(kidx);
        if ismember(kstr, KbName(cfg.keysOfInterest))
            responses = kstr;
            responseTime  = firstPress(kidx);
            anyPressed = 1;
            fprintf("%s key pressed at %.3f\n",kstr,responseTime)
            break
        elseif ismember(kstr,cfg.escapeKey)
            error("Escape key pressed")
        end

    end
end

if ~anyPressed
    responses = nan;
    responseTime = nan;
end

% KbQueueRelease;
KbQueueStop;