% Codes written by Soheil Bahrampour
% October 19, 2013

% To perform online unsupervised task driven dictionary learning
% Inputs:
%       XArr is a array, consisting of concatination of train samples from all modalities.
%       n is a vector consiting of feature dimension for each modality
%       d is the number of columns in dictionary
%       opts contains the parameters
%       trls is the train lables:

% Output:
%       D is the Learned Dictionary which is an array with same rows as X
%           consiting of d dictionaries learned from different sensors


function D = OnlineUnsupTaskDrivDicLeaJointC(XArr, trls, n, d, opts)

uniqtrls = unique(trls);
number_classes = length(uniqtrls);
iter = opts.iterUnsupDic; % maxmimum number of iterations for iterative learning
rho = opts.rho; % regularization term for ADMM
computeCost = opts.computeCost; % flag for computing and ploting cost
batchSize = opts.batchSize;

sum_n = sum(n);
S = length(n); % number of sensors
N = size(XArr,2); % number of train samples
dicIterations = 10; % initially this number should be high enough to have convergance, select with care for each application and monitor cost to set this value

if d > N
    error('Number of dictionary columns should be smaller than or equal to the number of train samples ');
end
D = zeros(sum_n,d); 
numAtomPerClass = floor(d/number_classes); % number of atoms per class
if numAtomPerClass < 1
    error('at least one atom per class is required, increase dictionary size d');
end
%Initialize D using (randomy taken) train samples from each class
temp = 1;
for i = 1: number_classes
    tempIndex = find(trls==uniqtrls(1,i));
    permut2 = randperm(length(tempIndex));
%     D(:,temp:temp+numAtomPerClass-1) = XArr(:, tempIndex(permut2(1,1:numAtomPerClass))); % at least one sample from the  positive class
    D(:,temp:temp+numAtomPerClass-1) = XArr(:, tempIndex(1,1:numAtomPerClass)); % at least one sample from the  positive class but not selected randomly
    temp = temp + numAtomPerClass;
end
if d > number_classes*numAtomPerClass % fill the rest with random train samples
    permut = randperm(N); %randomly shuffle data
    D(:,temp:d) = XArr(:,permut(1:d-temp+1)); %initialize to first d train samples
end

% optimization
if computeCost
    costStep = floor(N/batchSize); % Compute cost every costStep over the last costStep batch of train samples. For each batch of train samples, the cost will be computed before updating the dic using that trian samples
    costTemp = zeros(costStep,1); % to store cost over lasr costStep samples
    costTempCount = 0; % to count how many train sample are passed
    cost = zeros(iter*N,1); %cost value at each iteration
    costIter = 0;
end
A_past = zeros(d, d, S);
B_past = zeros(sum_n, d);

permut = randperm(N); %randomly shuffle data
XArr = XArr(:,permut);

L = zeros(d*S, d);  % for ADMM
U = zeros(d*S, d);

for iteration = 1: iter % number of iterations over whole training samples    
    if iteration > 1 %10
        dicIterations = 1; %5
    end
    for t = 1: batchSize: N-rem(N,batchSize)
%         step = step + 1;
        % fix D, optimize A
        temp = 1;
        for s = 1:S
            [L((s-1)*d+1:s*d,:), U((s-1)*d+1:s*d,:)] = factor(D(temp:temp+n(s,1)-1,:), rho);  % cash  L U factroziation for solving ADMM for whole batch
            temp = temp+n(s,1);
        end
        Atemp = zeros(S*d,batchSize); % concatinate sparse vector of differen modals
        
        for j= 1: batchSize  % if not running in paralle
            alpha = JointADMMEigenMex(D, XArr(:,j+t-1), n, opts.lambda, rho, L, U, opts.iterADMM);  
            Atemp(:,j) = alpha(:);
        end
        
        % the vectorized code is used to optimize this block
%         for j = 1: batchSize
%             temp = 1;
%             for s = 1:S
%                 AA = Atemp((s-1)*d+1:s*d,j)* Atemp((s-1)*d+1:s*d,j)'/batchSize;
%                 BB = XArr(temp:temp+n(s,1)-1,j+t-1)*Atemp((s-1)*d+1:s*d,j)'/batchSize;
%                 A_past(:,:,s) = A_past(:,:,s) + AA;
%                 B_past(temp:temp+n(s,1)-1,:) = B_past(temp:temp+n(s,1)-1,:) + BB;
%                 temp = temp+n(s,1);
%             end
%         end
        % optimized version        
        temp = 1;
        for s = 1:S
            A_past(:,:,s) = A_past(:,:,s) + Atemp((s-1)*d+1:s*d,:)* Atemp((s-1)*d+1:s*d,:)'/batchSize;
            B_past(temp:temp+n(s,1)-1,:) = B_past(temp:temp+n(s,1)-1,:) + XArr(temp:temp+n(s,1)-1,t:t+batchSize-1)*Atemp((s-1)*d+1:s*d,:)'/batchSize;
            temp = temp+n(s,1);
        end
      
        % compute cost
        if computeCost
            if costTempCount == costStep
                costIter = costIter + 1;
                cost(costIter,1) = mean(costTemp);
                costTempCount = 0;
                costTemp = zeros(costStep,1);
            end
            costTempCount = costTempCount + 1;
            for j = 1: batchSize
                A = reshape(Atemp(:,j),d,S);
                costTemp(costTempCount,1) = opts.lambda/sqrt(d)*norm12(A);
                temp = 1;
                for s = 1: S
                    costTemp(costTempCount,1) = costTemp(costTempCount,1) + 1/2*norm(XArr(temp:temp+n(s,1)-1,j+t-1)- D(temp:temp+n(s,1)-1,:)*A(:,s))^2;
                    temp = temp+n(s,1);
                end
            end
            costTemp(costTempCount,1) = costTemp(costTempCount,1)/batchSize;
        end
        
        % fix A, optimize D
        temp = 1;
        for s = 1: S
            D_temp= D(temp:temp+n(s,1)-1,:);
            for l = 1: dicIterations
                for j = 1:d % each column of dictionary
                    if A_past(j,j,s) > 1e-12
                        D_temp(:,j) = D_temp(:,j) + (B_past(temp:temp+n(s,1)-1,j)-D_temp*A_past(:,j,s))/A_past(j,j,s);
                        tempNorm = sqrt(sum(D_temp(:,j).^2)); %norm(D_temp(:,j));
                        if tempNorm > 1
                            D_temp(:,j) = D_temp(:,j)/tempNorm;
                        end
                    end
                end
            end
            D(temp:temp+n(s,1)-1,:) = D_temp;
            temp = temp+n(s,1);
        end
    end
end
if computeCost
    cost = cost(1:costIter,1); % remove extra elements
    figure;plot(cost);
end
end

function f = norm12(W)
f = sum(sqrt(sum(W.^2,2)));
end