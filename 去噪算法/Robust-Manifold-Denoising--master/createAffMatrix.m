function [ W, W1,S, index_mat,IDX_vote,S_tan,Data_PCA ] = createAffMatrix( feats,params,affinity_type )
%% W1 affinity matrix using Euclidean distances and RBF.

switch affinity_type
    case 'local_PCA'
       % [W1,index_mat, S] = RBF_affnity(feats,params);
        [W1,index_mat, S,IDX_vote,S_tan] = RBF_affnity_knn_fast(feats,params);
        %% W2 affinity using local tangent space with local PCA
        [Data_PCA,W2,theta] = locPCA_affnity_fast(feats, IDX_vote, params);
        %index_mat=IDX_vote;
        %% Connecting all the points
        Wc = W1.*W2;
        W = Wc.*Wc';
        
        %W_large=W_large.*W2;
        %W_large=W_large.*W_large;
        
    case 'Hillinger_affinity'
        %params.affinity_type='cosine';
      %  [W1, index_mat, S] = affinity.RBF_affnity(feats,params);
        [W1,index_mat, S,IDX_vote,S_tan] = RBF_affnity_knn(feats,params);
        params.affinity_type= 'Hillinger_affinity';
        
        [W2, W_l]= Hillinger_affinity( feats, IDX_vote,params); 
        Wc = W1.*W2;
        W = Wc.*Wc';       
    case 'sqeuclidean'  
       % [W1,index_mat, S] = affinity.RBF_affnity(feats,params);
      %  [W1,index_mat, S,IDX_vote,S_tan] = affinity.RBF_affnity_knn(feats,params);
        [W1,index_mat, S,IDX_vote,S_tan] = RBF_affnity_knn_fast(feats,params);
        W=W1;
        case 'outliers'  
        [W1,index_mat, S,IDX_vote,S_tan] = RBF_affnity_knn_fast(feats,params);
         W=W1;
        
    case 'cosine'
       % [W1,index_mat, S] = affinity.RBF_affnity(feats,params);
      % [W1,index_mat, S,IDX_vote,S_tan] = affinity.RBF_affnity_knn(feats,params);
       [W1,index_mat, S,IDX_vote,S_tan] = RBF_affnity_knn_fast(feats,params);
        
        
        W = W1;
    case 'Tensor_Voting'
        %[W1,index_mat, S] = affinity.RBF_affnity(feats,params);
        [W1,index_mat, S,IDX_vote,S_tan] = RBF_affnity_knn(feats,params);
        %% W2 affinity using the Tensor Voting Graph
        [Normal_Space,W2,theta] = TVG_affinity_knn(feats, IDX_vote, params,S_tan);
        %% Connecting all the points
        Wc = W1.*W2;
        %W=(Wc + Wc')./2;
        W = Wc.*Wc';
end
