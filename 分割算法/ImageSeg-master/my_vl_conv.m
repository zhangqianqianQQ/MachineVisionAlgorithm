function Y = my_vl_conv(X, W, B)
    X = single(X);
    W = single(W);
    Y = vl_nnconv(X, W, B, 'Pad', 1);
end