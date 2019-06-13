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