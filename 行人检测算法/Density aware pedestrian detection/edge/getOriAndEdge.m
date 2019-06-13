function [edge_image,angle_map,phase_map,edge_mag] = getOriAndEdge(Fo,Fe,edgeRange)

if (~exist('edgeRange'))
    edgeRange=[eps;1];
else
    if(max(size(edgeRange))==1)
        edgeRange=[edgeRange;1];
    end
end

[r c fn]=size(Fo);

mFo = Fo.^2;
mFe = Fe.^2;
mag_all = sqrt(mFo + mFe);
[max_mag,max_id]=max(mag_all,[],3);
mFo = max(sqrt(mFo),[],3);
mFe = max(sqrt(mFe),[],3);

ori_unit = pi/fn;
theta = fn:-1:1;
theta =theta*ori_unit - ori_unit/2;
theta=theta(:);

max_realpart=zeros(r,c);
max_imagepart=zeros(r,c);
for i=1:r
    for j=1:c
        max_imagepart(i,j)=Fo(i,j,max_id(i,j));
        max_realpart(i,j)=Fe(i,j,max_id(i,j));
    end
end

angle_map=theta(max_id);

angle_map=angle_map + pi.*(max_imagepart<0);

angle_map = mod(angle_map,2*pi);
edge_mag  = max_mag;
mm_mag  = max(max_mag(:))*edgeRange;
mm_mag  = max_mag>=mm_mag(1) & max_mag<=mm_mag(2);

phase_map = (max_realpart>eps) - (max_realpart<-eps);
he = mm_mag&[phase_map(:,2:end)~=phase_map(:,1:end-1),zeros(r,1)];
ve = mm_mag&[phase_map(2:end,:)~=phase_map(1:end-1,:);zeros(1,c)];

edge_mask = he|ve;

edge_image = max_mag.*edge_mask;
