function [coefplots] = coefplot(coefs)
count = zeros(size(coefs,1),1);
for i = 1:size(coefs,1)
    row = coefs(i,:);
    ind = find(row~=0);
    counttemp = length(ind);
    count(i,1) = counttemp;
end
coefplots = count;
% coefplots = bar(coefplots);
% logcoefplots = bar(log(coefplots));
% coefplot = reshape(count,[16 16]);
% coefplot = coefplot/max(coefplot(:));
% graylevel = 255;
% colormap = zeros(1,size(coefs,1));
% [num ind] = sort(coefplot(:),1,'descend');
% for j = 1:length(ind)
%     colormap(ind(j)) = graylevel;
%     graylevel = graylevel-1;
% end
% coefplot = reshape(count,[16 16]);
% colormap = reshape(colormap,[16 16]);
% colormapfinal = zeros(8*16,8*16);
% for i1 = 1:16
%     for j1 = 1:16
%         colormapfinal(1+8*(i1-1):1+8*(i1-1)+7,1+8*(j1-1):1+8*(j1-1)+7) = colormap(i1,j1);
%     end
% end
end