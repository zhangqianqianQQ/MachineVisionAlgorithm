function  length=level_center_length(level_center,k)

length=0;

for i=2:size(level_center,2)
    length=length+norm(level_center(1:k,i)-level_center(1:k,i-1));
end