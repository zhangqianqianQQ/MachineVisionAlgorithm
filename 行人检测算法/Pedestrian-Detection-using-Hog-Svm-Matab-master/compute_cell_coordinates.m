function windows=compute_cell_coordinates(I,wx_size, wy_size,~)
% COMPUTE_CELL_COORDINATES Function to divide the input image(I) 
%                          in windows of the specified size.
%
% INPUT:
%       img: image to split
%       w_size: window size in px
%       windows: matrix with the chunked image indices in 1 row and 4 columns
%                in the following format: [x_ini]
%                                         [x_fin]
%                                         [y_ini]    
%                                         [y_fin]
%
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: N/D $ 
%$ Revision : 1.00 $ 
%% FILENAME  : compute_cell_coordinates.m 

%% window size cheking
[r,c] = size(I(:,:,1));
if wx_size > c || wy_size > r
    fprintf('window size greater than image size: r=%d, c=%d \n',r,c);
end

%% image chunking
x_segs = floor(c/wx_size);
y_segs = floor(r/wy_size);


%% more Matlab way of doing
xs_ini(1:x_segs) = wx_size*((1:x_segs)-1)+1;     % x_ini
xs_fin(1:x_segs) = wx_size*min((1:x_segs),c);    % x_fin
ys_ini(1:y_segs) = wy_size*((1:y_segs)-1)+1;     % y_ini
ys_fin(1:y_segs) = wy_size*min((1:y_segs),r);    % y_fin

[X_ini,Y_ini] = meshgrid(ys_ini,xs_ini);
[X_fin,Y_fin] = meshgrid(ys_fin,xs_fin);
windows = [Y_ini(:),Y_fin(:),X_ini(:),X_fin(:)]';


%% Equivalent to but slightly slower: (just left here for clearness)
% fprintf('X segments: %d, Y segments: %d \n', x_segs, y_segs);
% if subPlot
%     figure('name', 'partitions');
% end
% windows = zeros(4,y_segs*x_segs);
% for i=1:x_segs
%     for j=1:y_segs
%         
%         % windows coordinates calculations
%         x_ini = wx_size*(i-1)+1;
%         x_fin = min(wx_size*i,c);
%         y_ini = wy_size*(j-1)+1;
%         y_fin = min(wy_size*j, r);
%         
%         % saving coordinates in the 'windows' array
%         col = (j-1)*x_segs+i;
%         windows(1,col) = x_ini;
%         windows(2,col) = x_fin;
%         windows(3,col) = y_ini;
%         windows(4,col) = y_fin;
%         
%         % showing the partitions
%         if subPlot==true
%             subplot(y_segs,x_segs,col), 
%             subimage(I(y_ini:y_fin,x_ini:x_fin,:));
%         end
%     end
% end

        
        
