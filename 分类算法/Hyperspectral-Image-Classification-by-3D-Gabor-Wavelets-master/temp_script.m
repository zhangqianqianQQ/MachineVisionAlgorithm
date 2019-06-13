%使用全部52特征的分类能力
load knn_result_gaborsel;
load svm_accuracy_sel;

knn(1,:)=sum(knn_result_gaborsel(1:3,:));
knn(2,:)=sum(knn_result_gaborsel(4:6,:));
knn(3,:)=sum(knn_result_gaborsel(7:9,:));

svm(1,:)=sum(accuracy(1:3,:));
svm(2,:)=sum(accuracy(4:6,:));
svm(3,:)=sum(accuracy(7:9,:));
knn=knn./3;
svm=svm./3;

x=[1:5];
figure;
plot(x,knn(1,:),'-*k');
hold on;
plot(x,svm(1,:),'-sr');
hold on;
plot(x,knn(2,:),'-*k');
hold on;
plot(x,knn(3,:),'-*k');
hold on;
plot(x,svm(2,:),'-sr');
hold on;
plot(x,svm(3,:),'-sr');
hold on;

title('经过特征选择后SVM与KNN的分类能力比较');
axis([1,5,0.65,1]);
set(gca,'XTickLabel',{'0.05','','0.1','','0.25','','0.5','','0.75'});
legend('knn','svm');
clear k x knn svm;