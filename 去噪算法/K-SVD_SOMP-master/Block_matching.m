function  [pos_arr,wei_arr]   =  Block_matching(im,L_look,step,basic_estimate,blocknum)
% global blocksize;
blocksize = 8;
S         =   19; %搜索区域的半径；
f         =   blocksize; %patch的边长；
alpha     =   0.88;
hp        = quantile_nakagami(L_look, blocksize, alpha) .* blocksize.^2;
s         =   2;%参考块步长
% if L_look <=2
par.nblk  =   blocknum;%每个相似组中相似块的个数 sigma>40时 par.nblk = 32
% else
%     par.nblk = blocknum/2;
% end
N         =   size(im,1)-f+1; %因为把patch的左上角作为参考点，故要防止最后的patch超出边界；
M         =   size(im,2)-f+1;
r         =   [1:s:N];
r         =   [r r(end)+1:N];
c         =   [1:s:M];
c         =   [c c(end)+1:M];
L         =   N*M; %图像（506*506）中像素的总数；
X         =   zeros(f*f, L, 'single');
basic_X   =   zeros(f*f, L, 'single');

k    =  0;
for i  = 1:f
    for j  = 1:f
        k    =  k+1;
        blk  =  im(i:end-f+i,j:end-f+j);
        X(k,:) =  blk(:)'; %每一行就是一副506*506的图像；
    end
end%这一部分不好理解，快速算法的思想，X是用来提取每个像素点索引对应的Patch
k    =  0;
for i  = 1:f
    for j  = 1:f
        k    =  k+1;
        blk  =  basic_estimate(i:end-f+i,j:end-f+j);
        basic_X(k,:) =  blk(:)'; %每一行就是一副506*506的图像；
    end
end
% Index image
I     =   (1:L); 
I     =   reshape(I, N, M); %目的是给506*506的图像中的每一个像素一个索引；
N1    =   length(r);
M1    =   length(c);
pos_arr   =  zeros(par.nblk, N1*M1 ); %N1*M1应该为相似集合的数目,par.nblk为相似集合的中相似块的数目；
wei_arr   =  zeros(par.nblk, N1*M1 );
X         =  X'; %每一列就是一副506*506的图像；
basic_X   =  basic_X';

for  i  =  1 : N1               %N1*M1应该是相似集合的数目，即对于整幅图像，每隔step隔像素取一个patch作为相似集合的中心；
    for  j  =  1 : M1
        
        row     =   r(i);       %相似集合的中心patch的top-left元素所在的行；
        col     =   c(j);       %当前相似集合中心patch的top-left元素所在的列；
        off     =  (col-1)*N + row;  %当前相似集合中心patch的top-left元素在图像（506*506）按列存储下的索引；
        off1    =  (j-1)*N1 + i;     %这样做的目的可能是让图像中以同一列中patch为中心的相似集合在pos_arr中处于相邻的列；
                                     %将每一个相似集合看成一个元素，则相似集合形成一个N1*M1（86*86）的矩阵，且存储方式是按列序的；
        rmin    =   max( row-S, 1 );
        rmax    =   min( row+S, N );
        cmin    =   max( col-S, 1 );
        cmax    =   min( col+S, M ); %确定了当前相似集合的搜索区域；
         
        idx     =   I(rmin:rmax, cmin:cmax); %找到当前相似集合的搜索区域内的所有元素的索引；
        idx     =   idx(:);
        % PPB 相似性度量
        B       =   X(idx, :);
        v       =   X(off, :);
        vm      =   repmat(v,length(idx),1);
        A       =   log(B./vm+vm./B);
        
        A(abs(A)<=0)=min(min(A(abs(A)>0)));
        A(isnan(abs(A)))=min(min(A(abs(A)>0)));
                
        if(step == 1)
            dis              =   (2*L_look-1)*sum(A,2);
            [val,ind]        =  sort(dis);
            dis(ind(1))      =  dis(ind(2));
            pos_arr(:,off1)  =  idx( ind(1:par.nblk) ); %保存的实际上是patch的top_left元素的索引；
            wei              =  exp( -dis(ind(1:par.nblk))./hp );
            wei              =  wei./(sum(wei)+eps);
            wei_arr(:,off1)  =  wei;
        else
            B2      =   basic_X(idx, :);
            v2      =   basic_X(off, :);
            vm2     =   repmat(v2,length(idx),1);
            addtion =   ((vm2-B2).^2)./(vm2.*B2);
            dis     =   (2*L_look-1)*sum(A,2) + L_look*sum(addtion,2);
            [val,ind]   =  sort(dis);
            pos_arr(:,off1)  =  idx( ind(1:par.nblk) ); %保存的实际上是patch的top_left元素的索引；
        end
    end
end
end