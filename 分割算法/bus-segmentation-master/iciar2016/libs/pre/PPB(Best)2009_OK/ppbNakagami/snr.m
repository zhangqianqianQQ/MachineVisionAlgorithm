function res = snr(hat, star)

    sigma = std(reshape(star,size(star,1)*size(star,2),1));
    res = psnr(hat, star, sigma);

end