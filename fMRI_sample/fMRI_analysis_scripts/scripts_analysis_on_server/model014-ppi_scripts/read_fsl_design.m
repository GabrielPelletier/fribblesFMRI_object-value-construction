function [fmri]=read_fsl_design(featdir)
%
  % [fmri] = read_fsl_design(featdir);
%
% selective averaging for FSL feat analysis
% read in a 4-d analyze file
% compute selective average on all in-mask voxels
%
% required arguments:
% params: a struct containing details about analysis:
%     params.featdir: FEAT directory for analysis
%     params.ClusterInStandardSpace = normalized region of interest image
%        - note: optional: set to '' to turn off. Provides reference image
%        for applyxfm4D (so coregistered output will have correct bounding box).
%     params.ter - effective temporal resolution of analysis
%        - note: Image Processing  Toolbox is required for TER ~= TR
%     params.PosWindow - positive time window for averaging (default=24 s)
%     params.NegWindow - negative time window for averaging (default=4 s)
%     params.sed_converter - full path of designconvert.sed

%
% Russ Poldrack, 7/2/04
% warning off MATLAB:divideByZero

if ~exist('featdir'),
 help read_fsl_design
 return;
end;

SED_LOCATION=which('fsl_ppi');
SED_LOCATION=SED_LOCATION(1:(end-9));

SED_CONVERTER=[SED_LOCATION,'designconvert.sed'];

% check that SED_CONVERTER exists
if ~exist(SED_CONVERTER,'file'),
  fprintf('%s does not exist!\n',SED_CONVERTER);
  return;
end;

% design: a cell matrix containing filenames for either SPM.mat file
% (for SPM analysis) or FSL 3-column onset files
% make sure featdir exists and has data in it

current_dir=pwd;
try,
  cd(featdir);
catch,
  fprintf('problem changing to featdir (%s)\n',featdir);
  return;
end;

% convert design.fsf to design.m

[s,w]=system(sprintf('sed -f %s design.fsf > design.m',SED_CONVERTER));
if s,
   fprintf('problem converting design.fsf to design.m\n');
   fprintf('make sure the program sed is in your path\n');
   fprintf(' e.g. click My Computer, Properties, Advanced, Environment Variables\n');
   fprintf('      then cdouble-lick on Path and add ;c:\cygwin\bin to end and press OK \n');
  return;
end;


design_file=which('design');
fprintf('Loading design from:\n%s\n',design_file);
try,
  design;
catch,
   fprintf('problem loading design.m\n');
  return;
end;


% set up params and check fields


% set up the design

TR=fmri.tr;
%ntp=fmri.npts %<- Poldrack's original code
ntp=fmri.npts-fmri.ndelete;%Nov 2004: Ojango: original script failed to deduct deleted volumes
roidata=zeros(1,ntp);

% determine how many conditions there are

nconds=fmri.evs_orig;

% fix the structures so that the index is not in the name
fields_to_fix={ 'shape' 'convolve' 'convolve_phase' ...
    'tempfilt_yn' 'deriv_yn' 'custom' 'gammasigma' 'gammadelay' ...
    'ortho'};

for c=1:nconds,
 for f=1:length(fields_to_fix),
   if isfield(fmri,sprintf('%s%d',fields_to_fix{f},c)),
     cmd=sprintf('fmri.%s(%d)={fmri.%s%d};',fields_to_fix{f},c,fields_to_fix{f},c);
    eval(cmd);
  end;
 end;
end;



% load in the onsets
% right now assume single-column input, deal with 3-column files later

ons=cell(1,nconds);
for c=1:nconds,
  if fmri.shape{c}==2, % single-column file
    fprintf('Loading condition %d onsets (single-column format):\n%s\n',...
            c,fmri.custom{c});

    [p1,p2,p3]=fileparts(fmri.custom{c});
    fmri.condname{c}=p2;
    fmri.sf(c)={load(fmri.custom{c})};

    % need to subtract off TR to get back to zero time origin
    fmri.ons{c}=find(fmri.sf{c})*fmri.tr - fmri.tr;

%   a.l. added duration and wt field and set defaults 
    fmri.dur{c} = 1*fmri.tr.*ones(length(fmri.ons{c}),1);
    fmri.wt{c} = fmri.sf{c};    % carry over the wt 


 elseif fmri.shape{c}==3, % 3-column format

    fprintf('Loading condition %d onsets (3-column format):\n%s\n',c,fmri.custom{c});

    [p1,p2,p3]=fileparts(fmri.custom{c});
    fmri.condname{c}=p2;

    tmp=load(fmri.custom{c});
    tmp=tmp(find(tmp(:,3)~=0),:);  % RP - added to deal with onset files
                                   % including zero-values lines
    %tmp = tmp';
    %ncolumns = length(tmp);
    %ncolumns = floor(ncolumns / 3);
    %tmp = reshape(tmp, 3, ncolumns); %LXB-
    %tmp = tmp'; %LXB -
	
    fmri.ons{c} = tmp(:,1);
    fmri.dur{c}= tmp(:,2);
    % a.l. added a wt field - for third column of 3 col regs
    fmri.wt{c} = tmp(:,3); 

  end;
end;


