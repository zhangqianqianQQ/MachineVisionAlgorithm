function X_result = drawresult(labels,row,col, imageType)
% figure;
% imageType 1£ºPavia University
% imageType 2£ºIndian Pines
% imageType 3£ºSalinas
% imageType 4£ºWashington DC
% imageType 5£ºPavia Center
% imageType 6£ºKSC
num_class = max(labels(:));
if imageType==1
    palette = [216 191 216;
        0 255 0
        0 255 255
        45 138 86
        255 0 255
        255 165 0
        159 31 239
        255 0 0
        255 255 0]/255;
elseif imageType==2
    palette = [255 0 0
        0 255 0
        0 0	255
        255	255	0
        0 255 255
        255 0 255
        176 48 96
        46 139 87
        160 32 240
        255 127 80
        127 255 212
        218 112 214
        160 82 45
        127 255 0
        216 191 216
        238 0 0]/255;
elseif imageType==3
    palette = [37 58 150
        47 78 161
        56 87 166
        56 116 186
        51 181 232
        112 204 216
        119 201 168
        148 204 120
        188 215 78
        238 234 63
        246 187 31
        244 127 33
        239 71 34
        238 33 35
        180 31 35
        123 18 20]/255;
elseif imageType==4
    palette = [255	255	255
        105 185 70
        55 85 165
        240 230 20
        35 140 85
        185 80 155
        250 165 30]/255;
elseif imageType==5
   palette = [37 97 163
        44 153 60
        122 182 41
        219 36 22
        227 156 47
        227 221 223
        108 35 127
        130 67 142
        229 225 74]/255;
elseif imageType==6
    palette = [94 203 55
    255 0 255
    217 115 0
    179 30 0
    0 52 0
    72 0 0
    255 255 255
    145 132 135
    255 255 172
    255 197 80
    60 201 255
    11 63 124
    0 0 255]/255;
end

X_result = zeros(size(labels,1),3);
for i=1:num_class
    X_result(find(labels==i),1) = palette(i,1);
    X_result(find(labels==i),2) = palette(i,2);
    X_result(find(labels==i),3) = palette(i,3);
end

X_result = reshape(X_result,row,col,3);
if imageType==4
    X_result(:,:,1) = flipud(X_result(:,:,1));
    X_result(:,:,2) = flipud(X_result(:,:,2));
    X_result(:,:,3) = flipud(X_result(:,:,3));
end
% imshow(X_result);
end