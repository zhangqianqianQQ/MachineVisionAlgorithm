function [DataTest DataTrain CTest CTrain Loc_test] = samplesdivide(indian_pines_corrected,indian_pines_gt,train,randpp);

CTrain = [];
CTest = [];
DataTest  = [];
DataTrain = [];

[m n p] = size(indian_pines_corrected);
indian_pines_map = uint8(zeros(m,n));
data_col = reshape(indian_pines_corrected,m*n,p);
[mm nn] = ind2sub([m n],1:m*n);
data_col = [mm' nn' data_col];

for i = 1:max(indian_pines_gt(:))
    ci = length(find(indian_pines_gt==i));    
    [v]=find(indian_pines_gt==i);    
    datai = data_col(find(indian_pines_gt==i),:);
    if train>1
        cTrain = round(train);
    else
        cTrain  = round(train*ci); 
    end
    cTest  = ci-cTrain;
    CTrain = [CTrain cTrain];
    CTest = [CTest cTest];
    index = randpp{i};
    DataTest = [DataTest; datai(index(1:cTest),:)];
    DataTrain = [DataTrain; datai(index(cTest+1:cTest+cTrain),:)];
end

Normalize = max(max(DataTrain(:,3:end)));
DataTrain(:,3:end) = DataTrain(:,3:end)./Normalize;
DataTest(:,3:end)  = DataTest(:,3:end)./Normalize;

