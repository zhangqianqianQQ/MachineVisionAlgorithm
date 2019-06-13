function img_q = quantization(img,N)
    img = mat2gray(img);
    rchan = img(:,:,1); 
    gchan = img(:,:,2);
    bchan = img(:,:,3);
    q_step = 1/(N-1);
    T = linspace(0,1,N);
    [row,col] = size(img(:,:,1));
    for i = 1 : row
        for j = 1 : col
            rchan(i,j) = T(floor(rchan(i,j)/q_step)+1);
            gchan(i,j) = T(floor(gchan(i,j)/q_step)+1);
            bchan(i,j) = T(floor(bchan(i,j)/q_step)+1);
        end
    end
    img_q(:,:,1) = rchan;
    img_q(:,:,2) = gchan;
    img_q(:,:,3) = bchan;
    img_q = img_q * (N-1) + 1;
end

