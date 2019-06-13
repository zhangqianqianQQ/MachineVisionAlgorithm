%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the proposal set for optimization
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,S] = getProposals(I, net, param)

imsz = [size(I,1) size(I,2)];
Ip = zeros(param.width,param.height,3,param.batchSize, 'single');
Ip(:,:,:,1) = prepareImage(I, param);
scores = net.forward({Ip});
scores = scores{1};
[scores, idx] = sort(scores(:,1)', 'descend');
BB = param.center(:, idx);
P = BB(:,1:param.masterImgPropN);
S = scores(1:param.masterImgPropN);

% extract ROIs
ROI = BB(:,1:param.roiN);
ROI = postProc(ROI, imsz, param);
ROI = clusterBoxes(ROI, param); % merge some ROI if needed
% process ROIs
imglist = cropImgList(I,ROI);
for i = 1:numel(imglist)
    Ip(:,:,:,i) = prepareImage(imglist{i}, param);
end
scores = net.forward({Ip});
scores = reshape(scores{1},[],param.batchSize);
[scores, idx] = sort(scores, 'descend');
for i = 1:numel(imglist)
    B = param.center(:,idx(1:param.subImgPropN,i));
    roi = ROI(:,i)./imsz([2 1 2 1])';
    B = getROIBBox(B, roi);
    P = [P, B];
    S = [S, scores(1:param.subImgPropN,i)'];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Ip = prepareImage(I, param)

Ip = imresize(I(:, :, [3 2 1]),...
        [param.height, param.width], 'bilinear', 'antialiasing', false);
Ip = single(Ip);
Ip = Ip - param.imageMean(1:param.height, 1:param.width, :);
Ip = permute(Ip, [2 1 3]);


function ROI = clusterBoxes(bb, param)

ROI = [];
if size(bb,2) < 2
    ROI = bb;
    return;
end
D = [];
for i = 1:size(bb,2)
    for j = i+1:size(bb,2)
        D(end+1) = 1-getIOUFloat(bb(:,j)',bb(:,i));
    end
end
Z = linkage(D);
T = cluster(Z,'cutoff',param.roiClusterCutoff,'criterion','distance');

for i = 1:max(T);
    ROI = [ROI [min(bb(1:2,T==i),[],2);max(bb(3:4,T==i),[],2)]];
end


function roi = postProc(roi, imsz, param)

% expand
w = roi(3,:)-roi(1,:);
h = roi(4,:)-roi(2,:);
roi(1,:) = roi(1,:)-w*param.roiExpand*0.5;
roi(2,:) = roi(2,:)-h*param.roiExpand*0.5;
roi(3,:) = roi(1,:)+w*(1+param.roiExpand);
roi(4,:) = roi(2,:)+h*(1+param.roiExpand);

roi = round(bsxfun(@times, roi,imsz([2 1 2 1])'));
roi(1:2,:) = max(roi(1:2,:),1);
roi(3,:) = min(roi(3,:),imsz(2));
roi(4,:) = min(roi(4,:),imsz(1));

% removing
area = (roi(3,:)-roi(1,:)+1).*(roi(4,:)-roi(2,:)+1);
roi = roi(:,area<0.9*imsz(1)*imsz(2));


function imglist = cropImgList(img,roilist)

imglist = [];
for i = 1:size(roilist,2)
    roi = roilist(:,i);
    imglist{i} = img(roi(2):roi(4), roi(1):roi(3),:);
end

