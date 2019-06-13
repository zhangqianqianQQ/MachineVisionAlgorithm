function res = psnr(hat, star, std)

    res = 10 * ...
          log(std^2 / mean(mean((hat - star).^2))) ...
          / log(10);

end
