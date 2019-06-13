function [sc_mask]  = compute_bin_mask(bin_r,nb_t)


nb_r            = length(bin_r) -1 ;

[xx,yy] = meshgrid(-bin_r(end):bin_r(end), -bin_r(end):bin_r(end));

mr  = sqrt(xx.*xx+yy.*yy);
mth = atan2(yy,xx);
mth = mod(mth, 2*pi);

ori_unit    = 2*pi/nb_t;
ori_bins    = (0:nb_t)*ori_unit;

[fr,fc]     = size(mr);

sc_mask    = zeros(fr*fc,nb_r*nb_t);

for r_bin=1:nb_r
    r_idx   = find(mr>bin_r(r_bin) & mr<=bin_r(r_bin+1));
    mth1    = mth(r_idx);
    for t_bin=1:nb_t
        t_idx	= find(mth1>=ori_bins(t_bin) & mth1<ori_bins(t_bin+1));
        sc_mask(r_idx(t_idx),(r_bin-1)*nb_t+t_bin)=1;
    end
end
sc_mask	= reshape(sc_mask, fr, fc, nb_r*nb_t);
sc_mask	= flipdim(sc_mask,1);
sc_mask	= flipdim(sc_mask,2);
