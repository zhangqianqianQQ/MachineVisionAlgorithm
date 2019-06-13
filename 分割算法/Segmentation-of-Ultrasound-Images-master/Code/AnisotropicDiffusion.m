function I = AnisotropicDiffusion(k1,lambda1)
%------This function is used for smooth image, remove noise from image and
%at same time, preserving the edges in the image.

k=k1;          
lambda=lambda1;
N=90;           %weight number control smooth level of image
[img,map] = imread('2.jpg');
disp(' Computing edge map ...');
img = rgb2gray(img);
img = im2double(img);
figure();
subplot(121);imshow(img);title('The original image')
[m n]=size(img);
imgn=zeros(m,n);
for i=1:N

    for p=2:m-1
        for q=2:n-1
            %present divergence of pexil, calculate partial derivative in four directions, partial difference in different directions
            %if it changes a lot, it is edgy. it should be preserve
            NI=img(p-1,q)-img(p,q);
            SI=img(p+1,q)-img(p,q);
            EI=img(p,q-1)-img(p,q);
            WI=img(p,q+1)-img(p,q);
            
            %heat conductivity coefficients in four directions, the more
            %change in each direction, the less the value is.
            cN=exp(-NI^2/(k*k));
            cS=exp(-SI^2/(k*k));
            cE=exp(-EI^2/(k*k));
            cW=exp(-WI^2/(k*k));
            
            imgn(p,q)=img(p,q)+lambda*(cN*NI+cS*SI+cE*EI+cW*WI);  %the new value after diffuse calculation      
        end
    end
    
    img=imgn;  
end
I = imgn;
subplot(122);imshow(imgn);title('The processed image')