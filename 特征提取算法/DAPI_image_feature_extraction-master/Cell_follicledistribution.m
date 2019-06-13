function [distri]=Cell_follicledistribution(segout, I1,coeff, n)
if(~exist('n','var'))
    n=13;
end
[boundary(:,2),boundary(:,1)]=find(segout==255);

[fo(:,2), fo(:,1)]=find(I1==1);
theta1=orderpoints(boundary, mean(boundary), coeff);
[trash, index1]=sort(theta1,'ascend');
theta1=theta1(index1);
boundary=boundary(index1,:);

theta2=orderpoints(fo, mean(boundary), coeff);
[trash, index2]=sort(theta2,'ascend');
theta2=theta2(index2);
fo=fo(index2,:);

center=mean(boundary);
KK=500;
interval=linspace(0,2*pi,n);
inter=1:floor(n/4):n;
figure;
imshow(I1)

for i=1:n-1
    hold on
    index_boundary=find(theta1>interval(i)&theta1<=interval(i+1));
    index_focell=find(theta2>interval(i)&theta2<=interval(i+1));
    length(i)=level_center_length(boundary(index_boundary,:)',size(boundary,2));
    number_focell(i)=numel(index_focell);
    temp=coeff*[cos(interval(i));sin(interval(i))];
    if ~ismember(i, inter)
        hold on
        plot([center(1)-KK*temp(1), center(1)+KK*temp(1)],...
            [center(2)-KK*temp(2), center(2)+KK*temp(2)],'r-','linewidth',2)
    end
end

hold on
scatter(center(1), center(2),100, 'ro','filled')
hold on
quiver(center(1)-KK*coeff(1,1),center(2)-KK*coeff(2,1),...
    2*KK*coeff(1,1), 2*KK*coeff(2,1),'g-','linewidth',2)
hold on
quiver(center(1)-KK*coeff(1,2),center(2)-KK*coeff(2,2),...
    2*KK*coeff(1,2), 2*KK*coeff(2,2),'g-','linewidth',2)
distri=number_focell./length;

p=[];
for i=1:n-1
    temp=linspace(interval(i),interval(i+1),100);
    ptemp=[distri(i)*sin(temp);distri(i)*cos(temp)];
    p=[p;ptemp'];
end
p=p*coeff';

KK1=25;
figure;
scatter(p(:,2),p(:,1),'filled')
for i=1:n-1
     temp=coeff*[cos(interval(i));sin(interval(i))];
    if ~ismember(i, inter)
        hold on
        plot([-KK1*temp(1), +KK1*temp(1)],...
            [+KK1*temp(2), -KK1*temp(2)],'r-','linewidth',2)
    end
end
hold on
scatter(0, 0,100, 'ro','filled')
hold on
quiver(-KK1*coeff(1,1),KK1*coeff(2,1),...
    2*KK1*coeff(1,1), -2*KK1*coeff(2,1),'g-','linewidth',2)
hold on
quiver(-KK1*coeff(1,2),KK1*coeff(2,2),...
    2*KK1*coeff(1,2), -2*KK1*coeff(2,2),'g-','linewidth',2)
axis equal
