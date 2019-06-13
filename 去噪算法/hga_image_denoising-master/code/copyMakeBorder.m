function bord = copyMakeBorder(imgOriginal, t)

[linhas, cols] = size(imgOriginal);

tmp = [fliplr(imgOriginal(:,2:t+1)) imgOriginal fliplr(imgOriginal(:,cols-t:cols-1))];

bord = [flipud(tmp(2:t+1,:)); tmp; flipud(tmp(linhas-t:linhas-1,:))];

end