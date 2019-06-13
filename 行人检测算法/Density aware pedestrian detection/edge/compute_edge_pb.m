function [ pb, theta ] = compute_edge_pb( img )

if(exist('pbCGTG.m','file')~=2)

    disp('Get the segbench toolbox');

end

img = im2double(img);

img = rescaleImage(img);


if (size(img, 3) > 1)
    [pb, theta] = pbCGTG(img);
else
    [pb, theta] = pbBGTG(img);
end

