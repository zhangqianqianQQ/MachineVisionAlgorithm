function [outdata outlab] = balanceData( indata, inlab, neg_lab )
    if nargin == 2
        neg_lab = 0;
    end
    
    pos_ind = find(inlab == 1);
    neg_ind = find(inlab == neg_lab);
    
    alpha = 1.2;
    
    if length(pos_ind) < length(neg_ind)
        x = [indata(pos_ind,:); indata(neg_ind(1:length(pos_ind)*alpha), :)];
        y = [inlab(pos_ind); inlab(neg_ind(1:length(pos_ind)*alpha))];
    else
        x = [indata(pos_ind(1:length(neg_ind)*alpha), :); indata(neg_ind, :)];
        y = [inlab(pos_ind(1:length(neg_ind)*alpha)); inlab(neg_ind)];
    end
    
    [outdata outlab] = randomize( x, y );
end