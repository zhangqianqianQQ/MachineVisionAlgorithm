function [ucmThresh, meanNSP] = computeSPThreshold(imSet, numSP)

	imList = getImageSet(imSet);
	high = 1;
	low = 0.005;
	thresh = 0.005;

	while(high > low+thresh)
		mid = (low+high)/2;
		[meanNSP, nSP] = helper(imList, mid);
		if(meanNSP < numSP)
			high = mid;
		else
			low = mid;
		end
		fprintf('Between %0.3f, and %0.3f\n', low, high);
	end
	
	ucmThresh = mid;
end


function [meanNSP, nSP] = helper(imList, ucmThresh)
	parfor i = 1:length(imList),
		[~, ~, nSP(i), ~] = getSuperpixels(imList{i}, ucmThresh);
	end
	meanNSP = mean(nSP);
end
