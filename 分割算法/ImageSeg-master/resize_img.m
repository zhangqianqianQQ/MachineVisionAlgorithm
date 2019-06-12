function resized = resize_img(img)
    s = size(img);
    % scaling up to 600 if necessary
    minside = min([s(1), s(2)]);
    if minside < 600
        scale = 600/minside;
        numrow = floor(size(img, 1) * scale);
        numcol = floor(size(img, 2) * scale);
        resized= imresize(img, [numrow, numcol]);
    end
    % scaling down to 1000 if necessary
    maxside = max([s(1), s(2)]);
    if maxside > 1000
        scale = 1000/maxside;
        numrow = floor(size(img, 1) * scale);
        numcol = floor(size(img, 2) * scale);
        resized = imresize(img, [numrow, numcol]);
    end
end