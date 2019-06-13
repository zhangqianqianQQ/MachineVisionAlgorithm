%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main function for the subset optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [res, stat] = propOpt(bboxes, bboxscore, param)

% for the special case when lambda == 0
if param.lambda == 0 
    res = bboxes;
    stat.O = 1:size(bboxes,2);
    return;
end

stat = doMAPForward(bboxes, double(bboxscore), param);
  
if numel(stat.O) > 1
    stat = doMAPBackward(bboxes, double(bboxscore), param, stat);
end

% We use the second output to intialized the optimization again
if param.perturb && numel(stat.O) > 1
    % use the second output to initialize the forward pass
    statTmp = doMAPEval(bboxes, double(bboxscore), param, stat.O(2), stat.W, stat.BGp);
    statTmp = doMAPForward(bboxes, double(bboxscore), param, statTmp);
    if statTmp.f > stat.f
        stat = statTmp;
    end
end 
res = bboxes(:, stat.O);
