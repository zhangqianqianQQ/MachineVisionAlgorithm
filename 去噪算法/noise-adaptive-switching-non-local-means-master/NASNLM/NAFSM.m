% Noise adaptive fuzzy switching median filter for salt-and-pepper noise
% reduction
% Kenny Kal Vin Toh, etc
function y = NAFSM(x)

x = padarray(x,[3 3],'symmetric');
x = double(x);

M = x;
y =x;

N = zeros(size(x));
N(x~=0 & x~=255) = 1;

smax = 3;

[xlen ylen] =size(x);
T1 = 10;
T2 = 30;


for i=4:1:xlen-3
    for j=4:1:ylen-3
        
        if N(i,j) == 0
            s = 1;
            g = N(i-s:i+s,j-s:j+s);   %% 得到噪声标志矩阵
            num = sum(g(:));          %% 得到窗口内非噪声像素的个数
            
            %%while sum(g(:)<1) && s<smax  %%  原程序有错，这条语句导致每次滤波窗口都为7*7
            while num == 0 && s<smax
                s = s+1;
                g = N(i-s:i+s,j-s:j+s);
                num = sum(g(:));
            end
            
            if s<=smax && sum(g(:)>0)
                
               %% clear tmp;
               tmp = x(i-s:i+s,j-s:j+s);
               tmp = tmp(g(:)==1);
               
               M(i,j) = median(tmp);
               
            else
                
               M(i,j) = median([x(i-1,j-1),x(i,j-1),x(i+1,j-1),x(i-1,j)]);
               
            end % if s>smax
            
        end % if N(i,j) == 0
    end
end % for i=4:1:xlen-3

for i=4:1:xlen-3
    for j=4:1:ylen-3
        
        if N(i,j) == 0
            %% clear tmp;
            tmp = abs(x(i-1:i+1,j-1:j+1)-x(i,j)*ones(3,3));

            d = max(tmp(:));
            
            if d<T1
                f = 0;
            else
                if d>=T1 && d<T2
                    f = (d-T1)/(T2-T1);
                else
                    f =1;
                end
            end % d<T1
            
            y(i,j) = (1-f)*x(i,j)+f*M(i,j);
        end %  if N(i,j) == 0
        
    end
end % for i=4:1:xlen-3

y = uint8(y(4:xlen-3,4:ylen-3));