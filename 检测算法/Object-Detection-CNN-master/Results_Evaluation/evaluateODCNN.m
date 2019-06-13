function [ precision, recall, PR_curve ] = evaluateODCNN( objects )
%EVALUATEODCNN Evaluates the result obtained by the ObjectDetector-CNN
% w.r.t. a given intersection over union (IoU) value.

%     list_classes = {};
    un_list_classes = {};
    countTot = 0;
    countObjs = 0;
    countGT = 0;
    countFound = 0;
    count_empty = 0;
    
    % TP1: number of TP windows with repeated GT instances
    % TP2: number of TP objects, without repeating GT instances
    TP1 = 0; TP2 = 0;
    FP = 0; FN = 0;
    
    found_GT = [];
    count_tot = [];
    
    for i = 1:length(objects)
        this_found = [];
        for j = 1:length(objects(i).objects)
            countTot = countTot+1;
            if(~strcmp('No Object', objects(i).objects(j).trueLabel))
                countObjs = countObjs+1;
                this_found = [this_found; objects(i).objects(j).trueLabelId];
                TP1 = TP1+1;
            else
                FP = FP+1;
            end
        end
        un_this_found = unique(this_found);
        countFound = countFound + length(un_this_found);
        lenGT = 0;
        
        found_GT = [found_GT zeros(1, length(objects(i).ground_truth))];
        count_tot = [count_tot zeros(1, length(objects(i).ground_truth))];
        if(length(un_this_found) == 1)
            found_counts = length(this_found);
        else
            [found_counts, ~] = hist(this_found, un_this_found);
        end
        found_GT(un_this_found+countGT) = found_counts;
        count_tot(countGT+1:end) = countTot;
        
        for j = 1:length(objects(i).ground_truth)
            if(~isempty(objects(i).ground_truth(j).name))
                lenGT = lenGT+1;
                if(~sum(ismember(un_list_classes, objects(i).ground_truth(j).name)))
                    un_list_classes = {un_list_classes{:}, objects(i).ground_truth(j).name};
                end
%                 list_classes = {list_classes{:}, objects(i).ground_truth(j).name};
            else
                count_empty = count_empty+1;
            end
        end
        countGT = countGT + lenGT;
    end

    
    frac_NoObj = 1-countObjs/countTot;
    detection_rate = countFound/countGT;
    
    FN = countGT - countFound;
    TP2 = countFound;
    
    % precision = 1 - frac_NoObj;
    % recall = detection_rate;
    
    precision = TP1 / (TP1 + FP); % how many are correct from all that it found?
    recall = TP2 / (TP2 + FN); % how many did it find from the total?
    
    %% Build precision-recall curve
    data_per = 0:0.1:1;
    rec = zeros(1,length(data_per));
    prec = zeros(1,length(data_per));
    count = 1;
    for dp = data_per
        topP = round(countGT*dp);
        if(topP == 0)
            topP = 1;
        end
        prec(count) = sum(found_GT(1:topP)) / count_tot(topP);
        rec(count) = sum(found_GT(1:topP) > 0) / countGT;
        count = count+1;
    end
    PR_curve.precision = prec;
    PR_curve.recall = rec;
end

