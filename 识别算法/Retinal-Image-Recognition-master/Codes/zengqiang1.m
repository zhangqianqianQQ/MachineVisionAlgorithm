% Retinal Blood Vessel Segmentation Test
clc; clear all; close all;
I = imread('D:\MATLAB源程序\DRIVE\test\images\02_test.tif');%D:\MATLAB源程序\CLRIS\CLRIS001.jpg');
figure(1), imshow(I),title('original image');
% Resize image for easier computation
[len,wid,channel]=size(I);
B = imresize(I, [len/4 wid/4]); %简化计算量
% B = imresize(I, [600 600]);
 
% Convert RGB to Gray via PCA
lab = rgb2lab(im2double(B));
%get wlab's method1
% f = 0;
% A_F=cat(3,1-f,f/2,f/2);
% B_F=bsxfun(@times,A_F,lab);
% wlab = reshape(B_F,[],3);
 
%get wlab's method2,same to method1
lab(:,:,2)=0;lab(:,:,3)=0;
wlab = reshape(lab,[],3); %向量化
 
[C,S] = pca(wlab); %主成分分析
S = reshape(S,size(lab));%S为PCA后新坐标下的矩阵
S = S(:,:,1);
gray = (S-min(S(:)))./(max(S(:))-min(S(:))); %归一化
 
%% Contrast Enhancment of gray image using CLAHE
J = adapthisteq(gray,'numTiles',[8 8],'nBins',256); %CLAHE直方图均衡
 
%% Background Exclusion
% Apply Average Filter
h = fspecial('average', [11 11]);
JF = imfilter(J, h);
% Take the difference between the gray image and Average Filter
Z = imsubtract(JF, J); %相减得到高频细节信息

% for ii = 1:6; 
%     axes(ha(ii)); 
%     plot(randn(10,ii)); 
% end
%set(ha(1:4),'XTickLabel',''); 
%set(ha,'YTickLabel','')
%subplot('position',[0,0,.475,.475]);
figure(2),

%ha = tight_subplot(2,3,[.001 .001],[.1 .01],[.01 .01])
subplot(1,1,1),imshow(JF);%,title('CLAHE后均值滤波');
subplot(1,1,1), imshow(Z);%,title('CLAHE后均值滤波差值');
%% Threshold using the IsoData Method
%level=isodata(Z) ; % threshold level
level = graythresh(Z);
%% Convert to Binary
BW = im2bw(Z, level-0.008);
%% Remove small pixels
BW2 = bwareaopen(BW,35); %删除二值图像BW中面积小于50的对象，默认情况下使用8邻域，参数可调
figure(3),
subplot(2,2,1),imshow(BW);%,title('BW');
%figure(4), 
subplot(2,2,2),imshow(BW2);%,title('BW2_1');
%% Overlay
BW2 = imcomplement(BW2); %对图像数据进行取反运算（可以实现底片效果）
out = imoverlay(B, BW2, [0 0 0]); %底片整体颜色设置为黑色
%figure(5), 
%out = bwareaopen(out,35);
subplot(2,2,3),imshow(out);%,title('最终结果');
%figure(6), 
subplot(2,2,4),imshow(BW2);%,title('BW2_2');
out1=rgb2gray(out);
[lm,ln]=size(out1);
for i=1:lm
   for j=1:ln
       if out1(i,j)>70
          out1(i,j)=255;
       end
   end
end
%out1 = bwareaopen(out1,10);
figure(7), 
subplot(1,1,1),imshow(out1);
imwrite(out1,'eye1.tif'); 
%ha = tight_subplot(2,3,[.01 .03],[.1 .01],[.01 .01])

function ha = tight_subplot(Nh, Nw, gap, marg_h, marg_w)

% tight_subplot creates "subplot" axes with adjustable gaps and margins
%
% ha = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
%
%   in:  Nh      number of axes in hight (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width 
%        marg_h  margins in height in normalized units (0...1)
%                   or [lower upper] for different lower and upper margins 
%        marg_w  margins in width in normalized units (0...1)
%                   or [left right] for different left and right margins 
%
%  out:  ha     array of handles of the axes objects
%                   starting from upper left corner, going row-wise as in
%                   going row-wise as in
%
%  Example: ha = tight_subplot(3,2,[.01 .03],[.1 .01],[.01 .01])
%           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

% Pekka Kumpulainen 20.6.2010   @tut.fi
% Tampere University of Technology / Automation Science and Engineering


if nargin<3; gap = .02; end
if nargin<4 || isempty(marg_h); marg_h = .05; end
if nargin<5; marg_w = .05; end

if numel(gap)==1; 
    gap = [gap gap];
end
if numel(marg_w)==1; 
    marg_w = [marg_w marg_w];
end
if numel(marg_h)==1; 
    marg_h = [marg_h marg_h];
end

axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;

py = 1-marg_h(2)-axh; 

ha = zeros(Nh*Nw,1);
ii = 0;
for ih = 1:Nh
    px = marg_w(1);

    for ix = 1:Nw
        ii = ii+1;
        ha(ii) = axes('Units','normalized', ...
            'Position',[px py axw axh], ...
            'XTickLabel','', ...
            'YTickLabel','');
        px = px+axw+gap(2);
    end
    py = py-axh-gap(1);
end
end