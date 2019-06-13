function writescores(pyra, model, info, fid)

% Write block scores to cascade score stats file.
%
% pyra     feature pyramid
% model    object model
% info     detection info from gdetect.m
% fid      file descriptor

% indexes into info from getdetections.cc
DET_USE = 1;    % current symbol is used
DET_IND = 2;    % rule index
DET_X   = 3;    % x coord (filter and deformation)
DET_Y   = 4;    % y coord (filter and deformation)
DET_L   = 5;    % level (filter)
DET_DS  = 6;    % # of 2x scalings relative to the start symbol location
DET_PX  = 7;    % x coord of "probe" (deformation)
DET_PY  = 8;    % y coord of "probe" (deformation)
DET_VAL = 9;    % score of current symbol
DET_SZ  = 10;   % <count number of constants above>

for i = 1:size(info,3)
  scores = zeros(model.numblocks, 1);

  for j = 1:model.numsymbols
    % skip unused symbols
    if info(DET_USE, j, i) == 0
      continue;
    end

    if model.symbols(j).type == 'T'
      scores = addfilterfeat(model, scores,           ...
                             info(DET_X, j, i),       ...
                             info(DET_Y, j, i),       ...
                             pyra.padx, pyra.pady,    ...
                             info(DET_DS, j, i),      ...
                             model.symbols(j).filter, ...
                             pyra.feat{info(DET_L, j, i)});
    else
      ruleind = info(DET_IND, j, i);
      if model.rules{j}(ruleind).type == 'D'
        bl = model.rules{j}(ruleind).def.blocklabel;
        dx = info(DET_PX, j, i) - info(DET_X, j, i);
        dy = info(DET_PY, j, i) - info(DET_Y, j, i);
        def = [-(dx^2); -dx; -(dy^2); -dy];
        scores(bl) = scores(bl) + model.rules{j}(ruleind).def.w*def;
      end
      bl = model.rules{j}(ruleind).offset.blocklabel;
      scores(bl) = scores(bl) + model.rules{j}(ruleind).offset.w;
    end
  end
  if abs(sum(scores) - info(DET_VAL, model.start, i)) > 1e-10
    fprintf('%f ~= %f\n', sum(scores), info(DET_VAL, model.start, i));
    error('wrong score');
  end
  dowrite(scores, fid);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stores the filter feature vector in the example ex
function scores = addfilterfeat(model, scores, x, y, padx, pady, ds, fi, feat)
% model object model
% x, y  location of filter in feat (with virtual padding)
% padx  number of cols of padding
% pady  number of rows of padding
% ds    number of 2x scalings (0 => root level, 1 => first part level, ...)
% fi    filter index
% feat  padded feature map

fsz = model.filters(fi).size;
% remove virtual padding
fy = y - pady*(2^ds-1);
fx = x - padx*(2^ds-1);
f = feat(fy:fy+fsz(1)-1, fx:fx+fsz(2)-1, :);

bl = model.filters(fi).blocklabel;
scores(bl) = scores(bl) + model.filters(fi).w(:)' * f(:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write scores to fid
function dowrite(scores, fid)

% write total score and block scores
fwrite(fid, [sum(scores); scores], 'double');
