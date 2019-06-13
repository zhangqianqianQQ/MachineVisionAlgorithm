clear all

disp('Data loading and generation...');
ima = double(imread('lena.png'));
L = 3;
s = zeros(size(ima));
for k = 1:L
    s = s + abs(randn(size(ima)) + i * randn(size(ima))).^2 / 2;
end
ima_nse = ima .* sqrt(s / L);

disp('Non-it PPB filter...');
hW = 10;
hD = 3;
alpha = 0.88;
T = inf;
nbit = 1;
ima_fil_1 = ppb_nakagami(ima_nse, L, ...
                         hW, hD, ...
                         alpha, T, ...
                         nbit);

disp('It PPB filter...');
hW = [1 3 5 10];
hD = [0 1 2 3];
alpha = 0.92;
T = 0.2;
nbit = [1 2 3 4];
ima_fil_2 = ppb_nakagami(ima_nse, L, ...
                         hW, hD, ...
                         alpha, T, ...
                         nbit);

figure
subplot(2,2,1), plotimage_sar(ima);
title('Noise-free image');
subplot(2,2,2), plotimage_sar(ima_nse, ima);
title(sprintf('Noisy image (PSNR %.3f)', snr(ima_nse, ima)));
subplot(2,2,3), plotimage_sar(ima_fil_1, ima);
title(sprintf('Non-it PPB filter (PSNR %.3f)', snr(ima_fil_1, ima)));
subplot(2,2,4), plotimage_sar(ima_fil_2, ima);
title(sprintf('It PPB filter (PSNR %.3f)', snr(ima_fil_2, ima)));

