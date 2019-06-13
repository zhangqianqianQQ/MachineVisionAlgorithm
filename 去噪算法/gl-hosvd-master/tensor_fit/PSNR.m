function PSNRdb = PSNR(x, y)

x=double(x);
y=double(y);
err = x - y;
err = err(:);
PSNRdb = 10 * log10(1/mean(err .^2));
