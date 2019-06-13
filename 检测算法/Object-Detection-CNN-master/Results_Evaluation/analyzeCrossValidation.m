%%%%%%%%%%%%%
% 
% ------------------------------------------------------------------------------------------
%       OUTPUT "Results" structure Attributes Description
% ------------------------------------------------------------------------------------------
%   CROSS-VALIDATION parameters
% - mergeType_values [N]:           window merge methods tested. 
% - minObjVal_values [M]:           minimum ODCNN score value accepted for picking windows.
% - mergeScales_values [S]:         merge all detection scales or not.
% - mergeThreshold_values [NxTn]:   threshold values applied on each method (mergeType_values)
%
% - ind_param [(NxTn)xSxM = nTests]:indices for each of the EVALUATION attributes to
%                                   the corresponding CROSS-VALIDATION parameters
%   EVALUATION attributes
% - precision [nTests x I]:         precision obtained on all the possible
%                                   test parameters and IoU GT evaluation metrics
% - recall [nTests x I]:            recall obtained on all the possible
%                                   test parameters and IoU GT evaluation metrics
% - PR_curve [nTests x 101]:        precision-recall curve for the first 0:0.01:1 
%                                   percentage of samples
% - AP [nTests x 11]:               average precision from 0 to 1 (0:0.1:1)
% - MAP [nTests]:                   mean average precision
% - AUC [nTests]:                   area under curve (recall-IoU curve)
% - IoU_values [I]:                 intersection over union GT evaluation metrics
% - avrgWindows [nTests]:           average # of windows obtained for each test parameter combination
% - stdWindows [nTests]:            standard deviation of avrgWindows
%
%%%%%%%%%%%%%

%% Parameters
% file = '/media/lifelogging/HDD_2TB/FoodCNN/tmp_cv_results';
% file = '/media/lifelogging/Shared SSD/food_tmp_cv_results';
file = '/Volumes/SHARED HD/FoodCNN/tmp_cv_results';

IoU_values = 0.5:0.05:1;


%% Load CV results
[objectsCV, files_list] = loadCV(file); % objectsCV

%% Prepare data structure to store results
Results = struct('mergeType_values', [], 'minObjVal_values', [], ...
    'mergeScales_values', [], 'mergeThreshold_values', [], 'ind_param', [], ...
    'precision', [], 'recall', [], 'IoU_values', [], 'avrgWindows', [], 'stdWindows', []);

%% Find tests parameters from the first image
nTests = length(objectsCV(1).test);
mergeType_values = {};
minObjVal_values = {};
mergeScales_values = {};
mergeThreshold_values = {};
% matrix with the indices to each parameter combination (for fast results storing)
ind_param = zeros(nTests,4);
for i = 1:nTests
    mty = objectsCV(1).test(i).mergeType;
    mov = num2str(objectsCV(1).test(i).minObjVal);
    ms = num2str(objectsCV(1).test(i).mergeScales);
    mth = num2str(objectsCV(1).test(i).mergeThreshold);
    pos_mty = find(ismember(mergeType_values, mty));
    pos_mov = find(ismember(minObjVal_values, mov));
    pos_ms = find(ismember(mergeScales_values, ms));
    if(isempty(pos_mty))
        mergeType_values = {mergeType_values{:}, mty};
        pos_mty = length(mergeType_values);
        mergeThreshold_values{pos_mty} = {};
    end
    if(isempty(pos_mov))
        minObjVal_values = {minObjVal_values{:}, mov};
        pos_mov = length(minObjVal_values);
    end
    if(isempty(pos_ms))
        mergeScales_values = {mergeScales_values{:}, ms};
        pos_ms = length(mergeScales_values);
    end
    
    pos_mth = find(ismember(mergeThreshold_values{pos_mty}, mth));
    if(isempty(pos_mth))
%         mergeThreshold_values{pos_mty} = {mergeThreshfeat_old_values{pos_mty}{:}, mth};
        mergeThreshold_values{pos_mty} = {mergeThreshold_values{pos_mty}{:}, mth};
        pos_mth = length(mergeThreshold_values{pos_mty});
    end
    
    % store parameter combination indices
    ind_param(i,:) = [pos_mty pos_mov pos_ms pos_mth];
end

%% Store in Results
Results.mergeType_values = mergeType_values;
Results.minObjVal_values = minObjVal_values;
Results.mergeScales_values = mergeScales_values;
Results.mergeThreshold_values = mergeThreshold_values;
Results.ind_param = ind_param;

%% Prepare evaluation variables
nSamples = length(objectsCV);
nIoU = length(IoU_values);
precision = zeros(nTests, nIoU);
recall = zeros(nTests, nIoU);
% nWindows = zeros(nTests, nSamples);
nWindows = [];
all_PR_curve = struct('precision', [], 'recall', []);
all_AP = zeros(nTests, nIoU);
all_AUC = zeros(nTests, 1);

%% Evaluate for each parameter combination
for i = 1:nTests
    disp(['Starting evaluation of test ' num2str(i) '/' num2str(nTests)]);
    
    % Create empty objects structure
    objects = struct('imgName', [], 'folder', [], 'ground_truth', [], 'objects', []);
    
    %% Load each CV file part
    nFiles = length(files_list);
    offset = 0;
    for nF = 1:nFiles
        disp(['Reading file ' files_list(nF).name]);
        load([file '/' files_list(nF).name]); % objectsCV
        nSamples = length(objectsCV);
        
        %% Get info from each sample
        for j = 1:nSamples

            objects(j+offset).imgName = objectsCV(j).imgName;
            objects(j+offset).folder = objectsCV(j).folder;
            nGT = length(objectsCV(j).ground_truth);
            nFound = 0;
            for k = 1:nGT
                if(~isempty(objectsCV(j).ground_truth(k).name))
                    nFound = nFound+1;
                    objects(j+offset).ground_truth(nFound).name = objectsCV(j).ground_truth(k).name;
                    objects(j+offset).ground_truth(nFound).ULx = objectsCV(j).ground_truth(k).ULx;
                    objects(j+offset).ground_truth(nFound).ULy = objectsCV(j).ground_truth(k).ULy;
                    objects(j+offset).ground_truth(nFound).BRx = objectsCV(j).ground_truth(k).BRx;
                    objects(j+offset).ground_truth(nFound).BRy = objectsCV(j).ground_truth(k).BRy;
                end
            end

            this_obj = objectsCV(j).test(i).objects;

            nWindows(i,j+offset) = length(this_obj);

            % Insert object candidate information for each object found
            for k = 1:nWindows(i,j+offset)
                objects(j+offset).objects(k).ULx = this_obj(k).ULx * objectsCV(j).resizeMaps;
                objects(j+offset).objects(k).ULy = this_obj(k).ULy * objectsCV(j).resizeMaps;
                objects(j+offset).objects(k).BRx = this_obj(k).BRx * objectsCV(j).resizeMaps;
                objects(j+offset).objects(k).BRy = this_obj(k).BRy * objectsCV(j).resizeMaps;
                objects(j+offset).objects(k).confidence = this_obj(k).confidence;
            end
        end

        offset = offset + nSamples;
    end    
        
    %% Evaluate for each IoU value
    objectsTMP = objects;
    for j = 1:nIoU
        disp(['  IoU = ' num2str(IoU_values(j))]);

        % Analyze objects found w.r.t. the GT
        disp('    Building GT...');
        [objectsTMP, nElems] = buildGroundTruth(objectsTMP, IoU_values(j), j == 1); % only rebuild from scratch with j == 1

        % Evaluate result for each IoU value
        disp('    Evaluating results for any Confidence value...');
        [precision(i,j), recall(i,j), PR_curve] = evaluateDetectionCNN(objectsTMP, nElems);

%         plot(PR_curve.recall, PR_curve.precision);
        AP = VOCap(PR_curve.recall', PR_curve.precision');

        all_PR_curve(i,j).precision = PR_curve.precision;
        all_PR_curve(i,j).recall = PR_curve.recall;
        all_AP(i,j) = AP;
    end
        
    all_AUC(i) = VOCap(IoU_values', recall(i,:)');
end


%% Store in Results
Results.precision = precision; % how many are correct from all that it found?
Results.recall = recall; % how many did it find from the total?
Results.IoU_values = IoU_values;
Results.avrgWindows = mean(nWindows, 2);
Results.stdWindows = std(nWindows, [], 2);
Results.PR_curve = all_PR_curve;
Results.AP = all_AP;
Results.MAP = mean(all_AP, 2);
Results.AUC = all_AUC;

save('Results.mat', 'Results');
disp('Done');
exit;
