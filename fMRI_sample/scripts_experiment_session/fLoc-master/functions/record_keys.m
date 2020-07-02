%% Modified by Gabriel Pelletier
% Jan 2018
% Line 35 to 42
% isempty = 0/1 was swapped by 1/0 to fix how False alarms and Correct
% responses are calculated in themain script.

function [keys, is_empty] = record_keys(start_time, dur, device_num)
% Collects all keypresses for a given duration (in secs).
% Written by KGS Lab
% Edited by AS 8/2014

% wait until keys are released
keys = [];
while KbCheck(device_num)
    if (GetSecs - start_time) > dur
        break
    end
end

% check for pressed keys
while 1
    [key_is_down, ~, key_code] = KbCheck(device_num);
    if key_is_down
        keys = [keys KbName(key_code)];
        while KbCheck(device_num)
            if (GetSecs - start_time) > dur
                break
            end
        end
    end
    if (GetSecs - start_time) > dur
        break
    end
end

% label null responses and store multiple presses as an array
if isempty(keys)
    is_empty = 0;
elseif iscell(keys)
    keys = num2str(cell2mat(keys));
    is_empty = 1;
else
    is_empty = 1;
end

end
