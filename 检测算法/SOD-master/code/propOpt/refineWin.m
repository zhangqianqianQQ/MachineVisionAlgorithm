%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A heuristic way to further refine the output windows
%
% For each small output window, we run our method on the
% this ROI again and extract the output that has the 
% largest IOU with the orignal window for replacement.
%
% NMS is further applied to remove duplicate windows.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = refineWin(I, res, net, param)

imsz = [size(I,1) size(I,2)];
param.lambda = 0.05;
for i = 1:size(res,2)
    bb = res(:,i);
    bbArea = (bb(3)-bb(1))*(bb(4)-bb(2));
    % only refine small windows
    if bbArea < 0.125*imsz(1)*imsz(2)
        margin = (bb(3)-bb(1)+bb(4)-bb(2))*0.2;
        bb = round(expandROI(bb, imsz, margin));
        Itmp = I(bb(2):bb(4), bb(1):bb(3) , :);
        [Ptmp, Stmp] = getProposals(Itmp, net, param);
        restmp = propOpt(Ptmp, Stmp, param);
        if ~isempty(restmp)
            restmp = getROIBBox(restmp, bb);
            [~,ii] = max(getIOUFloat(restmp', res(:,i)));
            res(:,i) = restmp(:,ii);
        end
    end
end
res = doNMS(res, 0.5);


