function [P R ap acc maxAcc cM] = calcPR(gt, out, wt)
% function [P R ap acc maxAcc cM] = calcPR(gt, out, wt)
% Function to calculate the precision, recall, ap, accuracy (at all thresholds), maximum accuracy and confusion matrix at point of maximum accuracy for a binary class problem.
% Input:
%	gt is the ground truth for each point. It should be between 0 and 1. Values between 0 and 1 are treated as how correct you think the gt is (for example for super pixels how much of a superpixel belongs to the corerct class. 
%	out is the score for the ith point.
%	wt is the weight for each point (for example for superpixels it might be the area of the super pixel).
% Output:
%	P is the precision
%	R is the recall at the corresponding precision value
%	ap is the average precision
%	acc is the corresponding accuracy for the precision and recall values
%	maxAcc is the maximum accuracy over all the thresholds
%	cM is the confusion matrix for the 2 class problem at the point at which there is maximum accuracy.

	if(~exist('wt','var'))
		wt = ones(size(gt));
	end
	assert(all(gt >= 0),'Ground truth should be between 0 and 1.\n');
	gt = wt(:).*gt(:);

	tog = [gt(:), wt(:), out(:)];
	tog = sortrows(tog,-3);
	sortgt = tog(:,1);
	cumsumsortgt = cumsum(sortgt);
	sortwt = tog(:,2);
	cumsumsortwt = cumsum(sortwt);
	P = cumsumsortgt./cumsumsortwt;
	R = cumsumsortgt./sum(sortgt);
	ap = VOCap(R,P);


	tp = cumsumsortgt;
	fp = cumsumsortwt - cumsumsortgt;
	tn = (sum(wt)-cumsumsortwt)-(sum(gt)-cumsumsortgt);
	fn = sum(gt)-cumsumsortgt;
	acc = (tp+tn)./(tp+fp+tn+fn);
	maxAcc = max(acc);
	[gr ind] = max(tp./(tp+fn)+tn./(tn+fp));
	cM(1,:) = [tp(ind) fn(ind)]./(tp(ind)+fn(ind));
	cM(2,:) = [fp(ind) tn(ind)]./(fp(ind)+tn(ind));
end
