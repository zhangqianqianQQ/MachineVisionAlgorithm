function [ap, prec, rec] = ml_ap(confidence, gt, draw)
% function [ap, prec, rec] = ml_ap(confidence, gt, draw)
% Average precision, adapted from VOCevaluation
% gt: a vector of 1 and -1. 1 is for positive, -1 is for negative.
% confidence: confidence for belonging to the positive class
% By: Minh Hoai Nguyen (minhhoai@robots.ox.ac.uk)
% Last modified: 23-Nov-2012

    if length(confidence) ~= length(gt)
        error('mismatch');
    end;
    confidence = confidence(:);
    gt = gt(:);
    [~,si]=sort(confidence, 'descend');
    tp=gt(si)>0;
    fp=gt(si)<0;

    fp=cumsum(fp);
    tp=cumsum(tp);
    rec=tp/sum(gt>0);
    prec=tp./(fp+tp);
    ap=VOCap(rec,prec);

    if draw
        % plot precision/recall
        plot(rec,prec,'-');
        grid;
        xlabel 'recall'
        ylabel 'precision'
    end

function ap = VOCap(rec,prec)
    mrec=[0 ; rec ; 1];
    mpre=[0 ; prec ; 0];
    for i=numel(mpre)-1:-1:1
        mpre(i)=max(mpre(i),mpre(i+1));
    end
    i=find(mrec(2:end)~=mrec(1:end-1))+1;
    ap=sum((mrec(i)-mrec(i-1)).*mpre(i));