function [contri_mtx] = contribution_matrix_mag(r,theta,mag,ori_edge,bin_r, nb_bin_theta, nb_ori,...
    blur_r,blur_t, blur_meth)

if (~exist('blur_r','var'))
    blur_r  = 0.2;
end

if (~exist('blur_t','var'))
    blur_t  = 0.8;
end

if (~exist('blur_meth','var'))
    blur_meth='gaussian';
end

if(strcmp(blur_meth,'gaussian'))
    blur_meth=1;
else 
    blur_meth=2;
end

nb_pix  = length(theta);
nb_r    = length(bin_r)-1;
nb_bins = nb_r*nb_bin_theta*nb_ori;

si = [];
sj = [];
val = [];

rad_bins_len    = bin_r(2:end) - bin_r(1:end-1);
rad_bins_len2   = rad_bins_len/2;
rad_blur_part   = rad_bins_len*blur_r;
rad_bins        = bin_r;
rad_bins_mid    = (rad_bins(1:end-1) + rad_bins(2:end))/2;

rad_bins_lambda = rad_bins_len2+rad_blur_part;

ori_unit        = 2*pi/nb_bin_theta;
ori_unit2       = ori_unit/2;
ori_bins        = (0:nb_bin_theta)*ori_unit;
ori_bins_mid    = (ori_bins(1:end-1) + ori_bins(2:end))/2;
ori_blur_part   = ori_unit*blur_t;

ori_bins_lambda = ori_unit2+ori_blur_part;


if(blur_meth==2) 
    rad_blur_part_scale   = (pi/2)./(rad_blur_part);
    ori_blur_part_scale   = (pi/2)/(ori_blur_part);
end

nb_ori  = length(ori_edge);

for ori_id  = 1:nb_ori
    rt_idx  = ori_edge(ori_id).idx;
    if(isempty(rt_idx))
        continue;
    end    
    mr  = r(rt_idx);
    mth = theta(rt_idx);
    
    ori_st_id=(ori_id-1)*nb_r*nb_bin_theta;    
    for r_bin=1:nb_r
        r_idx   = find(mr>(rad_bins(r_bin)-rad_blur_part(r_bin)) &...            
            mr< (rad_bins(r_bin+1)+rad_blur_part(r_bin)));
        if(isempty(r_idx))
            continue;
        end
        mr1     = mr(r_idx);
        mth1    = mth(r_idx);
        for t_bin=1:nb_bin_theta
            if(t_bin==1)
                t_idx   = find((mth1>=ori_bins(t_bin)&mth1<ori_bins(t_bin+1)+ori_blur_part)...
                    |mth1>ori_bins(end)-ori_blur_part);
            elseif(t_bin==nb_bin_theta)
                t_idx   = find(mth1>(ori_bins(t_bin)-ori_blur_part) | mth1<ori_blur_part);
            else
                t_idx   = find(mth1>(ori_bins(t_bin)-ori_blur_part) &...
                    mth1<(ori_bins(t_bin+1)+ori_blur_part));
            end
            if(isempty(t_idx))
                continue;
            end
            mr2     = mr1(t_idx);
            mth2    = mth1(t_idx);
            
            r_dis   = abs(mr2 - rad_bins_mid(r_bin));
            t_dis   = abs(angle_diff(mth2,ori_bins_mid(t_bin)));
            
            if(blur_meth==1) 
                contri  = Gauss(r_dis,rad_bins_lambda(r_bin)).*Gauss(t_dis,ori_bins_lambda);
                si = [si; rt_idx(r_idx(t_idx))];
                sj = [sj; (ori_st_id+(r_bin-1)*nb_bin_theta+t_bin)*ones(length(t_idx), 1)];
                val = [val; contri];
            else
                r_dis_within_idx=find(r_dis<=rad_bins_len2(r_bin));
                t_dis_within_idx=find(t_dis<=ori_unit2);
                r_dis   = r_dis-rad_bins_len2(r_bin);
                t_dis   = t_dis-ori_unit2;
                r_dis(r_dis_within_idx) = 0;
                t_dis(t_dis_within_idx)  = 0;               
                contri  = cos(r_dis*rad_blur_part_scale(r_bin)).*cos(t_dis*ori_blur_part_scale);
                si = [si; rt_idx(r_idx(t_idx))];
                sj = [sj; (ori_st_id+(r_bin-1)*nb_bin_theta+t_bin)*ones(length(t_idx), 1)];
                val = [val; contri];
            end
        end
    end
end


contri_mtx = sparse(si, sj, val, nb_pix, nb_bins);


contri_1    = full(sum(contri_mtx,2));
contri_1(find(contri_1<eps)) = 1;

contri_mtx  = spmtimesd(contri_mtx,mag./contri_1,[]);


function y=Gauss(x,sigma)

x=x(:);

y=exp(-x.^2/(2*sigma^2))/(sqrt(2*pi)*sigma);
