function [ ap, recall, precision] = compute_average_precision( score, label, draw )

[score, order]=sort(score, 'descend');
tp = label(order)>0;
fp = label(order)<0;

cfp       = cumsum(fp);
ctp       = cumsum(tp);
num_tp    = sum(label>0);
recall    = ctp/sum(label>0);
precision = ctp./(cfp+ctp);

% compute average precision

ap=0;
for t=0:0.1:1
    p=max(precision(recall>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/11;
end

if exist('draw', 'var') && draw
    plot(recall, precision); title('Precision - Recall');
end

end
