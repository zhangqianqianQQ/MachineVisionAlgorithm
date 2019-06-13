
%% Aux function to compute the windows coordiantes at level 0 pyramid image
function [bb_size, new_cords] = compute_level0_coordinates(wxl, coordinates, inds, scale)

    % Consts
    bb_width = 64;
    bb_height = 128;
    
    % Vars
    new_cords = zeros(size(inds,2),2);
    bb_size = zeros(size(inds,2),2);
    
    % for each positive window index...
    for i=1:size(inds,2)
        
        % linear index of the window
        ind = inds(i);
        
        % find the positive window original level 
        level = 0;

        while ind > sum(wxl(1:level))
        	level = level + 1;
        end

%         fprintf('Match found at level %d\n', level);
        
        % compute original coordinates in Level0 image 
        factor = (scale^(level-1));
        new_cords(i,1) = floor(coordinates(i,1) * factor);
        new_cords(i,2) = floor(coordinates(i,2) * factor);
        
        % Bounding Box resizing?
        bb_size(i,1) = ceil(bb_height*factor);
        bb_size(i,2) = ceil(bb_width*factor);
    end
end