function segDeepMwrite(dataset,VOCopts,id)

if nargin<3
	disp('Assign an id for writing...');
	keyboard;
	id = 'comp4';
end

if nargin<4
	suffix = ['_' id];
end

%% configure VOCdevkit
VOCopts.cachedir = ['cachedir' filesep];
VOCopts.testset = dataset;
VOCopts.detrespath=[VOCopts.resdir 'Main/%s_det_' VOCopts.testset '_%s.txt'];

ids = textread(sprintf(VOCopts.imgsetpath,dataset),'%s');

for i=1:VOCopts.nclasses
    cls = VOCopts.classes{i};
    load( [ VOCopts.cachedir 'voc_' VOCopts.year '_' dataset filesep cls '_boxes_voc_' VOCopts.year '_' dataset suffix '.mat' ]);
    fid = fopen(sprintf(VOCopts.detrespath, id ,cls),'w');
    fprintf('Processing class %s:',cls);
    base = numel(ids)/10;
    for j=1:numel(ids)
        if j > base
            base = base + numel(ids)/10;
            fprintf('.');
        end
        scored_boxes = boxes{j};
        keep = nms(scored_boxes, 0.3);
        dets = scored_boxes(keep, :);
        for k=1:size(dets,1)
            fprintf(fid,'%s %f %.2f %.2f %.2f %.2f\n',ids{j},dets(k,5),dets(k,1:4));
        end
    end
    fclose(fid);
    fprintf('\n');
end






