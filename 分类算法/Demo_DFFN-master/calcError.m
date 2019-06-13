function [overall_accuracy,kappa_accuracy,average_accuracy,class_accuracy,errorMatrix] = calcError( trueLabelling, segLabelling, labels )
% calculates square array of numbers organized in rows and columns which express the
% percentage of pixels assigned to a particular category (in segLabelling) relative
% to the actual category as indicated by reference data (trueLabelling)
% errorMatrix(i,j) = nr of pixels that are of class i-1 and were
% classified as class j-1
% accuracy is essentially a measure of how many ground truth pixels were classified
% correctly (in percentage). 
% average accuracy is the average of the accuracies for each class
% overall accuracy is the accuracy of each class weighted by the proportion
% of test samples for that class in the total training set

[nrX, nrY] = size(trueLabelling);
totNrPixels = nrX*nrY;
nrPixelsPerClass = zeros(1,length(labels))';
nrClasses = length(labels);

errorMatrix = zeros(length(labels),length(labels));
errorMatrixPerc = zeros(length(labels),length(labels));

for l_true=1:length(labels)
    tmp_true = find (trueLabelling == (l_true-1));
    nrPixelsPerClass(l_true) = length(tmp_true);
    for l_seg=1:length(labels)
        tmp_seg = find (segLabelling == (l_seg-1));
        nrPixels = length(intersect(tmp_true,tmp_seg));
        errorMatrix(l_true,l_seg) = nrPixels;  
    end
end

% classWeight = nrPixelsPerClass/totNrPixels;
diagVector = diag(errorMatrix);
class_accuracy = (diagVector./(nrPixelsPerClass));
average_accuracy = mean(class_accuracy);
overall_accuracy = sum(segLabelling == trueLabelling)/length(trueLabelling);
kappa_accuracy = (sum(errorMatrix(:))*sum(diag(errorMatrix)) - sum(errorMatrix)*sum(errorMatrix,2))...
    /(sum(errorMatrix(:))^2 -  sum(errorMatrix)*sum(errorMatrix,2));