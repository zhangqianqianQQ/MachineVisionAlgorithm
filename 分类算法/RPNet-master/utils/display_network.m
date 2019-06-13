function array = display_network(A, cols)

warning off all

% rescale
% A = A - mean(A(:));

% compute rows, cols
A = A(1:(floor(sqrt(size(A,1))))^2,:);
[L M]=size(A);
sz=sqrt(L);
buf=1;
if ~exist('cols', 'var')
    if floor(sqrt(M))^2 ~= M
        n=ceil(sqrt(M));
        while mod(M, n)~=0 && n<1.2*sqrt(M), n=n+1; end
        m=ceil(M/n);
    else
        n=sqrt(M);
        m=n;
    end
else
    n = cols;
    m = ceil(M/n);
end

array=zeros(buf+m*(sz+buf),buf+n*(sz+buf));

k=1;
for i=1:m
    for j=1:n
        if k>M,
            continue;
        end
        clim=max(abs(A(:,k)));
        
        array(buf+(i-1)*(sz+buf)+(1:sz),buf+(j-1)*(sz+buf)+(1:sz)) = (reshape(A(:,k),sz,sz) - min(A(:,k))) / (max(A(:,k)) - min(A(:,k)));
        
        k=k+1;
    end
end

colormap(gray);
imagesc(array,'EraseMode','none',[0 1]);

axis image off

drawnow;

warning on all
