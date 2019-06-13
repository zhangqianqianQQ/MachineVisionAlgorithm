function res_file = writeDetectionsPascalFile(boxes, image_paths, VOCopts, cls, dst_path)

image_ids = getImageIdsFromImagePaths(image_paths);

addpath(fullfile(VOCopts.datadir, 'VOCcode')); 

res_fn = sprintf(VOCopts.detrespath, 'comp4', cls);
[path, filename, ext] = fileparts(res_fn);
res_file = [dst_path, filesep, filename, ext];

fid = fopen(res_file, 'w');
for i = 1:length(image_ids);
    bbox = boxes{i};
    for j = 1:size(bbox,1)
        fprintf(fid, '%s %f %d %d %d %d\n', image_ids{i}, bbox(j,end), bbox(j,1:4));
    end
end
fclose(fid);

end

