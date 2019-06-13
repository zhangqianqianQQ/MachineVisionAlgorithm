function data = prepare_batch_feat_input_data(pooler, feature_paths, windows, data_param)
num_windows   = size(windows,1); 
feat_dim      = data_param.feat_dim;
data          = zeros(feat_dim, num_windows, 'single');
num_threads   = 6;

if isfield(data_param, 'num_threads') && data_param.num_threads > 0 
    num_threads = data_param.num_threads;
end

select_img_idx  = unique(windows(:,1));
num_sel_img     = length(select_img_idx);
feature_paths   = feature_paths(select_img_idx);
window_this_img = cell(num_sel_img, 1);
img_window_map  = cell(num_sel_img, 1);
for i = 1:num_sel_img
    indices = find(windows(:,1) == select_img_idx(i));
    window_this_img{i} = windows(indices, :);
    img_window_map{i}  = indices(:);
end
assert(sum(cellfun(@(x) size(x, 1), window_this_img, 'UniformOutput', true)) == num_windows);
assert(sum(cellfun(@(x) size(x, 1), img_window_map, 'UniformOutput', true)) == num_windows);

random_scale = data_param.random_scale;

num_blocks   = 3;
block_size   = ceil(num_sel_img / num_blocks);
for b = 1:num_blocks
    start_idx       = (b-1) * block_size + 1;
    stop_idx        = min(b*block_size,num_sel_img);
    this_block_size = stop_idx - start_idx + 1;

    block_sel_img_idx     = select_img_idx(start_idx:stop_idx);
    block_window_this_img = window_this_img(start_idx:stop_idx);
    block_feature_paths   = feature_paths(start_idx:stop_idx);

    block_feats    = cell(1,this_block_size);
    block_data_map = cell2mat(img_window_map(start_idx:stop_idx));
    
    assert(all(block_data_map > 0 & block_data_map <= num_windows));
    assert(length(unique(block_data_map)) == length(block_data_map));
    if num_threads == 1
        for i = 1:this_block_size
            assert(all(block_window_this_img{i}(:,1) == block_sel_img_idx(i)));
            %feat_cache = load(block_feature_paths{i}, 'feat');
            feat_cache  = read_feat_conv_data( block_feature_paths{i}, true );
            block_feats{i} = cell2mat(convFeat_to_poolFeat_multi_region(pooler, ...
                feat_cache.feat, block_window_this_img{i}(:, 4:7), random_scale));
        end
    else
        parfor (i = 1:this_block_size,num_threads)
            assert(all(block_window_this_img{i}(:,1) == block_sel_img_idx(i)));
            feat_cache  = read_feat_conv_data( block_feature_paths{i}, true );
            block_feats{i} = cell2mat(convFeat_to_poolFeat_multi_region(pooler, ...
                feat_cache.feat, block_window_this_img{i}(:, 4:7), random_scale));
        end
    end
    data(:,block_data_map) = cell2mat(block_feats);
    for i = 1:this_block_size, block_feats{i} = []; end
end
end
