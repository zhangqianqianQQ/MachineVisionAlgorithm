function [result] = multisvm(TrainingSet,GroupTrain,TestSet)

u=unique(GroupTrain);
numClasses=length(u);
result = zeros(length(TestSet(:,1)),1);
%  gamma = 0.0078125;
gamma = 0.1
c = 2
sigma = 1/(sqrt(2*gamma));
%build models
for k=1:numClasses
    
    %Vectorized statement that binarizes Group
    %where 1 is the current class and 0 is all other classes
    G1vAll=(GroupTrain==u(k));
    models(k) = svmtrain(TrainingSet,G1vAll,'kernel_function','rbf','boxconstraint',c,'rbf_sigma',sigma);
end

%classify test cases
for j=1:size(TestSet,1)
    for k=1:numClasses
        if(svmclassify(models(k),TestSet(j,:))) 
            break;
        end
    end
    result(j) = k;
end
