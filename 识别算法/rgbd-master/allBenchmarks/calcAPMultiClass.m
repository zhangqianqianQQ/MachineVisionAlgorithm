function [ap maxAcc conf count] = calcAPMultiClass(gt, scores)
	%Calculate the classwise AP
	for i = 1:size(scores,1),
		[P R ap(i) acc maxAcc(i) cM] = calcPR(gt == i, scores(i,:));
	end

	%Make hard assignments based on the probabilities and then calculate the confusion matrix.
	[gr pred] = max(scores,[],1);
	for i = 1:size(scores,1),
		for j = 1:size(scores,1),
			count(i,j) = nnz(gt == i & pred == j);
		end
	end
	conf = bsxfun(@rdivide, count, max(1,sum(count,2)));
end
