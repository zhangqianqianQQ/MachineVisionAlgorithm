function feat_glcm=GetGLCMFeat(img_q, offset,win_size)
% Compute GLCM texture feature of the input image
% Input:
%            img_q: quantified img, the graylevel should range from 0 to max_gray_lavel
%            offset: the spatial offset for compute the co-occurance matrix
%            win_size: the window size for statistic cumulation
%Output:
%            feat_glcm: GLCM featue,  a struct in which each element is
%                                 one of the ten GLCM features
% 2016-10-19, jlfeng
[nr,nc]=size(img_q);
num_filter=size(offset,1);

%initialization
feat_glcm.energy=zeros(nr,nc,num_filter);
feat_glcm.entropy=zeros(nr,nc,num_filter);
feat_glcm.homogeneity=zeros(nr,nc,num_filter);
feat_glcm.correlation=zeros(nr,nc,num_filter);
feat_glcm.autocorelation=zeros(nr,nc,num_filter);
feat_glcm.dissimilarity=zeros(nr,nc,num_filter);
feat_glcm.max_prob=zeros(nr,nc,num_filter);
feat_glcm.cluster_shade=zeros(nr,nc,num_filter);
feat_glcm.cluster_prom=zeros(nr,nc,num_filter);
feat_glcm.contrast=zeros(nr,nc,num_filter);

max_graylevel=max(img_q(:));
glcm_mat_size=max_graylevel*max_graylevel;
gray_origin=ceil((1:max_graylevel^2)/max_graylevel);
gray_shift=repmat(1:max_graylevel,[1 max_graylevel]);
gray_diff=gray_shift-gray_origin;
for kk=1:num_filter
    glcm_mat=zeros(glcm_mat_size,nr*nc);
    cooccur_filter=GetCoOccurFilter(offset(kk,:));
    cum_size=max(max(size(cooccur_filter)),win_size);    
    cum_filter=ones(cum_size,cum_size);
    img_pad=ImgPad(img_q,cum_size,0,0);
    img_filt=conv2(img_pad,cooccur_filter,'same');
    for ll=1:glcm_mat_size
        img_bw=img_pad==gray_origin(ll)&img_filt==gray_diff(ll);
        img_cum=conv2(double(img_bw),cum_filter,'same');
        img_cum=ImgPad(img_cum,cum_size,1);
        glcm_mat(ll,:)=img_cum(:);        
    end
    idx1=1:glcm_mat_size;
    idx2=reshape(idx1,[max_graylevel max_graylevel])';
    idx2=idx2(:);
    glcm_mat=(glcm_mat(idx1,:)+glcm_mat(idx2,:))/2;
    glcm_mat=glcm_mat./repmat(sum(glcm_mat,1)+eps,[glcm_mat_size 1]);
    temp1=repmat(gray_origin',[1 nr*nc]);
    mu_x=mean(glcm_mat.*temp1,1);
    sigma_x=mean(glcm_mat.*temp1.^2,1)-mu_x.^2;
    temp2=repmat(gray_shift',[1 nr*nc]);
    mu_y=mean(glcm_mat.*temp2,1);
    sigma_y=mean(glcm_mat.*temp2.^2,1)-mu_y.^2;
    
    %energy
    temp=sum(glcm_mat.^2,1);
    feat_glcm.energy(:,:,kk)=reshape(temp,[nr nc]);
    
    %entropy
    temp=sum(-glcm_mat.*log(glcm_mat+1*(glcm_mat==0)),1);
    feat_glcm.entropy(:,:,kk)=reshape(temp,[nr nc]);
    
    % homogeneity
    temp=sum(glcm_mat./(1+(temp1-temp2).^2),1);
    feat_glcm.homogeneity(:,:,kk)=reshape(temp,[nr nc]);
    
    % correlation
    idx=sigma_x~=0&sigma_y~=0;
    temp=sum(temp1.*temp2.*glcm_mat,1)-mu_x.*mu_y;
    temp(idx)=temp(idx)./sigma_x(idx)./sigma_y(idx);
    temp(~idx)=0;
    feat_glcm.correlation(:,:,kk)=reshape(temp,[nr nc]);
    
    % autocorelation
    temp=sum(temp1.*temp2.*glcm_mat,1);
    feat_glcm.autocorelation(:,:,kk)=reshape(temp,[nr nc]);
    
    % dissimilarity
    temp=sum(abs(temp1-temp2).*glcm_mat,1);
    feat_glcm.dissimilarity(:,:,kk)=reshape(temp,[nr nc]);
    
     % max probability
    temp=max(glcm_mat,[],1);
    feat_glcm.max_prob(:,:,kk)=reshape(temp,[nr nc]);
    
    % cluster shade
    temp=temp1+temp2-repmat(mu_x,[glcm_mat_size 1])-repmat(mu_x,[glcm_mat_size 1]);
    feat_glcm.cluster_shade(:,:,kk)=reshape(sum(temp.^3.*glcm_mat,1),[nr nc]);
    feat_glcm.cluster_prom(:,:,kk)=reshape(sum(temp.^4.*glcm_mat,1),[nr nc]);
    
    % contrast
    temp=repmat(gray_diff',[1 nr*nc]);
    temp=sum(temp.^2.*glcm_mat,1);
    feat_glcm.contrast(:,:,kk)=reshape(temp,[nr nc]);
end

function filter_out=GetCoOccurFilter(offset)
filter_out=zeros(1+abs(offset(1)),1+abs(offset(2)));
if (offset(1)==0 && offset(2)==0)
    error('Zero offsets in both direction.')
end
px0=1;py0=1;
px1=1+offset(1);
py1=1+offset(2);
if (px1<1)
    px0=px0-px1+1;
    px1=1;
end
if (py1<0)
    py0=py0-py1+1;
    py1=1;
end
filter_out(px0,py0)=1;
filter_out(px1,py1)=-1;


