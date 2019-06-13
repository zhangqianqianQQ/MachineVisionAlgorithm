%% 
%-----------Transform_Input-------------
%作  者：杨帆
%公  司：BJTU
%功  能：输入数据处理层。
%输  入：
%       in_img      -----> 输入图像（dim = 3）。
%       varargin    -----> 可变输入。
%                        |----> 2BGR：BGR转换开关。
%                        |----> mean：均值。
%                        |----> resize：图像大小调整。
%输  出：
%       out_img     -----> 输出图像（dim = 3）。
%备  注：Matlab 2016a。
%----------------------------------------

%%

function out_img = Transform_Input(in_img, varargin)

    % 输入参数整理
    if(mod(nargin, 2) == 0 && nargin > 7)
        error('输入参数错误，请检查输入参数！');
    else
        BGR_flag = false;
        im_mean = [];
        im_size = [];
        for i = 1: 2: 5
            switch varargin{i}
                case '2BGR'
                    BGR_flag = varargin{i + 1};
                case 'mean'
                    im_mean = varargin{i + 1};
                case 'resize'
                    im_size = varargin{i + 1};
                otherwise
                    error('未知字段，请查看本函数说明。')
            end
        end
    end
    
    % 数据类型转换。
    in_img = im2double(in_img);
    
    % 输入图像尺寸调整。
    if(~isempty(im_size))       
        out_img = imresize(255 * in_img, im_size);
    else
        out_img = in_img;
    end

    % RGB 2 BGR。
    if(BGR_flag == true)
        out_img = out_img(:,:, [3,2,1]);
    end

    % 减均值。
    if(~isempty(im_mean))
        if(BGR_flag == true)
            out_img(:, :, 1) = out_img(:, :, 1) - im_mean(3);
            out_img(:, :, 2) = out_img(:, :, 2) - im_mean(2);
            out_img(:, :, 3) = out_img(:, :, 3) - im_mean(1);
        else
            out_img(:, :, 1) = out_img(:, :, 1) - im_mean(1);
            out_img(:, :, 2) = out_img(:, :, 2) - im_mean(2);
            out_img(:, :, 3) = out_img(:, :, 3) - im_mean(3);
        end
    end
end