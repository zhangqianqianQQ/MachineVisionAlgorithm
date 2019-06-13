% Function to duplicate data ( to balance number of each color)
function [dt,labs]= duplicateData(data,label,a,al,num)
    dt = data;
    % Put data in the end
    for i=1:num
       dt = cat(4,dt,a);
    end
 
    % Make new label vector
    labs = label;
    for i=1:num
        labs = [labs al];
    end    
end