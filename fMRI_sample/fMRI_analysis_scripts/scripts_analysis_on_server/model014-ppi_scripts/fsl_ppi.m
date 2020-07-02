function [PPI,design] = fsl_ppi(featdir,voi,ppi_contrast,figs)
% 
% Bold deconvolution to create physio- or psycho-physiologic interactions
% 
% ORIGINAL FORMAT PPI = spm_peb_ppi(SPM);
% ORIGINAL INPUT:  SPM = SPM.mat structure containing generic details about analysis
%
% HACKED FORMAT [PPI,design] = fsl_ppi(featdir,voi,ppi_contrast,figs,[durs]);
%
% Usage: 
%
% e.g., [ppimat]=fsl_ppi('./subj1_run1.feat','/somepath/seed_timeseries.txt',[1 0 0 0],0)
% e.g., [ppimat]=fsl_ppi('./subj1_run1.feat','/somepath/seed_timeseries.txt',[1 0 0 0],0,[0 1 1 1])
%s
% INPUT:
%       featdir   = directory with feat output (containing design.fsf)
%       voi       = string 'nameOfTextfile.txt' - 1_column vector containing
%       timeseries of the seed region.
%       ppi_contrast = [0 0 1 -1] - contrast vector to select regressors of interest
%                                 - #elements = number of regs coded in design.fsf
%       figs      = display figs? 1/y, 0/n
%       durs [optional] = provide vector of length same as ppi_contrast
%                       that codes the duration-multiplier for each regressor
%    
%         e.g., [0 0 1 0] => set reg 1,2 and 4 event-durations to 0 and reg 3 durations as is
%         e.g., [.5 .5 .5 .5] => set all event durations to 1/2 of what they're currently coded           
%
% >>> NOTE: need SPM5 in your path to find spm_PEB.m for bayesian estim
% >>> NOTE: use durs variable to check effect of event duration on
%           analysis - default in SPM is 0 - delta function only
%           note that [1] will preserve original onsets
%
% OUTPUT:
% 
% PPI       = as noted below - note however that:
%
%              PPI.Y = the input voi data with MEAN AT 0	
%              PPI.Y_orig = the input voi data	 
%              PPI.ppi = (PSY*xn  or xn1*xn2) convolved with the HRF
%              PPI.P = PSY convolved with HRF 
%              PPI.name   = Name of PPI
%              PPI.xY     = Original VOI information
%              PPI.xn     = Deconvolved neural signal(s)
%              PPI.U.u    = Psychological variable
%              PPI.U.w    = Contrast weights for psychological variable
%              PPI.U.name = Condition Names
%
% design    = Structure containing generic details about the analysis
%
% if fig = 1 will plot 3 graphs overlaying convolved and deconvolved
% version of: timeseries, psychological regressor and PPI term
%

% July 3, 2006: Hacked by RP from spm_peb_ppi.m 
% Sept 18, 2008: Modified by AL. 
% Feb 21, 2009: Added optional 'durs' argument. AL.
% Jan 18, 2010: Added currdir check - will return to current dir
% **** see rest of file for original spm  notes on PPI output structure ****
%  **** pass PPI.Y_orig, PPI.P and PPI.ppi as regressors into PPI GLM ****
%  JM: March 22, 2010 Cleaned up code and fixed some settings to match SPM defaults.

currdir = pwd;

% --------------------------------------------------------------------
% ORIGINAL NOTES START HERE
% --------------------------------------------------------------------
%
% OUTPUT:
%
% PPI.ppi    = (PSY*xn  or xn1*xn2) convolved with the HRF
% PPI.Y      = Original BOLD eigenvariate. Use as covariate of no interest.
% PPI.P      = PSY convolved with HRF for psychophysiologic interactions,
%              or in the case of physiophysologic interactions contains
%              the eigenvariate of the second region. 
% PPI.name   = Name of PPI
% PPI.xY     = Original VOI information
% PPI.xn     = Deconvolved neural signal(s)
% PPI.U.u    = Psychological variable or input function (PPIs only)
% PPI.U.w    = Contrast weights for psychological variable (PPIs only)
% PPI.U.name = Names of psychological conditions (PPIs only)
%---------------------------------------------------------------------
%
% This routine is effectively a hemodynamic deconvolution using 
% full priors and EM to deconvolve the HRF from a hemodynamic
% time series to give a neuronal time series [that can be found in
% PPI.xn].  This deconvolution conforms to Weiner filtering 
% The neuronal process is then used to form PPIs.....
%
% SETTING UP A PPI THAT ACCOUNTS FOR THE HRF
% ==================================================================
% PPI's were initially conceived as a means of identifying regions whose
% reponses can be explained in terms of an interaction between activity in
% a specified source (the physiological factor) and some experimental
% effect (the psychological factor). However, a problem in setting up PPI's
% is that in order to derive a proper estimate of the interaction between
% a psychological variable (P) and measured hemodynamic signal (x), one cannot
% simply convolve the psychological variable with the hrf (HRF) and multiply
% by the signal. Thus:
% 
%                  conv(P,HRF).* x ~= conv((P.*xn),HRF)
%
% P   = psychological variable
% HRF = hemodynamic response function
% xn  = underlying neural signal which in fMRI is convolved with the hrf to
%       give the signal one measures -- x.
% x   = measured fmri signal
%
% It is actually the right hand side of the equation one wants.
% Thus one has to work backwards, in a sense, and deconvolve the hrf
% from x to get xn. This can them be multiplied by P and the resulting
% vector (or matrix) reconvolved with the hrf.
%
% This algorithm uses a least squares strategy to solve for xn.
%
% The source's hemodynamics are x = HRF*xn;
%
% Using the constraint that xn should have a uniform spectral density 
% we can expand x in terms of a discrete cosine set (xb)
%
%      xn  = xb*B
%       B  = parameter estimate
%
% The estimator of x is then
%
%       x  = HRF(k,:)*xn
%       x  = HRF(k,:) * xb * B
%
% This accounts for different time resolutions between
% our hemodynamic signal and the discrete representation of
% the psychological variable. In this case k is a vector 
% representing the time resolution of the scans.
%
% Conditional estimates of B allow for priors that ensure
% uniform variance over frequencies.
%
%---------------------------------------------------------------------
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Darren Gitelman
% $Id: spm_peb_ppi.m 539 2006-05-19 17:59:30Z Darren $




% ---------------------------------------------------------------------
% ---------------------------------------------------------------------

%                    START SCRIPT HERE


% >>> set up the graphical interface - RP SKIPPING GUI <<<
%----------------------------------------------------------------------

%Finter = spm_figure('GetWin','Interactive');
%if figs == 1
%Fgraph = spm_figure;
%end
%header = get(Finter,'Name');


% >>> RP: read in FSL design information <<<
design=read_fsl_design(featdir);


% check inputs and set up variables
%----------------------------------------------------------------------
if ~nargin
    swd   = spm_str_manip(spm_select(1,'^SPM\.mat$','Select SPM.mat'),'H');
    load(fullfile(swd,'SPM.mat'))
    cd(swd)
end

% >>> RP: changed variables RT and dt based on design (set dt as constant)
%RT     = design.tr;
%dt     = 0.1250;   % RP - assume 0.125 sec microresolution for design
%NT     = RT/dt;    % BINS will be constant at a fraction of a sec (1/8th)


%>>JM:  Changed to match SPM defaults
RT    = design.tr;
NT=16;  %JM- this is the default number of bins for SPM
dt    = RT/NT;  %JM- the length of the bin




% Ask whether to perform physiophysiologic or psychophysiologic interactions
%--------------------------------------------------------------------------
%set(Finter,'name','PPI Setup')
ppiflag    = {	'simple deconvolution',...
		'psychophysiologic interaction',...
		'physiophysiologic interaction'};
%i          = spm_input('Analysis type?',1,'m',ppiflag);

i=2;   % RP: set i flag to always perform psychphysiological interaction
ppiflag    = ppiflag{i};


switch ppiflag
    
    
case  'simple deconvolution'
    %=====================================================================
    spm_input('physiological variable:...  ',2,'d');
    voi      = spm_select(1,'^VOI.*\.mat$',{'select VOI'});
    p      = load(deblank(voi(:))','xY');
    xY(i)  = p.xY;
    Sess   = SPM.Sess(xY(1).Sess);

    
    
case  'physiophysiologic interaction' % interactions between 2 regions
    %=====================================================================
    spm_input('physiological variables:...  ',2,'d');
    voi      = spm_select(2,'^VOI.*\.mat$',{'select VOIs'});
    for  i = 1:2
        p      = load(deblank(voi(i,:)),'xY');
        xY(i)  = p.xY;
    end
    Sess   = SPM.Sess(xY(1).Sess);

    
    
case  'psychophysiologic interaction'  % get hemodynamic response 
    %=====================================================================

% >>> RP CHANGED EXTRACTION OF DATA FOR PSYCHOPHYSIOLOGICAL INTERACTION <<<

%    spm_input('physiological variable:...  ',2,'d');
%    voi      = spm_select(1,'^VOI.*\.mat$',{'select VOI'});
%    p      = load(deblank(voi(:))','xY');
%    xY(1)  = p.xY;



    voidata=load(voi); % >>> READING VOI DATA FROM INPUT FILE <<<
    [SPM,design]=fsldesign_to_spmsess(design); % >>> CREATE SPM MAT from DESIGN <<<

     Sess   = SPM.Sess;


% >>> CHANGES BELOW: RP ELIMINATED GUI INPUT AND READS IN PPI_CONTRAST <<<

    % get 'causes' or inputs U
    %----------------------------------------------------------------------
%    spm_input('Psychological variable:...  ',2,'d');
    u      = length(Sess.U);
    U.name = {};
    U.u    = [];
    U.w    = [];
    

%    ppi_contrast
%   using ppi_contrast instead of calling gui for selection of contrast
%   1. assign regressor to U.u from Sess.U(i).u(33:end,j) 
%   2. assign weight U.w
    for  i = 1:u
        for  j = 1:length(Sess.U(i).name)
	   fprintf('cond %d(%s): %d\n',j,Sess.U(i).name{j},ppi_contrast(i));
%            str   = ['include ' Sess.U(i).name{j} '?'];
%            if spm_input(str,3,'y/n',[1 0])
            if ppi_contrast(i)~=0,
                U.u             = [U.u Sess.U(i).u(33:end,j)];
                U.name{end + 1} = Sess.U(i).name{j};
		fprintf('including %s\n',Sess.U(i).name{j});
%                str             = 'Contrast weight';
%                U.w             = [U.w spm_input(str,4,'e',[],1)];
                U.w             = [U.w ppi_contrast(i)];
            end
        end
	
    end
    
    
end % (switch setup)


% >>> name of PPI file to be saved <<<
%------------------------------------------------------------------------- 
%PPI.name    = spm_input('Name of PPI',3,'s','PPI');
PPI.name='PPI';


% Setup variables
% >>> TAKE n FROM DESIGN RATHER THAN FROM xY(1).u <<<
%-------------------------------------------------------------------------
N     = design.npts;
k     = 1:NT:N*NT;  			% microtime to scan time indices


% create basis functions and hrf in scan time and microtime
%-------------------------------------------------------------------------
spm('Pointer','watch')
hrf   = spm_hrf(dt);


% create convolved explanatory {Hxb} variables in scan time
%-------------------------------------------------------------------------
xb    = spm_dctmtx(N*NT + 128,N);
Hxb   = zeros(N,N);
for i = 1:N
    Hx       = conv(xb(:,i),hrf);
    Hxb(:,i) = Hx(k + 128);
end
xb    = xb(129:end,:);


% get confounds (in scan time) and constant term
% >>> ASSIGNS X0 BASED ON ONES RATHER THAN TAKING CONFOUNDS <<<
%-------------------------------------------------------------------------
X0    = ones(N,1); % just the mean
M     = size(X0,2);


% get response variable,
% >>> ASSIGN RESPONSE VARIABLE FROM VOI INPUT <<<
%-------------------------------------------------------------------------
%for i = 1:size(xY,2)
%    Y(:,i) = xY(i).u;
%end
Y=voidata;

% remove confounds and save Y in ouput structure
% >>> REMOVES NOTHING (will rescale to mean 0 - just removing constant)
%-------------------------------------------------------------------------

% WHAT IS THE INTUITIVE MEANING OF THIS EQUATION
% Y - projection of Y into columnspace of X0 (removing that portion)


Yc    = Y - X0*inv(X0'*X0)*X0'*Y;
PPI.Y = Yc(:,1);
if size(Y,2) == 2
    PPI.P  = Yc(:,2);
end


% specify covariance components; assume neuronal response is white
% treating confounds as fixed effects
%-------------------------------------------------------------------------
Q      = speye(N,N)*N/trace(Hxb'*Hxb);
Q      = blkdiag(Q, speye(M,M)*1e6  );

% get whitening matrix (NB: confounds have already been whitened)
%-------------------------------------------------------------------------
W      = SPM.xX.W(Sess.row,Sess.row);

% create structure for spm_PEB
%-------------------------------------------------------------------------
P{1}.X = [W*Hxb X0];		% Design matrix for lowest level
P{1}.C = speye(N,N)/4;		% i.i.d assumptions
P{2}.X = sparse(N + M,1);	% Design matrix for parameters (0's)
P{2}.C = Q;


switch ppiflag
    
    
case  'simple deconvolution'
    %=====================================================================
    C       = spm_PEB(Y,P);
    xn      = xb*C{2}.E(1:N);
    xn      = spm_detrend(xn);
    
    % save variables
    %---------------------------------------------------------------------
    PPI.xn  = xn;
    
    % Plot so the user can see the results
    %---------------------------------------------------------------------
    %figure(Fgraph);
   
    t       = RT*[1:N];
    T       = dt*[1:(N*NT)];
    
    subplot(2,1,1)
    plot(t,Yc,T,PPI.xn)
    title('hemodynamic and neuronal responses')
    xlabel('time (secs)')
    axis tight square
    grid on
    legend('BOLD','neuronal')
    
case  'physiophysiologic interaction' % PHYSIOPHYSIOLOGIC INTERACTIONS
    %=====================================================================
    C       = spm_PEB(Y(:,1),P);
    xn1     = xb*C{2}.E(1:N);
    C       = spm_PEB(Y(:,2),P);
    xn2     = xb*C{2}.E(1:N);
    xn1     = spm_detrend(xn1);
    xn2     = spm_detrend(xn2);
    xnxn    = xn1.*xn2;
    
    % convolve and resample at each scan for bold signal
    %---------------------------------------------------------------------
    ppi     = conv(xnxn,hrf);
    ppi     = ppi(k);
    
    % save variables
    %---------------------------------------------------------------------
    PPI.xn  = [xn1 xn2];
    PPI.ppi = spm_detrend(ppi);
    
    
    % Plot so the user can see the results
    %---------------------------------------------------------------------
    %figure(Fgraph);
   
    t       = RT*[1:N];
    T       = dt*[1:(N*NT)];
    
    subplot(3,1,1)
    plot(t,PPI.ppi)
    title('PPI')
    xlabel('time (secs)')
    axis tight square
    grid on
    
    subplot(3,1,2)
    plot(t,Yc(:,1),T,PPI.xn(:,1))
    title('hemodynamic and neuronal responses (1st)')
    xlabel('time (secs)')
    axis tight square
    grid on
    legend('BOLD','neuronal')

    
    subplot(3,1,3)
    plot(t,Yc(:,2),T,PPI.xn(:,2))
    title('hemodynamic and neuronal responses (2nd)')
    xlabel('time (secs)')
    axis tight square
    grid on
    legend('BOLD','neuronal')
    
    
    
case  'psychophysiologic interaction'  
    %=====================================================================
    
    % COMPUTE PSYCHOPHYSIOLOGIC INTERACTIONS
    % use basis set in microtime
    %---------------------------------------------------------------------
    % get parameter estimates and neural signal; beta (C) is in scan time
    % This clever trick allows us to compute the betas in scan time which is
    % much quicker than with the large microtime vectors. Then the betas
    % are applied to a microtime basis set generating the correct neural
    % activity to convolve with the psychological variable in mircrotime
    %---------------------------------------------------------------------
    C       = spm_PEB(Y,P);
    xn      = xb*C{2}.E(1:N);
    xn      = spm_detrend(xn); %just removes mean
    
    % setup psychological variable from inputs and contrast weights
    %---------------------------------------------------------------------

    PSY     = zeros(N*NT,1);
    for i = 1:size(U.u,2)
        PSY = PSY + full(U.u(:,i)*U.w(:,i));
    end
%    PSY     = spm_detrend(PSY);
%    PSY = PSY-((max(PSY)-min(PSY))./2);

    % multiply psychological variable by neural signal
    %---------------------------------------------------------------------
    PSYxn   = PSY.*xn;
    
    % convolve and resample at each scan for bold signal
    %---------------------------------------------------------------------
    ppi	    = conv(PSYxn,hrf);
    ppi     = ppi(k);
    
    % similarly for psychological effect
    %---------------------------------------------------------------------
    PSYHRF  = conv(PSY,hrf);
    PSYHRF  = PSYHRF(k);


    % save psychological variables
    %---------------------------------------------------------------------
    PPI.psy = U;
    PPI.P   = PSYHRF;
    PPI.Pzc = PSY(k);
    PPI.xn  = xn;
    %PPI.ppi = spm_detrend(ppi);
    PPI.ppi=ppi;  %JM:  Don't really need to detrend it, FSL will do this

        
    % Plot so the user can see the results
    %---------------------------------------------------------------------
    if figs == 1
    %figure(Fgraph);
    figure
    t       = RT*[1:N];
    T       = dt*[1:(N*NT)];
    
    subplot(3,1,1)
    plot(t,Yc(:,1),T,PPI.xn(:,1))
    title('hemodynamic and neuronal responses')
    xlabel('time (secs)')
    %axis tight square
    grid on
    legend('BOLD','neuronal')
    
    subplot(3,1,2)
    plot(t,PPI.P,T,PSY,'--')
    title('[convolved] psych. variable')
    xlabel('time (secs)')
    %axis tight square
    grid on
    
    subplot(3,1,3)
    plot(t,PPI.ppi)
    title('PPI')
    xlabel('time (secs)')
    %axis tight square
    grid on
    end    
    
end % (switch)

% setup other output variables
% >>> REPLACE INPUT xY WITH Y <<<
%-------------------------------------------------------------------------
%PPI.xY  = xY;
PPI.Y_orig = Y;
PPI.dt  = dt;
str     = ['PPI_' PPI.name];

%if spm_matlab_version_chk('7') >= 0,
%    save(fullfile(SPM.swd,str),'-V6','PPI')
%else
%    save(fullfile(SPM.swd,str),'PPI')
%end


eval(['cd ' currdir ''])

% clean up
%-------------------------------------------------------------------------
spm('Pointer','arrow')
%spm('FigName',header);
fprintf('\ndone\n')
return



