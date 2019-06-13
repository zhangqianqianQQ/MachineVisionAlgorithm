function [rf rootIndex] = buildForest( rf_model )
%(treemap, nodestatus, nodeclass, bestvar, xbestsplit, ndbigtree)
    % extract all the fields
    treemap = double(rf_model.treemap);
    nodestatus = double(rf_model.nodestatus);
    nodeclass = double(rf_model.nodeclass);
    bestvar = double(rf_model.bestvar);
    xbestsplit = double(rf_model.xbestsplit);
    ndbigtree = double(rf_model.ndbigtree);

    [nrnodes ntree] = size(nodestatus);
    nnodes = sum(ndbigtree(1:ntree));
    rf = cell(1, nnodes);
    rootIndex = zeros(1, ntree);
    maskIndex = 0 * nodestatus;
    
    % first create nodes
    index = 1;
    for n = 1 : ntree
        rootIndex(n) = index;
        for jx = 1 : nrnodes
            if nodestatus(jx, n) ~= 0
                rf{index} = RFTreeNode( nodestatus(jx,n) == -1, nodeclass(jx, n),...
                    bestvar(jx, n), xbestsplit(jx, n) );
                maskIndex(jx, n) = index;
                index = index + 1;
            end
        end
    end
    
    assert( nnodes == index - 1 );
    
    % then create classification trees by linking the nodes
    for n = 1 : ntree
        for jx = 1 : nrnodes
            if nodestatus(jx, n) ~= 0
                nodeIndex = maskIndex(jx, n);
                treemat = treemap(:, 2*n-1 : 2*n);
                treemat = treemat(:);
                
                if treemat(2*jx-1) > 0
                    leftChildIndex = maskIndex( treemat(2*jx-1), n );
                    % rf{nodeIndex}.insertLeftChild( rf{leftChildIndex} );
                    rf{nodeIndex}.leftChild = leftChildIndex;
                end
                
                if treemat(2*jx) > 0
                    rightChildIndex = maskIndex( treemat(2*jx), n );
                    % rf{nodeIndex}.insertRightChild( rf{rightChildIndex} );
                    rf{nodeIndex}.rightChild = rightChildIndex;
                end
            end
        end
    end
end

function buildTree(nodes, r, treemat)
    
end

%     r = RFTreeNode;
%     r.bestVar = 'r';
%     n1 = RFTreeNode;
%     n1.bestVar = 'n1';
%     n2 = RFTreeNode;
%     n2.bestVar = 'n2';
%     n3 = RFTreeNode;
%     n3.bestVar = 'n3';
%     n3.isTerminal = true;
%     n4 = RFTreeNode;
%     n4.bestVar = 'n4';
%     n5 = RFTreeNode;
%     n5.bestVar = 'n5';
%     n5.isTerminal = true;
%     n6 = RFTreeNode;
%     n6.bestVar = 'n6';
%     n6.isTerminal = true;
%     n7 = RFTreeNode;
%     n7.bestVar = 'n7';
%     n7.isTerminal = true;
%     n8 = RFTreeNode;
%     n8.bestVar = 'n8';
%     n8.isTerminal = true;
%     
%     r.insertLeftChild( n1 );
%     r.insertRightChild( n2 );
%     n1.insertLeftChild( n3 );
%     n1.insertRightChild( n4 );
%     n4.insertLeftChild( n7 );
%     n4.insertRightChild( n8 );
%     n2.insertLeftChild( n5 );
%     n2.insertRightChild( n6 );
%     
% %     rf = cell(1, 8);
% %     rf{1} = n1;
% %     rf{2} = n2;
% %     rf{3} = n3;
% %     rf{4} = n4;
% %     rf{5} = n5;
% %     rf{6} = n6;
% %     rf{7} = n7;
% %     rf{8} = n8;
% %     rf{9} = r;
% 
%     % rf = zeros(1, 8);
%     rf(1) = r;
%     rf(2) = n1;
%     rf(3) = n2;
%     rf(4) = n3;
%     rf(5) = n4;
%     rf(6) = n5;
%     rf(7) = n6;
%     rf(8) = n7;
%     rf(9) = n8;
