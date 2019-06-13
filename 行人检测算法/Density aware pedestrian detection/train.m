para_sc = set_parameter;
para_sc.model_height    = 150;
dataroot    = getDataRoot;
img_dir = fullfile(dataroot,'train','images');
mask_dir= fullfile(dataroot,'train','mask');
codebook_file= fullfile(dataroot,'codebook','cb_test_new.mat');
anno_data   = load_anno_data(img_dir,mask_dir);
codebook    = load_codebook(anno_data,para_sc);
save(codebook_file,'codebook');


%ACM MM Test 4.
%ACM MM Test 5.