function [superpixels, ucm, nSP, spArea] = getSuperpixels(imName, ucmThresh)
% function [superpixels, ucm, nSP, spArea] = getSuperpixels(imName, ucmThresh)
%  includes the boundary at value ucmThresh, ucmThresh must be in double, like 34/255.
%  Returns the UCM in uint8 format.

	paths = getPaths();
	ucm = getUCM(imName);
	ucmD = im2double(ucm);
	superpixels = bwlabel(ucmD < ucmThresh);
	superpixels = superpixels(2:2:end,2:2:end);
	nSP = max(superpixels(:));
	if(nargout > 2)
		spArea = histc(superpixels(:),1:nSP);
	end
end
