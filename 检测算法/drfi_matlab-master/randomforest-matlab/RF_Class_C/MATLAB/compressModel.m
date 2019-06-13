function m = compressModel( rf_model )
    ntree = rf_model.ntree;
    treemap = cell(1, ntree);
    nodestatus = cell(1, ntree);
    nodeclass = cell(1, ntree);
    bestvar = cell(1, ntree);
    bestsplit = cell(1, ntree);
    treesize = rf_model.ndbigtree;
    
    for ix = 1 : ntree
        nnode = treesize(ix);
        nodestatus{ix} = rf_model.nodestatus(1:nnode, ix);
        nodeclass{ix} = rf_model.nodeclass(1:nnode, ix);
        bestvar{ix} = rf_model.bestvar(1:nnode, ix);
        bestsplit{ix} = rf_model.xbestsplit(1:nnode, ix);
        
        temp_treemap = zeros(nnode, 2);
        treemat = rf_model.treemap(:, 2*ix-1 : 2*ix);
        treemat = treemat(:);
        for jx = 1 : nnode
            temp_treemap(jx, 1) = treemat(2*jx -1);
            temp_treemap(jx, 2) = treemat(2*jx);
        end
        treemap{ix} = temp_treemap;
    end
    
    m.treemap = treemap;
    m.nodestatus = nodestatus;
    m.nodeclass = nodeclass;
    m.bestvar = bestvar;
    m.bestsplit = bestsplit;
    m.ntree = ntree;
    
    m.orig_labels = rf_model.orig_labels;
    m.new_labels = rf_model.new_labels;
    m.nclass = rf_model.nclass;
    m.mtry = rf_model.mtry;
end