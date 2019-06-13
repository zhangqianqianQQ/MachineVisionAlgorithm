function [ precision, recall, PR_curve ] = evaluateDetectionCNN( objects, nElems )
%EVALUATEODCNN Evaluates the result obtained by the ObjectDetector-CNN
% w.r.t. a given intersection over union (IoU) value.
    
    min_conf_per = 0:0.02:1;

    
    %% Get labels and scores for each TP sample
    [ all_TPs, all_FPs, TP_, FP_ ] = getTPs(objects, nElems);
    
    %% Only continue if we have any detection
    nDetections = TP_+FP_;
    if(nDetections > 0)
        %% Sort detection confidence scores
        sorted_scores = [];
        if(TP_ > 0)
            sorted_scores = [sorted_scores; all_TPs(:,4)];
        end
        if(FP_ > 0)
            sorted_scores = [sorted_scores; all_FPs(:,4)];
        end
        sorted_scores = sort(sorted_scores, 'descend');

        %% Build precision-recall curve
        rec = zeros(1,length(min_conf_per));
        prec = zeros(1,length(min_conf_per));
        count = 1;
        for conf_per = min_conf_per

            % Only evaluate then score is >= score on current percentage position
            pos_min_score = max(round(nDetections*conf_per), 1);
            min_score = sorted_scores(pos_min_score);
            [TP, FP, FN] = measuresByConfidence(objects, min_score, all_TPs, all_FPs, TP_, FP_);

            if(conf_per == 1)
                % precision = 1 - frac_NoObj;
                % recall = detection_rate;

                precision = TP / (TP + FP); % how many are correct from all that it found?
                recall = TP / (TP + FN); % how many did it find from the total?
            end

            prec(count) = TP / (TP + FP);
            rec(count) = TP / (TP + FN);
            count = count+1;
        end
    else
        precision = 0;
        recall = 0;
        rec = zeros(1,length(min_conf_per));
        prec = zeros(1,length(min_conf_per));
    end
        
    PR_curve.precision = prec;
    PR_curve.recall = rec;
end

