function [cnt_map] = contrast_map_overlap(img)
%input must be double, range 0:255
img_lum = (0.7656 + 0.0364*img).^2.2;

blk_size = 8;
d_blk = blk_size/2;

[num_rows, num_cols] = size(img_lum);

cnt_map = zeros(num_rows, num_cols);

for r = 1:d_blk:num_rows-d_blk
  for c = 1:d_blk:num_cols-d_blk
    
    rs = r:r+blk_size-1;
    cs = c:c+blk_size-1;
    rs1 = r:r+d_blk-1;
    cs1 = c:c+d_blk-1;
    blk = img_lum(rs, cs);
    m_lum = mean2(blk);
    if m_lum > 127.5
      blk = 255 - blk;
      m_lum = mean2(blk);
    end
    if (m_lum > 2 && max(blk(:))-min(blk(:)) > 5)
      contrast = std2(blk) / m_lum; % Using rms contrast only when a block
                                    % has enough brightness and some
                                    % variant ...
    else
      contrast = 0; % otherwise set to 0
    end
    if(contrast > 5)
      contrast = 5;
    end
    cnt_map(rs1, cs1) = contrast/5;
  end
end

% figure; imshow(cnt_map, []);
