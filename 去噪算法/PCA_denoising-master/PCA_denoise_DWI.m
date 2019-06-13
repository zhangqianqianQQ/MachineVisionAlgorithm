function [denoised_data, PCs] = PCA_denoise_DWI(data,b_values,options)

%%
% Denoise IVIM data according to: 
% "Principal component analysis for fast and model-free denoising of multi b-value diffusion-weighted MR images"
% by XXX et al. Investigative Radiology 2019 DOI: XXX
%
% [denoised_data, PCs] = PCA_denoise_DWI(data,b_values,options) uses PCA-denoising to denoise a multi-b-value DWI data-set.
%
% Output:
% denoised_data: the denoised data
% PCs: the number of PCs taken along to generate the data
%
% Input:
% data can be 2D slice or 3D volume and should be sorted as follow:
% 2D data: n x m x b matrix, with 2D (n x m) data from b b-values/directions/repeated measures *note that PCA denoising has only been tested for 3D data, to ensure sufficient voxels to determine the signal fractions. Potentially, the performance on 2D data is less
% 3D data: n x m x p x b matrix, with 3D (n x m x p) data from b b-values/directions/repeated measures
% b_values: the b-value vector corresponding to the last column dimensions
% options: an optional structure with various options
% options.plot --> put to 1 to show plots of some steps
% options.cutoff --> a cutoff value; if the signal intensity of the mean image of the lowest b-value is below this value, this data is set to zero and removed from the PCA analysis.
% options.directions --> a vector of length b (where b= length final dimension of data), repressenting which measurements where done under similar diffusion directions. When options.directions is given, the algorithm will also sort data according to directional index when calculating ideal cut-off value for number of PCs. Please make sure same directions have same indexes. 
% By default zero-filled entries of the data corresponding to the first b-value will be ignored during PCA-denoising
%%

if size(size(data),2)~=3 && size(size(data),2)~=4
    error('data has the wrong number of dimensions, should be 3D or 4D, with last dimensions looping over b-values/directions/repeated measures');
end

if nargin==2
    options.plot=0;
end
if ~isfield(options,'plot')
    options.plot=0;
end

if isfield(options,'cutoff')
    ub=unique(b_values);
    if size(size(data),2)==4
        data(mean(data(:,:,:,b_values==min(ub)),4)<options.cutoff)=0;
    else 
        data(mean(data(:,:,b_values==min(ub)),3)<options.cutoff)=0;
    end
end

if size(size(data),2)==4
    mask=data(:,:,:,1)>0;
    [~, reshuffle]=sort(b_values);
    data=data(:,:,:,reshuffle);
    sel=reshape(data,[size(data,1)*size(data,2)*size(data,3) size(data,4)]);
elseif size(size(data),2)==3
    mask=data(:,:,1)>0;
    [~, reshuffle]=sort(b_values);
    data=data(:,:,reshuffle);
    sel=reshape(data,[size(data,1)*size(data,2) size(data,3)]);
end
[~, unshuffle]=sort(reshuffle);
sel=sel(mask,:);

[comp, score, latent]=pca(sel);
score=score(1:size(sel,1),:);

%% option to pressent plots of the PC's.

if options.plot~=0
    figure
    set(gcf,'Position',get(gcf,'Position')+[0 -300 300 300])
    subplot(3,3,1)
    plot(comp(:,1:9).*latent(1:9)','color',0.9*[1 1 1])
    hold on
    plot(comp(:,1)*latent(1),'LineWidth',2)
    xlabel('Image index')
    ylabel('PC 1    ','Rotation',0) 
    for ii=2:9
        subplot(3,3,ii)
        plot(comp(:,2:9).*latent(2:9)','color',0.7*[1 1 1])
        hold on
        plot(comp(:,ii)*latent(ii),'LineWidth',2)
        xlabel('Image index')
        ylabel(['PC ' num2str(ii) '    '],'Rotation',0) 
    end
    subplot(3,3,2)
    title('Plots of PCs scaled by PC variances (PC 1 omitted except on top-left plot)')
end

%% select the cut-off and generalte the data again
take_along=PCAcutoff(comp,score,options);

dataset=repmat(mean(sel),[size(score,1) 1])+score(:,1:take_along)*comp(:,1:take_along)';

%% generating the output:
PCs=take_along;

dataset(dataset<0)=0;
denoised_data=zeros(size(data));
if size(size(data),2)==4
    denoised_data(repmat(mask,[1 1 1 size(dataset,2)])>0.5)=dataset;
    denoised_data=denoised_data(:,:,:,unshuffle);
elseif size(size(data),2)==3
    denoised_data(repmat(mask,[1 1 size(dataset,2)])>0.5)=dataset;
    denoised_data=denoised_data(:,:,unshuffle);
end
end