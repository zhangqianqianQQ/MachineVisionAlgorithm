function Y = my_vl_conv_relu(X, W, B)
    X = single(X);
    W = single(W);
    Y = vl_nnconv(X, W, B, 'Pad', 1);
    Y(Y<0)=0;
end