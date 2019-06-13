function [dets, boxes, t] = cascade_detect(pyra, model, thresh)

th = tic();

% gather PCA root filters for convolution
numrootfilters = length(model.rootfilters);
rootfilters = cell(numrootfilters, 1);
for i = 1:numrootfilters
  rootfilters{i} = model.rootfilters{i}.wpca;
end

% compute PCA projection of the feature pyramid
projpyra = projectpyramid(model, pyra);

% stage 0: convolution with PCA root filters is done densely
% before any pruning can be applied
numrootlocs = 0;
nlevels = size(pyra.feat,1);
rootscores = cell(model.numcomponents, nlevels);
s = 0;  % holds the amount of temp storage needed by cascade()
for i = 1:length(pyra.scales)
  s = s + size(pyra.feat{i},1)*size(pyra.feat{i},2);
  if i > model.interval
    scores = fconv_var_dim(projpyra.feat{i}, rootfilters, 1, numrootfilters);
    for c = 1:model.numcomponents
      u = model.components{c}.rootindex;
      v = model.components{c}.offsetindex;
      rootscores{c,i} = scores{u} + model.offsets{v}.w;
      numrootlocs = numrootlocs + numel(scores{u});
    end
  end
end
s = s*length(model.partfilters);
model.thresh = thresh;
% run remaining cascade stages and collect object hypotheses
coords = cascade(model, pyra.feat, projpyra.feat, rootscores, ...
                 numrootlocs, pyra.scales, pyra.padx, pyra.pady, s);
boxes = coords';
dets = boxes(:,[1:4 end-1 end]);
t = toc(th);
