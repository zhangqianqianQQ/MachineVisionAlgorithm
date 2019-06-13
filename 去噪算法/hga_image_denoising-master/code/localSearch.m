%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

%}

function g = localSearch(img)

r = randi(3);

switch r 
   
    case 1
        tmp = wavewiener2(img, 'db3', 4); 
    case 2
        tmp = lpa(img);
    case 3
        [psnr, tmp] = BM3D(1,img);
        tmp = tmp*255;
end

g = uint8(tmp);

end