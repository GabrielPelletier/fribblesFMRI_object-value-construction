function [dirs_names] = fdir(dir_path,dtype)
if nargin<2
    if nargin<1
        dir_path=pwd;
    end
    dtype=[];
end
dirs_struct=dir(dir_path);
dirs_struct=dirs_struct(~ismember({dirs_struct.name},{'.','..'})); % remvove the '.' and '..'
if strcmp(dtype,'dir')
    dirs_struct=dirs_struct(cell2mat({dirs_struct.isdir})); % keep only dirs
elseif strcmp(dtype,'file')
    dirs_struct=dirs_struct(~cell2mat({dirs_struct.isdir})); % keep only dirs
end
dirs_struct_names=rmfield(dirs_struct,{'date','bytes','isdir','datenum'}); % keep only the name
dirs_names=struct2cell(dirs_struct_names)'; % keep in cell column format