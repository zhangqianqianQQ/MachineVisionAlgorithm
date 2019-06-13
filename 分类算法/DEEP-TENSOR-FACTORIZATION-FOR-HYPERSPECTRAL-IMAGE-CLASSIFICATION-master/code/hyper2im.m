function imout=hyper2im(im,bands)
[m,n,p]=size(im);
if p==1
    im=double(im(:))';
    im=mapstd(im);
    im=mapminmax(im,0,1);
    imout=reshape(im,[m,n]);
    imout=im2uint8(imout);
%    imout=histeq(imout);
else
    if (nargin<2)
        bands=[1,round(p/2),p];
    end
    imout=zeros(m,n,3,'uint8');
    imout(:,:,1)=hyper2im(im(:,:,bands(1)));
    imout(:,:,2)=hyper2im(im(:,:,bands(2)));
    imout(:,:,3)=hyper2im(im(:,:,bands(3)));    
end
