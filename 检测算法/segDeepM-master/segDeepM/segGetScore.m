function [s,f] = segGetScore(W,cls,feats,detwin,config)
% Compute maximal score over all possible segment features

% Input:
%           W:          weight vector
%           pyras:      feature pyramid for segments 
%           detwin:     object proposals (in [x1,y1,x2,y2])


numDets = size(detwin,1);
numFeat = length(feats);

% for this class only
featSize = config.seg.featLength;

s = -inf*ones(numDets,1);
f = zeros(numDets,featSize);

foundSeg = 0;
segIdx = zeros(numDets,1);
for tt = 1:numFeat
	if tt==numFeat && foundSeg == 0
		assert(feats{tt}.class==0);
	else
		if feats{tt}.class~=cls
			continue;
		end
	end
	foundSeg = 1;
	
	feat = [feats{tt}.feat feats{tt}.featov feats{tt}.featscore];
	
	feat = config.seg.lambda*feat;
	
	% Pick the optimal feat w.r.t model parameters
	if ~isempty(W)
		ss = feat*W;
	else
		ss = feats{tt}.featov;
	end
	
	idx = ss>s;
	s(idx) = ss(idx);
	segIdx(idx) = tt;
	f(idx,1:end) = feat(idx,:); 
end


