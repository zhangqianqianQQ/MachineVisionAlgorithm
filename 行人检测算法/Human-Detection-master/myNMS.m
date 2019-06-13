function Final = myNMS(y, w)
%功能：非极大值抑制
%参数：
%示例：
%编写：欧阳超（ouyangchao16@163.com）

tw = w;
qx = 8;
qy = 16;
qs = log(1.3);
y = y';
s = log(y(3,:));

Hi = [];
Hh = zeros(3,3);
H = zeros(3,1);
D = [];
wy = [];
final = [];
k = 1;
mh = 1;
e = 0.001;

for i = 1:size(y,2)
    Hi(i,:) = [(exp(s(i))*qx)^2, (exp(s(i))*qy)^2, qs^2];
end

for j = 1:size(y,2)
    Hh = zeros(3,3);
    H = zeros(3,1);
    ym = y(:,j);
    mh = 1;
    
    while sqrt(sum(mh.*mh)) > e
        for i = 1:size(y,2)
            D(i) = (ym-y(:,i))'*inv(diag(Hi(i,:)))*(ym-y(:,i));
        end

        for i = 1:size(y,2)
            wy(i) = (abs(det(diag(Hi(i,:)))))^(-0.5) * tw(i) * exp((-0.5)*D(i));
        end
        wy = wy*sum(wy);

        for i = 1:size(y,2)
            Hh = Hh + wy(i)*inv(diag(Hi(i,:)));
        end

        for i = 1:size(y,2)
            H = H + wy(i)*inv(diag(Hi(i,:)))*y(:,i);
        end
        mh = inv(Hh)*H - ym;
        ym = ym + mh;
    end
    Final(:,k) = ym;
    if (j > 1) && (sqrt(sum((ym-lastym).*(ym-lastym))) < 1)
        Final(:,k) = [];
        k = k-1;
    end
    k = k+1;
    lastym = ym;
end
Final = Final';
