function Image_IF = fft2_filt(Image,FilterBank,edge_meth)

if(~exist('edge_meth'))
    edge_meth = 'zero';
end

if(strcmp(edge_meth,'zero'))
    edge_meth =1;
end
if(strcmp(edge_meth,'reflect'))
    edge_meth =2;
end
if(strcmp(edge_meth,'expand'))
    edge_meth =3;
end

[fr,fc, fn] = size(FilterBank);
[imr,imc]=size(Image);
if(~isa(Image,'double'))
    Image=double(Image);
end
fwin_r = floor(fr/2);
fwin_c = floor(fc/2);
Image_expand = zeros(size(Image)+[fwin_r*2 fwin_c*2]);
Image_expand(fwin_r+1:fwin_r+imr,fwin_c+1:fwin_c+imc)=Image;

if(edge_meth ==2)

    Image_expand(fwin_r+1:fwin_r+imr,1:fwin_c) =...
        fliplr(Image(:,1:fwin_c));
    Image_expand(fwin_r+1:fwin_r+imr,fwin_c+1+imc:end) =...
        fliplr(Image(:,end-fwin_c+1:end));
    Image_expand(1:fwin_r,fwin_c+1:fwin_c+imc) =...
        flipud(Image(1:fwin_r,:));
    Image_expand(fwin_r+1+imr:end,fwin_c+1:fwin_c+imc) =...
        flipud(Image(end-fwin_r+1:end,:));
    Image_expand(1:fwin_r,1:fwin_c) = flipud(fliplr(Image(1:fwin_r,1:fwin_c)));
    Image_expand(1:fwin_r,fwin_c+1+imc:end) = flipud(fliplr(Image(1:fwin_r,end-fwin_c+1:end)));
    Image_expand(fwin_r+1+imr:end,1:fwin_c)=flipud(fliplr(Image(end-fwin_r+1:end,1:fwin_c)));
    Image_expand(fwin_r+1+imr:end,fwin_c+1+imc:end)=flipud(fliplr(Image(end-fwin_r+1:end,end-fwin_c+1:end)));    
end
if(edge_meth==3)

    Image_expand(fwin_r+1:fwin_r+imr,1:fwin_c) =...
        2*( Image(:,1)*ones(1,fwin_c))-...
        fliplr(Image(:,2:fwin_c+1));
    Image_expand(fwin_r+1:fwin_r+imr,fwin_c+1+imc:end) =...
        2*( Image(:,end)*ones(1,fwin_c) )-... 
        fliplr(Image(:,end-fwin_c:end-1));

    Image_expand(1:fwin_r,fwin_c+1:fwin_c+imc) =...
        2*( ones(fwin_r,1)*Image(1,:) )-...
        flipud(Image(2:fwin_r+1,:));

    Image_expand(fwin_r+1+imr:end,fwin_c+1:fwin_c+imc) =...
        2*( ones(fwin_r,1)*Image(end,:) )-...
        flipud(Image(end-fwin_r:end-1,:));

    Image_expand(1:fwin_r,1:fwin_c) = ...
        2*Image(1,1) - flipud(fliplr(Image(2:fwin_r+1,2:fwin_c+1)));

    Image_expand(1:fwin_r,fwin_c+1+imc:end) =...
        2*Image(1,end) - flipud(fliplr(Image(2:fwin_r+1,end-fwin_c:end-1)));

    Image_expand(fwin_r+1+imr:end,1:fwin_c)=...
        2*Image(end,1) - flipud(fliplr(Image(end-fwin_r:end-1,2:fwin_c+1)));

    Image_expand(fwin_r+1+imr:end,fwin_c+1+imc:end)=...
        2*Image(end,end) - flipud(fliplr(Image(end-fwin_r:end-1,end-fwin_c:end-1)));   
end


Image_IF=zeros(imr,imc,fn);


for b=1:fn
    tmp=conv2(Image_expand,FilterBank(:,:,b),'same');
    Image_IF(:,:,b)=tmp(fwin_r+1:fwin_r+imr,fwin_c+1:fwin_c+imc);
end
