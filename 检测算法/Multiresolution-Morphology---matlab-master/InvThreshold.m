function [ Th ] = InvThreshold( image, t )
h=size(image,1);
w=size(image,2);
Th=zeros(h,w);
parfor i=1:h
    for j=1:w
        if (image(i,j)>t || image(i,j)==0)
            Th(i,j)=0;
        else
            Th(i,j)=1;
        end
    end
end
end