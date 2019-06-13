function theta=orderpoints(A, center, axis)
X0_in=center(1);
Y0_in=center(2);
x_axis=axis(:,1);
y_axis=axis(:,2);
centerlized=A-repmat([X0_in, Y0_in], size(A,1),1);
% length=sqrt(sum(centerlized.^2,2));
% cosx=centerlized*x_axis./length;
% cosy=centerlized*y_axis./length;
% 
% for i=1:size(A,1)
%     if (cosy(i)>0)
%         theta(i)=acos(cosx(i));
%     else 
%         theta(i)=2*pi-acos(cosx(i));
%         
%     end
% end

x1=centerlized(:,1);
y1=centerlized(:,2);
x2=repmat(x_axis(1), numel(x1),1);
y2=repmat(x_axis(2), numel(x1),1);
theta = mod(atan2(x1.*y2-x2.*y1,x1.*x2+y1.*y2),2*pi)';