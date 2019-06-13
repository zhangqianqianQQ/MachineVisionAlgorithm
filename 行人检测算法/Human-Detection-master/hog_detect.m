%功能：检测主程序

clear
clc
tic
load hog_model32;

Img = imread('image_00000983_0.png');

Img_backup = Img;
[H, W, K] = size(Img);

Xslide = 8;
Yslide = 16;
Xwindow = 64;
Ywindow = 128;
Sratio = 1.3;

t = 0;
Wnum = 0;
Whog = [];
Location = [];
ImgW = [];
Temp = [];
while Xwindow<W && Ywindow<H
    for j = 1:Yslide:H-Ywindow+1
        for i = 1:Xslide:W-Xwindow+1
            Wnum = Wnum+1;
            Location(Wnum,:) = [i j Sratio^t];
            ImgW = Img(j:j+Ywindow-1,i:i+Xwindow-1,:);
            Whog(Wnum,:) = hogcalculator(ImgW);
        end
    end
    Img = imresize(Img, 1/Sratio);
    [H, W, K] = size(Img);
    t = t+1;
end

Lab = ones(Wnum, 1);
[Wlabel, accuracy, weight] = svmpredict(Lab, Whog, hog_model32);

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
        if map > 0.5
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
imwrite(Img_backup, 'image_00000983_0.jpg');

toc
