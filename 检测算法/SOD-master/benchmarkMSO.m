%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Benchmark methods on the MSO dataset
%
% Jianming Zhang, Stan Sclaroff, Zhe Lin, Xiaohui Shen, 
% Brian Price and Radomír Mech. "Unconstrained Salient 
% Object Detection via Proposal Subset Optimization." 
% CVPR, 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('dataset/MSO', 'dir')
    downloadMSO;
end

param = getParam('VGG16');
net = initModel(param);

load dataset/MSO/imgIdx

cacheDir = 'propCache';
if ~exist(cacheDir, 'dir')
    mkdir(cacheDir);
end

props = [];
flag = false;
cacheName = ['MSO_' param.modelName '.mat'];

% load precomputed proposals if possible
if exist(fullfile(cacheDir,cacheName), 'file')
    fprintf('using precomputed proposals.\n');
    load(fullfile(cacheDir, cacheName));
    flag = true;
end

legs = [];

%% evaluate the MAP method
fprintf('run the MAP method\n');
lambda = [0,0.000001,0.0001,0.01:0.01:0.1,0.1:0.1:1];
res = [];
for j = 1:numel(imgIdx)
    I = imreadRGB(fullfile('dataset/MSO/img/',imgIdx(j).name));
    imsz = [size(I,1), size(I,2)];

    % load precomputed proposals
    if flag 
        P = props(j).P;
        S = props(j).S;
    else
        [P, S] = getProposals(I, net, param);
        props(j).P = P;
        props(j).S = S;
    end
    if mod(j,100) == 0
        fprintf('processed %d images\n',j);
    end

    for i = 1:numel(lambda)
        param.lambda = lambda(i);
        param.gamma = 10* lambda(i);
        tmpRes = propOpt(P, S, param);

        % scale bboxes to full size
        tmpRes = bsxfun(@times, tmpRes, imsz([2 1 2 1])');

        res{i}{j} = tmpRes;
    end
end

caffe.reset_all();

if ~flag
    save(fullfile(cacheDir, cacheName), 'props', '-v7.3');
end

figure
hold on

[TP NPred NGT] = evaluateBBox(imgIdx, res);

P = sum(TP,2)./max(sum(NPred,2), 0.01);
R = sum(TP,2)./max(sum(NGT),0.01);
plot(R,P,'r')
ap = calcAP(R,P);
legs{end+1} = sprintf('MAP: %f',ap);

%% evaluate the NMS baseline
fprintf('run the NMS baseline\n');
thresh = 0:0.02:1;
res = [];
for j = 1:numel(imgIdx)
    I = imreadRGB(fullfile('dataset/MSO/img/',imgIdx(j).name));
    imsz = [size(I,1), size(I,2)];
    P = props(j).P;
    S = props(j).S;
    if mod(j,100) == 0
        fprintf('processed %d images\n',j);
    end
            
    % scale bboxes to full size
    P = bsxfun(@times, P, imsz([2 1 2 1])');
    [S,idx] = sort(S, 'descend');
    P = P(:,idx);
    [P, sidx]= doNMS(P, 0.4);
    S = S(sidx);    
    
    for i = 1:numel(thresh)
        tmpRes = P(:, S>=thresh(i));
        res{i}{j} = tmpRes;
    end
end

[TP NPred NGT] = evaluateBBox(imgIdx, res);
P = sum(TP,2)./max(sum(NPred,2), 0.01);
R = sum(TP,2)./max(sum(NGT),0.01);
plot(R,P,'b')
ap = calcAP(R,P);
legs{end+1} = sprintf('NMS: %f',ap);

%% evaluate the MMR baseline
fprintf('run the MMR  baseline\n');
thresh = -1.0:0.01:1.0;
res = [];
for j = 1:numel(imgIdx)
    I = imreadRGB(fullfile('dataset/MSO/img/',imgIdx(j).name));
    imsz = [size(I,1), size(I,2)];
    P = props(j).P;
    S = props(j).S;
    if mod(j,100) == 0
        fprintf('processed %d images\n',j);
    end
            
    % scale bboxes to full size
    P = bsxfun(@times, P, imsz([2 1 2 1])');
    [S,idx] = sort(S, 'descend');
    P = P(:,idx);
    [P, S] = doMMR(P', S, 1.0);
    for i = 1:numel(thresh)
        tmpRes = P(:,S>thresh(i));
        res{i}{j} = tmpRes;
    end
end
[TP NPred NGT] = evaluateBBox(imgIdx, res);
P = sum(TP,2)./max(sum(NPred,2), 0.01);
R = sum(TP,2)./max(sum(NGT),0.01);
plot(R,P,'g')
ap = calcAP(R,P);
legs{end+1} = sprintf('MMR: %f',ap);

grid on
legend(legs)
title(sprintf('PR Curves on the MSO Dataset (%s)', param.modelName))
