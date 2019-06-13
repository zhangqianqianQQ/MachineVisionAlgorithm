 function [data4, X_P] = curves_with_angles(n1)
  
  if nargin <1
      n1=500;
  end
%4: two circles on 2D plane

% c1 = circle2D(8, 1000);
% c2 = circle2D(8, 1000) + [4*ones(1,1000); zeros(1,1000)];

c1 = circle2D(8, n1);
c2 = circle2D(8, n1) + [8*ones(1,n1); zeros(1,n1)];


%c2 = circle2D(8, 1000) + [6*ones(1,1000); zeros(1,1000)];

data4 = [c1, c2];
data4 = data4';
X_P=data4';

%curve1=find(c1(:,2)>
% s1=1800;s2=1800;
% scatter(c1(1,:),c1(2,:),s1,'r.'); 
% hold on;
% scatter(c2(1,:),c2(2,:),s2,'b.'); 
% figure;
% plot(c1(1,:),c1(2,:),'r.'); 
% hold on;
% plot(c2(1,:),c2(2,:),'b.'); 
% axis equal;
% 

%5: swiss roll (2000) and a plane (1000) + outliers
% load('swiss_roll_data.mat');
% X = X_data(:,1:2000);
% clear X_data;
% clear Y_data;
% n1 = 1000;
% plane1 = plane(45, 50, 90, n1);
% plane1(2,:) = plane1(2,:)-20;
% %data5 = [X];
% data5 = [X, plane1];
% 
% GT5 = [ones(1,5000), 2*ones(1,1000)];
% % % % % n_out = 100;
% % % % % outlier = zeros(n_out,3);
% % % % % outlier(1:50,1) = rand(50,1)*40-20;
% % % % % outlier(1:25,2) = rand(25,1)*10+20;
% % % % % outlier(26:50,2) = rand(25,1)*10-20;
% % % % % outlier(51:75,1) = rand(25,1)*10+15;
% % % % % outlier(76:100,1) = rand(25,1)*10-20;
% % % % % outlier(51:100,2) = rand(50,1)*30-15;
% % % % % outlier(:,3) = rand(n_out,1)*50;
% % % % % data5 = [data5; outlier];
% figure
% plot3(X(1,:), X(2,:),X(3,:), 'r.');
% hold on; 
% plot3(plane1(1,:), plane1(2,:),plane1(3,:), 'b.'); 
% view([-27 -38 453]);
% % % hold on; plot3(outlier(:,1), outlier(:,2),outlier(:,3), 'm.'); 





% The function is to generate a circle centered at (0,0,0) with radius r
% ====== input: r: radius; n: number of points on sphere
% ====== output: data: 3*n matrix
%   rou: the angle to xy plane, -90 ~ 90, uniformly distributed
% theta: the angle on xy plane, 0 ~ 360, uniformly distributed

function data = circle(r, n)
rou = (rand(1,n)*180 - 90)/180*pi;
theta = rand(1,n)*360 / 180*pi;

l = r * cos(rou);
data = zeros(3,n);
data(1,:) = l.*cos(theta);
data(2,:) = l.*sin(theta);
data(3,:) = r*sin(rou);

function data = circle2D(r, n)
theta = rand(1,n)*360 / 180*pi;
theta=sort(theta);
data = zeros(2,n);
data(1,:) = r.*cos(theta);
data(2,:) = r.*sin(theta);


% theta: the plane's angle to xy plane
%     n: number of points
% width: width of the plane
%length: length of the plane
function data = plane(width, length, theta, n)
theta = theta/180*pi;
 l = rand(1,n)*length;

data = zeros(3,n);
data(1,:) = l*cos(theta);
 data(2,:) = rand(1,n)*width;

data(3,:) = l*sin(theta);


function plotplot(data)
plot3(data(1,:), data(2,:), data(3,:), 'r.');
axis equal;

% add Gaussian noise to the data, scale is the standard deviation of Gaussian 
function data = addnoise(data, scale)
% Number of point
[d, n] = size(data);
noise = scale * randn(d,n);
data = data + noise;





 
    
    
    
    
    
    
    
    
    
    