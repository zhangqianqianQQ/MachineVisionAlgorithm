function Visualize_Eigenface(Eigenfaces, imgrow, imgcol)
%-------------------Show the maxmum nine pictures of Eigenfaces---------------
    Num_Eigenvalue = size(Eigenfaces,2);
    figure('Name','Eigenface')
    img = zeros(imgrow, imgcol);
    for i=1:min(Num_Eigenvalue,9)
        img(:) = Eigenfaces(:,i);
        subplot(3,3,i);
        imshow(img',[]);
    end
end