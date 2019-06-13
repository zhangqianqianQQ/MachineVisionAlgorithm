function f = estimateVariance(img)

out = laplacMult(img, 0);
list = reshape(out.',1, numel(out));
list = sort(list);
med = list(floor((length(list)+1)/2));

for i = 1:length(list)
   tmp = list(i)-med;
   list(i) = abs(tmp);
end

list = sort(list);

med = list(floor((length(list)+1)/2));

desv = med * 1.4828;

f = desv^2;

end


function g = laplacMult(img, c)

copy = double(copyMakeBorder(img,1));
out = zeros(size(img));

if (c ~= 0)
    mult = c;
else
    mult = 1.0/sqrt(20);
end

[linhas, colunas] = size(copy);

for i = 2:linhas-1
    for j = 2:colunas-1
        tmp = mult * (copy(i-1,j) + copy(i+1,j) + copy(i,j-1) + copy(i,j+1) - 4 * copy(i,j));
        out(i-1,j-1) = tmp;
    end
end

g = out;
end