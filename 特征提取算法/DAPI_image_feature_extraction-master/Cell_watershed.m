function L=Cell_watershed(I0, t4)
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I0), hy, 'replicate');
Ix = imfilter(double(I0), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
%figure, imshow(gradmag,[]), title('gradmag')


% first parameter
se = strel('disk', t4);
Io = imopen(I0, se);
%figure, imshow(Io), title('Io')

Ie = imerode(I0, se);
Iobr = imreconstruct(Ie, I0);
% figure, imshow(Iobr), title('Iobr')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
% figure, imshow(Iobrcbr), title('Iobrcbr')

fgm = imregionalmax(Iobrcbr,8);
%figure, imshow(fgm), title('fgm')

I2 = I0;
I2(fgm) = 255;
% figure, imshow(I2), title('fgm superimposed on original image')

% Second parameter
se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

% Third parameter
fgm4 = bwareaopen(fgm3, 5);
I3 = I0;
I3(fgm4) = 255;
% figure, imshow(I3)
% title('fgm4 superimposed on original image')

bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
%figure, imshow(bw), title('bw')
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
% figure, imshow(bgm), title('bgm')

gradmag2 = imimposemin(gradmag, bgm | fgm4);

L = watershed(gradmag2);
I4 = I0;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
% figure, imshow(I4)
% title('Markers and object boundaries superimposed on original image')

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
% figure, imshow(Lrgb)
% title('Lrgb')
figure, imshow(I0), hold on
himage = imshow(Lrgb);
set(himage, 'AlphaData', 0.3);
title('nurse cell blobs')