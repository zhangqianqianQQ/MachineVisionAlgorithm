function LBP_fea = LBP_feature_global(Data, radius, num_point, mapping, W0, map)

% Data: 3-D Data
% W0: block size of a local LBP image  (2*W0+1 x 2*W0+1), usually W0 >= 9
% for both Univ and Indian


% try these parameters: 
%  num_point = 18; % number of sampling points
%  radius = 3;
%  mapping = getmapping(num_point,'u2'); 
%  W0 = 11;  window = (2*W0+1) x (2*W0+1)

% output: LBP_fea;  size = [row * col,  num_of_bins * num_of_PC] 


[m,n,d] = size(Data);

% padding elements avoid edges
W = radius;
X = Data;

LBP_fea = [];

for i = 1:d
    if mod(i, 5) == 0
       fprintf(' ... ... ... ... processing %.2f%%\n', i/d*100.0);
    end
    I = X(:,:,i);
    I = I./max(I(:));
    [hist_fea lbp_img] = LBP(I,radius,num_point,mapping,'h');     
    hist_fea = hist_lbp_HSI(lbp_img, mapping, W0, 'h', map);
    LBP_fea = cat(3, LBP_fea, hist_fea);

end

% LBP_fea = reshape(LBP_fea, m*n, size(LBP_fea,3));

end


%%%% ==============================================================
%%%% ==============================================================

function x = roundn(x, n)

error(nargchk(2, 2, nargin, 'struct'))
validateattributes(x, {'single', 'double'}, {}, 'ROUNDN', 'X')
validateattributes(n, ...
    {'numeric'}, {'scalar', 'real', 'integer'}, 'ROUNDN', 'N')

if n < 0
    p = 10 ^ -n;
    x = round(p * x) / p;
elseif n > 0
    p = 10 ^ n;
    x = p * round(x / p);
else
    x = round(x);
end

end



%%%% ==============================================================
%%%% ==============================================================

function lbp_hist_fea = hist_lbp_HSI(result, mapping, W, mode, map)

%%%%% (input para) result : the lbp image

[m,n,d] = size(result);

%%%% pad edges %%%%%

X = zeros(m+2*W, n+2*W, d);
X(W+1:m+W, W+1:n+W, :) = result;
X(W+1:m+W, 1:W, :) = result(:, W:-1:1, :);
X(W+1:m+W, n+W+1:n+2*W, :) = result(:, n:-1:n-(W-1), :);
X(1:W, :, :) = X(2*W:-1:(W+1), :, :);
X(m+(W+1):m+2*W, :, :) = X(m+W:-1:(m+1), :, :);


bins = mapping.num;
lbp_hist_fea = zeros(m,n,bins);

%%%%% calculate block based lbp histogram %%%%%
for pp = W+1: m+W
    for qq = W+1: n+W 
    if map(pp-W, qq-W)>0    
        result = X(pp-W:pp+W, qq-W:qq+W);
        
        if isstruct(mapping)
            bins = mapping.num;
            for i = 1:size(result,1)
                for j = 1:size(result,2)
                    result(i,j) = mapping.table(result(i,j)+1);
                end
            end
        end
        
        if (strcmp(mode,'h') || strcmp(mode,'hist') || strcmp(mode,'nh'))
            % Return with LBP histogram if mode equals 'hist'.
            result=hist(result(:),0:(bins-1));
            if (strcmp(mode,'nh'))
                result=result/sum(result);
            end
        else
            %Otherwise return a matrix of unsigned integers
            if ((bins-1)<=intmax('uint8'))
                result=uint8(result);
            elseif ((bins-1)<=intmax('uint16'))
                result=uint16(result);
            else
                result=uint32(result);
            end
        end        
        lbp_hist_fea(pp-W,qq-W,:) = result;
    end
    end
end


end






