% classify function 
% TO RUN : 1) MatConvNet must be installed.
%          2) Modify variable 'setup_path'
% Input : 101 x 101 x 3 feature image
% Output : scores [0, 1] of each class (1~8)

function scores = classifyFeature(img, images, net)
    % 1) Input Normalization : change to 50x100x3 and subtract data_mean
    nor_im = single(img(52:101,1:100,:))- images.data_mean;
    
    % 2) Classify via vl_simplenn
    net.layers{end}.type = 'softmax';
    res = vl_simplenn(net, nor_im) ;
    
    % show the classification result
    scores = squeeze(gather(res(end).x)) ;

end