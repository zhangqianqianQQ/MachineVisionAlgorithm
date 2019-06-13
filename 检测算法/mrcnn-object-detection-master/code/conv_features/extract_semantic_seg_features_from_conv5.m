function rsp = extract_semantic_seg_features_from_conv5(Semantic_Aware_CNN, input_conv_feat_maps, opts)
% extract_conv_features extract the convolutional features of one image
% for the specified scales using the provided convolutional neural network. 
%
% INPUTS:
% 1) Semantic_Aware_CNN: the caffe net struct with the convolutional neural 
% network that implements the activation mas module for the semantic segmentation aware
% CNN features (section 4 of technical report)
% 2) input_conv_feat_maps: a 1 x NumScales cell array with the input 
% convolutonal feature maps from a set of scales that they will be used as 
% input to the Semantic_Aware_CNN in order to extract the semantic segmentation 
% aware convolutional feature maps.
% 3) opts: a struct with the options that are being used for extracting the
% activation maps. Its fields are:
%   opts.do_interleave: a boolean value that if set to true then the
%   resolution augmentation technique described on the OverFeat paper: http://arxiv.org/abs/1312.6229
%   (section 3.3 of OverFeat technical report) is being used
%   opts.interleave_num_steps: a scalar value for the number of steps that
%   are being using on the above resolution augmentation technique
%
% OUTPUTS:
% 1) rsp: a 1 x NumScales cell array with the semantic segmentation aware
% convolutonal feature maps of each scale. The i-th element is a 
% H_i x W_i x C array with the convolutional feature maps of the i-th 
% scale. H_i and W_i are the height and width correspondingly of the 
% convolutional feature maps for the i-th scale.
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

interleave_num_steps = 0;
if (isfield(opts, 'do_interleave') && opts.do_interleave) 
    interleave_num_steps = opts.interleave_num_steps;
end

if isnumeric(input_conv_feat_maps), input_conv_feat_maps = {input_conv_feat_maps}; end

num_inputs = length(input_conv_feat_maps);
rsp = {};
for i = 1:num_inputs
    in = input_conv_feat_maps{i};
    in = permute(in, [2, 1, 3]); % change order of width, height for compatibility with caffe
    in = preprocess_input(in, interleave_num_steps); 
    
    % reshape the network such that it will accept the proper size for
    % input
    Semantic_Aware_CNN = caffe_reshape_net(Semantic_Aware_CNN, ...
        {[size(in,1), size(in,2), size(in,3), size(in,4)]});
    
    % get the convolutional feature maps of the image        
    response    = Semantic_Aware_CNN.forward({in});
    response{1} = postprocess_output(response{1}, interleave_num_steps);
    rsp{i}      = permute(response{1}, [2, 1, 3]);
end
rsp = rsp(:)';
end

function input = preprocess_input(input, interleave_num_steps)
if (interleave_num_steps > 1)
    % pre-process the input in case the resolution augmentation technique 
    % described on the OverFeat paper: http://arxiv.org/abs/1312.6229
    % (section 3.3 of OverFeat technical report) is being used
    length_1   = size(input,1) - (interleave_num_steps-1);
    length_2   = size(input,2) - (interleave_num_steps-1);
    batch_size = interleave_num_steps * interleave_num_steps;
    
    batch = cell([1,1,1,batch_size]);
        
    for j = 1:interleave_num_steps
        for i = 1:interleave_num_steps
            inter_i  = (i-1)+(1:length_1);
            inter_j  = (j-1)+(1:length_2);
            batch_id = (j-1)*interleave_num_steps + i;
            batch{batch_id} = input(inter_i,inter_j,:);
        end
    end
    input = cell2mat(batch);
end
end

function final_output = postprocess_output(output, interleave_num_steps)
if (interleave_num_steps > 1)
    % post-process the output in case the resolution augmentation technique 
    % described on the OverFeat paper: http://arxiv.org/abs/1312.6229
    % (section 3.3 of OverFeat technical report) is being used
    final_out_size = [size(output,1)*interleave_num_steps, size(output,2)*interleave_num_steps, size(output,3)];
    final_output   = zeros(final_out_size, 'like', output);
    for j = 1:interleave_num_steps
        for i = 1:interleave_num_steps
            inter_i  = (i-1) + (1:interleave_num_steps:size(final_output,1));
            inter_j  = (j-1) + (1:interleave_num_steps:size(final_output,2));
            batch_id = (j-1)*interleave_num_steps + i;
            final_output(inter_i,inter_j,:) = output(:,:,:,batch_id);
        end
    end
else
    final_output = output;
end
end