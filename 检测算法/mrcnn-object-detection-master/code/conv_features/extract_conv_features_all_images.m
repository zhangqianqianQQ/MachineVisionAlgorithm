function extract_conv_features_all_images( net, input_file_paths, destination_dir, varargin)
% 
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% Part of the code in this file comes from the SPP-Net code: 
% https://github.com/ShaoqingRen/SPP_net
% 
% AUTORIGHTS
% --------------------------------------------------------
% Copyright (c) 2015 Spyros Gidaris
% 
% "Object detection via a multi-region & semantic segmentation-aware CNN model"
% Technical report: http://arxiv.org/abs/1505.01749
% Licensed under The MIT License [see LICENSE for details]
% ---------------------------------------------------------
% Copyright (c) 2014, Shaoqing Ren
% 
% This file is part of the SPP code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% --------------------------------------------------------- 

ip = inputParser;
ip.addOptional('start',    1, @isscalar);
ip.addOptional('end',      0, @isscalar);
ip.addOptional('scales',   [480 576 688 874 1200], @ismatrix);
ip.addOptional('mean_pix', [103.939, 116.779, 123.68],  @isnumeric);
ip.addOptional('force', false,  @islogical);

ip.parse(varargin{:});
opts = ip.Results;

if opts.end <= 0
    opts.end = length(input_file_paths);
else
    opts.end = min(opts.end, length(input_file_paths));
end

% Where to save feature cache
mkdir_if_missing(destination_dir);

opts.output_dir = destination_dir;
mkdir_if_missing(opts.output_dir);

% Log feature extraction
timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
diary_file = [destination_dir, 'extract_conv_features_all_images_', timestamp '.txt'];
diary(diary_file);
fprintf('Logging output in %s\n', diary_file);

fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
fprintf('Extract convolutional features options:\n');
disp(opts);
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n');

filenames  = getImageIdsFromImagePaths( input_file_paths );
total_time = 0;
total_file_size_mega = 0;
count = 0;
num_imgs = opts.end - opts.start + 1;
for i = opts.start:opts.end
    fprintf('%s: extract conv features: %d/%d\n', procid(), i, opts.end);
    output_file_path = [destination_dir, filesep, filenames{i}, '.mat'];
    
    if (~exist(output_file_path, 'file') || opts.force)
        tot_th = tic;
        
        try
            count = count + 1;
            file_size_mega = process_image(net, input_file_paths{i}, output_file_path, opts);
        catch exception
            file_size_mega = 0;
            fprintf('Error: Cannot proccess %s.\n', output_file_path);
            fprintf('Exception message %s\n', getReport(exception));
        end
        
        total_file_size_mega = total_file_size_mega + file_size_mega;
        avg_file_size_mega = total_file_size_mega/count;
        est_total_size_giga = num_imgs * avg_file_size_mega / 1024;
        total_time = total_time + toc(tot_th);
        avg_time = total_time/count;
        est_rem_time = avg_time * (num_imgs - i) / 60;
        fprintf('[avg time: %.2fs] [est rem. time: %.2fmins] [avg space %.3fMega] [est total space %.2fGiga]\n', ...
            avg_time, est_rem_time, avg_file_size_mega, est_total_size_giga);
    else
        fprintf(' [already exists]\n');
    end
end

end

function fileSizeInMbs = process_image(net, input_file_path, output_file_path, opts)
th = tic;

d = init_feat_data();
image = get_image(input_file_path);
d.feat.im_height = size(image,1);
d.feat.im_width  = size(image,2);
[d.feat.rsp, d.feat.scale] = extract_conv_features(net, image, opts.scales, opts.mean_pix);

fprintf(' [features: %.3fs]', toc(th));
th = tic;
save(output_file_path, '-struct', 'd');
fileInfo = dir(output_file_path);
fileSizeInMbs = fileInfo.bytes / (1024*1024);
fprintf(' [saving:   %.3fs]', toc(th));
fprintf(' [Mbytes:   %.4f]\n', fileSizeInMbs);
end

function d = init_feat_data()
d.gt       = []; 
d.overlap  = []; 
d.boxes    = []; 
d.class    = []; 
d.feat     = [];
end
