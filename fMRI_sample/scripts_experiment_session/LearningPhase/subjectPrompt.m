function [subID] = subjectPrompt
subID = '0';
while str2num(subID) < 10 
prompt = {'Enter participant number:'};
dlg_title ='New Participant';
num_lines = 1;
def = {'0'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
subID=(answer{1});

if str2num(subID) >= 10
return
end

error( 'The subjet number must be between 10 and 1000.');

end
end