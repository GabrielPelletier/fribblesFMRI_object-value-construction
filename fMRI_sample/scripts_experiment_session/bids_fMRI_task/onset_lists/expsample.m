function y = expsample(mean_t,min_t,max_t,interval)
% produce a random sample from an exponential distribution within limits (min/max) given a mean. 
% round to nearest interval.
% this is useful for generating jittered time intervals between
% stim presentations for event-related designs
% 
% by Dara Ghahremani - 4/7/05

tmp=exprnd(mean_t);
tmp=tmp-mod(tmp,interval); % round to nearest interval
while (tmp < min_t | tmp > max_t),
   tmp=exprnd(mean_t);
   tmp=tmp-mod(tmp,interval); % round to nearest interval   
end;
y=tmp;
