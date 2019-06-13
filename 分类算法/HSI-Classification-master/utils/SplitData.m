function splitInfo=SplitData(gt_label, split_type,n,excl_zero)
gt_label=gt_label(:);
labels=unique(gt_label);
num_data=length(gt_label);
train_idx=-1*ones(num_data,1);
train_label=-1*ones(num_data,1);
test_idx=-1*ones(num_data,1);
test_label=-1*ones(num_data,1);
num_train=0;
num_test=0;
if strcmp(split_type,'fix_num')
    for ll=1:length(labels)
        if (excl_zero&&0==labels(ll))
            continue;
        end
        idx_temp=find(gt_label==labels(ll));
        idx_temp=idx_temp(randperm(length(idx_temp)));
        num_train_temp=min(n,length(idx_temp));
        train_idx(num_train+1:num_train+num_train_temp)=idx_temp(1:num_train_temp);
        train_label(num_train+1:num_train+num_train_temp)=labels(ll);
        num_train=num_train+num_train_temp;
        num_test_temp=length(idx_temp)-num_train_temp;
        test_idx(num_test+1:num_test+num_test_temp)=idx_temp(num_train_temp+1:end);
        test_label(num_test+1:num_test+num_test_temp)=labels(ll);
        num_test=num_test+num_test_temp;
    end
elseif strcmp(split_type,'fix_ratio')
    if (n<0||n>1)
        disp('Wrong Split Ratio!');
        return;
    end
     for ll=1:length(labels)
        if (excl_zero&&0==labels(ll))
            continue;
        end
        idx_temp=find(gt_label==labels(ll));
        idx_temp=idx_temp(randperm(length(idx_temp)));
        num_train_temp=ceil(length(idx_temp)*n);        
        train_idx(num_train+1:num_train+num_train_temp)=idx_temp(1:num_train_temp);
        train_label(num_train+1:num_train+num_train_temp)=labels(ll);
        num_train=num_train+num_train_temp;
        num_test_temp=length(idx_temp)-num_train_temp;
        test_idx(num_test+1:num_test+num_test_temp)=idx_temp(num_train_temp+1:end);
        test_label(num_test+1:num_test+num_test_temp)=labels(ll);
        num_test=num_test+num_test_temp;
     end    
end
splitInfo=struct('train_idx',train_idx(1:num_train),'train_label',train_label(1:num_train),...
    'test_idx',test_idx(1:num_test),'test_label',test_label(1:num_test));
        