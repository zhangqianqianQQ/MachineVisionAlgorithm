function extract_semantic_features_all_images(net, conv5_file_paths, destination_dir, varargin)
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

ip = inputParser;
ip.addOptional('start',    1, @isscalar);
ip.addOptional('end',      0, @isscalar);
ip.addOptional('scales',   [576 874 1200], @ismatrix);
ip.addOptional('do_interleave',        0,  @isscalar);
ip.addOptional('interleave_num_steps', 1,  @isscalar);
ip.addOptional('force',            false,  @islogical);

ip.parse(varargin{:});
opts = ip.Results;

if opts.end <= 0
    opts.end = length(conv5_file_paths);
else
    opts.end = min(opts.end, length(conv5_file_paths));
end

% Where to save feature cache
mkdir_if_missing(destination_dir);

opts.output_dir = destination_dir;
mkdir_if_missing(opts.output_dir);

% Log feature extraction
timestamp = datestr(datevec(now()), 'yyyymmdd_HHMMSS');
diary_file = [destination_dir, 'extract_semantic_features_all_images_', timestamp '.txt'];
diary(diary_file);
fprintf('Logging output in %s\n', diary_file);

fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
fprintf('Extract semantic segmentation aware CNN features options:\n');
disp(opts);
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n');

filenames  = getImageIdsFromImagePaths( conv5_file_paths );
total_time = 0;
total_file_size_mega = 0;
count = 0;
num_imgs = opts.end - opts.start + 1;
for i = opts.start:opts.end
    fprintf('%s: extract semantic segmentation aware conv features: %d/%d\n', procid(), i, opts.end);
    output_file_path = [destination_dir, filesep, filenames{i}, '.mat'];
    
    if (~exist(output_file_path, 'file') || opts.force)
        tot_th = tic;
        
        try
            count = count + 1;
            file_size_mega = process_image(net, conv5_file_paths{i}, output_file_path, opts);
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

d          = read_feat_conv_data(input_file_path);
d.feat     = pick_scales_if_there(d.feat, opts.scales);    
d.feat.rsp = extract_semantic_seg_features_from_conv5(net, d.feat.rsp, opts);

fprintf(' [features: %.3fs]', toc(th));
th = tic;
save(output_file_path, '-struct', 'd');
fileInfo = dir(output_file_path);
fileSizeInMbs = fileInfo.bytes / (1024*1024);
fprintf(' [saving:   %.3fs]', toc(th));
fprintf(' [Mbytes:   %.4f]\n', fileSizeInMbs);
end

function feat = pick_scales_if_there(feat, scales)
num_scales = length(scales);

found_scales = zeros(size(scales));
found_rsp = {};
c = 0;
for s = 1:num_scales
    scale_index = find(feat.scale == scales(s));
    if ~isempty(scale_index)
        assert(numel(scale_index) == 1);
        c = c + 1;
        found_scales(c) = scales(s);
        found_rsp{c}    = feat.rsp{scale_index}; 
    end
end
feat.scale = found_scales(1:c);
feat.rsp   = found_rsp;
end