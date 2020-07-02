
%% Gabriel Pelletier
% March 2019


function [recovery] = recoveryPrompt


    answer = questdlg('A Folder with this Subject Number already Exists. What do you want to do?', ...
        'WARNING', ...
        'Abort everything','The code Crashed: Run from where it crashed','Run the experiment from the start anyway (Overwrite previous data)',...
         'Abort everything'); % The last thin is the Default value

    % Handle response
    switch answer
        case 'Abort everything'
            recovery = 0; % Cancel everything
        case 'The code Crashed: Run from where it crashed'
            recovery = 1; % Recover from the point where it Crashed
        case 'Run the experiment from the start anyway (Overwrite previous data)'
            recovery = 2; % Run from Starting, Overight the previous data.
    end

end