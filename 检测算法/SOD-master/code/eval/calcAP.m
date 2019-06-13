%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating average precision using 11 point
% averaging.
%
% We first linearly interpolate the PR curves, 
% which turns out to be more robust to the 
% number of points sampled on the PR cureve.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ap = calcAP(rec, prec, interval)
if nargin < 3
    interval = 0:0.1:1;
end

% linear interpolation
[rec,ii] = sort(rec);
prec = prec(ii);
[rec,ii] = unique(rec);
prec = prec(ii);
Rq = 0:0.01:1;
Pq = interp1(rec,prec,Rq);
Pq(isnan(Pq)) = 0;
prec = Pq;
rec = Rq;

ap=0;
for t=interval
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/numel(interval);
end