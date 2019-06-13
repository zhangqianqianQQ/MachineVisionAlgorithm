function [final_hist] = feature_vector(I)

M0 = [0,0,0,0,0,0,0,0; 0,0,0,0,0,0,0,0; 0,0,0,0,0,0,0,0;...
    1,1,1,1,1,1,1,1; 1,1,1,1,1,1,1,1; 0,0,0,0,0,0,0,0;...
    0,0,0,0,0,0,0,0; 0,0,0,0,0,0,0,0];

M90 = transpose(M0);

M45 = [0,0,0,0,0,0,1,1; 0,0,0,0,0,1,1,1; 0,0,0,0,1,1,1,0;...
    0,0,0,1,1,1,0,0; 0,0,1,1,1,0,0,0; 0,1,1,1,0,0,0,0;...
    1,1,1,0,0,0,0,0; 1,1,0,0,0,0,0,0];
 
M135 = [1,1,0,0,0,0,0,0; 1,1,1,0,0,0,0,0; 0,1,1,1,0,0,0,0;...
    0,0,1,1,1,0,0,0; 0,0,0,1,1,1,0,0; 0,0,0,0,1,1,1,0;...
    0,0,0,0,0,1,1,1; 0,0,0,0,0,0,1,1];


% I = imread('mdb022.pgm');
% I = imresize(I, [512 512]);
% I = rgb2gray(I);

dim = length(size(I));
if dim == 3
    I = rgb2gray(I);
else
    I = I;
end

I = edge(I,'canny');

[block wholeBlockRows wholeBlockCols] = subblocks(I,128,128);

Type = [];
Tblank = 0;
for j = 1 : length(block)
    
    a = cell2mat(block{j});
    [block8{j} wR wC] = subblocks(block{j}{:},8,8);
    
    for k = 1 : length(block8{j}) 
        b = block8{j}{k}{:};
        n = nnz(b);
        if n == 0
            Type{j}(k) = 1;
        else
            m0 = nnz(and(b,M0));
            m90 = nnz(and(b,M90));
            m45 = nnz(and(b,M45));
            m135 = nnz(and(b,M135));
            if m0 > 7
                Type{j}(k) = 2;
            elseif m45 > 7
                Type{j}(k) = 3;
            elseif m90 > 7
                Type{j}(k) = 4;
            elseif m135 > 7
                Type{j}(k) = 5;
            elseif m0 < 7 && m45 < 7 && m90 < 7 && m135 <7
                Type{j}(k) = 6;
            end
        end
    end

end

x = [1,2,3,4,5,6];
for l = 1 : length(Type)
   h(l,:) = hist(Type{l},x);
end

shape_hist = h(:)';

density_hist = density_histogram(I,block);

final_hist = [shape_hist density_hist];