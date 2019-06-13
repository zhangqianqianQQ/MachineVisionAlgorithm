%demostration of Region Ranking SVM (small scale)

%% path settings: check readme

addpath('/opt/ibm/ILOG/CPLEX_Studio128/cplex/matlab/x86-64_linux');
addpath('/opt/ibm/ILOG/CPLEX_Studio128/cplex/examples/src/matlab');


%% load data
try
load('valData.mat');
catch ME1
   error('valData not exist, try run createTestData first');
    
end

%% Ridge Regression/Least Square SVM:
%using mean of each bag as represetation
trD_g = cellfun( @(x)sum(x,2),trD,'UniformOutput', false) ;
trD_g=ML_Norm.l2norm( cat(2,trD_g{:}));

tstD_g = cellfun( @(x)sum(x,2),tstD,'UniformOutput', false) ;
tstD_g=ML_Norm.l2norm( cat(2,tstD_g{:}));


% lambda for Least Square SVM(ridge regression):
lambda=1e-4;

[w, b] = ML_Ridge.ridgeReg(trD_g, trLb, lambda, []);
%error
err = trD_g'*w + b - trLb;
totalErr = sum(err.^2);
% test:
pred=tstD_g'*w+b;
ap_ridge=ml_ap(pred,tstLb,0);
fprintf('Ridge Regression =====>  err: %.4f,ap:  %.4f\n', totalErr, ap_ridge);



%% Region Ranking SVM:

%init w,b from previous Ridge regression
opts.w=w;
opts.b=b;

[w, b, s, objVals] = RRSVM_s.train(trD, trLb, lambda, opts);

pred = RRSVM_s.predict(tstD, w, b, s);
ap_rrsvm = ml_ap(pred, tstLb, 0);
fprintf('Region Ranking SVM =====>  err: %.4f,ap:  %.4f\n', totalErr, ap_rrsvm);
fprintf('Number of valid regions: %d \n', sum(s>1e-5));