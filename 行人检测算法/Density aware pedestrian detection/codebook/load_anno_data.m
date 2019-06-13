function anno_list  = load_ann_data(imgdir,mask_dir)

anno_list   = [];
[path_list,fname,file_list] = get_file_list(imgdir,{'png','jpg','bmp'});
for ff=1:length(path_list)
    img = imread(path_list(ff).name);
    mask_file   = fullfile(mask_dir,fname(ff).name);
    mask_img=imread(mask_file);
    if(size(mask_img,3)>1)
        error('mask image should be gray image');
    end
    [mvalue,m,n] = unique(mask_img(:));
    mvalue  = mvalue(find(mvalue>0));
    nb_mask = length(mvalue);
    for mm=1:nb_mask
        anno_list(ff,mm).img    = img;
        anno_list(ff,mm).mask   = (mask_img==mvalue(mm));
    end
end
