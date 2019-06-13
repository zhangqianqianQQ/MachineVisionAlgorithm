function [ELPS,x,y] = genEllipse(rect_h,rect_w,square_shape)

if(~exist('square_shape','var'))
    square_shape=0;
end

if(square_shape)
    M   = max(rect_w,rect_h);
    N   = M;
else
    N   = rect_w;
    M   = rect_h;
end

[x,y]=meshgrid(-(N/2)+1/2:(N/2)-1/2,-(M/2)+1/2:(M/2)-1/2);

ELPS = (x.*x)/(rect_w*rect_w) + (y.*y)/(rect_h*rect_h);
ELPS = (ELPS<=0.25);
