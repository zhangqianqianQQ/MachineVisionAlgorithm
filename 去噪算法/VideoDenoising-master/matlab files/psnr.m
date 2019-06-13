function psnr_value = psnr(base,input)
f=base-input;
[m n]=size(f);
f1=f.^2;
mse=mean(mean(f1));
% mse=(1/(m*n))*sum(sum(f1));
psnr_value=20*log10(255/sqrt(mse));
end