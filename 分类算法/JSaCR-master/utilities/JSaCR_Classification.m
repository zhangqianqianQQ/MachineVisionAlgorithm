function class = JSaCR_Classification(DataTrains, CTrain, DataTests, lambda, c, gamma)

DataTrain = DataTrains(:,3:end);
DataTest  = DataTests(:,3:end); 

DDT = DataTrain*DataTrain';

numClass = length(CTrain);
[m Nt]= size(DataTest);
for j = 1: m
    if mod(j,round(m/20))==0
        fprintf('*...');        
    end
    
    xy = DataTests(j, 1:2);
    XY = DataTrains(:, 1:2);    
    norms = sum((abs(XY' - repmat(xy', [1 size(XY,1)]))).^c);
    norms = norms./max(norms);
    D = diag(gamma.*norms);
    
    Y = DataTest(j, :); % 1 x dim
    norms = sum((DataTrain' - repmat(Y', [1 size(DataTrain,1)])).^2);
    % norms = ones(size(DataTrain,1), 1);
    G = diag(lambda.*norms);
    weights = (DDT +  G + D)\(DataTrain*Y');
    
    a = 0;
    for i = 1: numClass 
        % Obtain Multihypothesis from training data
        HX = DataTrain((a+1): (CTrain(i)+a), :); % sam x dim
        HW = weights((a+1): (CTrain(i)+a));
        a = CTrain(i) + a;
        Y_hat = HW'*HX;
        
        Dist_Y(j, i) = norm(Y - Y_hat); 
    end
   Dist_Y(j, :) = Dist_Y(j, :)./sum(Dist_Y(j, :));
end
[~, class] = min(Dist_Y'); 
