function mappedX = plot_tsne_map(nPos, nNeg, paths)
% PLOT_TSNE_MAP plots a 2D map of the multi-dimensional spatial 
%               distribution of the features.
%  
% INPUT:
%       nPos, nNeg: number of positive / negative images
%       paths: image paths as a cell array
% OUTPUT:
%       reduced dimensional mapped data to print as a scatter plot.
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 02-Dec-2013 17:57:42 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : plot_tsne_map.m 

% Getting image directories
if nargin <= 2
    pos_path = uigetdir('.\images','Select positive test image path');
    if isa(pos_path,'double')
        cprintf('Errors','Invalid path...\nexiting...\n\n')
        return 
    end

    neg_path = uigetdir('.\images','Select negative test image path');
    if isa(neg_path,'double')
        cprintf('Errors','Invalid path...\nexiting...\n\n')
        return 
    end
    
else
   pos_path = paths{1};
   neg_path = paths{2};
end

% reading images and computing HOGs
[pos_ims,neg_ims] = get_files(nPos,nNeg,{pos_path, neg_path});
[labels, hogs] = get_feature_matrix(pos_ims, neg_ims);


%% Computing the t-sne map
% Params
n_dims = 2;
init_dims = 30;
perplexity = 30;

% Running t-sne
mappedX = tsne(hogs, [], n_dims, init_dims, perplexity);
whos('mappedX')

% Plot results
figure();
gscatter(mappedX(:,1), mappedX(:,2), labels,'br','xo');
