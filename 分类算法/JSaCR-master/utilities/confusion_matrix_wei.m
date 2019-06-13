function [confusion, accuracy, TPR, FPR] = confusion_matrix_wei(class, c)
%
% class is the result of test data after classification
%          (1 x n)
%
% c is the label for testing data
%          (1 x len_c)
%
%

class = class.';
c = c.';

n = length(class);
c_len = length(c);

if n ~= sum(c)
    disp('WRANING:  wrong inputting!');
    return;
end


% confusion matrix
confusion = zeros(c_len, c_len);
a = 0;
for i = 1: c_len
    for j = (a + 1): (a + c(i))
        confusion(i, class(j)) = confusion(i, class(j)) + 1;
    end
    a = a + c(i);
end


% True_positive_rate + False_positive_rate + accuracy
TPR = zeros(1, c_len);
FPR = zeros(1, c_len);
for i = 1: c_len
  FPR(i) = confusion(i, i)/sum(confusion(:, i));
  TPR(i) = confusion(i, i)/sum(confusion(i, :));
end
accuracy = sum(diag(confusion))/sum(c);
