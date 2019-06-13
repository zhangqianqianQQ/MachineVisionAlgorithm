function visualize(cell_matrix, img)
h_img = size(img, 1);
w_img = size(img, 2);
[NUM_OF_BINNING, height, width] = size(cell_matrix);
xt=1:NUM_OF_BINNING;
xt=xt(:);
yt=ones(NUM_OF_BINNING,1);
yt=yt*pi/NUM_OF_BINNING;
yt=yt.*xt;
x=[];
y=[];
u=[];
v=[];
w_shift = w_img / width;
h_shift = h_img / height;
for w = 1:width
    for h = 1:height        
        [u(end+1:end+NUM_OF_BINNING),v(end+1:end+NUM_OF_BINNING)] = pol2cart(yt, cell_matrix(:,h,w));
        x(end+1:end+NUM_OF_BINNING)=ones(NUM_OF_BINNING,1)*(w-1)*w_shift;
        y(end+1:end+NUM_OF_BINNING)=ones(NUM_OF_BINNING,1)*(h-1)*h_shift;
    end
end
figure();
subplot(1,3,2);
imshow(img);
title('Image and HoG');
hold on;
u=u*1e8;
v=v*1e8;
quiver(x,y,u,v, '-c');
subplot(1,3,1);
imshow(img);
title('Original Image');
subplot(1,3,3);
quiver(x,y,u,v, '-b');
title('HoG Visualization');