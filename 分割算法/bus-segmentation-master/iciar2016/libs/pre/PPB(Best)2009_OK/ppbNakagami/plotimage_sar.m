function figid = plotimage_sar (mod, mod_ref, nsigma)

    if nargin < 2
        mod_ref = mod;
    end
    if nargin < 3
        nsigma = 3;
    end

    th = mean(mean(mod_ref)) + nsigma * std(reshape(mod_ref,size(mod_ref,1)*size(mod_ref,2),1));
    mod(mod > th) = th;
    nmod = 255 * mod / th;

    plotimage(nmod);

end
