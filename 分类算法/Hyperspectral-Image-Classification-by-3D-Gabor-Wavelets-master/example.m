% gird-search for c&g

clear all;
IO_I;

sample_rate=0.05;
[sample_gt,~]=Random_I(sample_rate);
test_pos=1;
train_pos=1;
for k=1:20
    for kk=1:20
        if(sample_gt(k,kk)==1)  %是选中的样本，作为train
            trainlabels(train_pos,:)=indian_pines_gt(k,kk);
            traindata(train_pos,:)=indian_pines_corrected(k,kk,:);
            train_pos=train_pos+1;
        else
            if(indian_pines_gt(k,kk)~=0)  %作为test,背景
                testlabels(test_pos,:)=indian_pines_gt(k,kk);
                testdata(test_pos,:)=indian_pines_corrected(k,kk,:);
                test_pos=test_pos+1;
            end
        end
    end
    disp(k);
end

disp('svm ready');


bestacc = 0;    % 存放最佳识别率
for cc = 5:10
    for gg = -5:5
        acc = svmtrain(trainlabels, traindata, ['-c ', num2str(2^cc), ' -g ',  num2str(2^gg),' -v 5']);   % 5折交叉验证 c的取值范围[2^5--2^10] g的取值范围[2^(-5)--2^5]
        if acc > bestacc
            bestacc = acc;
            bestc = cc;      % 存储最佳c
            bestg = gg;      % 存储最佳g
        end
    end
end

% train with best c and g
model = svmtrain(trainlabels, traindata, ['-c ', num2str(2^bestc), ' -g ',  num2str(2^bestg)]);
[result, ~, ~] = svmpredict(testlabels, testdata, model);
accuracy = sum(result==testlabels)/length(result);
disp(testlabels);