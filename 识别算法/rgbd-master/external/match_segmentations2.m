function [sumRI, sumVOI ] = match_segmentations2(seg, groundTruth)
% match a test segmentation to a set of ground-truth segmentations with the PROBABILISTIC RAND INDEX and VARIATION OF INFORMATION metrics.

sumRI = 0;
sumVOI = 0;
[tx, ty] = size(seg);

for s = 1 : numel(groundTruth)
    gt = groundTruth{s}.Segmentation;

    num1 = max(seg(:));
    num2 = max(gt(:));
    confcounts = zeros(num1, num2);
    for i = 1:tx
        for j = 1:ty
            u = seg(i,j);
            v = gt(i,j); 
            if (u>0) && (v>0), % ignore label '0'
            	confcounts(u,v) = confcounts(u,v)+1;
            end
        end
    end
    
    curRI = rand_index(confcounts);
    curVOI = variation_of_information(confcounts);
    
    sumRI = sumRI + curRI;
    sumVOI = sumVOI + curVOI;

end

sumRI = sumRI / numel(groundTruth);
sumVOI = sumVOI / numel(groundTruth);


%% performance metrics following the implementation by Allen Yang:
% http://perception.csl.uiuc.edu/coding/image_segmentation/

function ri = rand_index(n)
N = sum(sum(n));
n_u=sum(n,2);
n_v=sum(n,1);
N_choose_2=N*(N-1)/2;
ri = 1 - ( sum(n_u .* n_u)/2 + sum(n_v .* n_v)/2 - sum(sum(n.*n)) )/N_choose_2;

function vi = variation_of_information(n)
N = sum(sum(n));
joint = n / N; % the joint pmf of the two labels
marginal_2 = sum(joint,1);  % row vector
marginal_1 = sum(joint,2);  % column vector
H1 = - sum( marginal_1 .* log2(marginal_1 + (marginal_1 == 0) ) ); % entropy of the first label
H2 = - sum( marginal_2 .* log2(marginal_2 + (marginal_2 == 0) ) ); % entropy of the second label
MI = sum(sum( joint .* log2_quotient( joint, marginal_1*marginal_2 )  )); % mutual information
vi = H1 + H2 - 2 * MI; 

function lq = log2_quotient( A, B )
lq = log2( (A + ((A==0).*B) + (B==0)) ./ (B + (B==0)) );
