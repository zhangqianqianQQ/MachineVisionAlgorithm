I = imread('bh.png'); 
%I = imread('C:\Users\Mostwanted\Desktop\Wuhan_China.jpg'); 
subplot(1,2,1); 
imshow(I); 


I=double(I); 
f=I(:,:,1); 
ff=I(:,:,2); 
fff=I(:,:,3); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
k1=4; 
k2=5; 
r=161; 
alf=1458; 
nn=floor((r+1)/2); 
for i=1:r 
    for j=1:r 
        b(i,j) =exp(-((i-nn)^2+(j-nn)^2)/(k1*alf))/(k2*pi*alf*10000); % Gaussian 1 
   end 
end 

k1=8;                                                                   
k2=8; 
r=161; 
alf=1458; 
nn=floor((r+1)/2); 
for i=1:r 
    for j=1:r 
        bb(i,j) =exp(-((i-nn)^2+(j-nn)^2)/(k1*alf))/(k2*pi*alf*10000);     % Gaussian 2 
   end 
end 

k1=0.5; 
k2=0.5; 
r=161; 
alf=1458; 
nn=floor((r+1)/2); 
for i=1:r 
    for j=1:r 
        bbb(i,j) =exp(-((i-nn)^2+(j-nn)^2)/(k1*alf))/(k2*pi*alf*10000);  % Gaussian 2 3 
    end 
    end 
%%%%%%%%%%% R component of treatment %%%%%%%%%%%%% 
Img = double(f); 
[m,n]=size(f); 

aa=125; 

for i=1:m 
    for j=1:n 
        C(i,j)=log(1+aa*(Img(i,j)/I(i,j))); 
    end 
end 

K=imfilter(Img,b); 
KK=imfilter(Img,bb); 
KKK=imfilter(Img,bbb); 

for i=1:m 
    for j=1:n       
       G(i,j)=1/3*(log(Img(i,j)+1)-log(K(i,j)+1)); 
        G(i,j)=1/3*(log(Img(i,j)+1)-log(KK(i,j)+1))+G(i,j); 
         G(i,j)=C(i,j)*(1/3*(log(Img(i,j)+1)-log(KKK(i,j)+1))+G(i,j)); 
    end 
end 

mi=min(min(G)); 
ma=max(max(G)); 
       L=(G-mi)*255/(ma-mi); 
%%%%%%%%%%%%%% G Processing Components %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
Img = double(ff); 
[m,n]=size(ff); 

aa=125; 
for i=1:m 
    for j=1:n 
        CC(i,j)=log(1+aa*(Img(i,j)/I(i,j))); 
    end 
end 

K=imfilter(Img,b); 
KK=imfilter(Img,bb); 
KKK=imfilter(Img,bbb); 
for i=1:m 
    for j=1:n       
       G(i,j)=1/3*(log(Img(i,j)+1)-log(K(i,j)+1)); 
        G(i,j)=1/3*(log(Img(i,j)+1)-log(KK(i,j)+1))+G(i,j); 
         G(i,j)=CC(i,j)*(1/3*(log(Img(i,j)+1)-log(KKK(i,j)+1))+G(i,j)); 
    end 
end 

mi=min(min(G)); 
ma=max(max(G)); 
       LL=(G-mi)*255/(ma-mi); 
%%%%%%%%%%%%% With the B component of the Department %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
Img = double(fff); 
[m,n]=size(fff); 

aa=125; 
for i=1:m 
    for j=1:n 
        CCC(i,j)=log(1+aa*(Img(i,j)/I(i,j))); 
    end 
end 

K=imfilter(Img,b); 
KK=imfilter(Img,bb); 
KKK=imfilter(Img,bbb); 

for i=1:m 
    for j=1:n       
       G(i,j)=1/3*(log(Img(i,j)+1)-log(K(i,j)+1)); 
        G(i,j)=1/3*(log(Img(i,j)+1)-log(KK(i,j)+1))+G(i,j); 
         G(i,j)=CCC(i,j)*(1/3*(log(Img(i,j)+1)-log(KKK(i,j)+1))+G(i,j)); 
    end 
end 

mi=min(min(G)); 
ma=max(max(G)); 

       LLL=(G-mi)*255/(ma-mi); 
%%%%%%%%%%%% Department of Integrated color image of science %%%%%%%%%%%%%%% 
msrcr=cat(3,L,LL,LLL); 
subplot(1,2,2); 
imshow(uint8(msrcr)); 
%imwrite(uint8(msrcr),'C:\Users\Mostwanted\Desktop\Wuhan_China_outcr1.jpg'); 
%imwrite(uint8(msrcr),'C:\Users\Mostwanted\Desktop\Washington_DC_outcr1.jpg'); 