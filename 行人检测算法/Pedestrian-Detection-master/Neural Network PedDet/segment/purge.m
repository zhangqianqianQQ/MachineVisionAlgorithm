%%
% purge function
function [ newcen] = purge( binimg )
%UNTITLED2 Summary of this function goes here
%   eliminate duplicate detections
[h, w] = size(binimg);
cen = regionprops(binimg, 'centroid');
cens = cat(1, cen.Centroid);
cenx = floor(cens);

noc = size(cenx, 1);  %number of components
area = zeros(noc, 1);
cordinates = zeros(4, noc); %store the rectangles
% use a set data structure to store the relationships
cover = cell(1, noc);
% imshow(binimg)
% hold on
% form window and calculate the areas
for i = 1 : noc
    ptx = cenx(i, 1);
    pty = cenx(i, 2);
    
    lb = max(ptx - 15, 1);      %left bound
    rb = min(ptx + 14, w);      %right bound
    ub = max(pty - 30, 1);      %top
    db = min(pty + 29, h);      %bottom
    
    % check duplicate
    for j = 1 : noc
        if (j == i) 
            continue;
        else
            cx = cenx(j, 1);
            cy = cenx(j, 2);
            if (cx <= rb && cx >= lb && cy >= ub && cy <= db)
                cover{i} = [cover{i}; j];
            end
        end
    end
    
    %store
%     plot(ptx,pty, 'r*')
    cordinates(:, i) = [lb;rb;ub;db];
    window = binimg(ub:db, lb:rb);
    area(i) = sum(window(:));
    
    
end

%for output
newarea = [];

newcen = [];

% remove dup
for i = 1 : noc
    list = cover{i};
    ar = area(i);
    flag = 2;           %if 1 this is the largest one, 0 not
    for j = 1 : length(list)
        if (ar < area(list(j)))
            flag = flag - 1;
            if (flag == 0)
               break;
            end
        end
    end
    
    
    if (flag)

        newcen = [newcen; cenx(i, :)];
    end
end


end

