%% Load library used for fHoG
clear all
addpath(genpath('../../tbxmanager/toolboxes/piotr_toolbox'))

%% Load dataset images
[X, y] = load_images();

%% Devided in 70% for training and 10% for validation and 20% for test
display('Dividing the dataset ...')
Xtrain = X(1:floor(0.7*size(X, 1)), :);
Xval = X(floor(0.7*size(X, 1)) + 1:floor(0.8*size(X, 1)), :);
Xtest = X(floor(0.8*size(X, 1))+1:end, :);

ytrain = y(1:floor(0.7*size(X, 1)), :);
yval = y(floor(0.7*size(X, 1)) + 1:floor(0.8*size(X, 1)), :);
ytest = y(floor(0.8*size(X, 1))+1:end, :);

display(['   ... Completed in ' num2str(toc) ' seconds.'])

%% Small cleanup
clear X y idx

%% Execute PCA (99% representation)
H = pca_transform(Xtrain, 0.99);

%% MLP training
[W1, W2] = mlp_train(Xtrain * H', ytrain, Xval * H', yval);

%% Create prediction anonymous function
g = @(x)(1 ./ (1 + exp(-x)));
o_nn = @(X)(g(W2 * [-ones(1, size(X, 1)); g(W1 * [-ones(size(X, 1), 1), X]')])');
o = @(X)(o_nn(X * H'));

%% Show results for MLP
display('Results for MLP ...')
tic; o(Xtest); 
display(['    ... Average prediction time: ' num2str(toc / size(Xtest,1))])
display('Confusion matrix')
confusionmat(ytest > 0.5, o(Xtest) > 0.5)

%% Run k-Means for RBF
[centroid, variance] = kmeans(Xtrain * H', ceil(sqrt(size(H,1))));

Xtrain_tf = rbf_kernel(Xtrain * H', centroid, variance);
Xval_tf = rbf_kernel(Xval * H', centroid, variance);

%% RBF Training
[W1rbf] = rbf_train(Xtrain_tf, ytrain, Xval_tf, yval);

%% Create prediction anonymous function
g = @(x)(1 ./ (1 + exp(-x)));
o_nn = @(X)(g(W1rbf * [-ones(1, size(X, 1)); rbf_kernel(X, centroid, variance)'])');
o = @(X)(o_nn(X * H'));

%% Show results for MLP
display('Results for RBF ...')
tic; o(Xtest); 
display(['    ... Average prediction time: ' num2str(toc / size(Xtest,1))])
display('Confusion matrix')
confusionmat(ytest > 0.5, o(Xtest) > 0.5)