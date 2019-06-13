function [data,noise,max_index] = addnoise(data, scale,mean)
% Number of point
if nargin<3
[d, n] = size(data);
noise = scale * randn(d,n);
data = data + noise;

noise_s= sqrt( data(1,:).^2 + data(2,:).^2 );

[max_index,max_index]=sort(noise_s,'descend');
elseif nargin==3
    
    
 [d, n] = size(data);
noise = scale * randn(d,n)+ mean;
data = data + noise;

noise_s= sqrt( data(1,:).^2 + data(2,:).^2 );
[max_index,max_index]=sort(noise_s,'descend');
end
    

