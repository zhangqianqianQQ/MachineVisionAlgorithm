function [f fRaw] = getPHog(vq, score, maxN)
	superpixels = zeros(size(score));
	[x y] = size(superpixels);
	sx = repmat(1:y,[x 1]);
	sx = ceil(sx./y*4);
	sy = repmat([1:x]',[1 y]);
	sy = ceil(sy./x*4);
	superpixels = sx+4*(sy-1);
	sp2reg = false(16,21);
	sp2reg(:,1) = true;
	sp2reg([1 2 5 6],2) = true;
	sp2reg([3 4 7 8],3) = true;
	sp2reg([9 10 13 14],4) = true;
	sp2reg([11 12 15 16],5) = true;
	sp2reg(:,6:21) = eye(16,16) == 1;

	[f fRaw]= histIt(vq, score, maxN, sp2reg, superpixels);
	f = f(:);
	fRaw = fRaw(:);
end

function [featureReg featureRegRaw] = histIt(vq, score, nbins, sp2reg, superpixels)
	%Quantize the lab into bins from 1 to 10
	featureSP = accumarray([superpixels(vq > 0) vq(vq > 0)], score(vq > 0), [max(superpixels(:)), nbins])';
	featureReg = featureSP*sp2reg;
	featureRegRaw = featureReg;
	featureReg = sparse(bsxfun(@times, featureReg, 1./(1+sum(featureReg,1))));
end
