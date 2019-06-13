function [ TP, FP, FN ] = measuresByConfidence( objects, min_confidence, all_TPs, all_FPs, TP_rep, FP )
%MEASURESBYCONFIDENCE Summary of this function goes here
%   Detailed explanation goes here

    countGT = 0;
    countFound = 0;    
    
    % TP_rep: number of TP windows with repeated GT instances
    % TP: number of TP objects, without repeating GT instances
    
    nImgs = length(objects);
    for i = 1:nImgs

        %% Get TP valid samples and remove non-valid ones (by confidence)
        if(TP_rep > 0)
            this_pos = find(all_TPs(:,1) == i);
            more_conf = find(all_TPs(this_pos,4) >= min_confidence);

            nMoreConf = length(more_conf);
            nLess = length(this_pos) - nMoreConf;
            TP_rep = TP_rep - nLess;
            
            this_found = all_TPs(this_pos(more_conf),3); % label ids of detections with min_confidence
        else
            this_found = [];
        end
        
        %% Find unique TPs labels
        un_this_found = unique(this_found);
        nUnique = length(un_this_found);
        countFound = countFound + nUnique;
        lenGT = 0;
        
        for j = 1:length(objects(i).ground_truth)
            if(~isempty(objects(i).ground_truth(j).name))
                lenGT = lenGT+1;
            end
        end
        countGT = countGT + lenGT;
    end

    %% Remove non-valid FPs (by confidence)
    if(FP > 0)
        nLess = sum(all_FPs(:,4) < min_confidence);
        FP = FP - nLess;
    end
    
    
%     frac_NoObj = 1-countObjs/countTot;
%     detection_rate = countFound/countGT;
    
    FN = countGT - countFound;
    TP = countFound;
    
    % Add all repeated TPs to FPs
    FP =  FP + (TP_rep-TP);

end

