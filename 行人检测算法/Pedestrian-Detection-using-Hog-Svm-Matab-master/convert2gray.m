function convert2gray()
% CONVERT2GRAY converts to gray all JPG, PNG or PPM images found in 
%              the specified folder and saves the results in the desired
%              output path.
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 17-Dec-2013 18:48:28 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : convert2gray.m 


origin_path = uigetdir('images','Select origin folder');
dest_path = uigetdir('images','Select destination image folder');
wildcards = {'*.jpg','*.png','*.ppm'};
w_params = get_params('window_params');
w = w_params.width; 
h = w_params.heigth;

% reading images
images = [];
for i=1:numel(wildcards)
    wildcard = strcat(origin_path,filesep,wildcards{i});
    images = [images; rdir(wildcard)];
end

disp(numel(images))

for i=1:numel(images)
   % Image info [path, name, ext]
   [~, name, ~] = fileparts(images(i).name);
   fprintf('Converting image: %s\n',name);
   
   % getting centered window from the original image
   I = imread(images(i).name);
   window = get_window(I,w,h,'center');
   window = rgb2gray(window);
   
   % saving gray image
   imwrite(window, strcat(dest_path,filesep,name,'.png')); 
end

end
