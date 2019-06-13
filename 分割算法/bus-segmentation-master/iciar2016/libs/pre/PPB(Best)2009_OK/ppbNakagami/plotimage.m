function plotimage(img)

    img(:, :, 1) = img(:, :, 1);
    img(:, :, 2) = img(:, :, 1);
    img(:, :, 3) = img(:, :, 1);
    image(cast(img, 'uint8'));
    axis off
    axis image

end