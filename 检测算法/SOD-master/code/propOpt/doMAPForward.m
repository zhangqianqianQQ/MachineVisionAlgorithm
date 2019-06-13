function [stat] = doMAPForward(B, S, param, stat)

if isempty(B)
    fprintf('Empty proposal set.\n');
    stat = [];
    return;
end
nB = size(B,2);
if nargin == 3 || isempty(stat)
    % initialization
    stat.W = [];
    stat.Xp = []; % optimal w_{ij} given the output set
    stat.X = zeros(nB,1); % assignment
    % construct W
    [stat.W, stat.Xp] = getW(B, S, param);
    stat.BGp = stat.Xp;
    stat.nms = zeros(size(B,2),1);
    stat.f = sum(stat.Xp);
    stat.O = [];
end

%% loop
while numel(stat.O) < min(param.maxnum, nB)
    V = max(stat.W - repmat(stat.Xp, [1 nB]),0);
    [score, vote] = max(sum(V) + stat.nms(:)');
    if score == 0 % no supporters
        break
    end
    tmpf = stat.f + score + param.phi;
    
    if (tmpf > stat.f) 
        mask = V(:,vote) > 0;
        stat.X(mask) = vote;
        stat.O(end + 1) = vote;
        stat.Xp(mask) = stat.W(mask,vote);
        stat.f = tmpf;
        stat.nms = stat.nms + ...
            param.gamma*getNMSPenalty(B, B(:,vote));
    else
        break
    end
end








