function feat_gbr=GetGaborFeat(img,lambda,theta,var_xy)
%Extract Gabor texture feature of the input image
%Example: 
%              lambda=[0,1/2,1/3];
%              theta=[0,45,90,135]/180*pi;
%              var_xy=[3,3;7,7;11,11;15,15];
%              feat_gbr=GetGaborFeat(img,lambda,theta,var_xy)
% 2016-10-19, jlfeng
[nr,nc]=size(img);
num_scale=size(var_xy,1);num_direct=length(theta);num_freq=length(lambda);
num_channel=num_scale*num_direct*num_freq;
feat_gbr=zeros(nr,nc,num_channel);
for ii=1:num_scale
    sx_now=var_xy(ii,1)/3;sy_now=var_xy(ii,2)/3;
    win_size=1+2*max(sx_now*4,sy_now*4);
    img_pad=ImgPad(img,win_size,0,0); 
    for jj=1:num_freq
        for kk=1:num_direct
            filt_gbr=ConstructGbr(win_size,lambda(jj), theta(kk),sx_now,sy_now);
            filt_gbr=real(filt_gbr);%GbFr=GbFr./sum(GbFr(:));
            img_filt=abs(conv2(img_pad,filt_gbr,'same')); 
            idx_channel=(ii-1)*(num_freq*num_direct)+(jj-1)*num_direct+kk;
            feat_gbr(:,:,idx_channel)=ImgPad(img_filt,win_size,1);
        end
    end
end
            

function filt_gbr=ConstructGbr(win_size,lambda,theta,sigma_x, sigma_y)
grid_vec=-win_size:1:win_size;
[grid_x, grid_y]=meshgrid(grid_vec,grid_vec);
grid_x_rot=grid_x*cos(theta)+grid_y*sin(theta);
grid_y_rot=-grid_x*sin(theta)+grid_y*cos(theta);
temp=-grid_x_rot.^2/(2*sigma_x*sigma_x)-grid_y_rot.^2/(2*sigma_y*sigma_y);
filt_gbr=exp(temp)./(2*pi*sigma_x*sigma_y);
filt_gbr=filt_gbr.*exp(1i*2*pi*grid_x_rot.*lambda);





