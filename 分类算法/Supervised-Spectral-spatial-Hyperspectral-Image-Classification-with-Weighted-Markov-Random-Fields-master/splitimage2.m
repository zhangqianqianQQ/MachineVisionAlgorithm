function p = splitimage2(input,z,w,scale,sigma)

x=input;
clear input

% x -> spectral vectors
% save classes
% y=x(2,:);

% delete first two (pixel number and classes)
% x(1:2,:)=[];


[d,n] =size(x);
nz = sum(z.^2);
n1 = floor(n/80);
p = [];
for i = 1:79
    x1 = x(:,((i-1)*n1+1):n1*i);
%     x(:,1:n1) = [];
    nx1 = sum(x1.^2);
    [X1,Z1] = meshgrid(nx1,nz);
    clear nx1;
    dist1 = Z1-2*z'*x1+X1;
    K1=exp(-dist1/2/scale/sigma^2);
    K1 = [ones(1,n1); K1];
    p1=mlogistic(w,K1);
    p = [p p1];
%     x(:,1:n1) = [];
end

x1 = x(:,(79*n1+1):n);
clear x
nx1 = sum(x1.^2);
[X1,Z1] = meshgrid(nx1,nz);
dist1 = Z1-2*z'*x1+X1;
K1=exp(-dist1/2/scale/sigma^2);
K1 = [ones(1,n-79*n1); K1];
p1=mlogistic(w,K1);
p = [p p1];

    
% x1 = x(:,1:n1);
% x(:,1:n1) = [];
% nz = sum(z.^2);
% nx1 = sum(x1.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% clear nx1
% dist1 = Z1-2*z'*x1+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n1); K1];
% p1=mlogistic(w,K1);
% clear x1;


% n1 = floor(n/20);
% n2 = n1*2;
% n3 = n1*3;
% n4 = n1*4;
% n5 = n1*5;
% n6 = n1*6;
% n7 = n1*7;
% n8 = n1*8;
% n9 = n1*9;
% n10 = n1*10;
% n11 = n1*11;
% n12 = n1*12;
% n13 = n1*13;
% n14 = n1*14;
% n15 = n1*15;
% n16 = n1*16;
% n17 = n1*17;
% n18 = n1*18;
% n19 = n1*19;
% 
% x1 = x(:,1:n1);
% x(:,1:n1) = [];
% nz = sum(z.^2);
% nx1 = sum(x1.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% clear nx1
% dist1 = Z1-2*z'*x1+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n1); K1];
% p1=mlogistic(w,K1);
% clear x1;
% 
% x2 = x(:,1:(n2-n1));
% x(:,1:(n2-n1)) = [];
% nx1 = sum(x2.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x2+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n2-n1); K1];
% p2=mlogistic(w,K1);
% clear x2;
% 
% x3 = x(:,1:(n3-n2));
% x(:,1:(n3-n2)) = [];
% nx1 = sum(x3.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x3+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n3-n2); K1];
% p3=mlogistic(w,K1);
% clear x3;
% 
% x4 = x(:,1:(n4-n3));
% x(:,1:(n4-n3)) = [];
% nx1 = sum(x4.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x4+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n4-n3); K1];
% p4=mlogistic(w,K1);
% clear x4;
% 
% x5 = x(:,1:(n5-n4));
% x(:,1:(n5-n4)) = [];
% nx1 = sum(x5.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x5+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n5-n4); K1];
% p5=mlogistic(w,K1);
% clear x5;
% 
% x6 = x(:,1:(n6-n5));
% x(:,1:(n6-n5)) = [];
% nx1 = sum(x6.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x6+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n6-n5); K1];
% p6=mlogistic(w,K1);
% clear x6;
% 
% x7 = x(:,1:(n7-n6));
% x(:,1:(n7-n6)) = [];
% nx1 = sum(x7.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x7+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n7-n6); K1];
% p7=mlogistic(w,K1);
% clear x7;
% 
% x8 = x(:,1:(n8-n7));
% x(:,1:(n8-n7)) = [];
% nx1 = sum(x8.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x8+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n8-n7); K1];
% p8=mlogistic(w,K1);
% clear x8;
% 
% x9 = x(:,1:(n9-n8));
% x(:,1:(n9-n8)) = [];
% nx1 = sum(x9.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x9+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n9-n8); K1];
% p9=mlogistic(w,K1);
% clear x9;
% 
% x10 = x(:,1:(n10-n9));
% x(:,1:(n10-n9)) = [];
% nx1 = sum(x10.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x10+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n10-n9); K1];
% p10=mlogistic(w,K1);
% clear x10;
% 
% x11 = x(:,1:(n11-n10));
% x(:,1:(n11-n10)) = [];
% nz = sum(z.^2);
% nx1 = sum(x11.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% clear nx1
% dist1 = Z1-2*z'*x11+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n11-n10); K1];
% p11=mlogistic(w,K1);
% clear x11;
% 
% x12 = x(:,1:(n12-n11));
% x(:,1:(n12-n11)) = [];
% nx1 = sum(x12.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x12+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n12-n11); K1];
% p12=mlogistic(w,K1);
% clear x12;
% 
% x13 = x(:,1:(n13-n12));
% x(:,1:(n13-n12)) = [];
% nx1 = sum(x13.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x13+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n13-n12); K1];
% p13=mlogistic(w,K1);
% clear x13;
% 
% x14 = x(:,1:(n14-n13));
% x(:,1:(n14-n13)) = [];
% nx1 = sum(x14.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x14+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n14-n13); K1];
% p14=mlogistic(w,K1);
% clear x14;
% 
% x15 = x(:,1:(n15-n14));
% x(:,1:(n15-n14)) = [];
% nx1 = sum(x15.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x15+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n15-n14); K1];
% p15=mlogistic(w,K1);
% clear x15;
% 
% x16 = x(:,1:(n16-n15));
% x(:,1:(n16-n15)) = [];
% nx1 = sum(x16.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x16+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n16-n15); K1];
% p16=mlogistic(w,K1);
% clear x16;
% 
% x17 = x(:,1:(n17-n16));
% x(:,1:(n17-n16)) = [];
% nx1 = sum(x17.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x17+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n17-n16); K1];
% p17=mlogistic(w,K1);
% clear x17;
% 
% x18 = x(:,1:(n18-n17));
% x(:,1:(n18-n17)) = [];
% nx1 = sum(x18.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x18+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n18-n17); K1];
% p18=mlogistic(w,K1);
% clear x18;
% 
% x19 = x(:,1:(n19-n18));
% x(:,1:(n19-n18)) = [];
% nx1 = sum(x19.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x19+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n19-n18); K1];
% p19=mlogistic(w,K1);
% clear x19;
% 
% x20 = x;
% nx1 = sum(x20.^2);
% [X1,Z1] = meshgrid(nx1,nz);
% dist1 = Z1-2*z'*x20+X1;
% K1=exp(-dist1/2/scale/sigma^2);
% K1 = [ones(1,n-n19); K1];
% p20=mlogistic(w,K1);
% clear x20;
% 
% output = [p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15 p16 p17 p18 p19 p20];