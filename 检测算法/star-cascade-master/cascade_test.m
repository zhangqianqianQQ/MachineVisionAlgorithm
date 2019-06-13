function boxes1 = cascade_test(model, prec, testset, year, suffix)

% boxes1 = cascade_test(cls, model, testset, year, suffix)
% Compute bounding boxes in a test set.
% boxes1 are detection windows and scores.
%
% prec specifies the target level of precision that wish to achieve.
% if you let prec = [], a threshold tuned to reach the prec-equals-recall
% point will be selected.

% Now we also save the locations of each filter for rescoring
% parts1 gives the locations for the detections in boxes1
% (these are saved in the cache file, but not returned by the function)

setVOCyear = year;
globals;
pascal_init;

cls = model.class;
ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

[prec, recall, thresh] = cascade_thresh(model, year, prec);
model.thresh = thresh;
pca = 5;
model = cascade_model(model, model.year, pca, model.thresh);

% run detector in each image
try
  load([cachedir cls '_boxes_' testset '_' suffix]);
catch
  times = zeros(length(ids), 2);
  % parfor gets confused if we use VOCopts
  opts = VOCopts;
  % parallel implementation disabled for single-threaded tests
  %parfor i = 1:length(ids);
  for i = 1:length(ids);
    if strcmp('inriaperson', cls)
      % INRIA uses a mixutre of PNGs and JPGs, so we need to use the annotation
      % to locate the image.  The annotation is not generally available for PASCAL
      % test data (e.g., 2009 test), so this method can fail for PASCAL.
      rec = PASreadrecord(sprintf(opts.annopath, ids{i}));
      im = imread([opts.datadir rec.imgname]);
    else
      im = imread(sprintf(opts.imgpath, ids{i}));  
    end
    th = tic();
    pyra = featpyramid(im, model);
    time_feat = toc(th);

    th = tic();
    [dets, boxes] = cascade_detect(pyra, model, model.thresh);
    time_det = toc(th);

    if ~isempty(boxes)
      [dets boxes] = clipboxes(im, dets, boxes);
      I = nms(dets, 0.5);
      boxes1{i} = dets(I,[1:4 end]);
      parts1{i} = boxes(I,:);
    else
      boxes1{i} = [];
      parts1{i} = [];
    end
    times(i,:) = [time_det time_feat];
    fprintf('%s: testing: %s %s, %d/%d (avg time %.3f)\n', cls, testset, year, ...
            i, length(ids), mean(times(1:i,1)));
  end    
  save([cachedir cls '_boxes_' testset '_' suffix], ...
       'boxes1', 'parts1', 'times');
end
