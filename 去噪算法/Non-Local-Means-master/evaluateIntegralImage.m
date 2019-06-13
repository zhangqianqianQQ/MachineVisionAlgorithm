function [patchSum] = evaluateIntegralImage(ii, row, col, delta)
% This function should calculate the sum over the patch centred at row, col
% of size patchSize of the integral image ii


 % NOTE : the integral image now has an extra row and an extra column 
 % so we have to add a 1 to all our indices.
 % We can notice that when we subtract delta we should've had a minus 1 as
 % well but because we're also adding a 1 is just row-delta.
 % 
 
 row_plus  = min(row+delta+1, size(ii,1));
 row_minus = max(row-delta, 1);
 col_plus  = min(col+delta+1, size(ii,2));
 col_minus = max(col-delta, 1);
 
% SOME DEBUG CODE 
% disp(row_plus);
% disp(row_minus);
% disp(clu_plus);
% disp(col_minus);
 
 patchSum = ii(row_plus,  col_plus)     ...
         + ii(row_minus, col_minus)    ...
         - ii(row_minus, col_plus)     ...
         - ii(row_plus,  col_minus); 


end