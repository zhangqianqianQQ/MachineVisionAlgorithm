function m = compressClassModel( model )
    maxnnode = max(model.ndbigtree(:));
    ntree = model.ntree;
    
    m.ntree = ntree;
    m.nclass = model.nclass;
    m.orig_labels = model.orig_labels;
    m.new_labels = model.new_labels;
    m.mtry = model.mtry;
    m.nrnodes = maxnnode;
    m.classwt = model.classwt;
    m.cutoff = model.cutoff;
    
    m.treemap = int32( zeros(maxnnode, ntree*2) );
    m.nodestatus = int32( zeros(maxnnode, ntree) );
    m.nodeclass = int32( zeros(maxnnode, ntree) );
    m.bestvar = int32( zeros(maxnnode, ntree) );
    m.xbestsplit = zeros(maxnnode, ntree);
    m.ndbigtree = model.ndbigtree(1:ntree);
    
    for n = 1 : ntree
        nnode = model.ndbigtree(n);
        m.nodestatus(1:nnode, n) = model.nodestatus(1:nnode, n);
        m.nodeclass(1:nnode, n) = model.nodeclass(1:nnode, n);
        m.bestvar(1:nnode, n) = model.bestvar(1:nnode, n);
        m.xbestsplit(1:nnode, n) = model.xbestsplit(1:nnode, n);
         
        treemat = model.treemap(:, 2*n-1 : 2*n);
        m.treemap = reshape(treemat(1:2*maxnnode), [maxnnode 2]);
%         for jx = 1 : nnode
%             
%             m.treemap(jx, 2*n-1) = treemat(2*jx-1);    % left child
%             m.treemap(jx, 2*n)   = treemat(2*jx);      % right child
%         end
%         jx = 1 : 1 : nnode;
%         m.treemap(jx, 2*n-1) = treemat(2*jx-1);          % left child
%         m.treemap(jx, 2*n)   = treemat(2*jx);            % right child
    end
end