% Codes written by Soheil Bahrampour
% Feb 14, 2014

% To perform online supervised task driven dictionary Learning on the train
% XArr with lable trls. The classifier is the multiclass qudratic classifier.

% Inputs:
%       XArr onsisting of train samples where different modalities are concatinated.
%       trls is the train lables
%       n is a vector consiting of feature dimension for each modality
%       d is the number of columns in dictionary
%       opts contains the parameters for multi-task optimization
%       nu is the regularization parameter for the classifier
%       ro is the constant for computing learnning rate
%       InitW consists of parameters for initializing W

% Output:
%       D is the Learned Dictionary which is cell array with same size as X
%           consiting of n*d dictionaries learned from different sensors
%       modelQuad is a Quadratic classifier consisting of the linear coeficients W
%       and bias term b

%%% sparce codes from different modalities are averaged to form the final
%%% feature vector which will be used for classification

function [D, modelQuad] = OnlineSupTaskDrivDicLeaDecFusJointQuadC(XArr, Y, n, d, opts, nu, ro, varargin)

iter = opts.iterSupDic;
rho = opts.rho; % regularization term for ADMM
computeCost = opts.computeCost; % flag for computing and ploting cost
batchSize = opts.batchSize;
intercept = opts.intercept;

sum_n = sum(n);
S = length(n); % number of sensors
N = size(XArr,2); % number of train samples
number_classes = size(Y,1);

if nargin > 7 % initial D is provided
    D  = varargin{1};
else   
    % Initialize D using (randomy taken) train samples + at least NumPos samples the positive lables  
    D = zeros(sum_n,d);
    permut = randperm(N); %randomly shuffle data
    tempIndex = find(trls==lable);
    NumPos = length(tempIndex); % May need to be tuned for the application
    permut2 = randperm(length(tempIndex));
    for s = 1: S
        if d > N
            error('Number of dictionary columns for a given class should be smaller than or equal to the number of train samples in that class');
        end
        D(:,1:d-NumPos) = XArr(:,permut(1:d-NumPos)); %initialize to first d train samples
        D(:,d-NumPos+1:end) = XArr(:, tempIndex(permut2(1,1:NumPos))); % at least one sample from the  positive class
    end
end

if nargin > 8 % % initial model parameters are provided
   modelQuad =  varargin{2};
   W = zeros(d, number_classes,S); % initialize W to small random numbers rather than setting all to zeros
   b = zeros(S, number_classes);
   for s=1:S
       W(:,:,s) = modelQuad{1,s}.W;
       b(s,:) = modelQuad{1,s}.b;
   end
else
    % intialize W using unsisupervised learning
    W = 0.01*randn(d, number_classes,S); % initialize W to small random numbers rather than setting all to zeros
    b = 0.01*zeros(S, number_classes);
end

% learning rate of the stochastic gradient descent algorithm
t0 = floor(N/batchSize)*iter/10; % after finalizing N % for setting the learning rate according to the task-driven dic learning paper: we set t0=T/10 where T is total number of updates
permut = randperm(N);
XArr = XArr(:,permut);
Y = Y(:,permut);

% optimization
if computeCost
    costStep = floor(N/batchSize); % Compute cost every costStep over the last costStep batch of train samples. For each batch of train samples, the cost will be computed before updating the dic using that trian samples
    costTemp = zeros(costStep,1); % to store cost over lasr costStep samples
    costTempCount = 0; % to count how many train sample are passed
    cost = zeros(iter*N,1); %cost value at each iteration
    costIter = 0;
end

step = 0;
BetaTemp2 = zeros(d,batchSize,S);       
Do = zeros(sum_n, S*d);
Atemp2 = zeros(d, S, N);
gradD = zeros(sum_n,d);
L = zeros(d*S, d);  % for ADMM
U = zeros(d*S, d);
gradW = zeros(d, number_classes, S);
gradb = zeros(S, number_classes);
for iteration = 1: iter % number of iterations over whole training samples
    for t = 1: batchSize: N-rem(N,batchSize) % to loop over all train samples
        step = step + 1;
        % find sparse code A
        Atemp = zeros(S*d,batchSize); % concatinate sparse vector of differen modals
        temp = 1;
        for s = 1:S
            [L((s-1)*d+1:s*d,:), U((s-1)*d+1:s*d,:)] = factor(D(temp:temp+n(s,1)-1,:), rho);  % cash  L U factroziation for solving ADMM for whole batch
            Do(temp: temp+n(s,1)-1, s:S:S*d) = D(temp:temp+n(s,1)-1, :);
            temp = temp+n(s,1);
        end
        DoTDoAll = Do'*Do; % computate Do'Do for all columns       
        for j= 1: batchSize  % if not running in paralle
            alpha = JointADMMEigenMex(D, XArr(:,j+t-1), n, opts.lambda, rho, L, U, opts.iterADMM);
            Atemp(:,j) = alpha(:);
            Atemp2(:,:,j+t-1) = alpha;
            act = zeros(d, 1); % to maintain active rows
            Gamma = zeros(d*S,d*S);
            temp = 1;
            temp_norm = sqrt(sum(alpha.^2,2));
            for row = 1:d
                if  temp_norm(row,1) > 10^(-8)
                    act(row) = 1;
                    Gamma(temp:temp+S-1, temp:temp+S-1) = (eye(S)-alpha(row,:)'*alpha(row,:)/temp_norm(row,1)^2)/temp_norm(row,1);
                    temp = temp + S;
                end
            end
            Gamma = Gamma(1:temp-1,1:temp-1);
            num_act = sum(act); % number of active rows
            act = logical(act);
            %%%
            %  flag = isAlphaValid(D, XArr(:,j+t-1), n, alpha, opts.lambda, act); % only to check optimality condition for alpha, should be commented after debug. 
            %%%
            Beta = zeros(d*S,1);
            W_act = W(act,:,:);
            gradLs_actAlphaVec = zeros(num_act,S);
            for s= 1:S
                gradLs_actAlphaVec(:,s) = W_act(:,:,s)*(W_act(:,:,s)'*alpha(act,s) + b(s,:)' - Y(:,j+t-1)); 
            end
            gradLs_actAt =  gradLs_actAlphaVec';
            gradLs_actAt_vec = gradLs_actAt(:);
            acts = act(:, ones(S,1))'; %repmat(act', S, 1); repmat is slow
            DoTDo = DoTDoAll(acts(:),acts(:));  % compute Do'Do for whole columns and then select relevant columns
            Beta(acts(:),1) = (DoTDo + opts.lambda*Gamma + opts.lambda2*eye(num_act*S))\gradLs_actAt_vec;   %use this iff ill-conditioned (lambda2 not equal zero)
            Beta(acts(:),1) = (DoTDo + opts.lambda*Gamma)\gradLs_actAt_vec;
            BetaTemp2(:,j,:) = reshape(Beta,S,d)'; 
%             temp = 1; % replaceed with a vectoried version for efficiency
%             for s= 1:S
%                 gradD(temp:temp+n(s,1)-1,:) = -(D(temp:temp+n(s,1)-1,:)*Beta(s:S:S*d,1))*alpha(:, s)' + (XArr(temp:temp+n(s,1)-1,j+t-1) - D(temp:temp+n(s,1)-1,:)*alpha(:, s))*Beta(s:S:S*d,1)' + gradD(temp:temp+n(s,1)-1,:);
%                 temp = temp+n(s,1);
%             end
%             temp2 = y(1,j+t-1)*gradLogReg(y(1,j+t-1)*(Atemp(:,j)'*W+b));
%             gradW = gradW + Atemp(:,j)*temp2;
%             if intercept
%                 gradb = gradb + temp2;
%             end
        end
        temp = 1;
        for s= 1:S
            temp3 = BetaTemp2(:,:,s)*squeeze(Atemp2(:, s, t:t+batchSize-1))';
            gradD(temp:temp+n(s,1)-1,:) = - D(temp:temp+n(s,1)-1,:)*temp3/batchSize + (XArr(temp:temp+n(s,1)-1,t:t+batchSize-1)*BetaTemp2(:,:,s)' - D(temp:temp+n(s,1)-1,:)*temp3')/batchSize;      
%             gradD(temp:temp+n(s,1)-1,:) = -(D(temp:temp+n(s,1)-1,:)*BetaTemp2(:,:,s))*squeeze(Atemp2(:, s, t:t+batchSize-1))'/batchSize + (XArr(temp:temp+n(s,1)-1,t:t+batchSize-1) - D(temp:temp+n(s,1)-1,:)*squeeze(Atemp2(:, s, t:t+batchSize-1)))*BetaTemp2(:,:,s)'/batchSize;
            temp = temp+n(s,1);
        end
        
        temp = 1;
        for s= 1:S
            temp2 = W(:,:,s)'*Atemp(temp:temp+d-1,:) + repmat(b(s,:)', 1, batchSize) - Y(:,t:t+batchSize-1);
            gradW(:,:,s)  = Atemp(temp:temp+d-1,:)*temp2'/batchSize + nu*W(:,:,s);
            if intercept
                gradb(s,:) = sum(temp2,2)'/batchSize;
            end
            temp = temp + d;
        end

%          error = checkGradientW(W,b,gradW, Atemp, Y(:,t), nu); % set batch size to 1 for checking
 %         error = checkGradientD(D,gradD, W,b, XArr(:,t), Y(:,t), nu, n, S, d, opts, rho, opts.iterADMM); % set batch size to 1 for checking

        % compute cost
        if computeCost
            if costTempCount == costStep
                costIter = costIter + 1;
                cost(costIter,1) = mean(costTemp);
                costTempCount = 0;
                costTemp = zeros(costStep,1);
            end
            costTempCount = costTempCount + 1;
             temp = 1;
             for s = 1 : S
                costTemp(costTempCount,1) = costTemp(costTempCount,1) + 0.5*sum(sum((Y(:,t:t+batchSize-1) - W(:,:,s)'*Atemp(temp:temp+d-1,:) - repmat(b(s,:)', 1, batchSize)).^2));
                temp = temp + d;
             end
             costTemp(costTempCount,1)= costTemp(costTempCount,1)/batchSize + nu/2*sum(sum(sum(W.^2))); % note that b is not regularized
        end
        
        % update W, b, D
        learnRate = min(ro, ro*t0/step);
        W = W - learnRate*gradW;
        if intercept
            b = b - learnRate*gradb;
        end
        D = D - learnRate*gradD;
        temp = 1;
        for s=1:S
            D(temp:temp+n(s,1)-1,:) = projectionDic(D(temp:temp+n(s,1)-1,:));
            temp = temp + n(s,1);
        end
    end
end
if computeCost
    cost = cost(1:costIter,1); % remove extra elements
    figure;plot(cost);
end

for s= 1:S
    modelQuad{1,s}.W = W(:,:,s);
    modelQuad{1,s}.b = b(s,:);
end
end

% function DoTDo = computeDotDo(D, S, n, sum_n, num_act, act)
% Do = zeros(sum_n, S*num_act);
% ind = 1;
% for s= 1:S
%     Do(ind: ind+n(s,1)-1, s:S:S*num_act) = D(ind:ind+n(s,1)-1, act);
%     ind = ind+n(s,1);
% end
% DoTDo = Do'*Do;
% end
% 
% function DoTDo = computeDotDo2(D, S, n, sum_n, d) % compute Do'Do for whole columns, not just active and save that
% Do = zeros(sum_n, S*d);
% ind = 1;
% for s= 1:S
%     Do(ind: ind+n(s,1)-1, s:S:S*d) = D(ind:ind+n(s,1)-1, :);
%     ind = ind+n(s,1);
% end
% DoTDo = Do'*Do;
% end

%%%% only with batchSize equal to 1
function error = checkGradientW(W, b, gradW, Atemp, y, nu)
epsil = 0.0001;
error = zeros(size(W,1), 1);
S = size(b,1);
d = size(W,1);
for i=1:size(W,1)
    W2 = W;
    W2(i,1) = W2(i,1) + epsil;
    temp = 1;
    costp = 0;
    for s = 1 : S
        costp = costp + 0.5*sum(sum((y - W2(:,:,s)'*Atemp(temp:temp+d-1,:) - b(s,:)').^2));
        temp = temp + d;
    end
    costp = costp + nu/2*sum(sum(sum(W2.^2))); % Note that b is not regularized
    W2(i,1) = W2(i,1) - 2*epsil;
    temp = 1;
    costn = 0;
    for s = 1 : S
        costn = costn + 0.5*sum(sum((y - W2(:,:,s)'*Atemp(temp:temp+d-1,:) - b(s,:)').^2));
        temp = temp + d;
    end
    costn = costn + nu/2*sum(sum(sum(W2.^2))); % Note that b is not regularized
    error(i,1)=(costp-costn)/2/epsil-gradW(i,1); % this should be close to zero
end
end


%%%% only with batchSize equal to 1
function error = checkGradientD(D,gradD, W, b, X, y, nu, n, S, d, opts, rho, iterADMM)
epsil = 0.0001;
L = zeros(d*S, d);  
U = zeros(d*S, d);
error = zeros(d*S, d);

for s= 1:S%S
    temp = 1;
    for s1 = 1:S
        [L((s1-1)*d+1:s1*d,:), U((s1-1)*d+1:s1*d,:)] = factor(D(temp:temp+n(s1,1)-1,:), rho);  % cash  L U factroziation for solving ADMM for whole batch
        temp = temp + n(s1,1);
    end
    temp = sum(n(1:s-1))+1;
    for j =1 : 20%size(D,2)
        for i=1:10%n(s,1)
            D2 = D;
            D2(temp+i-1,j) = D2(temp+i-1,j) + epsil;
            [L((s-1)*d+1:s*d,:), U((s-1)*d+1:s*d,:)] = factor(D2(temp:temp+n(s,1)-1,:), rho);
            alpha = JointADMMEigenMex(D2, X, n, opts.lambda, rho, L, U, iterADMM);       
            costp = 0;
            for s1=1:S
                costp = costp + 0.5*sum(sum((y - W(:,:,s1)'*alpha(:,s1) - b(s1,:)').^2));
            end
            costp = costp + nu/2*sum(sum(sum(W.^2))); % Note that b is not regularized
            D2(temp+i-1,j) = D2(temp+i-1,j) - 2*epsil;
            [L((s-1)*d+1:s*d,:), U((s-1)*d+1:s*d,:)] = factor(D2(temp:temp+n(s,1)-1,:), rho);
            alpha = JointADMMEigenMex(D2, X, n, opts.lambda, rho, L, U, iterADMM);
            costn = 0;
            for s1=1:S
                costn = costn + 0.5*sum(sum((y - W(:,:,s1)'*alpha(:,s1) - b(s1,:)').^2));
            end
            costn = costn + nu/2*sum(sum(sum(W.^2))); % Note that b is not regularized            
            error(temp+i-1,j)=(costp-costn)/2/epsil-gradD(temp+i-1,j); % this should be close to zero
        end
    end
end
end

function flag = isAlphaValid(D, X, n, alpha, lambda, act) % check optimality condition for joint sparsity given a candidate solution
flag = 0;
checkMat = zeros(size(alpha));
S = size(alpha,2);
temp = 1;
for s=1:S
    checkMat(:,s) = D(temp:temp+n(s,1)-1,:)'*(X(temp:temp+n(s,1)-1,:)-D(temp:temp+n(s,1)-1,:)*alpha(:,s)) ;
    temp = temp + n(s,1);
end
RHS = lambda*alpha(act,:)./repmat(sqrt(sum(alpha(act,:).^2,2)), 1,S);
if norm(checkMat(act,:)-RHS)< 1e-10 % if condition is valid for active set (approximately)
    if isempty(find(sqrt(sum(alpha(~act,:).^2,2)) > lambda, 1))
        flag = 1;
    end
end
end