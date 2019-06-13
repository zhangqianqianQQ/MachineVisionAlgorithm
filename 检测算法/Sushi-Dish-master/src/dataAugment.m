%
% Data Augmentation
% input : data(101x101x3 x N) labels (1x N)
% output : augmented and cutted data (50x100x3 x 4N)
%          with labels and set indicator randomly permuted
%

function [n_data,n_label] = dataAugment(data,labels)
% flipud : Flip upside down and concat to make perfect circle
% fliplr : flip left and right
% imnoise : add noise to make model robust  
% (gaussian noise with 0 mean, 0.001 variance)
% imshow(imnoise(a,'gaussian',0,0.001))

    cut_data  = data(52:101,1:100,:,:);

    % augment with flip left and right
    flip_data = fliplr(cut_data);
    aug_data = cat(4,cut_data,flip_data);
    aug_labels = [labels labels];
    
    % augment with noise
    noi_data = imnoise(aug_data,'gaussian',0,0.001);
    n_data = cat(4,aug_data,noi_data);
    n_label = [aug_labels aug_labels];
    
    % length of total augmented dataset
    sz = size(n_label);
    length = sz(2);
    
    % Shuffle dataset 
    ran = randperm(length);
    n_data = n_data(:,:,:,ran);
    n_label = n_label(1,ran);    
    
    % possibly 4000 < data is collected
    % mark training dataset and validation dataset!  
end