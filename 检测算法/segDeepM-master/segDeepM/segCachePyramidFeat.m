function feats = segCachePyramidFeat(imname,detwin,config)
% Cache features for each segment
% This could save some time in training as we iterate over images 
% Input:
%           imname:     name for input image
%           detwin:     object proposals (in [x1,y1,x2,y2])
% Output:
%           feats:      cell array containing features for each segment


try
    load([config.seg.segSaveDir filesep imname '.mat'],'feats');
catch
    pyras = segGetPyramid(imname, config);
    
    numSeg = length(pyras);
    numDets = size(detwin,1);
    numPyra = config.seg.numPyra;
    
    XP1 = detwin(:,1);
    YP1 = detwin(:,2);
    XP2 = detwin(:,3);
    YP2 = detwin(:,4);
    area = (XP2-XP1+1).*(YP2-YP1+1);
    areamax = max(area);
    
    feats = cell(1,numSeg);
    
    % Create a mesh to store pyramid locations
    HP = (YP2-YP1)/numPyra;
    WP = (XP2-XP1)/numPyra;
    inds = cell(numPyra+1,numPyra+1);
    for m1 = 1:numPyra+1
        for m2 = 1:numPyra+1
            YP = round(YP1 + (m1-1)*HP );
            XP = round(XP1 + (m2-1)*WP );
            inds{m1,m2}=sub2ind([size(pyras{1}.bbfeat,1) size(pyras{1}.bbfeat,2)], YP, XP);
        end
    end
    
    boxes = zeros(numSeg,4);
    % Loop over the segments
    for tt = 1:numSeg
        bbfeat = pyras{tt}.bbfeat;
        bbfeatneg = pyras{tt}.bbfeatneg;
        ovfeat = pyras{tt}.ovfeat;
        segsize = max(1e-4,pyras{tt}.segsize);
        segsizeneg = max(1e-4,pyras{tt}.segsizeneg);
        
        % Features for each detection windows
        featnf = zeros(numDets,numPyra*numPyra);
        featfneg = featnf;
        for m1 = 1:numPyra
            for m2 = 1:numPyra
                % seg-in
                featnf(:,(m1-1)*numPyra+m2) = bbfeat(inds{m1,m2}) - bbfeat(inds{m1,m2+1}) - bbfeat(inds{m1+1,m2}) + bbfeat(inds{m1+1,m2+1});
                % back-in
                featfneg(:,(m1-1)*numPyra+m2) = bbfeatneg(inds{m1,m2}) - bbfeatneg(inds{m1,m2+1}) - bbfeatneg(inds{m1+1,m2}) + bbfeatneg(inds{m1+1,m2+1});
            end
        end
        
        ind = 1:numDets;
        % seg-out
        featnb = bbfeat(end,end) - sum(featnf(ind',:),2);
        % back-out
        featbneg = bbfeatneg(end,end) - sum(featfneg(ind',:),2);
        featnf = featnf / segsize;
        featnb = featnb / segsize;
        
        featfneg = featfneg / segsizeneg;
        featbneg = featbneg / segsizeneg;
        
        % norm
        featfneg = featfneg * segsizeneg / areamax - 1/numPyra/numPyra;
        featbneg = (featbneg - (1 - areamax / segsizeneg)) / (areamax / segsizeneg);
        
        % overlap features, IOU - 0.7
        [ii,jj] = find(ovfeat==1);
        if ~isempty(ii)
            bbox2 = [min(jj) min(ii) max(jj) max(ii)];
            feats{tt}.bbox = bbox2;
            boxes(tt,:)=bbox2;
            area2 = (bbox2(3)-bbox2(1)+1)*(bbox2(4)-bbox2(2)+1);
            ovbox = [max(XP1,bbox2(1)) max(YP1,bbox2(2)) min(XP2,bbox2(3)) min(YP2,bbox2(4))];
            ova = max(0,ovbox(:,3)-ovbox(:,1)+1) .* max(0,ovbox(:,4)-ovbox(:,2)+1);
            ov = ova./(area+area2-ova);
            featov = ov-0.7;
        else
            feats{tt}.bbox = [0 0 0 0];
            boxes(tt,:) = [0 0 0 0];
            featov = -0.7*ones(size(featnf,1),1);
        end
        
        featscore = repmat(pyras{tt}.score, numDets, 1);
        
        feat = [featnf featnb featfneg featbneg];
        
        feats{tt}.class = pyras{tt}.class;
        
        feats{tt}.feat = feat;
        feats{tt}.featov = featov;
        feats{tt}.featscore = featscore;
    end
    
    if config.seg.saveFeat
        save([config.seg.segSaveDir filesep imname '.mat'],'feats');
    end
end


function pyras = segGetPyramid(imname, config)
% Before calling this function, all potentials must be normalized to [-1,1]

N = config.seg.maxSegUsed;

rec = load([config.seg.maskPath imname '.mat']);
pot = load([config.seg.potentialPath imname '.mat']);

% Set background potential to -2
if size(pot.potential,2) == config.seg.numSegClasses
    pot.potential = [pot.potential ones(size(pot.potential,1),1)*-2];
else
    pot.potential(:,end) = ones(size(pot.potential,1),1)*-2;
end

% Remove segment smaller than 1500 pixels
segSize = zeros(1,size(rec.masks,3));
assert(size(rec.masks,3)>0);
for i=1:numel(segSize)
    segSize(i)=sum(sum(rec.masks(:,:,i)));
end

remove = segSize<1500;

% Cache mask size
imgSize = size(rec.masks(:,:,1));
rec.masks(:,:,remove)=[];
pot.potential(remove,:)=[];

[maxScore, maxClsIdx] = max(pot.potential,[],2);
[~, list] = sort(maxScore,'descend');

% Currently we dont use background
list(maxClsIdx==config.seg.numSegClasses+1)=[];

N = min(numel(list),N);
pyras = cell(1,N+1);

for i=1:N
    k = list(i);
    img = rec.masks(:,:,k);
    pyra.ovfeat = img;
    
    ss = sum(sum(double(img)));
    img = cumsum(cumsum(double(img)),2);
    
    pyra.bbfeat = img;
    pyra.segsize = ss;
    pyra.bgtag = 0;
    
    img = 1-rec.masks(:,:,k);
    ss = sum(sum(double(img)));
    img = cumsum(cumsum(double(img)),2);
    pyra.bbfeatneg = img;
    pyra.segsizeneg = ss;
    
    pyra.class = maxClsIdx(k);
    pyra.score = 1./(exp(-pot.potential(k,1:config.seg.numSegClasses))+1);
    
    pyras{i}=pyra;
end

% A dummy mask for classes that has no instance
img = zeros(imgSize);
pyra.bbfeat = img;
pyra.segsize = numel(img);
imgbg = ones(imgSize);
imgbg = cumsum(cumsum(double(imgbg)),2);
pyra.bbfeatneg = imgbg;
pyra.segsizeneg = numel(imgbg);
pyra.ovfeat = img;
pyra.bgtag = 1;
pyra.score = zeros(1,config.seg.numSegClasses);
pyra.class = 0;

pyras{N+1} = pyra;

