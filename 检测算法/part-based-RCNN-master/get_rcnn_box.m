q = load('/u/vis/nzhang/projects/recurPart/scripts/bird_boxes_all.mat');
for i = 1: length(config.impathtest)
    if ~isempty(q.aboxes{3}{i})
        config.test_bbox_prior(i, :) =  [q.aboxes{3}{i}(1,2)  q.aboxes{3}{i}(1,1) q.aboxes{3}{i}(1,4) q.aboxes{3}{i}(1,3)];
        config.test_head_prior(i,:) = [q.aboxes{3}{i}(1,6)  q.aboxes{3}{i}(1,5) q.aboxes{3}{i}(1,8) q.aboxes{3}{i}(1,7)];
        config.test_body_prior(i,:) = [q.aboxes{3}{i}(1,10) q.aboxes{3}{i}(1,9) q.aboxes{3}{i}(1,12) q.aboxes{3}{i}(1,11)];
    else
        config.test_bbox_prior(i, :) = [-1 -1 -1 -1];
        config.test_head_prior(i,:) = [-1 -1 -1 -1];
        config.test_body_prior(i,:) = [-1 -1 -1 -1];
    end
    if ~isempty(q.aboxes{4}{i})
        config.test_bbox_neighbor(i, :) = [q.aboxes{4}{i}(1,2)  q.aboxes{4}{i}(1,1) q.aboxes{4}{i}(1,4) q.aboxes{4}{i}(1,3)];
        config.test_head_neighbor(i,:) = [q.aboxes{4}{i}(1,6)  q.aboxes{4}{i}(1,5) q.aboxes{4}{i}(1,8) q.aboxes{4}{i}(1,7)];
        config.test_body_neighbor(i,:) = [q.aboxes{4}{i}(1,10) q.aboxes{4}{i}(1,9) q.aboxes{4}{i}(1,12) q.aboxes{4}{i}(1,11)];
    else
        config.test_bbox_neighbor(i, :) = [-1 -1 -1 -1];
        config.test_head_neighbor(i,:) = [-1 -1 -1 -1];
        config.test_body_neighbor(i,:) = [-1 -1 -1 -1];
    end
end


q = load('/u/vis/nzhang/projects/recurPart/scripts/bird_boxes_all_fix.mat');
for i = 1: length(config.impathtest)
    if ~isempty(q.aboxes{1}{i})
        config.test_bbox_box(i,:) = [q.aboxes{1}{i}(1,2)  q.aboxes{1}{i}(1,1) q.   aboxes{1}{i}(1,4) q.aboxes{1}{i}(1,3)];
        config.test_head_box(i,:) = [q.aboxes{1}{i}(1,6)  q.aboxes{1}{i}(1,5) q.aboxes{1}{i}(1,8) q.aboxes{1}{i}(1,7)];
        config.test_body_box(i,:) = [q.aboxes{1}{i}(1,10) q.aboxes{1}{i}(1,9) q.aboxes{1}{i}(1,12) q.aboxes{1}{i}(1,11)];
    else
        config.test_bbox_box(i, :) = [-1 -1 -1 -1];
        config.test_head_box(i,:) = [-1 -1 -1 -1];
        config.test_body_box(i,:) = [-1 -1 -1 -1];
    end
end

q = load('/u/vis/nzhang/projects/recurPart/scripts/bird_boxes_parts_all.mat');
for i = 1: length(config.impathtest)
    if ~isempty(q.aboxes{1}{i})
        config.head_box(i, :) =  [q.aboxes{1}{i}(1,2)  q.aboxes{1}{i}(1,1) q.aboxes{1}{i}(1,4) q.aboxes{1}{i}(1,3)] + [config.test_bb(i,1) config.test_bb(i,2) config.test_bb(i,1) config.test_bb(i,2)];
        config.body_box(i,:) = [q.aboxes{1}{i}(1,6)  q.aboxes{1}{i}(1,5) q.aboxes{1}{i}(1,8) q.aboxes{1}{i}(1,7)] + [config.test_bb(i,1) config.test_bb(i,2) config.test_bb(i,1) config.test_bb(i,2)];
    else
        config.head_box(i, :) = [-1 -1 -1 -1];
        config.body_box(i,:) = [-1 -1 -1 -1];
    end
 
    if ~isempty(q.aboxes{3}{i})
        config.head_prior(i, :) =  [q.aboxes{3}{i}(1,2)  q.aboxes{3}{i}(1,1) q.aboxes{3}{i}(1,4) q.aboxes{3}{i}(1,3)] + [config.test_bb(i,1) config.test_bb(i,2) config.test_bb(i,1) config.test_bb(i,2)];
        config.body_prior(i,:) = [q.aboxes{3}{i}(1,6)  q.aboxes{3}{i}(1,5) q.aboxes{3}{i}(1,8) q.aboxes{3}{i}(1,7)] + [config.test_bb(i,1) config.test_bb(i,2) config.test_bb(i,1) config.test_bb(i,2)];
    else
