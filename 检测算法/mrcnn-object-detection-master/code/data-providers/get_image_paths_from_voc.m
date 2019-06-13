function [ image_paths, image_set_name ] = get_image_paths_from_voc( voc_path, image_set, voc_year )

VOCopts         = initVOCOpts( voc_path, voc_year );
VOCopts.testset = image_set;
image_set_name  = ['voc_', voc_year, '_' image_set];

image_ext       = '.jpg';
image_dir       = fileparts(VOCopts.imgpath);
image_ids       = textread(sprintf(VOCopts.imgsetpath, image_set), '%s');
image_paths     = strcat([image_dir, filesep], image_ids, image_ext);
end


