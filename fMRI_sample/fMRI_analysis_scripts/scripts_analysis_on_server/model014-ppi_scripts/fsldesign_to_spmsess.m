function [SPM,design] = fsldesign_to_spmsess(design)
%
%
% [SPM] = fsldesign_to_spmsess(design);
%
% reads in an fsl design (opened using read_fsl_design) and
% creates an SPM5 Sess variable for use with fsl_ppi
% 
% This is an edited version of the original fsdesign_to_spmsess (by RP
% and AL).  This version  was created to match the spm algorithms from the spm_get_ons.m file
% that is part of SPM5.  Specifically, around line 238 of that code.
%
% 4/18/2010:  JMumford created  code.

% CURRENT SCRIPT

Sess=[];

Sess.row=[1:design.npts];
for c=1:length(design.condname),
  
  Sess.U(c).name=design.condname(c);
  Sess.U(c).ons=design.ons{c};


  %  JM:  NT is the number of time bins that each TR is divided into.
  %  SPM's default is 16, so I use that here.
  NT=16;

  %  JM: To clarify, RT here is *not* the same as TR in the SPM code.
  %  TR is 1 in the SPM code if the design is specified in seconds and T*dt
  %  if in scans. 
  RT=design.tr;

  %  JM:dt is the length of the upsampled time bins. 
  dt=RT/NT;


  Sess.U(c).dt=dt;

  Sess.U(c).P.name='none';  %the name
  Sess.U(c).P.h=0;          %order of polynomial expansion
  Sess.U(c).P.i=1;  %sub=indices pertaining to P 
                    %(I think this involves interactions)

  %code edited from spm_get_ons (around line 254)

  ton = round(design.ons{c}/dt) + 32;  %TR removed, since=1
  tof = round(design.dur{c}/dt) + ton + 1; %when to turn off
  sf  = sparse((design.npts*NT + 128),1);
  ton = max(ton,1);
  tof = max(tof,1);
  for j = 1:length(ton)
    if size(sf,1) > ton(j)
      sf(ton(j),:) = sf(ton(j),:) + design.wt{c}(j);
    end
    if size(sf,1) > tof(j)
      sf(tof(j),:) = sf(tof(j),:) - design.wt{c}(j) ;
    end
  end
  sf        = cumsum(sf);	% integrate
  sf        = sf(1:(design.npts*NT + 32),:);	% stimulus

  Sess.U(c).u=sf;
end;

xX.W=sparse(eye(design.npts,design.npts));
  
SPM.Sess=Sess;
SPM.xX=xX;
SPM.swd=pwd;




