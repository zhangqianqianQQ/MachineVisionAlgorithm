function [center, coeff, score, latent, area_real,level_center, oocyte_size]=Cell_orientation(segout,I0, major, u)
%% Get the inner points
addpath InsidePolyFolder
k_shrink=major./(10*u);
I0=double(I0);

[inner(:,2),inner(:,1)]=find(segout==50);
center1=(max(inner)+min(inner))./2;
[coeff,score,latent] = princomp(inner);
intensity=I0(sub2ind(size(segout), inner(:,2),inner(:,1)));
%final(sub2ind(size(final), inner(:,2),inner(:,1)))=intensity;

[boundary(:,2),boundary(:,1)]=find(segout==255);
centerlized=boundary-repmat(center1, size(boundary,1),1);
length=sqrt(sum(centerlized.^2,2));
inner_boundary=(centerlized./repmat(length,1,2)).*repmat(length-min(0.3*length, k_shrink),1,2)+repmat(center1, size(boundary,1),1);
theta=orderpoints(inner_boundary, center1, coeff);
[trash, index]=sort(theta,'ascend');
xv = [inner_boundary(index,1) ; inner_boundary(index(1),1)]; yv = [inner_boundary(index,2) ; inner_boundary(index(1),2)];
IN = insidepoly(inner(:,1),inner(:,2), xv,yv);



%% get the orientation and benchmark lines
[center]=mean(inner);
intensity_IN=intensity(IN);
index1=score(IN,1)>0;
index2=score(IN,1)<0;
if mean(intensity_IN(index1))<mean(intensity_IN(index2))
    coeff(:,1)=-coeff(:,1);
    score(:,1)=-score(:,1);
end
if dot(cross([coeff(:,1);0],[coeff(:,2);0]),[0,0,1]')<0
    coeff(:,2)=-coeff(:,2);
    score(:,2)=-score(:,2);
end
[AA1, BB]=sort(score(:,1),'ascend');

area30=max(max(score(BB(1:floor(0.3*numel(BB))),1)));
area50=max(max(score(BB(1:floor(0.5*numel(BB))),1)));
area70=max(max(score(BB(1:floor(0.7*numel(BB))),1)));

area30_plot=[area30,0]*inv(coeff);
area50_plot=[area50,0]*inv(coeff);
area70_plot=[area70,0]*inv(coeff);

%% Learn the real boundary
[level_center]=compute_skeleton_pc([inner(IN,:),double(intensity(IN))],score(IN,1),30,0.1);



figure;
imshow(I0);
hold on
scatter(inner_boundary(:,1),inner_boundary(:,2),20,'bo','filled')
hold on
scatter(boundary(:,1),boundary(:,2),20,'ro','filled')
hold on
scatter(center1(1), center1(2), 100,'ro','filled')
hold on
scatter(level_center(1,:), level_center(2,:),60,'go','filled')
hold on
for i=1:5:size(level_center,2)
text(level_center(1,i), level_center(2,i),num2str(i),'FontSize',40,'color', 'r');
end
title('Skeleton')
figure;
bar(level_center(3,:));
title('Intensity along the skeletion')

s = movingstd(level_center(3,:),4,'backward');
% figure
% bar(s);
% title('The middle line and the moving standard deviation to detect the optimal boundary')

%kk=input('please input the number for possible edge \n');
kk=find(level_center(3,:)~=0, 1)-1;
length1=level_center_length(level_center(:, 1:kk),2);
length2=level_center_length(level_center,2);



area_real=level_center([1:2],kk);

figure; h1=imshow(segout); hold on; h2=imshow(I0); set(h2, 'AlphaData', 0.5); title('outlined original image');
hold on
scatter(center(1), center(2),100, 'ro','filled')
hold on
%plot([center(1)-sqrt(latent(1))*coeff(1,1),center(1)+sqrt(latent(1))*coeff(1,1)],...
%   [center(2)-sqrt(latent(1))*coeff(2,1),center(2)+sqrt(latent(1))*coeff(2,1)],'g--','linewidth',4)

quiver(center(1)-sqrt(latent(1))*coeff(1,1),center(2)-sqrt(latent(1))*coeff(2,1),...
    2*sqrt(latent(1))*coeff(1,1), 2*sqrt(latent(1))*coeff(2,1),'g-','linewidth',2)
% hold on
% plot([area30_plot(1)+center(1)-3*sqrt(latent(2))*coeff(1,2),area30_plot(1)+center(1)+3*sqrt(latent(2))*coeff(1,2)],...
%     [area30_plot(2)+center(2)-3*sqrt(latent(2))*coeff(2,2),area30_plot(2)+center(2)+3*sqrt(latent(2))*coeff(2,2)],'b--','linewidth',4)
% 
% hold on
% plot([area50_plot(1)+center(1)-3*sqrt(latent(2))*coeff(1,2),area50_plot(1)+center(1)+3*sqrt(latent(2))*coeff(1,2)],...
%     [area50_plot(2)+center(2)-3*sqrt(latent(2))*coeff(2,2),area50_plot(2)+center(2)+3*sqrt(latent(2))*coeff(2,2)],'c--','linewidth',4)
% 
% hold on
% plot([area70_plot(1)+center(1)-3*sqrt(latent(2))*coeff(1,2),area70_plot(1)+center(1)+3*sqrt(latent(2))*coeff(1,2)],...
%     [area70_plot(2)+center(2)-3*sqrt(latent(2))*coeff(2,2),area70_plot(2)+center(2)+3*sqrt(latent(2))*coeff(2,2)],'r--','linewidth',4)
% hold on
% 
% plot([area_real(1)-3*sqrt(latent(2))*coeff(1,2),area_real(1)+3*sqrt(latent(2))*coeff(1,2)],...
%     [area_real(2)-3*sqrt(latent(2))*coeff(2,2),area_real(2)+3*sqrt(latent(2))*coeff(2,2)],'y--','linewidth',4)
title('green arrow points to anterior')

fprintf('This oocyte has size  %4.2f in percentage, and the length of the oocyte region is %4.2f in percentage \n',...
numel(find(score(:,1)<(area_real'-center)*coeff(:,1)))./numel(score(:,1))*100,length1./length2*100)
 
oocyte_size=numel(find(score(:,1)<(area_real'-center)*coeff(:,1)))./numel(score(:,1))*100;
figure;
imshow(I0);
hold on
scatter(inner_boundary(:,1),inner_boundary(:,2),20,'bo','filled')
hold on
scatter(boundary(:,1),boundary(:,2),20,'ro','filled')
hold on
scatter(center1(1), center1(2), 100,'ro','filled')
hold on
scatter(level_center(1,:), level_center(2,:),60,'go','filled')
hold on
for i=1:5:size(level_center,2)
text(level_center(1,i), level_center(2,i),num2str(i),'FontSize',15,'color', 'r');
hold on
plot([area_real(1)-3*sqrt(latent(2))*coeff(1,2),area_real(1)+3*sqrt(latent(2))*coeff(1,2)],...
    [area_real(2)-3*sqrt(latent(2))*coeff(2,2),area_real(2)+3*sqrt(latent(2))*coeff(2,2)],'y--','linewidth',4)

end
title('Detected boundary of oocyte in yellow')