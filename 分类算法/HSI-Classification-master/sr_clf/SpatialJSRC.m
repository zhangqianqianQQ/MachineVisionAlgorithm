function pred_label=SpatialJSRC(feat, train_data, train_label, sp_label, block_size, param)
% Classification of superpixels with joint sparse representation
% Input:
%    feat: extracted img features, nr*nc*nd where nd is the number of feature channel
%    dict: the dictionary
%    dict_label: the label of dictionary atoms
%    sp_label: the label of superpixels, nr*nc
%    block_size: the size for block-wise processing
%    param: parameter for sparse representation
%            param.L (optional, maximum number of elements in each decomposition, 
%               min(m,p) by default)
%            param.eps (optional, threshold on the squared l2-norm of the residual,
%               0 by default
%            param.lambda (optional, penalty parameter, 0 by default
%            param.numThreads (optional, number of threads for exploiting
%            multi-core / multi-cpus. By default, it takes the value -1,
%            which automatically selects all the available CPUs/cores).
%   2016-10-20, jlfeng

[nr,nc,~]=size(feat);
sp_label=reshape(sp_label,[nr*nc 1]);
[group_label,sortidx]=sort(sp_label);
feat_sort=VectorIndexing3D(feat,sortidx);
idx_group_start=zeros(length(unique(group_label)),1);
idx_group_start(2:end)=int32(find(diff(group_label)~=0));

num_sp=length(idx_group_start);
num_block=ceil(num_sp/block_size);
disp('Block-wise classification strategy is used. ');
disp(['Number of Blocks: ', num2str(num_block)]);
pause(0.05)
pred_label_sort=zeros(nr*nc,1);
for nn=1:num_block
    disp(['Processing block ',num2str(nn)]);tic
    idxstart=(nn-1)*block_size;
    idxend=min(nn*block_size-1,num_sp-1);
    idx_block=(group_label>=idxstart)&(group_label<=idxend);
    test_data=feat_sort(:,idx_block);
    idx_group_start_block=idx_group_start(idxstart+1:idxend+1);
    idx_group_start_block=idx_group_start_block-idx_group_start_block(1);
    pred_label_block=JSRClassifier(train_data,train_label,test_data,idx_group_start_block,param);
    pred_label_sort(idx_block)=pred_label_block;
end
pred_label=zeros(nr*nc,1);
pred_label(sortidx)=pred_label_sort;
pred_label=reshape(pred_label,[Nx Ny]);
