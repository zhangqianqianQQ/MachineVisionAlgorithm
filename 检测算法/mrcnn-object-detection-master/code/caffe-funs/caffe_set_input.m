function caffe_set_input(net, input)
% 
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% AUTORIGHTS
% --------------------------------------------------------
% Copyright (c) 2015 Spyros Gidaris
% 
% "Object detection via a multi-region & semantic segmentation-aware CNN model"
% Technical report: http://arxiv.org/abs/1505.01749
% Licensed under The MIT License [see LICENSE for details]
% ---------------------------------------------------------

input_blob_names = net.inputs;
input_size  = caffe_get_blobs_size(net, input_blob_names);
assert(numel(input_size) == numel(input));
num_inputs  = length(input_blob_names);

for i = 1:num_inputs
    shape_this = net.blobs(input_blob_names{i}).shape;
    input{i}   = reshape(input{i}, shape_this);
    net.blobs(input_blob_names{i}).set_data(input{i}); 
end
end

