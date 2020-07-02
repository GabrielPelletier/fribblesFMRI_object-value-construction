%% This script Shows the Rating Scale, and Waits for a response to be made,
% the closes

%while 
sca;
[myScreen, rect] = Screen('OpenWindow', 0, 0);

screenPointer = myScreen;
question = 'Is this thing working?';
endPoints = {'Nop...', 'Hell yeah'};
[position, RT, answer] = slideScale(screenPointer, question, rect, endPoints, 'device','keyboard');
%end
sca;