function rect = genbinarymap(imglabel, salmap)
imx = processing(salmap); 
imx = imresize(imx,[size(imglabel,1) size(imglabel,2)]);
stats = regionprops(imx, 'BoundingBox');
rect = stats.BoundingBox;
figure;
imshow(imglabel);
hold on;
rectangle('Position',rect,'EdgeColor','r', 'LineWidth',4);
F = getframe;
imwrite(F.cdata, 'Object.jpg', 'jpg');
hold off; 

% binarization
function X = processing(X, minarea)
level = graythresh(X);
X1 = im2bw(X,level);
X1 = imfill(X1,'holes');
if nargin<2,
    minarea = length(find(X1))*0.01;   %
end
BW1 = bwlabel(X1,4);
nregions = max(BW1(:));
for i = 1:nregions,
    idxi = logical(BW1==i);
    idxi_n = find(BW1==i);    
    %X_gain=sum(X(idxi))/length(idxi_n);
    X_gain=max(X(idxi));
    if i ==1
        X_gain_old=X_gain;
        idxi_n_old=idxi_n;
    else
        if X_gain > X_gain_old
            X1(idxi_n_old) = 0;
            X_gain_old=X_gain;
            idxi_n_old=idxi_n;
        else
            X1(idxi_n) = 0;
        end
    end
end
X=X1;






