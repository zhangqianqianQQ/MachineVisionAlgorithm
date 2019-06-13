function [yhat prdt_per_tree] = classRFPredict( x, rf )
    [nsample ndim] = size(x);
    ntree = rf.ntree;
    prdt_per_tree = zeros(nsample, ntree);
    
    ntree = rf.ntree;
    
    for ix = 1 : nsample
        for n = 1 : ntree
            k = 1;
            while rf.nodestatus{n}(k) ~= -1
                if x(ix, rf.bestvar{n}(k)) <= rf.bestsplit{n}(k)
                    k = rf.treemap{n}(k, 1);
                else
                    k = rf.treemap{n}(k, 2);
                end
            end
            prdt_per_tree(ix, n) = rf.nodeclass{n}(k);
            % fprintf( 'ix: %d, n: %d\n', ix, n );
        end
    end
    
    yhat = zeros(nsample, 1);
    for ix = 1 : nsample
        % for n = 1 : ntree
            % when there are equal votes for the classes, it favors the
            % first class
            yhat(ix) = mode( prdt_per_tree(ix, :) );
        % end
    end
    
    for ix = 1 : length(rf.new_labels)
        yhat( yhat == rf.new_labels(ix) ) = rf.orig_labels(ix);
    end
end