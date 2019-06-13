function H=Heaviside(z)
% Heaviside step function (smoothed version)
% Copyright (c) 2009, 
% Yue Wu @ ECE Department, Tufts University
% All Rights Reserved  

Epsilon=10^(-5);
H=zeros(size(z,1),size(z,2));
idx1=find(z>Epsilon);
idx2=find(z<Epsilon & z>-Epsilon);
H(idx1)=1;
for i=1:length(idx2)
    H(idx2(i))=1/2*(1+z(idx2(i))/Epsilon+1/pi*sin(pi*z(idx2(i))/Epsilon));
end;