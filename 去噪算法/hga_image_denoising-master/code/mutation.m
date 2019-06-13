%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

%}

function g = mutation(img)

r = randi(3);

switch r
    
    case 1
        tmp = double(img);
        rate = 0.7 + 0.6*rand;
        i = rate*tmp;
        i = floor(i + 0.5);
    case 2
        t = getFilterSize(2);
        sigma = rand * 5 + 0.05;
        h = fspecial('gaussian', t, sigma);
    case 3
        t = getFilterSize(2);
        h = fspecial('average', t);        
        
end

if (r ==2 || r == 3)
    i = imfilter(img, h);
end

g = uint8(i);

end

function s = getFilterSize(maxSize)
n = randi(maxSize);

s = 2*n+1;
end