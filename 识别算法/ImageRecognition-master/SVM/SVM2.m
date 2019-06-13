function SVM2()
    X = [];
    X =  LoadImages(X);
    X = double(X);
    L = Load_Labels();
    [DataSets,numPosLabels] = ReArrange(X,L);
    X = DataSets;
    L = numPosLabels;
    Weights = [];
    [Weights,Bs,alpha] = TrainSVM2(X,L);

    field1 = 'Weights';
    field2 = 'Bs';
    field3 = 'alpha';
    Model = struct(field1,Weights,field2,Bs,field3,alpha);
    save('Model.mat','Model');
    DataSets = [];
    numPosLabels = [];
end

function [DataSets,numPosLabels] = ReArrange(X,L)
Feats = X;
Labels = L;
l = unique(Labels);
X = cell(length(l),1);

for iter = 1:size(X,1)
    X{iter} =  [];   
end

for i = 1:size(Feats,1)
    r = find(l == Labels(i));
    X{r} = vertcat(cell2mat(X(r)),Feats(i,:));
end

DataSets = cell(length(l),1);
for iter = 1:size(X,1)
    DataSets{iter} =  [];   
end

numPosLabels = zeros(length(l),1);
for j = 1:length(l)
    T = cell2mat(X(j));
    numPosLabels(j) = size(T,1);
    F = [];
    for j2 = 1:length(l)
        if (j2 ~= j)
            F = vertcat(F,cell2mat(X(j2)));
        end
    end
    DataSets{j} = vertcat(T,F);
end   
end

function [Weights,Bs,alpha] = TrainSVM2(DataSets,numPosLabels)
Weights = cell(size(DataSets,1),1);
Bs = Weights;
t = cell2mat(DataSets(1));
alpha = randperm(size(t,2),size(t,2)/2);
% alpha = randperm(size(t,2),500);

for i = 1:size(DataSets,1)
% for i = 1:1
    Tee = cell2mat(DataSets(i));
%     T = T(1:5000,:);
%     T = double(T(1:2*numPosLabels(i),:));
    T = [];
    for s = 1:length(alpha)
%         T = horzcat(T, double(Tee(1:floor(6*numPosLabels(i)),alpha(s))));
        T = horzcat(T, double(Tee(1:3000,alpha(s))));
    end
    L = vertcat(ones(numPosLabels(i),1),-1 * ones(3000-numPosLabels(i),1));
%     L = vertcat(ones(numPosLabels(i),1),-1 * ones(floor(5*numPosLabels(i)),1));
    x0 = (1/size(T,1))*ones(size(T,1),1);
    i
    sig = 2;
    K = x0;
    
    f = -ones(1,size(T,1));
%     H = T*T';
    H = computeH(T,L,sig);
    H = H.*(L*L');
    
%     H = computeH(T,L,sig);
    Aeq = L';
    beq = zeros(1);
    lb = zeros(size(L));
    ub = 15*ones(size(L));
    
    options = optimoptions('quadprog',...
    'Algorithm','interior-point-convex','Display','off');
    [w_new,~,~]= quadprog(H,f',[],[],Aeq,beq,lb,ub,[],options);
  
    for IterM = 1:1
    Ws = zeros(1,size(T,2));
    for iter = 1:size(w_new,1)
        if (w_new(iter) > 0.001)
            Ws = Ws + (L(iter) * w_new(iter) * T(iter,:));
        end
    end
    bs = mean(L - ((Ws)*T')');
    
    [LCheck] = SVMclassify2(T,Ws,bs);
    Err = L - LCheck;
    IterM;
    size(find(Err ~= 0))

    end
    
    Weights{i} = Ws;
    Bs{i} = mean(L - ((Ws)*T')');
end
end

function [L] = SVMclassify2(X,Weights,Bs)
L = zeros(size(X,1),1);
    for iter = 1:size(X,1) 
        for i = 1:size(Weights,1) 
        k = (X(iter,:))*(Weights(i,:))'+ (Bs(i));
            if (k>0)
                L(iter) = 1;
            else
                L(iter) = -1;
            end
        end
    end
end

function [K] = computeQuadH(T,L)
% K = zeros(size(T,1));
% for i = 1:size(T,1)
%     for j = 1:size(T,1)
%         Num = (T(i,:))*(T(j,:)');
%         K(i,j) = (1+Num).^2;        
%     end
% end
size1=size(T);
size2=size(T);

G = sum((T.*T),2);
H = sum((T.*T),2);

Q = repmat(G,1,size2(1));
R = repmat(H',size1(1),1);

H = Q + R - 2*(T*T');

H = (1+H)^2;
end

function [H] = computeH(T,L,sig)

deg = sig;
size1=size(T);
size2=size(T);

G = sum((T.*T),2);
H = sum((T.*T),2);

Q = repmat(G,1,size2(1));
R = repmat(H',size1(1),1);

H = Q + R - 2*(T*T');

H=exp(-H/2/deg^2);
end

function [Features] =  LoadImages(X)
Features = [];
for j = 1:5
   num = num2str(j);
   str = strcat('../CIFAR10/small_data_batch_',num,'.mat');
   load(str);
    Feat = [];
    for i = 1:size(data,1)
        image = reshape(data(i,:),[32,32,3]);
        image = imresize(image,2);
        feat = extract_feature(image);
        Feat = horzcat(Feat,feat);
    end
    Features = vertcat(Features,Feat');
end
end