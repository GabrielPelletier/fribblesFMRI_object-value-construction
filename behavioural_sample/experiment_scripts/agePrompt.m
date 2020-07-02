function [age] =agePrompt
age = '0';
while str2num(age) < 18 
prompt = {'Enter participant AGE:'};
dlg_title ='New Participant';
num_lines = 1;
def = {'0'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
age=(answer{1});

if str2num(age) >= 18
return
end

error( 'Age must be between 18 and 100.');

end
end