function [lang] = languagePrompt


lang = questdlg('Please select your primary language:','lang','English','Hebrew','English');
while isempty(lang)
    lang = questdlg('Please select your  primary language:','lang','English','Hebrew','English');
end


end