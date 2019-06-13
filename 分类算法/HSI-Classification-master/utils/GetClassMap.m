function class_map=GetClassMap(label,cmap)
img_size=size(label);
class_map=cmap(label(:)+1,:);
class_map=reshape(class_map,[img_size(1), img_size(2),3]);
class_map=uint8(class_map);
