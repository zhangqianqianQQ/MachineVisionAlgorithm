function sc=compute_sc(x,y,ex,ey,ori,mag,bin_r,nb_bin_theta,nb_ori,blur_r,blur_t,blur_o,blur_meth)


if(~exist('mag','var') || isempty(mag))
    mag=1;
end

if(~exist('bin_r','var') || isempty(bin_r))
    bin_r   = [0,10,25,45];
end

if(~exist('nb_bin_theta','var') || isempty(nb_bin_theta))
    nb_bin_theta = 12;
end

if(~exist('nb_ori','var') || isempty(nb_ori))
    nb_ori=4;
end

if(~exist('blur_r','var') || isempty(blur_r))
    blur_r  = 0.2;
end

if(~exist('blur_t','var') || isempty(blur_t))
    blur_t  = 1.0;
end

if(~exist('blur_o','var') || isempty(blur_o))
    blur_o  = 0.2;
end

if (~exist('blur_meth','var'))
    blur_meth='gaussian';
end

if(strcmp(blur_meth,'gaussian'))
    blur_meth=1;
else % using cosine function to blur
    blur_meth=2;
end

nb_bin_r    = length(bin_r)-1;

nb_pix  = length(x);

sc  = zeros(nb_pix, nb_bin_r*nb_bin_theta*nb_ori);

ori = mod(ori,pi);

ori_edge    = edge_splitting(ori,blur_o,nb_ori);

for ii=1:length(x)
    
    dx      = ex-x(ii);
    dy      = ey-y(ii);
    r       = sqrt(dx.*dx+dy.*dy);
    theta   = atan2(dy, dx);
    theta   = mod(theta,2*pi);
    
    contri_mtx  = contribution_matrix_mag(r,theta,mag,ori_edge,bin_r, nb_bin_theta, nb_ori,...
        blur_r,blur_t, blur_meth);
    V   = sum(contri_mtx,1);
    sc(ii,:)    = V;    
end

