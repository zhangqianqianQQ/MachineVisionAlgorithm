function max_tree=GetMaxTree(img,graylevel_list)
% Construct the Max-Tree for extracting Attribute Profile
%2016-10-20, jlfeng
[nr,nc,nd]=size(img);
if (nd>1)
    error('Scalar value img is expected.');
end
num_obj=1;
label_obj=ones(nr,nc);
max_tree=struct('level',0,'area',0,'std',[],'hu_moment1',[],'idx_pix',cell(1,1000),'idx_parent',[],'idx_children',[]);
max_tree(1).level=1;
max_tree(1).area=nr*nc;
max_tree(1).std=0;
max_tree(1).hu_moment1=1;
% max_tree(1)={struct('level',1,'area',nr*nc,'idx_pix',[],'idx_parent',[],'idx_children',[])};
for kk=2:length(graylevel_list)
    img_bw=img>graylevel_list(kk);
    [label_cc,num_cc]=bwlabel(img_bw,4);
    props_cc=regionprops(label_cc,img,'Area','PixelIdxList','PixelList','PixelValues');
    if num_cc>0
        for ll=1:num_cc
            idx_pix=props_cc(ll).PixelIdxList;
            idx_parent=label_obj(idx_pix(1));
            if max_tree(idx_parent).area>props_cc(ll).Area&&props_cc(ll).Area>9
                num_obj=num_obj+1;
                max_tree(num_obj).level=kk;
                max_tree(num_obj).area=props_cc(ll).Area;
                max_tree(num_obj).std=std(props_cc(ll).PixelValues);
                max_tree(num_obj).hu_moment1=GetHuM1(props_cc(ll).PixelList,props_cc(ll).PixelValues);
                max_tree(num_obj).idx_pix=idx_pix;
                max_tree(num_obj).idx_parent=idx_parent;
                max_tree(idx_parent).idx_children=union(max_tree(idx_parent).idx_children,num_obj);
                label_obj(idx_pix)=num_obj;
            end
        end
    end
end
max_tree=max_tree(1:num_obj);

function  hu_moment1=GetHuM1(pixel_list,pixel_values)
% Compute the first Hu Invariant Moment
m00=sum(pixel_values);
m10=sum(pixel_list(:,1).*pixel_values);
m01=sum(pixel_list(:,2).*pixel_values);
x0=m10./m00;y0=m01./m00;
u00=m00;
u20=sum((pixel_list(:,1)-x0).^2.*pixel_values);
u02=sum((pixel_list(:,2)-y0).^2.*pixel_values);
y20=u20/u00/u00;
y02=u02/u00/u00;
hu_moment1=y20+y02;

