function X_extension = MirrowCut(X,hw)

% X  size: row * column * num_feature
[row col num_feature] = size(X);

X_extension = zeros(3*row,3*col,num_feature);
for i=1:num_feature
    lr = fliplr(X(:,:,i));
    ud = flipud(X(:,:,i));
    lrud = fliplr(ud);
    
    X_extension(:,:,i) = [lrud ud lrud; lr X(:,:,i) lr; lrud ud lrud];
end
X_extension = X_extension(row+1-hw:2*row+hw,col+1-hw:2*col+hw,:);
end