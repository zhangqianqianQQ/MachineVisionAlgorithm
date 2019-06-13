%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   My_adapthisteq：限制对比度的自适应直方图算法
%   输入：灰度图I_gray
%   输出：均衡化后的灰度图output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = My_adapthisteq(I_gray)
    %% 第一步 获取图片基本信息
    [height,width] = size(I_gray);  
    % 获取最大最小像素
    min_pixel = double(min(min(I_gray)));  
    max_pixel = double(max(max(I_gray)));  
    
    %% 第二步 对图片进行分块
    % |-------Y
    % |
    % |
    % X
    % 根据经验按照图片尺寸分成若干个子块
    % Y分为（width/100-2）个子块
    subpart_Y = floor(width/100)-2;  
    % X分为（height/100-1）个子块
    subpart_X = floor(height/100)-1;  
    % 子块的宽和高
    height_size = ceil(height/subpart_X);  
    width_size = ceil(width/subpart_Y);  
    
    % 不能保证整除，需要补零  
    delta_y = subpart_X*height_size - height;  
    delta_x = subpart_Y*width_size - width;  
    
    % 补零
    temp_Image = zeros(height+delta_y,width+delta_x);  
    temp_Image(1:height,1:width) = I_gray;  
    
    % 新的高和宽
    new_width = width + delta_x;  
    new_height = height + delta_y;  
    % 像素点总数  
    sum_pixels = width_size * width_size; 
    
    %% 第三步 建立Look-up-table
    % 像素容器的总数，决定直方图横轴的间隔
    sum_pixel_bins = 256;
    % 建立Look-Up-Table
    look_up_table = zeros(max_pixel+1,1);  
    
    % 通过输入的灰度值范围进行映射
    for i = min_pixel:max_pixel  
        look_up_table(i+1) = fix(i - min_pixel);  
    end  
    
    %% 第四步 为每个子块建立直方图
    % 归一化整幅图的灰度值
    % 使用Look-up-table
    pixel_bin = zeros(new_height, new_width);  
    for m = 1 : new_height  
        for n = 1 : new_width  
            pixel_bin(m,n) = 1 + look_up_table(temp_Image(m,n) + 1);  
        end  
    end  
    
    % Hist为长度256的4*8矩阵，用来存储直方图
    % 4*8表示划分成了4*8个子块，256表示灰度级
    % Hist(x,y,i)表示
    % （在划分的坐标为(x,y)的子块中，像素值=i的像素点）的总数
    Hist = zeros(subpart_X, subpart_Y, 256);  
    for i=1:subpart_X  
        for j=1:subpart_Y  
            % 为每个子块建立直方图
            tmp = uint8(pixel_bin(1+(i-1)*height_size:i*height_size, 1+(j-1)*width_size:j*width_size));  
            [Hist(i, j, :), x] = imhist(tmp, 256);  
        end  
    end  
    % 调整灰度值的那一维  
    Hist = circshift(Hist,[0, 0, -1]);  
    
    %% 第五步 剪裁直方图 
    % 剪裁参数
    clip_limit = 2.5;  
    clip_limit = max(1,clip_limit * height_size * width_size/sum_pixel_bins);  
    
    % 调用剪裁函数
    Hist = My_clip_histogram(Hist,sum_pixel_bins,clip_limit,subpart_X,subpart_Y);  
    
    %% 第六步 灰度值映射和线性插值处理
    Map = My_map_histogram(Hist, min_pixel, max_pixel, sum_pixel_bins, sum_pixels, subpart_X, subpart_Y);  
    y_I = 1;  
    for i = 1:subpart_X+1  
        % 单独处理边界
        if i == 1  
            sub_Y = floor(height_size/2);  
            y_Up = 1;  
            y_Bottom = 1;  
        elseif i == subpart_X+1  
            sub_Y = floor(height_size/2);  
            y_Up = subpart_X;  
            y_Bottom = subpart_X;  
        % 否则在内部
        else  
            sub_Y = height_size;  
            y_Up = i - 1;  
            y_Bottom = i;  
        end  
        xI = 1;  
        % 单独处理边界
        for j = 1:subpart_Y+1  
            if j == 1  
                sub_X = floor(width_size/2);  
                x_Left = 1;  
                x_Right = 1;  
            elseif j == subpart_Y+1  
                sub_X = floor(width_size/2);  
                x_Left = subpart_Y;  
                x_Right = subpart_Y;
            % 否则在内部
            else  
                sub_X = width_size;  
                x_Left = j - 1;  
                x_Right = j;  
            end  
            % 进行灰度值映射
            U_L = Map(y_Up,x_Left,:);  
            U_R = Map(y_Up,x_Right,:);  
            B_L = Map(y_Bottom,x_Left,:);  
            B_R = Map(y_Bottom,x_Right,:);  
            sub_Image = pixel_bin(y_I:y_I+sub_Y-1,xI:xI+sub_X-1);  
      
            % 线性插值处理 
            s_Image = zeros(size(sub_Image));  
            num = sub_Y * sub_X;  
            for m = 0:sub_Y - 1  
                inverse_I = sub_Y - m;  
                for n = 0:sub_X - 1  
                    inverse_J = sub_X - n;  
                    val = sub_Image(m+1,n+1);  
                    s_Image(m+1, n+1) = (inverse_I*(inverse_J*U_L(val) + n*U_R(val)) ...  
                                    + m*(inverse_J*B_L(val) + n*B_R(val)))/num;  
                end  
            end     
            output(y_I:y_I+sub_Y-1, xI:xI+sub_X-1) = s_Image;  
            xI = xI + sub_X;  
        end  
        y_I = y_I + sub_Y;  
    end  
    
    %% 第七步 输出非补零的部分
    output = output(1:height, 1:width);  
end