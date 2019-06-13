function Q = computeQuantMatrix(image_lab, bins)
%compute the quantization matrix based on the 3-dimensional matrix imgLAB

    if length(bins) ~= 3
        error('Need 3 bins for quantization');
    end
    
    L = image_lab(:,:,1);
    a = image_lab(:,:,2);
    b = image_lab(:,:,3);

    ll = min(floor(L/(100/bins(1))) + 1,bins(1));
    aa = min(floor((a+120)/(240/bins(2))) + 1,bins(2));
    bb = min(floor((b+120)/(240/bins(3))) + 1,bins(3));
    
    Q = (ll-1)* bins(2)*bins(3) + ...
        (aa-1)* bins(3) + ...
        bb + 1;