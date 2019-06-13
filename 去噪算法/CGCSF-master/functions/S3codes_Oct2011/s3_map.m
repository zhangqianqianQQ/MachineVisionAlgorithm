function [s_map1 s_map2 s3] = s3_map(img, show_res)
% Input: img is a gray scale image, in double type, range from 0 - 255. 
% You have to convert to gray scale if your image
% is color. You also have to cast img to double in order to run this code
% Parameter show_res = 1 to show results
% Output:   
% s_map1: The sharpness map measure based on spectral slope
% s_map2: The sharpness map measure based on total variation (spatial)            
% s3: the final sharpness map (combination of s_map1 and s_map2)
if nargin < 2
  show_res = 0;
end

% ----------------------------------------------------------------------
% blr_map1
s_map1 = spectral_map(img, 16);

%-----------------------------------------------------------------------
% blr_map2
s_map21 = spatial_map(img, 8); % Spatial map, blocks start from (1,1)
s_map22 = spatial_map(img, 4); % Spatial map, blocks start from (5,5) 
s_map2 = max(s_map21, s_map22);

%-----------------------------------------------------------------------
% combine
s_map1(s_map1 < -99) = 0;
s_map2(s_map2 < -99) = 0;

alpha = 0.5;
s3 = (s_map1.^alpha) .* ((s_map2).^(1-alpha));
if show_res
  figure; imshow(s_map1);
  figure; imshow(s_map2);
  figure; imshow(img/255);
  figure; imshow(s3);
end
end %function

%% Spectral Sharpness, slope of power spectrum
function res = spectral_map(img, pad_len)
blk_size = 32; %big block size for more coefficients of the power spectrum
d_blk = blk_size/4; % Distance b/w blocks

pad_L = fliplr(img(:, 1:pad_len)); % Take 16 columns on the left of the
                                    % original image to pad to the left
pad_R = fliplr(img(:, end-pad_len:end));%Take 16 columns on the right of the
                                        % original image to pad to the
                                        % right
img = [pad_L img pad_R]; %Pad left and right

pad_T = flipud(img(1:pad_len, :)); %Similarly, pad top and bottom
pad_B = flipud(img(end-pad_len:end, :));
img = [pad_T; img; pad_B];

num_rows = size(img, 1);
num_cols = size(img, 2);
res = zeros(num_rows, num_cols) - 100;
contrast_thresold = 0;

%disp_progress; % Just to show progress
for r = blk_size/2+1:d_blk:num_rows-blk_size/2 % Just start from inside blocks
                                                % of the padded image
  %disp_progress(r, num_rows);
  for c = blk_size/2+1:d_blk:num_cols-blk_size/2
    gry_blk = img(...
      r-blk_size/2:r+blk_size/2-1,...
      c-blk_size/2:c+blk_size/2-1 ...
      );
    contrastMap = contrast_map_overlap(gry_blk);
    if(max(contrastMap(:))> contrast_thresold) % Avoid the case when contrast = 0
      val = blk_amp_spec_slope_eo_toy_1(gry_blk); % Val(1) will be the slope of
                                                % power spectrum of the block
      val(1) = 1 - 1 ./ (1 + exp(-3*(val(1) - 2))); %Input to a sigmoid function
      %if(max(gry_blk(:))==min(gry_blk(:))) % Black block
       % val_1 = 0;
      %else
        val_1 = val(1);
      %end
    else
        val_1 = 0;
    end
    res(...
      r-d_blk/2:r+d_blk/2-1,...
      c-d_blk/2:c+d_blk/2-1 ...
      ) = val_1;
  end
end
% Remove padded parts
res = res(pad_len+1:end-pad_len-1, pad_len+1:end-pad_len-1);
end % function

%% ---Spatial Sharpness, local total variation
function res = spatial_map(img, pad_len)
% pad_len = 8 if we dont want to shift img
% pad_len = 4 if we want to shift img by 4;
blk_size = 8;

pad_L = fliplr(img(:, 1:pad_len)); % Take pad_len columns on the left of
                                   % the original image to pad to the left
pad_R = fliplr(img(:, end-pad_len:end));%Take pad_len columns on the right
                                % of the original image to pad to the right
img = [pad_L img pad_R]; %Pad left and right

pad_T = flipud(img(1:pad_len, :)); %Similarly, pad top and bottom
pad_B = flipud(img(end-pad_len:end, :));
img = [pad_T; img; pad_B];

[num_rows, num_cols] = size(img);
res = zeros(num_rows, num_cols);

for r = blk_size/2+1 : blk_size : num_rows-blk_size/2
  for c = blk_size/2+1 : blk_size : num_cols-blk_size/2
    gry_blk = img(...
      r-blk_size/2 : r+blk_size/2-1,...
      c-blk_size/2 : c+blk_size/2-1 ...
      );
    % Measure local total variation for every 2x2 block of gry_blk
    tmp_idx = 1;
    for i = 1 : blk_size - 1
      for j = 1 : blk_size - 1
        tv_tmp(tmp_idx) = (abs(gry_blk(i,j) - gry_blk(i,j+1))...
          + abs(gry_blk(i,j) - gry_blk(i+1,j))...
          + abs(gry_blk(i,j) - gry_blk(i+1,j+1))...
          + abs(gry_blk(i+1,j+1) - gry_blk(i+1,j))...
          + abs(gry_blk(i+1,j) - gry_blk(i,j+1))...
          + abs(gry_blk(i+1,j+1) - gry_blk(i,j+1)))/255; %Each pixel ranges
        %from 0 - 255, so divide by 255 to make it from 0 - 1
        tmp_idx = tmp_idx + 1;
      end
    end

    tv_max = max(tv_tmp) / 4; % Normalize tv_max to be from 0 -1. We can
                              % easily see that the maximum value of total
                              % variation for each 2x2 block is 4, in
                              % blocks like   1 0
                              %               0 1
    
    res(...
      r - blk_size/2 : r + blk_size/2-1,...
      c - blk_size/2 : c + blk_size/2-1 ...
      ) = tv_max; 
  end
end
res = res(pad_len + 1 : end-pad_len - 1, pad_len + 1 : end-pad_len - 1);

end % function


