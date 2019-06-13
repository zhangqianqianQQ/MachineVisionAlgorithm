% 该代码非自己编写。
% 出自：http://blog.csdn.net/h2008066215019910120/article/details/25917609
function pick = NMS(boxes,threshold,type)

    % 输入为空，则直接返回
    if isempty(boxes)
      pick = [];
      return;
    end

    % 依次取出左上角和右下角坐标以及分类器得分(置信度)
    x1 = boxes(:,3);
    y1 = boxes(:,4);
    x2 = boxes(:,5);
    y2 = boxes(:,6);
    s = boxes(:,2);

    % 计算每一个框的面积
    area = (x2-x1+1) .* (y2-y1+1);

    %将得分升序排列
    [vals, I] = sort(s);

    %初始化
    pick = s*0;
    counter = 1;

    % 循环直至所有框处理完成
    while ~isempty(I)
        last = length(I); %当前剩余框的数量
        i = I(last);%选中最后一个，即得分最高的框
        pick(counter) = i;
        counter = counter + 1;  

        %计算相交面积
        xx1 = max(x1(i), x1(I(1:last-1)));
        yy1 = max(y1(i), y1(I(1:last-1)));
        xx2 = min(x2(i), x2(I(1:last-1)));
        yy2 = min(y2(i), y2(I(1:last-1)));  
        w = max(0.0, xx2-xx1+1);
        h = max(0.0, yy2-yy1+1); 
        inter = w.*h;

        %不同定义下的IOU
        if strcmp(type,'Min')
            %重叠面积与最小框面积的比值
            o = inter ./ min(area(i),area(I(1:last-1)));
        else
            %交集/并集
            o = inter ./ (area(i) + area(I(1:last-1)) - inter);
        end

        %保留所有重叠面积小于阈值的框，留作下次处理
        I = I(find(o<=threshold));
    end
    pick = pick(1:(counter-1));
end
