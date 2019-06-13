function m = compressRegModel(model)
    maxnnode = max(model.ndtree);
    
    m.lDau = model.lDau(1:maxnnode, :);
    m.rDau = model.rDau(1:maxnnode, :);
    nsts = mexCharArray2DoubleArray(model.nodestatus);
    dnsts = nsts(1:maxnnode, :);%model.nodestatus(1:maxnnode, :);
    m.nodestatus = mexDoubleArray2CharArray( dnsts );
    m.nrnodes = maxnnode;
    m.upper = model.upper(1:maxnnode, :);
    m.avnode = model.avnode(1:maxnnode, :);
    m.mbest = model.mbest(1:maxnnode, :);
    m.ndtree = model.ndtree;
    m.ntree = model.ntree;
    m.coef = model.coef;
end