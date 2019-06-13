% calc_mse.m
% calculate mse error between two images

function E = calc_psnr(img1,img2);

[h w c] = size(img1);

diff = double(img1) - double(img2);
dobro = diff(:,:,1).*diff(:,:,1);
sum1 = sum(sum(dobro(:,:,1)));
e = sum1/(h*w);
E = 20*log10(255/sqrt(e));
