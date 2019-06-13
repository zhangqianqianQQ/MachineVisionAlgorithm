function [ objects, nElems ] = buildGroundTruth( objects, threshold_detection, rebuild )
%BUILDGROUNDTRUTH Analyzes the GT and applies a matching on each of the 
% object candidate windows.

    nSamples = length(objects);
    nElems = 0;

    for j = 1:nSamples
        nGT = length(objects(j).ground_truth);

        if(rebuild)
            
            %% Initialize object candidates
            nObjs = length(objects(j).objects);
            for k = 1:nObjs
                objects(j).objects(k).OS = zeros(1, nGT);
                objects(j).objects(k).trueLabel = 'No Object';
                objects(j).objects(k).trueLabelId = [];
            end
            
            %% For each object
            for k = 1:nGT
                %% Check if any object in objects(j).objects matches 
                %  with the ground_truth for assign them the true label!
                GT = objects(j).ground_truth(k);
                GT.height = (GT.BRy - GT.ULy + 1);
                GT.width = (GT.BRx - GT.ULx + 1);
                GT.area = GT.height * GT.width;

                %% Check for each object candidate, if it fits the current true object
                count_candidate = 1;
                for w = objects(j).objects
                    if(~isempty(w.ULx)) % if the list of candidates is not empty
                        % Check area and intersection on current window "w"
                        w.height = (w.BRy - w.ULy + 1);
                        w.width = (w.BRx - w.ULx + 1);
                        w.area = w.height * w.width;

                        % Check intersection
    %                     count_intersect_old = rectint([GT.ULy, GT.ULx, GT.height, GT.width], [w.ULy, w.ULx, w.height, w.width]);
                        x_overlap = max(0, min(GT.BRx,w.BRx) - max(GT.ULx,w.ULx));
                        y_overlap = max(0, min(GT.BRy,w.BRy) - max(GT.ULy,w.ULy));
                        count_intersect = x_overlap * y_overlap;

                        % Calculate overlap score
                        OS = count_intersect / (GT.area + w.area - count_intersect);

                        if(OS >= threshold_detection) % object detected!
                            label = objects(j).ground_truth(k).name;
                            % If OS bigger than previous, then assign this
                            if(max(w.OS) < OS)
                                w.trueLabel = label;
                                w.trueLabelId = k;
                            end
                        end
                        w.OS(k) = OS;

                        % Store w object
                        objects(j).objects(count_candidate).OS = w.OS;
                        objects(j).objects(count_candidate).trueLabel = w.trueLabel;
                        objects(j).objects(count_candidate).trueLabelId = w.trueLabelId;

                        count_candidate = count_candidate + 1;
                    end
                end
                nElems = nElems+count_candidate-1;
            end
        else % Only pick the maximum OS (already calculated) if it is over the given threshold
            count_candidate = 1;
            for w = objects(j).objects
                if(w.OS(w.trueLabelId) < threshold_detection)
                    objects(j).objects(count_candidate).trueLabel = 'No Object';
                    objects(j).objects(count_candidate).trueLabelId = [];
                end
                count_candidate = count_candidate + 1;
            end
            nElems = nElems+count_candidate-1;
        end
    end 

end

