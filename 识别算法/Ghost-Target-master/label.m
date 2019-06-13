% Labels 64ths of imagae and saves to file
numImages = length(dir('C:\Users\brend_000\Documents\MATLAB\Machine Learning\Ghost Target\Images\cambride')) - 2;  
for imageNum = 1:5
    imgLabel = cell(8,8);
    image = imread(['C:\Users\brend_000\Documents\MATLAB\Machine Learning\Ghost Target\Images\cambridge\img',num2str(imageNum),'.jpg']);
    image = nxel(8,image);
    for i = 1:8
        for j = 1:8
            imshow(image{i,j})
            imgLabel{i,j} = input('Label?','s');
        end
    end
    save(['Images\cambridge_labels\img',num2str(imageNum),'.mat'],'imgLabel')
end
