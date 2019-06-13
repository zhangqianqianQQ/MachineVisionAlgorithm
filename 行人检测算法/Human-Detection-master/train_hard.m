clear
clc

AllImg = dir('E:\学习\实习题目\行人数据集\tud-brussels-motionpairs\TUD-MotionPairs\negative\*.png');

Xslide = 16;
Yslide = 16;
Xwindow = 64;
Ywindow = 128;
leng = 1;
load hog_model32;

for i = 1:length(AllImg)
    Img = imread(['E:\学习\实习题目\行人数据集\tud-brussels-motionpairs\TUD-MotionPairs\negative\',AllImg(i).name]);
    [H, W, K] = size(Img);
    Wnum = 0;
    Location = [];
    Whog = [];
    ImgW = [];
    for j = 1:Yslide:H-Ywindow+1
        for i = 1:Xslide:W-Xwindow+1
            Wnum = Wnum+1;
            Location(Wnum,:) = [i j];
            ImgW = Img(j:j+Ywindow-1,i:i+Xwindow-1,:);
            Whog(Wnum,:) = hogcalculator(ImgW);
        end
    end
    Lab = ones(Wnum, 1);
    Wlabel = svmpredict(Lab, Whog, hog_model32);
    Human = find(Wlabel==1);
    Temp = [];
    for i = 1:length(Human)
        Temp = Location(Human(i),:);
        NegImg = Img(Temp(2):Temp(2)+Ywindow-1,Temp(1):Temp(1)+Xwindow-1,:);
        leng = leng+1;
        c = strcat('train_neg', num2str(leng));
        name = strcat(c, '.png');
        imwrite(NegImg, name);
    end
end



