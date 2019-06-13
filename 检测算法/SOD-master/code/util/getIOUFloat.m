function iou = getIOUFloat(res,gt)

xmin = max(res(:,1),gt(1));
ymin = max(res(:,2),gt(2));
xmax = min(res(:,3),gt(3));
ymax = min(res(:,4),gt(4));

I = max((xmax-xmin),0).*max((ymax-ymin),0);
U = (res(:,3)-res(:,1)).*(res(:,4)-res(:,2))+(gt(3)-gt(1))*(gt(4)-gt(2));
iou = I./(U-I);