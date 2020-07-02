function [gender] = genderPrompt


gender = questdlg('Please select your gender:','Gender prompt','Male','Female','Female');
while isempty(gender)
    gender = questdlg('Please select your gender:','Gender prompt','Male','Female','Female');
end


end