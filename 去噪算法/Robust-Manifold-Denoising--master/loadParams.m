% Copyright (C) 2018,Shay Deutsch

N = size(feats,2);
dim = size(feats,1);
%mydisp(['Working with feat dim ' n2s(dim) ' with #samples ' n2s(N)]);
mydisp(['Graph based on ', params.affinity_type]);
switch dataName
    case 'circle'
        %% Number of neighbours
        params.n_neighbors = 10;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 3; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 1;
      %% order of polynomial approximation
        %params.m = 10;
        %% number of scales for SGW decomposition
        params.Nscales = 6;
        %params.Nscales = 35;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        %%%if Tensor Voting 
        params.Sigma_vote = 1 ;
        params.m = 6;
        params.powerCos = 1;
        params.iterTich = 2;
        params.time_step_value=0.5;
        case 'square'
        params.n_neighbors = 10;
        %params.n_neighbors = 20;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 2; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 1;
      %% order of polynomial approximation
        %params.m = 10;
        %% number of scales for SGW decomposition
        params.Nscales = 5;
        params.m = 5;
        %params.Nscales = 6;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        %%%if Tensor Voting 
        params.Sigma_vote = 4 ;
        params.Sigma_vote = 6 ;
        params.m = 5;
        params.powerCos = 2;
        %params.n_neighbors = 10;
        params.iterTich = 3;
        params.time_step_value=0.25;   
    case 'hole'
        params.n_neighbors = 15;
        %params.n_neighbors = 20;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 2; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 1;
      %% order of polynomial approximation
        %params.m = 10;
        %% number of scales for SGW decomposition
        params.Nscales = 5;
        params.m = 5;
        %params.Nscales = 6;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        %%%if Tensor Voting 
        params.Sigma_vote = 4 ;
        params.m = 5;
        params.powerCos = 2;
        %params.n_neighbors = 10;
        params.iterTich = 3;
        params.time_step_value=0.25;    
    case 'fishbowl'
        %% Number of neighbours
        params.n_neighbors = 15;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 1; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 1;
        params.powerCos = 2;
        %% order of polynomial approximation
        params.m = 4;
        %% number of scales for SGW decomposition
        params.Nscales = 4;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        params.iterTich = 3;
        params.time_step_value=0.25;  
        params.Sigma_vote = 0.2 ;
        params.Sigma_vote = 0.1 ;
         %params.Sigma_vote = 0.15 ;
         case 'sphere_helix'
        %% Number of neighbours
        params.n_neighbors = 8;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 1; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 1;
        params.powerCos = 1;
        %% order of polynomial approximation
        params.m = 5;
        %% number of scales for SGW decomposition
        params.Nscales = 5;
        params.Sigma_vote = 3 ;
        params.Sigma_vote = 0.6 ;
        params.Sigma_vote = 1 ;
        %params.Sigma_vote = 0.3 ;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        params.iterTich = 3;
        params.time_step_value=0.25; 
    case 'point_cloud'
        %% Number of neighbours
        params.n_neighbors = 15;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 0.5; %% for the affinity matrix
        params.Sigma = 2; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 2;
        params.powerCos = 2;
        %% order of polynomial approximation
        params.m = 5;
        %% number of scales for SGW decomposition
        params.Nscales = 5;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        params.iterTich = 3;
%         params.Sigma_vote = 0.005 ;
%         params.time_step_value=0.0005;      
        params.Sigma_vote = 0.001 ;
        params.time_step_value=0.0005;
        %params.affinity_type='Euclidean';
        case 'box_plane'
        %% Number of neighbours
        params.n_neighbors = 10;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 0.25; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 2;
        params.powerCos = 4;
        %% order of polynomial approximation
        params.m = 5;
        %% number of scales for SGW decomposition
        params.Nscales = 5;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        params.iterTich = 3;
%       params.Sigma_vote = 0.005 ;
%       params.time_step_value=0.0005;
        params.Sigma_vote = 0.005 ;
        params.time_step_value=0.00001;
        %params.affinity_type='Euclidean';
    case 'Hemisphere_plane'
        %% Number of neighbours
        params.n_neighbors = 20;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 0.25; %% for the affinity matrix
        params.Sigma = 0.5; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 2;
        params.powerCos = 4;
        %% order of polynomial approximation
        params.m = 5;
        %% number of scales for SGW decomposition
        params.Nscales = 5;
        params.m = 5;
%         %% number of scales for SGW decomposition
        params.Nscales = 5;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        params.iterTich = 3;
        params.iterTich = 3;
%       params.Sigma_vote = 0.005 ;
%       params.time_step_value=0.0005;
        params.Sigma_vote = 0.01 ;
        params.time_step_value=0.00001;
    case 'planes'
        params.n_neighbors = 10;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 0.25; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 2;
        params.powerCos = 4;
        %% order of polynomial approximation
        params.m = 5;
        %% number of scales for SGW decomposition
        params.Nscales = 5;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        params.iterTich = 3;
%       params.Sigma_vote = 0.005 ;
%       params.time_step_value=0.0005;
        params.Sigma_vote = 0.005 ;
        params.time_step_value=0.00001;
    
           
        case 'cyclo'
        %% Number of neighbours
         params.n_neighbors = 20;
        %% Scale of Gaussian weights based on Euclidean distances
        params.Sigma = 2; %% for the affinity matrix
        params.Sigma_noise = 0;
        %% Intrinsic dimensionality for local PCA or tensor voting
        params.int_dim = 1;
        params.powerCos = 4;
        %% order of polynomial approximation
        params.m = 5;
        %% number of scales for SGW decomposition
        params.Nscales = 5;
        %% Numbers of bands o denoise; usually the same as Nscales
        params.k_band_denoise = params.Nscales + 1;
        params.iterTich = 2;

        params.Sigma_vote = 0.2 ;
        params.time_step_value=0.00001;
       
        
       
end