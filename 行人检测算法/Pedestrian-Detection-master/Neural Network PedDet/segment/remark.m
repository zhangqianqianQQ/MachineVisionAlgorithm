%%
% mark windows in original image
function [ windows ] = remark( im, cens, sz1, sz2, r ,model )
%im -- colored img
%cordi -- window coordinates
windows = cell(1, size(cens, 1));
[h, w, ~] = size(im);
imshow(im)
hold on
%plot(cens(:,1), cens(:,2), 'gd')

for i = 1 : size(cens,1)
    ptx = cens(i, 1);
    pty = cens(i, 2);
    
    lb = max(ptx-(sz2/2)*r, 1);    %x cordinate
    ub = max(pty-(sz1/2)*r, 1);    %y cordinate
    %rectangle('Position', [lb ub 30 60], 'EdgeColor', 'g');
    
    rb = min(w, lb+sz2*r-1);
    db = min(h, ub+sz1*r-1);
    win = im(ub:db, lb:rb, :);
    if (~isempty(win))
        winx = imresize(win, [sz1, sz2]);
        %windows{i} = winx;
        if proj_inference( winx ,model)==2
            rectangle('Position', [lb ub sz2*r sz1*r], 'EdgeColor', 'g');
            windows{i} = winx;
        end
    end
    
    
end

%output the windows
%c = clock;
%strt = strcat(int2str(c(5)), int2str(c(6)*10000));

%print(strt, '-djpeg');

end

