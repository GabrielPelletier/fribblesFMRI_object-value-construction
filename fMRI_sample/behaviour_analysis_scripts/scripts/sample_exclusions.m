% fribbles_fMRI
% Gabriel Pelletier
% September 2019

function subs = sample_exclusions

% ALL PARTICIPANTS:

subs = [ 0309 310 0311 0401 0402 0403 0404 0405 0406 0407 0408 0409 ...
        0410 0411 0412 0413 0414 0415 0416 0417 0418 0419 0420 0421 ...
        0422 0423 0424 0425 0426 0427 0428 0429 0430 0431 0432 0433 ...
        0434 0435 0436 0437 0438 0439 0440 0441 0442 0443 0444 0445 ...
        0446 0447 0448 0449 0450 0451 0452 0453 0454];


% EXCLUSIONS:

exclusions_behavior = [310 401 404 409 416 424 425 426 427 442 443 451];

exclusions_mri = [401 404 420 423 442];

exclusions_all = [exclusions_behavior, exclusions_mri];

exclusions = unique(exclusions_all);

fprintf('\nA total of %d participants were scanned.\n', length(subs));
fprintf('\nA total of %d participants were excluded.\n', length(exclusions));

[c,out_ind] = intersect(subs, exclusions);
subs(out_ind) = [];

fprintf('\nThe final sample contains %d participants \n', length(subs));
%disp(subs');

end