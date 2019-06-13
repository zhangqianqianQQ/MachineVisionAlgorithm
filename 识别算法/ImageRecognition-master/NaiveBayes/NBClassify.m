%Takes in the Test Features Matrix xTest
%Mean Matrix M
%variance Matrix V
%class probability P
%Output is classifiers
function [t] = NBClassify(xTest, M, V, p)
[dim1,dim2] = size(M);
[dataSize, featureSize] = size(xTest);
if dim1 > length(p)
V = V';
M = M';
d1 = length(p);
d2 = dim1;
else
d1 = dim1;
d2 = length(p);
end

for k = 1:dataSize
    for i = 1:d1
        YGivenX = 1;
        for j = 1:d2
            Mean = M(i,j);
            Var = sqrt(V(i,j));
            x = xTest(k,j);
            s = normpdf(x,Mean,Var);
            YGivenX = YGivenX * s;
        end
        YGivenAllX(k,i) = YGivenX * p(i);
    end
    [~,t(k)] = max(YGivenAllX(k,:));
    if size(t,1) == 1
      t = t';
    end
end
end