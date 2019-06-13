function [data,data_clean]=Hemisphere_plane
%pctest7.m
%Generates ground truth and noisy point clouds for hemisphere on a plane

%No. of points in each of the parts
npoints=1200;
psize=3;

%Noise level
sigma=0.025;
sigma=0.06;
sigma=0.03;
sigma=0.015;
%sigma=0;
P=zeros(npoints,4);

R=sqrt(1/(3*pi));
R2=R^2;

for n=1:npoints
	x=rand()-0.5; y=rand()-0.5;
	x2=x^2; y2=y^2;
	if (x2+y2)>R2
		P(n,:)=[x y 0 1];
	else
		theta=2*pi*rand();
		phi=0.5*pi*rand();
		x=R*cos(theta)*sin(phi);
		y=R*sin(theta)*sin(phi);
		z=R*cos(phi);
		P(n,:)=[x y z 0.5];
	end
end

fileID=fopen('pc_hemi_gt.asc','w');
for n=1:npoints
	fprintf(fileID,'%f %f %f %f\n',P(n,1),P(n,2),P(n,3),P(n,4));	
end
fclose(fileID);
data_clean=P(:,1:3);
P(:,1:3)=P(:,1:3)+sigma*randn(npoints,3);

fileID=fopen('pc_hemi_noise.asc','w');
for n=1:npoints
	fprintf(fileID,'%f %f %f %f\n',P(n,1),P(n,2),P(n,3),P(n,4));
end
fclose(fileID);

fileID=fopen('pc_hemi_gt.asc','r');
Porig=textscan(fileID,'%f %f %f %f');
fclose(fileID);

np=max(size(Porig{1}(:)));
Pgt=zeros(np,4);
Pgt(:,1)=Porig{1}(:);
Pgt(:,2)=Porig{2}(:);
Pgt(:,3)=Porig{3}(:);
Pgt(:,4)=Porig{4}(:);

fileID=fopen('pc_hemi_noise.asc','r');
Porig=textscan(fileID,'%f %f %f %f');
fclose(fileID);

np=max(size(Porig{1}(:)));
Pnoise=zeros(np,4);
Pnoise(:,1)=Porig{1}(:);
Pnoise(:,2)=Porig{2}(:);
Pnoise(:,3)=Porig{3}(:);
Pnoise(:,4)=Porig{4}(:);

figure(1)
scatter3(Pgt(:,1),Pgt(:,2),Pgt(:,3),psize,Pgt(:,4),'filled')
xlabel('x'); ylabel('y'); zlabel('z');
colormap(jet)
colorbar
title('Ground Truth Point Cloud')
axis equal
axis([-.55 .55 -.55 .55 -0.05 0.4])

figure(2)
scatter3(Pnoise(:,1),Pnoise(:,2),Pnoise(:,3),psize,Pnoise(:,4),'filled')
xlabel('x'); ylabel('y'); zlabel('z');
colormap(jet)
colorbar
title('Noisy Point Cloud')
axis equal
axis([-.55 .55 -.55 .55 -0.05 0.4])

%Calculate overall point cloud error

%Distance of each point from the manifold
dist=zeros(np,1);
for n=1:np
	x0=Pnoise(n,1); y0=Pnoise(n,2); z0=Pnoise(n,3);
	r0=sqrt(x0^2+y0^2+z0^2); theta0=acos(z0/r0); phi0=atan(y0/x0);
	
	rxy=sqrt(x0^2+y0^2);
	if rxy>R
		dist(n)=z0;
	else
		dist(n)=abs(r0-R);
	end
	
end

pc_error=mean(dist)
data=Pnoise';
data=data(1:3,:);
figure;plot3(data(1,:),data(2,:),data(3,:))
% fileID=fopen('feats_denoised_hemisphere k=30.asc','r');
% Porig=textscan(fileID,'%f %f %f %f');
% fclose(fileID);
% 
% np=max(size(Porig{1}(:)));
% Pdenoised=zeros(np,4);
% Pdenoised(:,1)=Porig{1}(:);
% Pdenoised(:,2)=Porig{2}(:);
% Pdenoised(:,3)=Porig{3}(:);
% Pdenoised(:,4)=Porig{4}(:);
% 
% figure(3)
% scatter3(Pdenoised(:,1),Pdenoised(:,2),Pdenoised(:,3),psize,Pdenoised(:,4),'filled')
% xlabel('x'); ylabel('y'); zlabel('z');
% colormap(jet)
% colorbar
% title('Denoised Point Cloud')
% axis equal
% axis([-.55 .55 -.55 .55 -0.05 0.4])
% 
% %Calculate overall point cloud error
% 
% %Distance of each point from the manifold
% dist=zeros(np,1);
% 
% tic
% R2=R^2;
% for n=1:np
% 	x0=Pdenoised(n,1); y0=Pdenoised(n,2); z0=Pdenoised(n,3);
% 	r2xy=x0^2+y0^2;
% 	r0=sqrt(r2xy+z0^2); theta0=acos(z0/r0); phi0=atan(y0/x0);
% 	
% 	
% 	if r2xy>R2
% 		dist(n)=z0;
% 	else
% 		dist(n)=abs(r0-R);
% 	end
% 	
% end
% 
% pc_error_denoised=mean(dist)
% 
% toc
% 
% 
% 
% 
% 
% 
