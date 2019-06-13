function y = dpad( I, stepsize, nosteps, varargin )
%
% DPAD
%
%    y = DPAD(i, stepsize, nosteps, varargin) returns the 
%    image y as the result of the application of the anisotropic diffusion schemes
%    for multiplicative speckle to the image I. 
%    Implements [Yu02] (SRAD) and the corrections in [Aja06] (DPAD).
%
%    Based on SRADDIF toolbox by Yu and Acton
%
%  INPUT:
%      
%    I          input image (VALUES IN 0-255)
%    stepsize   Size of time step in each iteration
%               If scalar: constant stepsize) 
%               If vector: variable stepsize. length(stepsize) = number of steps.
%               For stability use stepsize < 0.2. 
%               If using 'aos' option stepsize can be any positive number.
%    nosteps    Number of iteration steps
%
%
%  OPTIONAL INPUTS
% 
% 1.-Noise Estimation Method (For the Cu Estimation)------------------------
%    (The coefficient of variation of noise is a neede parameter)
%
%    y=  DPAD(..., 'cnoise',n) Adaptive noise estimation. Options (n):
%                  n=0   minimum of local Cs
%                  n=1   mean of local Cs
%                  n=2   lambda*min + (1-lambda)*mean 
%                  n=3   min with correction
%		   n=4   median of local Cs
%		   n=5   mode (Recomended) of local Cs
%
%    y=  DPAD(..., 'yuest') Noise estimated over absolute deviation of median [Yu04]
%                          (DEFAULT)
%    y=  DPAD(..., 'Wnoise',WN) Noise in a WN window
%                WN 2x2  matrix
%                WN=[x_start x_end; y_start y_end]
%    y=  DPAD(..., 'BWnoise',WN) similar to 'Wnoise' but with mean different to 1
%    y=  DPAD(..., 'qn' + [q0 rho]) Estimator based on q0 [Yu02]
%           -  q0: Original noise level q=qO.*exp(-rho*t);
%           -  rho: 
%
% 2. Diffusion function-----------------------------------
%
%  Default: SRAD in [Yu02]
%
%    y = DPAD(..., 'aja')  DPAD version    [Aja06]
%    y = DPAD(..., 'simp') Simplified SRAD [Aja06]
%   
%
% 3. Other Methods--------------------------------------
%
%    y = DPAD(..., 'big',WS)  The statistics for noise estimation (Cs) are estimated on
%          a WsxWs square window. RECOMENDED!!!! [Aja06]
%          WS= Window size (odd value recommended)
%    y = DPAD(..., 'aos') uses the AOS scheme to update the image. 
%    y = DPAD(..., 'dfstep',n) only recalculates the diffusivities after n steps (increase speed)
%    y = DPAD(..., 'prom') Normalize the image in each iteration
%
%  Example of use:
%
%          I=dpad(I0,0.2,100,'cnoise',5,'big',5,'aja');
%
% REFERENCES--------------------------------------
%
%   SRAD:
%      [Yu02] Yu Y, Acton ST. Speckle reducing anisotropic diffusion.
%             IEEE Trans Image Process. 2002;11(11):1260-70.
%
%  DPAD: 
%      [Aja06] S. Aja‐Fernandez, C. Alberola Lopez, On the Estimation of 
%              the Coefficient of Variation for Anisotropic Diffusion Speckle 
%              Filtering, IEEE Trans. Image Processing, Vol.15, no. 9, sept 2006.
%
%  Noise Estimation: 
%
%     [Aja09]  S. Aja‐Fernandez, G. Vegas Sanchez‐Ferrero, M. Martin‐Fernandez y C. 
%              Alberola‐Lopez, Automatic Noise Estimation in Images Using Local Statistics. 
%              Additive and Multiplicative Cases. Image and Vision Computing, 
%              Vol. 27, Issue 6, May 2009, pp. 756‐770. 
%
%     [Yu04]   Y. Yu and S. Acton, “Edge detection in ultrasound imagery using the
%              instantaneous coefficient of variation,” IEEE Trans. Image Proccess.,
%              vol. 13, no. 12, pp. 1640–1655, Dec. 2004.
%
%    Santiago Aja, 12/04/2005
%    Based on SRADDIF toolbox by Yu and Acton
%    The toolbox uses some functions from SRAD and PMDIF toolboxes by YU

[dfstep, aos, aja, simp, dinamNoise, WN,WS,big,q0, rho,prom,metod] = parse_inputs(varargin{:});

addpath common

% 1.- Variable initialization----------------------
y = double(I);
if ndims(I) ==3
    y=mean(I,3)
elseif ndims(I)>3
   error('Input image must be grayscale.')
end
dif_time = 0;
% 2.- Verifying inputs------------------------------

[stepsize] = verify_inputs(stepsize, nosteps);

%Dynamic lambda
if (dinamNoise==1)&(metod==2)
	lambda=0:1./(nosteps-1):1;
end

% 3.- ITERATIONS----------------------------------
for i=1:nosteps

   if prom   %Normalization
		y=norm255(y);
   end   
   if mod(i-1,dfstep) == 0 % Recalc diffusivity step

	  
% 3.1.- Calculate difusivity--------------------

	if big   %Big Window for estimation [Aja06]----------
	 
		med1=(filter2(ones(WS), y) / WS.^2);
		Cs = ( (filter2(ones(WS),y.^2)/WS.^2)-(med1).^2 )./(med1.^2);
		Cs=((WS^2)/(WS^2 -1)).*Cs;
		  
	else  %4 pixels for estimation [Yu02]---------------
	  
	  	Laplace2=(roll(y,[0  -1]) -y+roll(y,[0  1]) -y + roll(y,[-1  0]) -y +roll(y,[1  0]) -y )./y; 
	  	magrad2=((roll(y,[0  -1]) -y).^2 + (roll(y,[0  1]) -y).^2 + (roll(y,[-1  0]) -y).^2 +(roll(y,[1  0]) -y).^2)./y.^2;
	  	
	    %According to the paper: [Yu02]	
		%Cs = abs(0.5*magrad2 - (Laplace2.^2)./16)./(1+0.25*Laplace2).^2;
	    %According to Yu toolbox-software		  	
		Cs = abs(0.25*magrad2 - (Laplace2.^2)./17)./(1+0.25*Laplace2).^2;
	    %Unbiased estimation
		%Cs = (4/3).*abs(0.25*magrad2 - (Laplace2.^2)./16)./(1+0.25*Laplace2).^2;	
       	end	 
		%Correction to avoid 0 values
	Cs=max(Cs,0.0001); 

% 3.2 Noise estimation----------

	if (dinamNoise==1)        %Dynamic noise estimation [Aja06]  
		if metod==0             %MIN
			Cu=min(Cs(:));
		elseif metod==1         %MEAN
		  	Cu=mean(Cs(:));
		elseif metod==2
		  	Cu=lambda(i).*min2(Cs) + (1-lambda(i)).*mean2(Cs);
		elseif metod==3
			Cu=min(Cs(:))./(0.655^2);	
		elseif metod==4
			Cu=median(Cs(:)); %MEDIAN
		elseif metod==5
			Cu=moda(Cs(:),1000);	%MODE
		end
	elseif (dinamNoise==2) %Noise in a window
	      %Noise variance
		var_ruido=(std2( y(WN(1,1):WN(1,2),WN(2,1):WN(2,2))) ).^2;
	     %Assuming med_ruido=1;
		Cu=var_ruido;		  
		
	elseif (dinamNoise==3) %Noise in a window
	      %In a window with mean not 1
	  	var_ruido=(std2( y(WN(1,1):WN(1,2),WN(2,1):WN(2,2))) ).^2;
		med_ruido=mean2( y(WN(1,1):WN(1,2),WN(2,1):WN(2,2)) );
		Cu=var_ruido./(med_ruido.^2);
		  		  
	elseif (dinamNoise==4) %Logarithm
	  	%Deleted
	elseif (dinamNoise==5) %Method in [Yu02] (Very bad performance)
	  	Cu=(q0.*exp(-rho.*dif_time)).^2;		
	else   %Deviation of median (default) [Yu04]
	  	if big
			tm=(WS-1)/2;
			[fx,fy]=gradient(log(y),tm,tm);
		else
	  		[fx,fy]=gradient(log(y));
     		end
		MED=median(median(sqrt(fx.^2+fy.^2)));
     		MAD=sqrt((fx-MED).^2+(fy-MED).^2);    
     		Cu2=1.4826*median(median(MAD));
     		Cu=0.5*Cu2.^2;
	end
	  	
	Cu=max(Cu,0.0001);
	  
	if aja	 %DPAD Complete Equation [Aja06]  
	  	g=(1+(1./Cs))./(1+(1./Cu));	 		
	elseif simp %Simplified version
	  	g=Cu./Cs;
	else	%SRAD [Yu02]
	  	g= 1./(1+ ((Cs-Cu)./(Cu*( 1+ Cu))));		
        end
	  %Upperbound to avoid infinity values
	  %g=min(g,10);
	  
   end %dfstep
   
% 3.3 Calculate dy/dt---------------------------

   if aos    %Semi-implicit scheme 
      y = aosiso(y,g,stepsize(i)); % updating
   else     %Explicit Scheme
      dy = isodifstep(y, g);
      y = y + stepsize(i) * 0.25 * dy;  % updating
   end
     
% 3.4 Calculate diffusion time---------  

   dif_time = dif_time + stepsize(i);
   
end % for i

%FINAL NORMALIZATION--------------------------------------
if prom
	y=norm255(y);
else
	y=y./mean2(y);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dfstep,aos, aja, simp,dinamNoise, WN,WS,big,q0,rho,prom,metod] = parse_inputs(varargin)
aos = 0;
dinamNoise=0;
WN=[];
WS=3;
aja=0;
dfsteppos = -1;
big=0;
test=0;
q0=0; 
rho=0;
prom=0;
metod=0;
simp=0;
dfstep = 1;

for i = 1 : length(varargin)
   flag = 0;
   if i == dfsteppos
      flag = 1;
   end
   if strcmp(varargin{i},'dfstep')
      dfstep = varargin{i+1};
      flag = 1;
      dfsteppos = i+1;
   elseif strcmp(varargin{i},'cnoise')      
	  dinamNoise=1;
      flag = 1;  
	  metod= varargin{i+1};
      dfsteppos = i+1;
   elseif strcmp(varargin{i},'Wnoise')
      WN = varargin{i+1};
	  dinamNoise=2;
      flag = 1; 
      dfsteppos = i+1;
   elseif strcmp(varargin{i},'BWnoise')
      WN = varargin{i+1};
	  dinamNoise=3;
      flag = 1; 
      dfsteppos = i+1;  
   %elseif strcmp(varargin{i},'log')
   %   dinamNoise=4;
   %   flag = 1;
   %   metod= varargin{i+1};
   %   dfsteppos = i+1;  
   elseif strcmp(varargin{i},'yuest')
      dinamNoise=6;
      flag = 1;      
   elseif strcmp(varargin{i},'aja')
      aja = 1;
      flag = 1;   
   elseif strcmp(varargin{i},'simp')
      simp = 1;
      flag = 1; 
   elseif strcmp(varargin{i},'aos')
      aos = 1;
      flag = 1; 
   elseif strcmp(varargin{i},'prom')
      prom = 1;
      flag = 1;    
   elseif strcmp(varargin{i},'big')
      big = 1;
      flag = 1;     
	  WS= varargin{i+1};
      dfsteppos = i+1;
   elseif strcmp(varargin{i},'qn')
      dinamNoise=5;
	  valores = varargin{i+1};
	  q0=valores(1);
	  rho=valores(2);
      flag = 1;  
	  dfsteppos = i+1; 
   end
   if flag == 0
      error('Too many parameters !')
      return
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nstepsize] = verify_inputs(stepsize, nosteps)



% Verifying stepsize
if sum(size(stepsize)>1) == 0 % constant stepsize
   nstepsize = linspace(stepsize,stepsize,nosteps);
else
   if sum(size(stepsize)>1) > 1
      error('stepsize must be a row vector')
      return
   end
   if length(stepsize)~=nosteps
      error('length(stepsize) must be equal to number of steps')
      return
   end
   nstepsize = stepsize;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function In=norm255(Im)

In=double(Im).*255./max2(Im);
