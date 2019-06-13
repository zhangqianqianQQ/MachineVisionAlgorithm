function sigma_hat=function_stdEst(z,kernel_type,est_type,which_dims)
% Estimate noise standard deviation (AWGN model) from data of arbitrary dimensionality.
% --------------------------------------------------------------------------------------
%
% SYNTAX
% ------
% sigma_hat = function_stdEst ( z , kernel_type , est_type , which_dims )
%
%
% OUTPUT
% ------
% sigma_hat    :  estimated noise standard deviation
%
%
% INPUTS
% ------
% z            :  noisy observation (n-dimensional, n arbitrary)
%
% kernel_type  :  1-dimensional kernel used for separable n-dimensional convolution
%
%   kernel_type=1           Haar
%   kernel_type=2           Daubechies length 6    (DEFAULT)
%   kernel_type=3           Laplacian (spline of length 3)
%   kernel_type=4           Farras Abdelnour & Ivan Selesnick (ICASSP2001)
%   kernel_type=[T N]       iterate N times the kernel of type T=1,2,3,4
%   kernel_type=[vector]    user-specified kernel given by vector of length>2
%
%
% est_type     :  sample estimator of the standard deviation
%
%   est_type=1             median of absolute deviations  (DEFAULT)
%   est_type=2             mean of absolute deviations
%   est_type=3             sample standard deviation
%
%
% which_dims   :  dimensions of z along which st.sigma_hat. estimation is performed
%                 (DEFAULT: all dimensions)
%
%
%
% classical examples:
%
%   kernel_type=2, est_type=1  Donoho's MAD      (DEFAULT)
%                              sigma_hat = function_stdEst(z);
%
%   kernel_type=3, est_type=2  Immerkaer's algorithm
%
%
%
%
% Alessandro Foi - Tampere University of Technology - 2011
% -----------------------------------------------------------------------

if ~exist('kernel_type','var')
    kernel_type=2;
end
if ~exist('est_type','var')
    est_type=1;
end


if kernel_type(1)==1  %%% Haar
    kernel=[-1;1];
elseif kernel_type(1)==2  %%% Daubechies length 6
    kernel=[-0.33267055295008 ;  0.80689150931109 ; -0.45987750211849 ; -0.13501102001025 ; 0.08544127388203  ; 0.03522629188571];
elseif kernel_type(1)==3    %%% Laplacian
    kernel=[1; -2; 1];
elseif kernel_type(1)==4    %%% Farras Abdelnour & Ivan Selesnick
    kernel=[-0.011226792152540; 0.011226792152540; 0.088388347648320; 0.088388347648320; -0.695879989034000; 0.695879989034000; -0.088388347648320; -0.088388347648320; 0; 0];
end


if numel(kernel_type)==2
    kernelb=kernel;
    for conv_counter=1:kernel_type(2)
        kernel=conv2(kernel,kernelb);
    end
elseif numel(kernel_type)>2
    kernel=reshape(kernel_type,[numel(kernel_type) 1]);
end


% make kernel zero-mean
kernel=kernel-mean(kernel(:));

% normalize ell2
kernel=kernel/sqrt(sum(kernel(:).^2));


if ~exist('which_dims','var')
which_dims=find(size(z)>1);
end

for jj=which_dims
    z=convn(z,permute(kernel,circshift((1:max(2,jj)),[0 jj-1])),'valid');
end


if est_type==1        %%% median of absolute deviations  
    sigma_hat=median(abs(z(:)))/0.674489750196082;   %  assumes, for simplicity, that median(z(:))=0.
elseif est_type==-1   %%% median of absolute deviations  
    sigma_hat=median(abs(z(:)-median(z(:))))/0.674489750196082;  % 0.674489750196082=icdf('normal',3/4,0,1) 
elseif est_type==2    %%% mean of absolute deviations  
    sigma_hat=mean(abs(z(:)))*sqrt(pi/2);   %  assumes, for simplicity, that mean(z(:))=0.
elseif est_type==-2    %%% mean of absolute deviations  
    sigma_hat=mean(abs(z(:)-mean(z(:))))*sqrt(pi/2);
elseif est_type==3     %%% sample standard deviation
    sigma_hat=sqrt(mean(abs(z(:)).^2));    %  assumes, for simplicity, that mean(z(:))=0.
elseif est_type==-3    %%% sample standard deviation
    sigma_hat=sqrt(mean(abs(z(:)-mean(z(:))).^2));
end

