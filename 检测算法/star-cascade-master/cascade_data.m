function cascade_data(model, data_year, pca)

% cascade_data(model, data_year, pca)
%
% Compute score statistics for filters and deformation models
% using the model and training data associated with the model
% and dataset year 'data_year'.  If PCA is given a value > 0, then
% the score statistics are computed using a PCA projection of the
% model and training data.
%
% The score statistics are written in to the file 
% class_year_cascade_data_pcaK_data_year.inf, which is used 
% by cascade_model.m.
%
% model      object detector
% data_year  dataset year as a string (e.g., '2007')
% pca        number of PCA components to project onto (if pca > 0)

setVOCyear = model.year;
globals;
pascal_init;

% if using PCA, project the model
if pca > 0
  load('pca.mat');
  [ignore, model] = projectmodel(model, coeff, pca);
end

% files used by scorestat.cc
pca_str = num2str(pca);
class_year = [model.class '_' model.year];
detfile = [cscdir class_year '_cascade_data_det_' data_year '.inf'];
inffile = [cscdir class_year '_cascade_data_pca' pca_str '_' data_year '.inf'];

% load training images
pos = pascal_data(model.class, true, data_year);
if pca == 0
  % file for recording the detection location and component of each detection
  detfid = fopen(detfile, 'w');
  validinfo = [];
else
  % read the detection location and component used for each detection by the
  % non-PCA model
  pattern = ['%n%n%n' repmat('%n', 1, model.numblocks)];
  detfid = fopen(detfile);
  D = textscan(detfid, '%d %d %d %d %d', 'Delimiter', ' ');
  fclose(detfid);
  validinfo = [D{2} D{3} D{4} D{5}];
end

% reserve an int at the beginning of the file
inffid = fopen(inffile, 'wb');
fwrite(inffid, 0, 'int32');
% compute detections on training images
num = process(model, pos, validinfo, pca, detfid, inffid);
% rewind and write sample size
frewind(inffid);
fwrite(inffid, num, 'int32');
fclose(inffid);
if pca == 0
  fclose(detfid);
end
fprintf('Wrote score statistics for %d examples.\n', num);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write detection info file and detection feature vector file.
function num = process(model, pos, validinfo, pca, detfid, inffid)

numpos = length(pos);
pixels = model.minsize * model.sbin;
minsize = prod(pixels);

num = 0;
batchsize = 16;
% process positive examples in parallel batches
for j = 1:batchsize:numpos
  % do batches of detections in parallel
  thisbatchsize = batchsize - max(0, (j+batchsize-1) - numpos);
  % data for this batch
  pardata = {};
  parfor k = 1:thisbatchsize
    i = j+k-1;
    fprintf('%s %s: cascade data (PCA=%d): %d/%d', procid(), model.class, pca, i, numpos);
    bbox = [pos(i).x1 pos(i).y1 pos(i).x2 pos(i).y2];
    valid = struct('c',0,'x',0,'y',0,'l',0);
    % skip small examples
    if (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1) < minsize
      pardata{k}.det = [];
      if pca == 0
        pardata{k}.detinfo = valid;
      end
      fprintf(' (too small)\n');
      continue;
    end
    % get example
    im = imreadx(pos(i));
    [im, bbox] = croppos(im, bbox);
    pyra = featpyramid(im, model);
    if pca > 0
      pyra = projectpyramid(model, pyra);
      valid.c = validinfo(i,1);
      valid.x = validinfo(i,2);
      valid.y = validinfo(i,3);
      valid.l = validinfo(i,4);
    end
    [det, boxes, info] = gdetectvalid(pyra, model, 0, bbox, 0.5, valid);
    pardata{k}.detinfo = getdetinfo(model, info);
    pardata{k}.det = det;
    pardata{k}.boxes = boxes;
    pardata{k}.info = info;
    pardata{k}.pyra = pyra;

    if ~isempty(det)
      fprintf(' (%f)\n', det(end));
      num = num + 1;
      %showboxes(im, det);
    else
      fprintf(' (skip)\n');
    end
  end
  % write data to disk sequentially
  for k = 1:thisbatchsize
    i = j+k-1;
    if ~isempty(pardata{k}.det)
      writescores(pardata{k}.pyra, model, pardata{k}.info, inffid);
    end
    if pca == 0
      % record the detection location and component for this detection 
      detinfo = pardata{k}.detinfo;
      fprintf(detfid, '%d %d %d %d %d\n', ...
              i, detinfo.c, detinfo.x, detinfo.y, detinfo.l);
    end
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve the (x,y,scale) location of the detection in feature
% pyramid coordinates.
function d = getdetinfo(model, info)

d.c = 0;
d.x = 0;
d.y = 0;
d.l = 0;

if ~isempty(info)
  % See: gdetectwrite.m and getdetections.cc
  DET_IND = 2;    % rule index (i.e. component number)
  DET_X   = 3;    % x coord (filter and deformation)
  DET_Y   = 4;    % y coord (filter and deformation)
  DET_L   = 5;    % level (filter)

  ruleind = info(DET_IND, model.start, 1);
  d.c = ruleind;
  d.x = info(DET_X, model.start, 1);
  d.y = info(DET_Y, model.start, 1);
  d.l = info(DET_L, model.start, 1);
end
