function contrib_prev = gpu_reverse_max(l_prev, contrib_curr)
disp('gpu_reverse_max');
tic;
    s = size(l_prev);
    num_row = s(1);
    num_col = s(2);
    num_ch = s(3);
    contrib_prev = zeros(s);
    
    for ch = 1:num_ch
        for row = 1:floor(num_row/2)
            for col = 1:floor(num_col/2)
                sq = squeeze(l_prev((2*row-1):(2*row),(2*col-1):(2*col),ch));
                max_val = max(sq(:));
                %assert(isequal(max_val,))
                [r,c] = ind2sub([2,2], find(sq==max_val));
                
                for i=1:length(r)
                    contrib_prev(2*row+r(i)-2,2*col+c(i)-2,ch) = contrib_curr(row,col,ch)/length(r);
                end
                
                %contrib_prev(2*row+r(1)-2,2*col+c(1)-2,ch) = contrib_curr(row,col,ch)/length(r);
            end
        end
    end
toc
end