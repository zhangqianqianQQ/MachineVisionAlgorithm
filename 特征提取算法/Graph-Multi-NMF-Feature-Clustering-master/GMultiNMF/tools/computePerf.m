function performance = computePerf(testAnnotations,Score_w_I,annotLabels)

numOfTestImages = size(testAnnotations,1);
numOfLabels = size(testAnnotations,2);

testLabelTableSize = zeros(numOfLabels,1);
for i = 1:numOfLabels
	testLabelTableSize(i) = sum(testAnnotations(:,i));
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% precision, recall, f1-score, nplus 

correct = zeros(numOfLabels,1);
predict = zeros(numOfLabels,1);
ground = zeros(numOfLabels,1);
for i = 1:numOfTestImages
	actualLabels = find(testAnnotations(i,:)==1);
	currScores1 = Score_w_I(:,i);
	assignedLabels = zeros(1,annotLabels);
	for j = 1:annotLabels
		[val,indx] = max(currScores1);
		assignedLabels(j) = indx;
		currScores1(indx) = -inf;
	end;

	for j = 1:length(assignedLabels)
		predict(assignedLabels(j)) = predict(assignedLabels(j)) + 1;
	end;

	for j = 1:length(actualLabels)
		ground(actualLabels(j)) = ground(actualLabels(j)) + 1;
		for k = 1:length(assignedLabels)
			if( assignedLabels(k)==actualLabels(j) )
				correct(assignedLabels(k)) = correct(assignedLabels(k)) + 1;
			end;
		end;
	end;
end;
prec = zeros(numOfLabels,1);
rec = zeros(numOfLabels,1);
for i = 1:numOfLabels
	if( predict(i)>0 )
		prec(i) = correct(i)/predict(i);
	end;
	if( ground(i)>0 )
		rec(i) = correct(i)/ground(i);
	end;
end;
precision = mean(prec);
recall = mean(rec);
f1score = 2*precision*recall/(precision+recall);
nplus = find(rec>0);

performance = [precision recall f1score length(nplus)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


