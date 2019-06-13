function Training_Data = ReadFace(Training_Path)
% ---------- Construct 2D matrix from all of the 1D image vectors in the training data file ------------
flist = dir(strcat(Training_Path,'\*.jpg'));
Training_Data = [];
for imidx = 1:length(flist)
    fprintf('Constructing Training Image Data Space [%d] \n', imidx); 
    path = strcat(Training_Path,strcat('\',int2str(imidx),'.jpg'));
    img = imread(path);
    [irow icol] = size(img);
    temp = reshape(img',irow*icol,1);   % Reshaping 2D images to 1D image vectors
    Training_Data = [Training_Data temp];
end
fprintf('\n');