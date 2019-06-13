%%
% resize and detect
function [ winr ] = resndet( im,model,sz1,sz2,k)

[h, w, ~] = size(im);
% transform h to around 80
img = rgb2gray(im);
r = h/((k/3)*sz1);
imr = imresize(img, 1/r);
imb = segment(imr);
chop = chopp(imb,sz1,sz2);
cens = purge(chop);
cenr = cens * r;
% window size has changed 
hw = floor(sz1 * r);
ww = floor(sz1 * r);
hw = hw - mod(hw, 2);
ww = ww - mod(ww, 2);
winr = remark(im, cenr, sz1, sz2 ,r,model);

end

