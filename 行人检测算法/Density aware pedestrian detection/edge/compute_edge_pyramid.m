function I_edge  = compute_edge_pyramid(img,detector,h_down,ratio)

if(~exist('detector','var') || isempty(detector))
    detector=1;
else
    if(strcmp(detector,'pb'))
        detector=1;
    else
        detector=2;
    end
end

if(exist('ratio','var') && isempty(ratio))
    ratio = 1/1.2;
end

if(ratio>1)
    error('ratio must be <1');
end

img     = im2double(img);
pimg    = img;

scale_no= 1;
I_edge=[];
while(1)    
    if(detector==1)
        [t_edge,t_theta]    = compute_edge_pb(pimg);
    else
        [t_edge,t_theta]    = compute_edge_flt(pimg);
    end
    I_edge(scale_no).edge   = t_edge;
    I_edge(scale_no).theta  = t_theta;
    scale_no= scale_no + 1;
    [imgh,imgw,ch]  = size(pimg);
    imgh1           = round(imgh*ratio);
    if(imgh1<h_down)
        break;
    end
    pimg = imresize(pimg,ratio,'bicubic');
end
