function [ source_directory, list_of_images ] = createListOfImagesFromVOCOpts( path_to_voc_devkit, set_name )

addpath([path_to_voc_devkit,'/VOCcode']);
VOCopts = VOCInitFrom( path_to_voc_devkit );

image_ids      = textread(sprintf(VOCopts.imgsetpath,set_name),'%s');
list_of_images = cell(numel(image_ids),1);

for i = 1:numel(image_ids)
    list_of_images{i} = sprintf(VOCopts.imgpath,image_ids{i});
end


end

