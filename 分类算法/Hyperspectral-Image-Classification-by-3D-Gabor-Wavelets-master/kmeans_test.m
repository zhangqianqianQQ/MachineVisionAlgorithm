%开题报告中knn算法的演示图片

a=[rand(1,30)*3,rand(1,40)*3+3,rand(1,30)*3+6];
b=[rand(1,30)*3,rand(1,40)*3+3,rand(1,30)*3+6];
for k=1:100
    m(k,:)=[a(k),b(k)];
end

[IDC]=kmeans(m,3);
figure;

for k=1:100
    if(IDC(k)==1)
        x=m(k,1);
        y=m(k,2);
        plot(x,y,'.r');
        hold on;
    elseif(IDC(k)==2)
        x=m(k,1);
        y=m(k,2);
        plot(x,y,'.k');
        hold on;
    else
        x=m(k,1);
        y=m(k,2);
        plot(x,y,'.g');
        hold on;
    end
end

title('Maltab simulation for KNN algorithm');
xlabel('x');
ylabel('y');
clear all;

    