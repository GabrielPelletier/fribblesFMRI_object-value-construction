function pathout=dropboxPath(varargin)
%DROPBOXPATH Get path to dropbox folder of current user.
%
% This function returns the path to the Dropbox folder of the current user (if
% it exists). You can add arguments in similar style to fullfile to get a path
% within a dropbox folder:
% USES:
%    dbpath = dropboxPath
%    dbpath = dropboxPath(filepart1,...,filepartN)
%
% 
% 25/08/14 - Initial 
% 27/08/14 - added facility to generate full path to something in a drop box
% folder in a simialr manner to fullfile.
%
% Copyright (c) 2014, Chris Betters
if nargin>0
    appendpath=strjoin(varargin,filesep);
else
    appendpath='';
end

if isunix
    hostdb=fullfile('~','.dropbox','host.db');
else
    hostdb=fullfile(getenv('APPDATA'),'Dropbox','host.db');
end

assert(logical(exist(hostdb,'file')),'DROPBOXPATH:hostdb:NotFound','The Dropbox host.db file could not be found at %s',hostdb)
    
fid=fopen(hostdb,'r');
fgetl(fid); % skip first line
tline = fgetl(fid); % this line has path, in base64
fclose(fid);
dbpath = char(typecast(org.apache.commons.codec.binary.Base64.decodeBase64(uint8(tline)), 'uint8')');
pathout=fullfile(dbpath,appendpath,filesep);