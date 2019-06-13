%----------------------------------------------------
% This code is modified based on the code of SAIST algorithm (Nonlocal image restoration with bilateral variance estimation: a low-rank approach)
% Data: May 6th, 2017
% Author: Xinyuan Zhang (519573769@qq.com)
% Article: Denoise diffusion-weighted images using higher-order singular value decomposition
%----------------------------------------------------
function  im_out=glhosvd(I_noisy,nsig,kglobal,klocal)

time0         =   clock;
nim           =   I_noisy;
b             =   8; % block size
step          =   5; % step length
sw            =   5; % radius of search window
[h  w ch]     =   size(nim);

disp(sprintf('--------start denoising--------'));
%%%The global HOSVD denoising stage 
[Sigma0 U0]   =   hosvd(full(nim ));
th            =   kglobal*nsig*sqrt( 2*log(length(nim(:))) );
Sigma0(find(abs(Sigma0(:))<th))=0;
pre_im        =   tprod(Sigma0, U0); %%%%the prefiltered data

%%%The local HOSVD denoising stage
Ys            =   zeros( size(nim) );        
W             =   zeros( size(nim) );  
for  i  =  [1:step:size(nim,1)-b size(nim,1)-b+1]
    for j = [1:step:size(nim,2)-b size(nim,2)-b+1]
        
        B1=pre_im(i:i+b-1,j:j+b-1,:);
        imin=max(1,i-sw);imax=min(size(nim,1)-b+1,i+sw);
        jmin=max(1,j-sw);jmax=min(size(nim,2)-b+1,j+sw);
  
        num=1;
        for ki=imin:imax
            for kj=jmin:jmax
                B2(:,:,:,num)=pre_im(ki:ki+b-1,kj:kj+b-1,:);
                B_n(:,:,:,num)=nim(ki:ki+b-1,kj:kj+b-1,:);                 
                dis(num)=sum(sum(sum((B1-B2(:,:,:,num)).^2)))/length(B1(:));
                tmp(num,:)=[ki kj];
                num=num+1;
            end
        end
        [val,ind]   =  sort(dis); 
        th=3*nsig*nsig;
        th_number=length(find(val<th));th_n=max(30,min(80,th_number));  
        th_n=min(length(ind(:)),th_n(:));

        indd=ind(1:th_n);  
        B=B_n(:,:,:,indd);
        B_pre=B2(:,:,:,indd); 
       [Ysp, Wp]   =   Low_rank_SSC( double(B_pre),double(B),klocal*nsig);
        for num=1:th_n      
          pt=tmp(indd(num),:);     ki=pt(1);kj=pt(2);      
          Ys(ki:ki+b-1,kj:kj+b-1,:)=Ys(ki:ki+b-1,kj:kj+b-1,:)+Ysp(:,:,:,num);
          W(ki:ki+b-1,kj:kj+b-1,:)=W(ki:ki+b-1,kj:kj+b-1,:)+Wp(:,:,:,num);                       
        end
        clear B_n;clear tmp;clear dis;clear B_n_noisefree;clear B2;
    end
end   
im_out  =  Ys./W;    
disp(sprintf('Total elapsed time = %f min\n', (etime(clock,time0)/60) ));
return;


function  [X W]   =   Low_rank_SSC( Y1,Y2, nsig)

  [Sigma2 U1] = hosvd2(full(Y1),full(Y2));
  
  Sigma2(abs(Sigma2) < nsig*sqrt( 2*log(length(Y1(:))) ) )=0;
  r   =   sum( abs(Sigma2(:))>0 );
  X   =   tprod(Sigma2, U1); 
  wei =   1/(1+r);
  W   =   wei*ones( size(X) );
  X   =   X*wei;
return;
