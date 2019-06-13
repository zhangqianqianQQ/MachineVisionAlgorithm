function [Im_DN,D_] = Denoise(Im_N,Sigma,K,n,Algo)
% INPUT ARGUMENTS : Im_N - the noisy image (gray-level scale)
%                   Sigma - the s.d. of the noise (assume to be white Gaussian).
%                   K - the number of atoms in the representing dictionary.
%                   n - Block Size n x n 
%% Data Stuff
Reduce_DC = 1;
[N1,N2] = size(Im_N);
C = 1.15;                       % Taken from the Paper Elad 06
E_T = C*Sigma;                  % Required Average target Error in OMP
if Sigma > 5
    noIt = 10;
else
    noIt = 5;
end
MaxTPatches = 62001;

%% DCT Dictionary Creation
% D_DCT = Dict_DCT(n,K);
if Reduce_DC
    D_DCT = odctdict(n^2,K+1);
    D_DCT = D_DCT(:,2:end);
else
    D_DCT = odctdict(n^2,K);
end
%% Block Patches to Columns
fprintf('Learning Dictionary using %s\n',Algo);
if(prod([N1,N2]-n+1)> MaxTPatches)
    randPermutation =  randperm(prod([N1,N2]-n+1));
    selectedBlocks = randPermutation(1:MaxTPatches);

    Y = zeros(n^2,MaxTPatches);
    for i = 1:MaxTPatches
        [row,col] = ind2sub(size(Im_N)-n+1,selectedBlocks(i));
        currBlock = Im_N(row:row+n-1,col:col+n-1);
        Y(:,i) = currBlock(:);
    end
else
    Y = im2col(Im_N,[n,n],'sliding');       % Signal Y with patches as Columns
end

%% Reducing DC component
if (Reduce_DC)
    vecOfMeans = mean(Y);
    Y = Y-ones(size(Y,1),1)*vecOfMeans;
end

%% Data Whitening
% Y = Data_Whiten(Y,1);

%% Going into Dictionary Learning Algo for Training
D_ = normc(D_DCT);
for it = 1:noIt 
    W = omp2(D_,Y,D_'*D_,(n*E_T));    %
    switch lower(Algo)
        case 'ksvd'
            [D_,W] = Optimize_K_SVD(Y,D_,W);
        case 's1'
            alpha = .37;    
            [D_,W] = Optimize_S1(Y,D_,W,alpha);
        case 's1svd'
            alpha = 100;    gamma = 1;
            [D_,W] = Optimize_S1SVD(Y,D_,W,alpha,gamma);        
        otherwise
            error('Invalid Learning Method Specified');
            break;
    end
    D_ = I_clearDictionary(D_,W,Y);
    disp(['Iteration # ',num2str(it),' With average number of Coefficients = ',num2str(nnz(W)/size(W,2))])
end 

%% DEnoising with the Trained Dictionary
disp('Denoising with the Trained Dictionary')
Y = im2col(Im_N,[n,n],'sliding'); 
if (Reduce_DC)
    vecOfMeans = mean(Y);
    Y = Y-ones(size(Y,1),1)*vecOfMeans;
end
Coefs = omp2(D_,Y,D_'*D_,(n*E_T));
if (Reduce_DC)
    Y = D_*Coefs + ones(size(Y,1),1) * vecOfMeans;
else
    Y = D_*Coefs;
end

%% Generation and Averaging of The signal from Y (columns)
count = 1;
Weight= zeros(N1,N2);
IMout = zeros(N1,N2);
idx = 1:size(Y,2);
[rows,cols] = ind2sub(size(Im_N)-n+1,idx);
for i  = 1:length(cols)
    col = cols(i); row = rows(i);
    Y_ = reshape(Y(:,count),[n,n]);
    IMout(row:row+n-1,col:col+n-1) = IMout(row:row+n-1,col:col+n-1)+Y_;
    Weight(row:row+n-1,col:col+n-1) = Weight(row:row+n-1,col:col+n-1)+ones(n);
    count = count+1;
end;
Im_DN = (Im_N+0.034*Sigma*IMout)./(1+0.034*Sigma*Weight);

end

%% KSVD implementation for Elad 2006
function [D_,W] = Optimize_K_SVD(Y1,D_,W)
    R = Y1 - D_*W;
    for k=1:size(D_,2)
        I = find(W(k,:));
        Ri = R(:,I) + D_(:,k)*W(k,I);
        [U,S,V] = svds(Ri,1,'L');
        D_(:,k) = U;
        W(k,I) = S*V';
        R(:,I) = Ri - D_(:,k)*W(k,I);
    end     
end

%% S1 implementation
function [D,W] = Optimize_S1(Y,D,W,alpha)
    Ek = Y - D * W;
    for k = 1:size(D,2)       
        Eki = Ek + D(:,k)*W(k,:);
        for j = 1:2
            G = D(:,k)'*Eki;   g = std(G);  G = G./g; % std = 1
            %alpha2 = std(G)*alpha;
            W(k,:) = g.*sign(G).*max(0,abs(G)-alpha);
            D(:,k) = (Eki * W(k,:)')/norm(Eki * W(k,:)');
        end
%         nnz(W(k,:))
        Ek = Eki - D(:,k)*W(k,:);
    end
end

%% S1 WIth SVD Dictionary Update Stage
function [D,W] = Optimize_S1SVD(Y,D,W,alpha,gamma)
    Ek = Y - D * W;
    for k = 1:size(D,2)       
        Eki = Ek + D(:,k)*W(k,:);
        % SVD
%         [D(:,k),s,v] = svds(Eki,1,'L');
%         W(k,:) = s*v';
        % Power Iteration
        for i = 1:5
            W(k,:) = D(:,k)'*Eki;
            D(:,k) = Eki*W(k,:)';    D(:,k) = D(:,k)/norm(D(:,k));  
        end
        for j = 1:2     
            G = D(:,k)'*Eki;  g=1; %g = std(G);  G = G./g;    
            alpha2 = std(G)*alpha;
            W(k,:) = g.* sign(G).*max(0,(abs(G) - g.* alpha2./(abs(W(k,:)))));  %.^gamma
            D(:,k) = Eki*W(k,:)'/norm(Eki*W(k,:)');
        end
%             nnz(W(k,:))
        Ek = Eki - D(:,k)*W(k,:);
    end
end