%Matlab版HOG代码
function F = hogcalculator(img, cellpw, cellph, nblockw, nblockh,...
    nthet, overlap,issigned, normmethod);

% HOG特征由Dalal在2005 cvpr 的一篇论文中提出

% NORMMETHOD：重叠块中的特征标准化函数的方法
%       e为一个设定的很小的数使分母不为0
%       v为标准化前的特征向量
%       'none', which means non-normalization;
%       'l1', which means L1-norm normalization; V=V/(V+e)
%       'l2', which means L2-norm normalization; V=V/根号(V平方+e平方)
%       'l1sqrt',V=根号(V/(V+e))
%       'l2hys',l2的省略形式。将V最大值限制为0.2

if nargin < 2
    % 在DALAL论文中指出的在rows:128*columns:64情况下的最佳值，设定为DEFAULT
    cellpw = 8;
    cellph = 8;
    nblockw = 2;
    nblockh = 2;
    nthet = 9;
    overlap = 0.5;
    issigned = 'unsigned';
    normmethod = 'l2hys';
else
    if nargin < 9
        error('输入参数不足.');
    end
end

[M, N, K] = size(img);  %M为行数，N为列数，K为维数
if mod(M,cellph*nblockh) ~= 0   %行数必须为块的高度的整数倍
    error('图片行数必须为块的高度的整数倍.');
end
if mod(N,cellpw*nblockw) ~= 0   %列数必须为块的宽度的整数倍
    error('图片列数必须为块的宽度的整数倍.');
end                             
if mod((1-overlap)*cellpw*nblockw, cellpw) ~= 0 ||...  %要使滑步后左边是整数
        mod((1-overlap)*cellph*nblockh, cellph) ~= 0
    error('滑步的像素个数必须为细胞单元尺寸的整数倍');
end

%设置高斯空间权值窗口的方差
delta = cellpw*nblockw * 0.5;


%计算梯度矩阵  梯度的计算【-1，0，1】效果是很好的，而3*3的sobel算子或者2*2的对角矩阵反而会系统的降低效果
hx = [-1,0,1];
hy = -hx';   %转置
gradscalx = imfilter(double(img),hx);  %imfilter是滤波器，hx表示滤波掩膜
gradscaly = imfilter(double(img),hy);

if K > 1
    gradscalx = max(max(gradscalx(:,:,1),gradscalx(:,:,2)), gradscalx(:,:,3));  %取RGB中最大值
    gradscaly = max(max(gradscaly(:,:,1),gradscaly(:,:,2)), gradscaly(:,:,3));
end
gradscal = sqrt(double(gradscalx.*gradscalx + gradscaly.*gradscaly));  %梯度矩阵 gradscal

% 计算梯度方向矩阵
gradscalxplus = gradscalx+ones(size(gradscalx))*0.0001;  %防止为0，所以gradscalx加了0.0001
gradorient = zeros(M,N);                                 %初始化梯度方向矩阵
% unsigned situation: orientation region is 0 to pi.
if strcmp(issigned, 'unsigned') == 1                     %无向的情况
    gradorient =...
        atan(gradscaly./gradscalxplus) + pi/2;           %加pi/2因为atan的区间取值从-pi/2开始
    or = 1;
else
    % signed situation: orientation region is 0 to 2*pi. %有向的情况
    if strcmp(issigned, 'signed') == 1
        idx = find(gradscalx >= 0 & gradscaly >= 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx));
        idx = find(gradscalx < 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx)) + pi;
        idx = find(gradscalx >= 0 & gradscaly < 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx)) + 2*pi;
        or = 2;
    else
     %  error('Incorrect ISSIGNED parameter.');
        error('参数ISSIGNED输入有误');
    end
end

% 计算块的滑步
xbstride = cellpw*nblockw*(1-overlap);   %x方向的滑步
ybstride = cellph*nblockh*(1-overlap);
xbstridend = N - cellpw*nblockw + 1;     %x方向块左角能达到的最大值
ybstridend = M - cellph*nblockh + 1;

% 块总数=ntotalbh*ntotalbw
ntotalbh = ((M-cellph*nblockh)/ybstride)+1; %除了第一个，后面每个都是只需要ybstride就可以加一块
ntotalbw = ((N-cellpw*nblockw)/xbstride)+1;

% hist3dbig存储三维直方图，其中外面加了一层包裹以方便计算
      hist3dbig = zeros(nblockh+2, nblockw+2, nthet+2);
        F = zeros(1, ntotalbh*ntotalbw*nblockw*nblockh*nthet);
        glbalinter = 0;
   
% 生成存储一个块的特征值的向量
sF = zeros(1, nblockw*nblockh*nthet);

% 生成高斯权值的模板
[gaussx, gaussy] = meshgrid(0:(cellpw*nblockw-1), 0:(cellph*nblockh-1));   %生成一个块的网格
weight = exp(-((gaussx-(cellpw*nblockw-1)/2)...
    .*(gaussx-(cellpw*nblockw-1)/2)+(gaussy-(cellph*nblockh-1)/2)...
    .*(gaussy-(cellph*nblockh-1)/2))/(delta*delta));

% 权值投票，三线插值
for btly = 1:ybstride:ybstridend
    for btlx = 1:xbstride:xbstridend
        for bi = 1:(cellph*nblockh)
            for bj = 1:(cellpw*nblockw)
                
                i = btly + bi - 1;       %在整个坐标系中的坐标
                j = btlx + bj - 1;
                gaussweight = weight(bi,bj);
                
                gs = gradscal(i,j);   %梯度值
                go = gradorient(i,j); %梯度方向
                          
                % calculate bin index of hist3dbig
                % 计算八个统计区间中心点的坐标
                binx1 = floor((bj-1+cellpw/2)/cellpw) + 1;
                biny1 = floor((bi-1+cellph/2)/cellph) + 1;
                binz1 = floor((go+(or*pi/nthet)/2)/(or*pi/nthet)) + 1;
                
                if gs == 0
                    continue;
                end
                
                binx2 = binx1 + 1;
                biny2 = biny1 + 1;
                binz2 = binz1 + 1;
                
                x1 = (binx1-1.5)*cellpw + 0.5;
                y1 = (biny1-1.5)*cellph + 0.5;
                z1 = (binz1-1.5)*(or*pi/nthet);
                
                % trilinear interpolation.三线插值
                hist3dbig(biny1,binx1,binz1) =...
                    hist3dbig(biny1,binx1,binz1) + gs*gaussweight...
                    * (1-(bj-x1)/cellpw)*(1-(bi-y1)/cellph)...
                    *(1-(go-z1)/(or*pi/nthet));
                hist3dbig(biny1,binx1,binz2) =...
                    hist3dbig(biny1,binx1,binz2) + gs*gaussweight...
                    * (1-(bj-x1)/cellpw)*(1-(bi-y1)/cellph)...
                    *((go-z1)/(or*pi/nthet));
                hist3dbig(biny2,binx1,binz1) =...
                    hist3dbig(biny2,binx1,binz1) + gs*gaussweight...
                    * (1-(bj-x1)/cellpw)*((bi-y1)/cellph)...
                    *(1-(go-z1)/(or*pi/nthet));
                hist3dbig(biny2,binx1,binz2) =...
                    hist3dbig(biny2,binx1,binz2) + gs*gaussweight...
                    * (1-(bj-x1)/cellpw)*((bi-y1)/cellph)...
                    *((go-z1)/(or*pi/nthet));
                hist3dbig(biny1,binx2,binz1) =...
                    hist3dbig(biny1,binx2,binz1) + gs*gaussweight...
                    * ((bj-x1)/cellpw)*(1-(bi-y1)/cellph)...
                    *(1-(go-z1)/(or*pi/nthet));
                hist3dbig(biny1,binx2,binz2) =...
                    hist3dbig(biny1,binx2,binz2) + gs*gaussweight...
                    * ((bj-x1)/cellpw)*(1-(bi-y1)/cellph)...
                    *((go-z1)/(or*pi/nthet));
                hist3dbig(biny2,binx2,binz1) =...
                    hist3dbig(biny2,binx2,binz1) + gs*gaussweight...
                    * ((bj-x1)/cellpw)*((bi-y1)/cellph)...
                    *(1-(go-z1)/(or*pi/nthet));
                hist3dbig(biny2,binx2,binz2) =...
                    hist3dbig(biny2,binx2,binz2) + gs*gaussweight...
                    * ((bj-x1)/cellpw)*((bi-y1)/cellph)...
                    *((go-z1)/(or*pi/nthet));
            end
        end
       
        %F生成
            if or == 2   %有向的时候，BINZ=nthet+2要返回给BINZ=2，BINZ=1要还给BINZ=nthet+1
                         %因为类似一个首尾相接的环
                hist3dbig(:,:,2) = hist3dbig(:,:,2)...
                    + hist3dbig(:,:,nthet+2);
                hist3dbig(:,:,(nthet+1)) =...
                    hist3dbig(:,:,(nthet+1)) + hist3dbig(:,:,1);
            end
            hist3d = hist3dbig(2:(nblockh+1), 2:(nblockw+1), 2:(nthet+1));
            
        
            for ibin = 1:nblockh     %对块内每个细胞单元
                for jbin = 1:nblockw
                    idsF = nthet*((ibin-1)*nblockw+jbin-1)+1;
                    idsF = idsF:(idsF+nthet-1);
                    sF(idsF) = hist3d(ibin,jbin,:);  %每个细胞单元的nthet个BIN
                end
            end
            iblock = ((btly-1)/ybstride)*ntotalbw +...
                ((btlx-1)/xbstride) + 1;
            idF = (iblock-1)*nblockw*nblockh*nthet+1;
            idF = idF:(idF+nblockw*nblockh*nthet-1);
            F(idF) = sF;
            hist3dbig(:,:,:) = 0;
        
    end
end

F(F<0) = 0;   %负值清0

%归一化方法
e = 0.001;  %为了防止分母出现0，设定一个较小的值e
l2hysthreshold = 0.2;
fslidestep = nblockw*nblockh*nthet;
switch normmethod
    case 'none'
    case 'l1'        %l1-norm
        for fi = 1:fslidestep:size(F,2)
            div = sum(F(fi:(fi+fslidestep-1)));
            F(fi:(fi+fslidestep-1)) = F(fi:(fi+fslidestep-1))/(div+e);
        end
    case 'l1sqrt'    %l1-sqrt
        for fi = 1:fslidestep:size(F,2)
            div = sum(F(fi:(fi+fslidestep-1)));
            F(fi:(fi+fslidestep-1)) = sqrt(F(fi:(fi+fslidestep-1))/(div+e));
        end
    case 'l2'        %l2-norm
        for fi = 1:fslidestep:size(F,2)
            sF = F(fi:(fi+fslidestep-1)).*F(fi:(fi+fslidestep-1));
            div = sqrt(sum(sF)+e*e);
            F(fi:(fi+fslidestep-1)) = F(fi:(fi+fslidestep-1))/div;
        end
    case 'l2hys'     %l2-Hys 限定最大不超过0.2
        for fi = 1:fslidestep:size(F,2)
            sF = F(fi:(fi+fslidestep-1)).*F(fi:(fi+fslidestep-1));
            div = sqrt(sum(sF)+e*e);
            sF = F(fi:(fi+fslidestep-1))/div;
            sF(sF>l2hysthreshold) = l2hysthreshold;
            div = sqrt(sum(sF.*sF)+e*e);
            F(fi:(fi+fslidestep-1)) = sF/div;
        end
    otherwise
        error('参数NORMMETHOD输入不正确');
end
