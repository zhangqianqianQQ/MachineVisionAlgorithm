function select_final_model(conf,imdb,roidb,model,rpn,max_iter,val_interval)

    mynet = caffe.Net(model.test_net_def_file, 'test');
    caffe.set_mode_gpu();
    
    val_iter=max_iter/val_interval;
    weight_folder=model.output_model_file(1:end-6); % except '\final'
    test_folder=strrep(weight_folder,'train','test');
    mkdir_if_missing(test_folder);
    n=length(imdb.image_ids);
    
    gt_boxes=cell(n,1);
    for i=1:n
        boxes=[roidb.rois(i).boxes, roidb.rois(i).ignores];
        boxes=[boxes(:,1),boxes(:,2),boxes(:,3)-boxes(:,1),boxes(:,4)-boxes(:,2),boxes(:,5)];
        gt_boxes{i}=boxes;
    end
    
    if(~rpn)
        aboxes=load(fullfile(strrep(test_folder,'fast_rcnn','rpn'),'final_boxes'));
        rpn_boxes=aboxes.proposal_boxes;
    end
    proposal_boxes=cell(n,1);
    min_MR=100;
    for v=1:(max_iter/val_iter)

        method_name=sprintf('iter_%d',val_iter*v);
        mynet.copy_from(fullfile(weight_folder,method_name));

        for i=1:n
            if(~rpn)
                im=imread(imdb.image_at(i));
                [img, ~, ~]=my_image_blob(conf,imdb.image_at(i),model.multi_frame);
                img = img(:, :, [3, 2, 1], :); % from rgb to brg
                img = single(permute(img, [2, 1, 3, 4]));
                rpn_box=rpn_boxes{i};
                [rcnn_box, scores] = fast_rcnn_conv_feat_detect( conf, mynet, im, img, rpn_box(:, 1:4));
                rcnn_box = boxes_filter([rcnn_box, scores(:,2)], 100, 0.5, 10, 1);
                proposal_boxes{i} = rcnn_box;
            else
                [boxes, scores, ~, ~, ~] = proposal_im_detect(conf, mynet, imdb.image_at(i), model.multi_frame);
                rpn_boxes = boxes_filter([boxes, scores], 10000, 0.5, 100, 1);
                proposal_boxes{i} = rpn_boxes;
            end
        end
        wh_boxes=proposal_boxes;
        for i=1:n
            boxes=wh_boxes{i};
            boxes=[boxes(:,1),boxes(:,2),boxes(:,3)-boxes(:,1),boxes(:,4)-boxes(:,2),boxes(:,5)];
            wh_boxes{i}=boxes;
        end
        thr=0.5; % overlap>thrÀÌ¸é TP·Î
        mul=0;
        ref=10.^(-2:.25:0);
        [gt,dt] = bbGt('evalRes',gt_boxes,wh_boxes,thr,mul);
        [~,~,~,miss] = bbGt('compRoc',gt,dt,1,ref);
        miss=exp(mean(log(max(1e-10,1-miss))));
        if(min_MR>miss)
            save(fullfile(test_folder,'final_boxes'),'proposal_boxes');
            final_name=sprintf('iter_%d',val_iter*v);
            min_MR=miss;
        end
    end
    movefile(fullfile(weight_folder,final_name),fullfile(weight_folder,'final'));
    fprintf([sprintf('model MR: %f, ',min_MR), final_name, ' is selected.\n']);
    caffe.reset_all();
end

function aboxes = boxes_filter(aboxes, per_nms_topN, nms_overlap_thres, after_nms_topN, use_gpu)
    % to speed up nms
    if per_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), per_nms_topN), :);
    end
    % do nms
    if nms_overlap_thres > 0 && nms_overlap_thres < 1
        aboxes = aboxes(nms(aboxes, nms_overlap_thres, use_gpu), :);       
    end
    if after_nms_topN > 0
        aboxes = aboxes(1:min(length(aboxes), after_nms_topN), :);
    end
end