function [data_noise]=outlier_generation_new  (data)
X_P=data;
%X_P=data;
dim=size(X_P,1);
inliers=size(X_P,2);
%Num_outliers=550;
Num_outliers=inliers/2;
outlier = zeros(Num_outliers,dim);
if dim==2
    X1=X_P(1,:);
    Y1=X_P(2,:);
x_min=min(X1);x_max=max(X1);
x_avg=(x_min+x_max)/2;
y_min=min(Y1);y_max=max(Y1);
y_avg=(y_min+y_max)/2;
const=1;
x_range=const*(x_max-x_min);
y_range=const*(y_max-y_min);

% outlier(1:Num_outliers,1) = rand(Num_outliers,1)*x_range;%-(abs(x_range));
% outlier(1:Num_outliers,2) = rand(Num_outliers,1);%-(abs(y_range));

% outlier(1:Num_outliers,1) =  x_min + rand(Num_outliers,1)*x_range;%-(abs(x_range));
% outlier(1:Num_outliers,2) =  y_min + rand(Num_outliers,1)*y_range;%-(abs(y_range));

outlier(1:Num_outliers,1) =  (-abs(x_range) + rand(Num_outliers,1)*x_range*2)/1.5;
outlier(1:Num_outliers,2) =  (-abs(y_range) +  rand(Num_outliers,1)*y_range*2)/1.5;

% outlier(1:Num_outliers,1) =  -abs(x_range) + rand(Num_outliers,1)*x_range*2;
% outlier(1:Num_outliers,2) =  -abs(y_range) +  rand(Num_outliers,1)*y_range*2;

outlier=outlier';

%outliers_correction;
%outlier=outlier_new;
Num_outliers=size(outlier,2);

figure;
plot(X_P(1,:), X_P(2,:), 'b.');
hold on; 
plot(outlier(1,:), outlier(2,:),'m.'); 
xlabel('x');
ylabel('y');
%axis equal
X_P_outliers=[X_P(1,:),outlier(1,:);X_P(2,:),outlier(2,:)];
end

if dim==3
    X1=X_P(1,:);
    Y1=X_P(2,:);
    Z1=X_P(3,:);
x_min=min(X1);x_max=max(X1);
x_avg=(x_min+x_max)/2;
y_min=min(Y1);y_max=max(Y1);
y_avg=(y_min+y_max)/2;
z_min=min(Z1);z_max=max(Z1);
z_avg=(z_min+z_max)/2;

const=1;
x_range=const*(x_max-x_min);
y_range=const*(y_max-y_min);
z_range=const*(z_max-z_min);


% outlier(1:Num_outliers,1) = rand(Num_outliers,1)*x_range;%-(abs(x_range));
% outlier(1:Num_outliers,2) = rand(Num_outliers,1);%-(abs(y_range));

% outlier(1:Num_outliers,1) =  x_min + rand(Num_outliers,1)*x_range;%-(abs(x_range));
% outlier(1:Num_outliers,2) =  y_min + rand(Num_outliers,1)*y_range;%-(abs(y_range));

outlier(1:Num_outliers,1) =  (-abs(x_range) + rand(Num_outliers,1)*x_range*2)/1.5;
outlier(1:Num_outliers,2) =  (-abs(y_range) +  rand(Num_outliers,1)*y_range*2)/1.5;
outlier(1:Num_outliers,3) =  (-abs(z_range) +  rand(Num_outliers,1)*z_range*2)/1.5;

% outlier(1:Num_outliers,1) =  -abs(x_range) + rand(Num_outliers,1)*x_range*2;
% outlier(1:Num_outliers,2) =  -abs(y_range) +  rand(Num_outliers,1)*y_range*2;

outlier=outlier';

%outliers_correction;
%outlier=outlier_new;
Num_outliers=size(outlier,2);

figure;
plot3(X_P(1,:), X_P(2,:), X_P(3,:), 'b.');
hold on; 
plot3(outlier(1,:), outlier(2,:), outlier(3,:), 'b.'); 
xlabel('x');
ylabel('y');
zlabel('y');
%axis equal
X_P_outliers=[X_P(1,:),outlier(1,:);X_P(2,:),outlier(2,:); X_P(3,:),outlier(3,:)];
end

data_noise=X_P_outliers;

