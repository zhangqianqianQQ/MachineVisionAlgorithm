function img_out=GetLabelEdge(img,label,varargin)
% Generate a image with label edges,
% Input:
%    img:the input img
%    label: the class label
%    varargin{1}: edge color
% Output:
%    img_with_edge: output image with color edge
% 2016-10-23, jlfeng
[nr,nc,nd]=size(img);
if (size(label,1)~=nr || size(label,2)~=nc)
    error('Input img and label have different size.')
end
if (nd==1)
    img_r=img;
    img_g=img;
    img_b=img;
elseif (nd==3)
    img_r=img(:,:,1);
    img_g=img(:,:,2);
    img_b=img(:,:,3);
end

if (nargin<3)
    edge_color=[255,0,0];
else
    edge_color=varargin{1};
end

label_pad=ImgPad(label,2,0,1);
label_grad=abs(label-label_pad(1:nr,2:nc+1))+abs(label-label_pad(3:nr+2,2:nc+1)) ...
   +abs(label -label_pad(2:nr+1,1:nc))+abs(label-label_pad(2:nr+1,3:nc+2));

idx=label_grad>0;
img_r(idx)=edge_color(1);
img_g(idx)=edge_color(2);
img_b(idx)=edge_color(3);

img_out=cat(3,img_r,img_g,img_b);

