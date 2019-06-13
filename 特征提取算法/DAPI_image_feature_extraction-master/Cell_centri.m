function [I3, I2]=Cell_centri(I0,  coeff, latent, area_real, boundary, t5)
if(~exist('t5','var'))
    t5=.2;
end
area_right=area_real+2*t5*sqrt(latent(1))*coeff(:,1);
area_left=area_real-2*t5*sqrt(latent(1))*coeff(:,1);

[inner(:,2),inner(:,1)]=find(I0>=0);
centerlized1=inner-repmat(area_right', size(inner,1),1);
score1=centerlized1*coeff(:,1);

centerlized2=inner-repmat(area_left', size(inner,1),1);
score2=centerlized2*coeff(:,1);
I1=I0;
I1((score1.*score2)<0)=0;
I1((score1.*score2)>0)=1;
I2=I1;
figure;
imshow(I1)
hold on
h=imshow(I0);
alpha(h, 0.5)
I3=false(size(I0));




%% get rid of the part left
stats = regionprops(I0, 'Area','FilledArea','MajorAxisLength',...
    'MinorAxisLength', 'Orientation', 'Eccentricity','PixelIdxList');
AA=struct2cell(stats);
% area=zeros(1,size(AA,2));
% ratio=zeros(1,size(AA,2));
plist=cell(1,size(AA,2));
for i=1:size(AA,2)
%     area(i)=AA{1,i};
%     ratio(i)=AA{2,i}./AA{3,i};
    plist{i}=AA{7,i};
    if all(I1(plist{i})==0)
        I3(plist{i})=1;
    end
    
end
[A, B]=find(I3==1);
[IDX, D]=knnsearch(boundary, [B,A]);
index1=find(I3==1);
I3=false(size(I0));
I3(index1(D<1.5*sqrt(latent(2))))=1;


