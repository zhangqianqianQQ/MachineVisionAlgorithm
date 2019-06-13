% Shay Deutsch (shaydeu@math.ucla.edu)
% (c) Shay Deutsch, 2018
%%%%This is a demo function for robust denoising of piece-wise smooth
%%%%manifolds 
%1. Upload data and parameters
%2. Construct an affinity graph W and L (graph Laplacian)
%3. Take the Spectral Grpah Wavelet Transform for each manifold coordiante 
%4. Perform regularization for each of the SGW coefficients with respect to the affinity graph with similar spectral bands 
%5. Take the inverse SGW for each of the manifold coordaintes

%% Note some important parameters and varaibles:
%% feats - the input manifold
%% feats_denoised - the output denoised manifold
%%Parameters 
%-params.n_neighbors - k nearest neighbors parameter choice for the graph;
%-m- localization parameter in the vertex domain 
% params.k_band_denoise- localization parameter in the spectral domain
% L- Laplacian constructed from W
% dim- dimension of the manifold 
% feats -input manifold of dimension N by dim 
% feats_denoised -input manifold of dimension N by dim 
% full_wpall - cell contains all stored spectral wavelet coefficents
% full_wpall2 cell which contains all the denoised spectral wavelet coefficents
% lmax - largest eigenvalue of L the Laplacian
function Main_Demo()
addpath('/Users/shaydeutsch/Documents/Robust_PieceWise_Smooth_Denoising');
startup
%%%%% Strat with Loading data and parameters
dataName = 'circle';
%dataName = 'Hemisphere_plane';
%dataName=  'cyclo';
%dataName= 'fishbowl';
%dataName='sphere_helix';
%%%%% Choose a type of similarity graph 
%params.affinity_type = 'local_PCA';
%params.affinity_type = 'Hillinger_affinity';
params.affinity_type='sqeuclidean';
%params.affinity_type='Tensor_Voting';
loadDataset
loadParams
tic
%%%%% Constrcut an Affinity graph W
[ W, W1, S ,index_mat, index_vote,S_tan] = createAffMatrix( feats, params, params.affinity_type);
 toc
%% BEGIN Spectral Graph Wavelet Transform %%%%%%%
%Constrcut a K hop graph for each spectral band
K_hop_matrix_new=cell(1,params.k_band_denoise);
for k=1:params.k_band_denoise
    K_hop_matrix_new{k}=spalloc(N,N,300*N);
end
for k=1:params.k_band_denoise
    K_hop_matrix_new{k} = k_hope_matrix_new (W,k,params.Sigma,feats);
end
 L = sparse(sgwt_laplacian(W));
lmax = sgwt_rough_lmax(L);
arange = [0, lmax];
mydisp(['Measuring largest eigenvalue, lmax = ' n2s(lmax) ]);
mydisp('Designing transform in spectral domain');
%%%Construct 
%% designtype - type of filter used in the spectral domain 
designtype='abspline3';
[g, t] = sgwt_filter_design(lmax,params.Nscales,'designtype',designtype);
for k=1:numel(g)
    c{k} = sgwt_cheby_coeff(g{k},params.m,params.m+1,arange);
end
mydisp('finish coeffcient estimation');
h = waitbar(0,'sgwt_cheby_op...');
full_wpall =  cell(1,params.Nscales+1,dim);
full_wpall2 = cell(1,params.Nscales+1,dim);
for i=1:dim
    waitbar(i/dim,h)
    eachdimFeat = feats(i,:); 
    wpall = sgwt_cheby_op(eachdimFeat',L,c,arange);
    full_wpall(:,:,i) =  wpall;
    
end
[full_wpall2]= create_zero_array(full_wpall, dim, params);
close(h)
mydisp('finish forward transform ');

for i=1:dim
    %%%%%Denoising each band using Tichonov regularization
    full_wpall2{:,1,i} = full_wpall{:,1,i};
    for k=2:params.k_band_denoise
        W_k = K_hop_matrix_new{k};
        temp_k_band = (full_wpall{:,k,i})';
        % calls to Tikonov regularization
        params.iterTich=3;
        for iter=1:params.iterTich
        time_step_value=0.01;
        [temp_k_band,L_k]= time_step_RBF_new(W_k, temp_k_band, 0, time_step_value);
        full_wpall2{:,k,i} = temp_k_band';
        end
        full_wpall2{:,k,i} = temp_k_band';size(wpall(1))
    end
end
%%%%Take inverse Transform
feats_denoised = zeros(size(feats,1),size(feats,2));
parfor i=1:dim
    wpall2_temp = full_wpall2(:,:,i);
    feats_denoised(i,:) = sgwt_inverse(wpall2_temp,L,c,arange);
end
toc
%% END the inverse SGW and reconstruct the manifold coordinates from the denoised signals%%%%%%%%%
if dim==2
    %figure(100)
    figure;
    plot(feats(1,:),feats(2,:),'r.')
    hold on, axis equal
    plot(feats_denoised(1,:),feats_denoised(2,:),'b.')
    title('The denoised Manifold in blue Vs. noisy manifold in red');
 elseif dim>=3
    figure
    plot3(feats(1,:),feats(2,:),feats(3,:),'r.')
    hold on
    plot3(feats_denoised(1,:),feats_denoised(2,:),feats_denoised(3,:),'b.')
    title('The denoised Manifold in blue Vs. noisy manifold in red');
end


