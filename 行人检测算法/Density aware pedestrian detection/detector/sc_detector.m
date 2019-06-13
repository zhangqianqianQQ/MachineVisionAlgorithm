function [hypo_list,score_list, bbox_list,recog_result] = sc_detector(img,codebook,I_edge, para, verbose)


if(~exist('verbose','var'))
    verbose = 0;
end

if(isempty(I_edge))
    if(isempty(img))
        error('Neither image nor edge data is provided in');
    else
        if(verbose>1)
            fprintf(1,'Empesando por ed...');
            tic;
        end
        para_sc     = para{1};
        para_fea    = para{2};
        para_vote   = para{3};
        I_edge  = compute_edge_pyramid(img, para_sc.detector, ...
            para_vote.min_height, para_fea.ratio);
        if(verbose>1)
            fprintf(1,'Term en: %f secs\n',toc);
        end
    end
end

[hypo_list, score_list, bbox_list,recog_result] = ...
    sc_detector_on_edge(I_edge, codebook, para, verbose);
hypo_list   = round(hypo_list);
bbox_list   = round(bbox_list);
