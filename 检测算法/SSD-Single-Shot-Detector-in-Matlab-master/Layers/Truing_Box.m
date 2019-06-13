%% 
%--------------Truing_Box---------------
%作  者：杨帆
%公  司：BJTU
%功  能：精修Prior Box。
%输  入：
%       priorbox        -----> 默认框。
%       loc             -----> 精修信息。
%输  出：
%备  注：Matlab 2016a。
%----------------------------------------

%%

function box = Truing_Box(priorbox, loc)

    % 检查数据维数    
    in_dims = ndims(priorbox);
    if(in_dims == 3)
        [height, width, depth] = size(priorbox);
    else
        error('输入数据维度小于3维，请检查输入数据。');
    end
    
    box = zeros(height, width, depth);
    
    for k = 1: 4: depth
        
        cenx = 0.5 * (priorbox(:, :, k) + priorbox(:, :, k + 2));
        ceny = 0.5 * (priorbox(:, :, k + 1) + priorbox(:, :, k + 3));        
        width = priorbox(:, :, k + 2) - priorbox(:, :, k);
        height = priorbox(:, :, k + 3) - priorbox(:, :, k + 1);
        
        cenx = 0.1 * loc(:, :, k) .* width + cenx;
        ceny = 0.1 * loc(:, :, k + 1) .* height + ceny;
        width = exp(0.2 * loc(:, :, k + 2)) .* width;
        height = exp(0.2 * loc(:, :, k + 3)) .* height;
        
        box(:, :, k) = max(cenx - width / 2, 0);
        box(:, :, k + 1) = max(ceny - height / 2, 0);
        box(:, :, k + 2) = min(cenx + width / 2, 1);
        box(:, :, k + 3) = min(ceny + height / 2, 1);
    end