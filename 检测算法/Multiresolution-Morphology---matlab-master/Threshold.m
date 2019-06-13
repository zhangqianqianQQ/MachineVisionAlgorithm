function [ Th ] = Threshold( image, t )
h=size(image,1);
w=size(image,2);
Th=zeros(h,w);
parfor i=1:h
    for j=1:w
        if image(i,j)>t
            Th(i,j)=1;
        else
            Th(i,j)=0;
        end
    end
end
end