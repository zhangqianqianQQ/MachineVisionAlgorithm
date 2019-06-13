%pctest6.m
%Generates ground truth and noisy point clouds for cuboid on a plane


%No. of points in each of the parts
npoints=500;
psize=3;

%Noise level
sigma=0.025;
%sigma=0;
Px1=zeros(npoints,4);
Px2=Px1; Py1=Px1; Py2=Px1; Pz1=Px1; Pz2=Px1;

Py1=[rand(npoints,1)-0.5 0.5*ones(npoints,1) rand(npoints,1) ones(npoints,1)];
Py2=[rand(npoints,1)-0.5 -0.5*ones(npoints,1) rand(npoints,1) ones(npoints,1)];

Px1=[0.5*ones(npoints,1) rand(npoints,1)-0.5 rand(npoints,1) ones(npoints,1)];
Px2=[-0.5*ones(npoints,1) rand(npoints,1)-0.5 rand(npoints,1) ones(npoints,1)];

Pz1=[rand(npoints,1)-0.5 rand(npoints,1)-0.5 ones(npoints,1) ones(npoints,1)];

n=0;
while n<npoints
	x=2*(rand()-0.5); y=2*(rand()-0.5);
	if x>0.5 | x<-0.5 | y>0.5 | y<-0.5
		n=n+1;
		Pz2(n,:)=[x y 0 0.5];
	end
end

fileID=fopen('pc_box_gt.asc','w');
for n=1:npoints
	fprintf(fileID,'%f %f %f %f\n',Px1(n,1),Px1(n,2),Px1(n,3),Px1(n,4));
	fprintf(fileID,'%f %f %f %f\n',Px2(n,1),Px2(n,2),Px2(n,3),Px2(n,4));
	
	fprintf(fileID,'%f %f %f %f\n',Py1(n,1),Py1(n,2),Py1(n,3),Py1(n,4));
	fprintf(fileID,'%f %f %f %f\n',Py2(n,1),Py2(n,2),Py2(n,3),Py2(n,4));	
	
	fprintf(fileID,'%f %f %f %f\n',Pz1(n,1),Pz1(n,2),Pz1(n,3),Pz1(n,4));
	fprintf(fileID,'%f %f %f %f\n',Pz2(n,1),Pz2(n,2),Pz2(n,3),Pz2(n,4));		
end
fclose(fileID);

Px1(:,1:3)=Px1(:,1:3)+sigma*randn(npoints,3);
Px2(:,1:3)=Px2(:,1:3)+sigma*randn(npoints,3);

Py1(:,1:3)=Py1(:,1:3)+sigma*randn(npoints,3);
Py2(:,1:3)=Py2(:,1:3)+sigma*randn(npoints,3);

Pz1(:,1:3)=Pz1(:,1:3)+sigma*randn(npoints,3);
Pz2(:,1:3)=Pz2(:,1:3)+sigma*randn(npoints,3);

fileID=fopen('pc_box_noise.asc','w');
for n=1:npoints
	fprintf(fileID,'%f %f %f %f\n',Px1(n,1),Px1(n,2),Px1(n,3),Px1(n,4));
	fprintf(fileID,'%f %f %f %f\n',Px2(n,1),Px2(n,2),Px2(n,3),Px2(n,4));
	
	fprintf(fileID,'%f %f %f %f\n',Py1(n,1),Py1(n,2),Py1(n,3),Py1(n,4));
	fprintf(fileID,'%f %f %f %f\n',Py2(n,1),Py2(n,2),Py2(n,3),Py2(n,4));	
	
	fprintf(fileID,'%f %f %f %f\n',Pz1(n,1),Pz1(n,2),Pz1(n,3),Pz1(n,4));
	fprintf(fileID,'%f %f %f %f\n',Pz2(n,1),Pz2(n,2),Pz2(n,3),Pz2(n,4));		
end
fclose(fileID);

fileID=fopen('pc_box_gt.asc','r');
Porig=textscan(fileID,'%f %f %f %f');
fclose(fileID);

np=max(size(Porig{1}(:)));
Pgt=zeros(np,4);
Pgt(:,1)=Porig{1}(:);
Pgt(:,2)=Porig{2}(:);
Pgt(:,3)=Porig{3}(:);
Pgt(:,4)=Porig{4}(:);

fileID=fopen('pc_box_noise.asc','r');
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
axis([-1.05 1.05 -1.05 1.05 -0.05 1.05])

figure(2)
scatter3(Pnoise(:,1),Pnoise(:,2),Pnoise(:,3),psize,Pnoise(:,4),'filled')
xlabel('x'); ylabel('y'); zlabel('z');
colormap(jet)
colorbar
title('Noisy Point Cloud')
axis equal
axis([-1.05 1.05 -1.05 1.05 -0.05 1.05])

%Calculate overall point cloud error

%Distance of each point from the manifold
dist=zeros(np,1);
Pproj=zeros(5,3);
for n=1:np
	x0=Pnoise(n,1); y0=Pnoise(n,2); z0=Pnoise(n,3);
	Pproj(1,:)=[x0 0.5 z0];
	Pproj(2,:)=[x0 -0.5 z0];
	Pproj(3,:)=[0.5 y0 z0];
	Pproj(4,:)=[-0.5 y0 z0];
	
	if x0>0.5 | x0<-0.5 | y0>0.5 | y0<-0.5 | z0>1
		Pproj(5,:)=[x0 y0 0];
	else
		Pproj(5,:)=[x0 y0 1];
	end
	
	Pdiff=abs(Pproj-ones(5,1)*Pnoise(n,1:3));
	dist(n)=min(max(Pdiff'));
end

pc_error=mean(dist)

data=Pnoise';
data=data(1:3,:);



% fileID=fopen('feats_denoised_box k=20.asc','r');
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
% axis([-1.05 1.05 -1.05 1.05 -0.05 1.05])
% 
% %Calculate overall point cloud error
% 
% %Distance of each point from the manifold
% dist=zeros(np,1);
% Pproj=zeros(5,3);
% 
% tic
% 
% for n=1:np
% 	x0=Pdenoised(n,1); y0=Pdenoised(n,2); z0=Pdenoised(n,3);
% 	Pproj(1,:)=[x0 0.5 z0];
% 	Pproj(2,:)=[x0 -0.5 z0];
% 	Pproj(3,:)=[0.5 y0 z0];
% 	Pproj(4,:)=[-0.5 y0 z0];
% 	
% 	if x0>0.5 | x0<-0.5 | y0>0.5 | y0<-0.5 | z0>1
% 		Pproj(5,:)=[x0 y0 0];
% 	else
% 		Pproj(5,:)=[x0 y0 1];
% 	end
% 	
% 	Pdiff=abs(Pproj-ones(5,1)*Pdenoised(n,1:3));
% 	dist(n)=min(max(Pdiff'));
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
