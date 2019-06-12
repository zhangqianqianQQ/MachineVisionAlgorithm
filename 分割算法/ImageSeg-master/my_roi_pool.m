function my_pooled = my_roi_pool(ft_map, roi, im_size)
    %im_size = [rows, cols]
    %roi = [0, im_col_start, im_row_start, im_col_end, im_row_end]
    %ft_map has size 37*37, one layer
    im_num_rows = im_size(1);
    im_num_cols = im_size(2);
    ft_map_size = size(ft_map);
    fm_num_rows = ft_map_size(1);
    fm_num_cols = ft_map_size(2);
    
    fm_row_start = roi(3)/im_num_rows * fm_num_rows;
    fm_col_start = roi(2)/im_num_cols * fm_num_cols;
    fm_row_end = roi(5)/im_num_rows * fm_num_rows;
    fm_col_end = roi(4)/im_num_cols * fm_num_cols;
    
    row_step = (fm_row_end - fm_row_start)/7;
    col_step = (fm_col_end - fm_col_start)/7;
    
    my_pooled = [];
    
    for r_start = fm_row_start: row_step: fm_row_end-1
        temp_row = [];
        for c_start = fm_col_start: col_step: fm_col_end-1
            curr_ft_square = ft_map( ceil(r_start):ceil(r_start+row_step), ceil(c_start):ceil(c_start+col_step) );
            max_pool = max(curr_ft_square(:));
            temp_row = [temp_row max_pool];
        end
        my_pooled = [my_pooled; temp_row];
    end

end