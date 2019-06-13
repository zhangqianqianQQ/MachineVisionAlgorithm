function [ out ] = SimpleHist1D( image, w )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
image = double (image);
n = length(image(1,:,1));
m = length(image(:,1,1));
out = zeros(256/w, 3);

for i=1:3
    for x=1:n
        for y=1:m
            hue = image(y,x,i);
            %bin = idivide(hue,w,'floor')+1;
            bin = floor(hue/w)+1;
            out(bin,i) = out(bin,i) + 1;
        end
    end
end

out = out/(n*m);

end