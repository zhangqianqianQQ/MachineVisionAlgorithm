%功能：检测主程序

clear
clc
tic
load hoof_model32;

Img1 = imread('hof1.png');
Img2 = imread('hof2.png');

Img_backup = Img1;
[H, W, K] = size(Img1);

Xslide = 8;
Yslide = 16;
Xwindow = 64;
Ywindow = 128;
Sratio = 1.6;

t = 0;
Wnum = 0;
Whof = [];
Location = [];
Temp = [];

[u, v] = flow(Img1, Img2, 1);
u = imresize(u, [H, W]);
v = imresize(v, [H, W]);

while Xwindow<W && Ywindow<H
    for j = 1:Yslide:H-Ywindow+1
        for i = 1:Xslide:W-Xwindow+1
            Wnum = Wnum+1;
            Location(Wnum,:) = [i j Sratio^t];
            Imgu = u(j:j+Ywindow-1,i:i+Xwindow-1,:);
            Imgv = v(j:j+Ywindow-1,i:i+Xwindow-1,:);
            ImgW = Img1(j:j+Ywindow-1,i:i+Xwindow-1,:);
            Whog = hogcalculator(ImgW);
            Fu = hogcalculator(Imgu);
            Fv = hogcalculator(Imgv);
            Whof(Wnum,:) = [Whog Fu Fv];
        end
    end
    Img1 = imresize(Img1, 1/Sratio);
    u = imresize(u, 1/Sratio);
    v = imresize(v, 1/Sratio);
    [H, W, K] = size(Img1);
    t = t+1;
end

Lab = ones(Wnum, 1);
[Wlabel, accuracy, weight] = svmpredict(Lab, Whof, hoof_model32);

Human = find(Wlabel==1);
Temp = Location(Human,:);
dw = weight(Human,:);
Final = [];
mark = [];
N = size(Temp,1);
for j = 1:N
    flag = [];
    Temp1 = Temp(j,:);
    Rect1 = [Temp1(1)*Temp1(3) Temp1(2)*Temp1(3) Temp1(1)*Temp1(3)+Xwindow*Temp1(3) Temp1(2)*Temp1(3)+Ywindow*Temp1(3)];
    for i = 1:N
        Temp2 = Temp(i,:);
        Rect2 = [Temp2(1)*Temp2(3) Temp2(2)*Temp2(3) Temp2(1)*Temp2(3)+Xwindow*Temp2(3) Temp2(2)*Temp2(3)+Ywindow*Temp2(3)];
        map = overlap(Rect1, Rect2);
        if map > 0
            flag = [flag i];
        end
    end
    if length(flag) == 1
        mark = [mark flag];
    end
end
Temp(mark,:) = [];
dw(mark,:) = [];
Final = nms(Temp, dw);

for i = 1:size(Final,1)
    RectX = round(Final(i, 1)*Final(i, 3));
    RectY = round(Final(i, 2)*Final(i, 3));
    RectW = round(Xwindow*Final(i, 3));
    RectH = round(Ywindow*Final(i, 3));
    Img_backup(RectY, RectX:RectX+RectW, 1)=255;
    Img_backup(RectY, RectX:RectX+RectW, 2)=0;
    Img_backup(RectY, RectX:RectX+RectW, 3)=0;
    Img_backup(RectY:RectY+RectH, RectX, 1)=255;
    Img_backup(RectY:RectY+RectH, RectX, 2)=0;
    Img_backup(RectY:RectY+RectH, RectX, 3)=0;
    Img_backup(RectY+RectH, RectX:RectX+RectW, 1)=255;
    Img_backup(RectY+RectH, RectX:RectX+RectW, 2)=0;
    Img_backup(RectY+RectH, RectX:RectX+RectW, 3)=0;
    Img_backup(RectY:RectY+RectH, RectX+RectW, 1)=255;
    Img_backup(RectY:RectY+RectH, RectX+RectW, 2)=0;
    Img_backup(RectY:RectY+RectH, RectX+RectW, 3)=0;
end

imshow(Img_backup);
imwrite(Img_backup, 'image_00000985_0.jpg');

toc
