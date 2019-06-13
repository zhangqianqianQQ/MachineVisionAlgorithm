function ima_fil = ppb_nakagami (ima_nse, L, ...
                                 hW, hD, ...
                                 alpha, T, ...
                                 nbit, ima_est)
%PPB_NAKAGAMI (NL-SAR) Iterative PPB filter for Nakagami-Rayleigh noise
%   IMA_FIL = PPB_NAKAGAMI(IMA_NSE, L, HW, HD, ALPHA, T, NBIT, IMA_EST)
%   denoise iteratively an image corrupted by Nakagami-Rayleigh
%   noise with the iterative Probabilistic Patch-Based (PPB)
%   filter described in "Iterative Weighted Maximum Likelihood
%   Denoising with Probabilistic Patch-Based Weights", written by
%   C.A. Deledalle, L. Denis and F. Tupin, IEEE Trans. on Image
%   Processing, vol. 18, no. 12, pp. 2661-2672, December 2009.
%   It also corresponds on the NL-SAR filter: "A non-local
%   approach for SAR and interferometric SAR denoising", C-A. Deledalle,
%   Florence Tupin and Loïc Denis, in the proceedings of IGARSS, Honolulu,
%   Hawaii, USA, July 2010.
%   Please refer to these papers for a more detailed description of
%   the arguments. Note that this function ables also to treat
%   large images by preserving memory thanks to a block processing
%   on 1024x1024 subimages.
%
%       ARGUMENT DESCRIPTION:
%               IMA_NSE  - Noisy image
%               L        - ENL of the Nakagami-Rayleigh noise
%                          (default 1)
%               HW       - Half sizes of the search window width
%                          (default 10)
%               HD       - Half sizes of the  window width
%                          (default 3)
%               ALPHA    - Alpha-quantile parameters on the noisy image
%                          (default 0.92)
%               T        - filtering parameters on the estimated image
%                          (default 0.2)
%               NBIT     - numbers of iteration
%                          (default 4)
%               IMA_EST  - First noise-free image estimate (Optional).
%                          (default constant image)
%
%       OUTPUT DESCRIPTION:
%               IMA_FIL  - Fixed-point filtered reflectivity image
%
% Thanks to the GRIP (Università degli Studi di Napoli, Federico
% II) for helping us debugging this piece of code to make it
% compatible with Windows 64 bits version.


    if nargin < 2
        L = 1;
    end
    if nargin < 3
        hW = 10;
    end
    if nargin < 4
        hD  = 3;
    end
    if nargin < 5
        alpha = 0.92;
    end
    if nargin < 6
        T = 0.2;
    end
    if nargin < 7
        nbit = 4;
    end
    if nargin < 8
        ima_est = ones(size(ima_nse));
    end

    W = 2 * hW + 1;
    D = 2 * hD + 1;
    h = quantile_nakagami(L, D, alpha) .* D.^2;
    T = T ./ h .* D.^2 / L;

    width = size(ima_nse, 1);
    height = size(ima_nse, 2);
    sw = 1024;
    sh = 1024;
    overlap = hW + hD;

    ima_nse(abs(ima_nse) <= 0) = min2(abs(ima_nse(abs(ima_nse) > 0)));
    ima_nse(isnan(abs(ima_nse))) = min2(abs(ima_nse(abs(ima_nse) > 0)));
    ima_est(abs(ima_est) <= 0) = min2(abs(ima_est(abs(ima_est) > 0)));
    ima_est(isnan(abs(ima_est))) = min2(abs(ima_est(abs(ima_est) > 0)));

    for l = 1:size(nbit, 2)
        for k = 1:nbit(l)
            for i = 0:(ceil(width / sw) - 1)
                for j = 0:(ceil(height / sh) - 1)
                    sx = 1 + i * sw;
                    ex = sw + i * sw;
                    sy = 1 + j * sh;
                    ey = sh + j * sh;
                    margesx = overlap(l);
                    margeex = overlap(l);
                    margesy = overlap(l);
                    margeey = overlap(l);
                    if ex > width
                        ex = width;
                    end
                    if ey > height
                        ey = height;
                    end
                    if sx - margesx < 1
                        margesx = 0;
                    end
                    if ex + margeex > width
                        margeex = 0;
                    end
                    if sy - margesy < 1
                        margesy = 0;
                    end
                    if ey + margeey > height
                        margeey = 0;
                    end

                    xrange = (sx - margesx):(ex + margeex);
                    yrange = (sy - margesy):(ey + margeey);

                    sub_ima_nse = ima_nse(xrange, yrange);
                    sub_ima_est = ima_est(xrange, yrange);

                    if strcmp(mexext, 'mexw64')
                        [sub_ima_fil] = ...
                            sqrt(ppbNakagami (sub_ima_nse, ...
                                              sub_ima_est.^2, ...
                                              hW(l), ...
                                              hD(l), ...
                                              h(l), T(l)));
                    else
                        clear input;
                        input(:,:,1) = sub_ima_nse;
                        input(:,:,2) = sub_ima_est;

                        [sub_ima_fil] = ...
                            ppbNakagami (input, ...
                                         hW(l), ...
                                         hD(l), ...
                                         h(l), T(l));
                    end
                    xrange = (1 + margesx):(ex - sx + 1 + margesx);
                    yrange = (1 + margesy):(ey - sy + 1 + margesy);

                    ima_fil(sx:ex, sy:ey, l) = sub_ima_fil(xrange, yrange);

                    ima_fil(abs(ima_fil) <= 0) = min2(abs(ima_fil(abs(ima_fil) > 0)));
                    ima_fil(isnan(abs(ima_fil))) = min2(abs(ima_fil(abs(ima_fil) > 0)));

                end
            end
            ima_est = ima_fil(:,:,l);
        end
    end
    l = size(ima_fil, 3);
    ima_fil = ima_fil(:,:,l);
end

function m = min2(mat)

    m = min(min(mat));

end

function r = quantile(x, alpha) % SAS-5

       x = sort(x);
       N = size(x, 2);
       h = N * alpha + 0.5;
       if alpha == 0
           r = x(1);
           return;
       end
       if alpha == 1
           r = x(N);
           return;
       end
       r = (x(ceil(h - 0.5)) + x(floor(h + 0.5))) / 2;
end

function r = quantile_nakagami(L, ws, alphas)

    for kw = 1:size(ws, 2);
        w = ws(kw);
        ima_nse = zeros(w * 256);
        i = sqrt(-1);
        for l = 1:L
            ima_nse = ima_nse + abs(randn(size(ima_nse)) + i * randn(size(ima_nse))).^2 / 2;
        end
        ima_nse = sqrt(ima_nse / L);

        k = 1;
        for i = 1:(2*w):(size(ima_nse,1) - 2*w)
            for j = 1:w:(size(ima_nse,2) - w)
                sub_nse_1 = ima_nse(i:(i + w - 1), j:(j + w - 1));
                sub_nse_2 = ima_nse((i + w):(i + 2 * w - 1), j:(j + w - 1));

                lsl = log(sub_nse_1 ./ sub_nse_2 + sub_nse_2 ./ sub_nse_1);

                v(k) = mean(mean(lsl));
                k = k + 1;
            end
        end

        for q = 1:size(alphas, 2)
            r(q, kw) = quantile(v, alphas(q)) - mean(v);
        end
    end

end