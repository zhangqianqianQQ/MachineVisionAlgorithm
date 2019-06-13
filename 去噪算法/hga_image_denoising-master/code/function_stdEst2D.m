function dev=function_stdEst2D(z,method)
% Estimate noise standard deviation (AWGN model)
%
% dev = function_stdEst2D(z,method)
%
%
% OUTPUT
% ------
% dev    :  estimated noise standard deviation
%
% INPUTS
% ------
% z      :  noisy observation (1D vector or 2D image)
% method :  method to attenuate signal (optional input)
%             0  standard shifted differences
%             1  cascaded horizontal-vertical shifted differences
%             2  wavelet domain estimation  (DEFAULT)
%             3  wavelet domain estimation with boundary removal
%             4  Immerkaer's method  (FASTEST)
%
%             7  Immerkaer's method with Daubechies-based Laplacian
%             8  Blockwise Immerkaer's method with Daubechies-based Laplacian
%
%
%  methods 0-3 are based on the Median of Absolute Deviation (MAD)
%  technique, whereas method 4 is based on Laplacian filtering
%
% Alessandro Foi - Tampere University of Technology - 2005-2006
% -----------------------------------------------------------------------
if nargin==1
    method=2; %% by default use Daubechies wavelets, without caring about boundary
end
if min(abs(method-[0 1 2 3 4 7 8]))>0
    disp(' ');disp('   !!!!!   Second argument must be either 0, 1, 2, 3, 4, 7, or 8.  (see help)');disp(' ');
    return
end
if ndims(z)>2
    disp(' ');disp('   !!!!!   Input has to be 1D vector or 2D image.  ');disp(' ');
    return
end
size_z=size(z);
if min(size_z(1:2))==1   %% 1D vector
    z=z(:);  % column
    if method==0||method==1 %%%% standard shifted differences
        z1=circshift(z,[1 0]);
        dz=abs(z(2:end,:)-z1(2:end,:));
        dev=median(dz(:))/(0.6745*sqrt(2));
    end
    if method==2  %%% wavelet domain estimation (Daubechies length 6)
        daub6kern=[0.03522629188571 0.08544127388203 -0.13501102001025 -0.45987750211849 0.80689150931109 -0.33267055295008]';
        wav_det=conv2(z,daub6kern,'same');
        dev=median(abs(wav_det(:)))/.6745;
    end
    if method==3  %%% wavelet domain estimation (Daubechies length 6)
        daub6kern=[0.03522629188571 0.08544127388203 -0.13501102001025 -0.45987750211849 0.80689150931109 -0.33267055295008]';
        wav_det=conv2(z,daub6kern,'valid');
        dev=median(abs(wav_det(:)))/.6745;
    end
    if method==4    %%% Immerkaer
        LAPL=[1 -2 1]';
        LAPL=LAPL*sqrt(pi/2/sum(LAPL(:).^2));
        YY=conv2(z,LAPL,'valid');
        dev=mean(abs(YY(:)));
    end
    if method==7    %%% Immerkaer-Daubechies
        daub6kern=[0.03522629188571 0.08544127388203 -0.13501102001025 -0.45987750211849 0.80689150931109 -0.33267055295008]';
        LAPL=conv(daub6kern,daub6kern);
        YY=conv2(z,daub6kern*sqrt(pi/2/sum(LAPL(:).^2)),'valid');
        YY=conv2(YY,daub6kern,'valid');
        dev=mean(abs(YY(:)));
    end
    if method==8    %%% blockwise Immerkaer-Daubechies
        daub6kern=[0.03522629188571 0.08544127388203 -0.13501102001025 -0.45987750211849 0.80689150931109 -0.33267055295008]';
        LAPL=conv2(daub6kern,daub6kern);
        YY=conv2(z,daub6kern*sqrt(pi/2/sum(LAPL(:).^2)),'valid');
        YY=conv2(YY,daub6kern,'valid');
        LL=16;
        NB1=floor(size(YY,1)/LL);
        YY=YY(1:NB1*LL);
        dev=median(mean(abs(reshape(YY,[LL NB1])),1));
    end
else  %% image
    if method==0 %%%% standard shifted differences
        z1=circshift(z,[1 0]);
        dz=abs(z(2:end,:)-z1(2:end,:));
        dev=median(dz(:))/(0.6745*sqrt(2));
        z2=circshift(z,[0 1]);
        dz=abs(z(:,2:end)-z1(:,2:end));
        dev=0.5*dev+0.5*median(dz(:))/(0.6745*sqrt(2));
    end
    if method==1   %%%  cascaded horizontal-vertical shifted differences
        z1=circshift(z,[1 0]);
        dz=z(2:end,:)-z1(2:end,:);
        dev=median(dz(:))/(0.6745*sqrt(2));
        z1=circshift(dz,[0 1]);
        dz=abs(dz(:,2:end)-z1(:,2:end));
        dev=median(dz(:))/(0.6745*2);
    end
    if method==2  %%% wavelet domain estimation (Daubechies length 6)
        daub6kern=[0.03522629188571 0.08544127388203 -0.13501102001025 -0.45987750211849 0.80689150931109 -0.33267055295008];
        daub6kern=daub6kern(end:-1:1); %% flip is used only to give exactly same result as previous version of the code (which was using filter2)
        wav_det=conv2(z,daub6kern,'same');
        wav_det=conv2(wav_det,daub6kern','same');
        dev=median(abs(wav_det(:)))/.6745;
    end
    if method==3  %%% wavelet domain estimation (Daubechies length 6)
        daub6kern=[0.03522629188571 0.08544127388203 -0.13501102001025 -0.45987750211849 0.80689150931109 -0.33267055295008];
        wav_det=conv2(z,daub6kern,'valid');
        wav_det=conv2(wav_det,daub6kern','valid');
        dev=median(abs(wav_det(:)))/.6745;
    end
    if method==4    %%% Immerkaer
        LAPL=[1 -2 1;-2 4 -2;1 -2 1];
        LAPL=LAPL*sqrt(pi/2/sum(LAPL(:).^2));
        YY=conv2(z,LAPL,'valid');
        dev=mean(abs(YY(:)));
    end
    if method==7    %%% Immerkaer-Daubechies
        %LAPL=[1 -2 1;-2 4 -2;1 -2 1];
        daub6kern=[0.03522629188571 0.08544127388203 -0.13501102001025 -0.45987750211849 0.80689150931109 -0.33267055295008];
        LAPL=conv2(daub6kern,daub6kern);
        LAPL=conv2(LAPL,daub6kern');
        LAPL=conv2(LAPL,daub6kern');
        %    LAPL=LAPL*sqrt(pi/2/sum(LAPL(:).^2));
        %    YY=conv2(z,LAPL,'valid');
        YY=conv2(z,daub6kern*sqrt(pi/2/sum(LAPL(:).^2)),'valid');
        YY=conv2(YY,daub6kern,'valid');
        YY=conv2(YY,daub6kern','valid');
        YY=conv2(YY,daub6kern','valid');
        dev=mean(abs(YY(:)));
    end
    if method==8    %%% blockwise Immerkaer-Daubechies
        %LAPL=[1 -2 1;-2 4 -2;1 -2 1];
        daub6kern=[0.03522629188571 0.08544127388203 -0.13501102001025 -0.45987750211849 0.80689150931109 -0.33267055295008];
        LAPL=conv2(daub6kern,daub6kern);
        LAPL=conv2(LAPL,daub6kern');
        LAPL=conv2(LAPL,daub6kern');
        YY=conv2(z,daub6kern*sqrt(pi/2/sum(LAPL(:).^2)),'valid');
        YY=conv2(YY,daub6kern,'valid');
        YY=conv2(YY,daub6kern','valid');
        YY=conv2(YY,daub6kern','valid');
        LL=8;
        NB1=floor(size(YY,1)/LL);
        NB2=floor(size(YY,2)/LL);
        YY=YY(1:NB1*LL,1:NB2*LL);
        dev=median(mean(abs(YY(repmat(reshape(repmat([1:LL],[LL 1])'+repmat([0:LL*NB1:LL*LL*NB1-1]',[1 LL])',[LL*LL 1]) ,[1 NB1*NB2])+repmat(reshape(repmat([0:LL:NB1*LL-1],[NB2 1])+repmat(NB1*LL*[0:LL:NB2*LL-1]',[1 NB1]),[1 NB1*NB2]),[LL*LL 1]))),1));
        %     iii3=0;
        %     for iii1=1:LL:size(YY,1)-LL
        %         for iii2=1:LL:size(YY,2)-LL
        %             iii3=iii3+1;
        %             YY2=YY(iii1:min(size(YY,1),iii1+LL-1),iii2:min(size(YY,2),iii2+LL-1));
        %             devs(iii3)=mean(abs(YY2(:)));
        %         end
        %     end
        %     dev=median(devs(:));
    end
end

%    disp(['Estimated noise sigma = ',num2str(dev)]);

