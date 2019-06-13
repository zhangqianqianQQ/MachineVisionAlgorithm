function out = gaussian_kernel(x,d1,d2,bandWidth)

% taken from a reference on the web to generate a Gaussian kernal
ns = 1000; % resolution 
xs1 = linspace(0,bandWidth(1,1),ns+1); % spatial
xs2 = linspace(0,bandWidth(1,2),ns+1); %range
kfun1 = exp(-(xs1.^2)/(2*bandWidth(1,1)^2));
kfun2 = exp(-(xs2.^2)/(2*bandWidth(1,2)^2));
w1 = kfun1(1,1:size(d1)).*(round(d1/bandWidth(1,1)*ns)+1);
w2=kfun2(1,1:size(d2)).*(round(d2/bandWidth(1,2)*ns)+1);
w=w1+w2;
w = w/sum(w); % normalise
out = sum( bsxfun(@times, x, w ), 2 );
end