% Codes= written by Soheil Bahrampour
% Jan 2, 2014

% to perform stochastic gradiant descent (SDG) for multiclass quadratic
% cost function (formulation of 3.3.1 in PAMI paper) 
% Inputs:
%       X is data matrix with n (dimension of feature) rows and N (number of train
%           samples) columns
%       Y is the output vector of size q*N where each column is the output
%            vector for one observation in X
%       nu is the regularization parameter
%       iter: Number of epochs over whole data
%       intercept: fit intercept b as well (1) or not (0) (without regularization)
%       batchSize: Mini batch size for stochastic gradient descent
%       computeCost: Flag to compute the cost and plot it
%       ro: constant for computing learnning rate, ro = 5 worked well!

% Output:
%       linear parameter modelQuad.W and modelQuad.b

function modelQuad = SGDMultiClassQuadC(X, Y, nu, iter, intercept, batchSize, ro, computeCost)

N = size(X,2); % number of train samples
t0 = floor(N/batchSize)*iter/10; % for setting the learning rate according to the task-driven dic learning paper: we set t0=T/10 where T is total number of updates
n = size(X,1); % number of features
number_classes = size(Y,1);
W = zeros(number_classes, n);
b = zeros(number_classes, 1);

% optimization
if computeCost
    cost = zeros(iter*N,1); %cost value at each iteration
    costIter = 0;
    costStep = floor(N/batchSize); % Compute cost every costStep over the last costStep batch of train samples. For each batch of train samples, the cost will be computed before updating the dic using that trian samples
    costTemp = zeros(costStep,1); % to store cost over lasr costStep samples
    costTempCount = 0; % to count how many train sample are passed
end
step = 0;
permut = randperm(N); %randomly shuffle data
X = X(:,permut);
Y = Y(:, permut);

for iteration = 1: iter % number of iterations over whole training samples
    for t = 1: batchSize: N-rem(N,batchSize)
        step = step + 1;
        temp = W*X(:,t:t+batchSize-1) + repmat(b, 1, batchSize) - Y(:,t:t+batchSize-1);
        gradW = (temp)*X(:,t:t+batchSize-1)'/batchSize + nu*W;
        if intercept
            gradb = sum(temp,2)/batchSize; % Intercept wil not be regularized
        end 
        
        % compute cost (before update)
        if computeCost
            if costTempCount == costStep
                costIter = costIter + 1;
                cost(costIter,1) = mean(costTemp);
                costTempCount = 0;
                costTemp = zeros(costStep,1);
            end
            costTempCount = costTempCount + 1;
            costTemp(costTempCount,1)= 0.5*sum(sum((Y(:,t:t+batchSize-1) - W*X(:,t:t+batchSize-1)-repmat(b, 1, batchSize)).^2))/batchSize + nu/2*sum(sum(W.^2));
        end
        
        % update
        learnRate = min(ro, ro*t0/step);
        W = W - learnRate*gradW;
        if intercept
            b = b - learnRate*gradb;
        end
    end
end
if computeCost
    cost = cost(1:costIter,1); % remove extra elements
    figure;plot(cost);
end
modelQuad.W = W';
modelQuad.b = b';
end