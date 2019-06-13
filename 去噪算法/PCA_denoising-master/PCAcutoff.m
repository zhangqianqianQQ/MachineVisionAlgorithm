function PCAcutoff = PCAcutoff(comp,score,options)


%%
% Select ideal number of PCs according to:
% "Principal component analysis for fast and model-free denoising of multi b-value diffusion-weighted MR images"
% by XXX et al. Investigative Radiology 2019 DOI: XXX
%
% PCAcutoff = PCAcutoff(comp,score,options)
%
% Output:
% PCAcutoff: the ideal cutoff number of PCs
%
% Input:
% comp: a matrix repressenting the PCs
% score: the corresponding PC scores
% options: an optional structure with various options
% options.plot --> put to 1 to show plots of some steps
% options.directions --> a vector of length b (where b= length final dimension of data), repressenting which measurements where done under similar diffusion directions. When options.directions is given, the algorithm will also sort data according to directional index when calculating ideal cut-off value for number of PCs. Please make sure same directions have same indexes.
%%

if nargin==2
    options.plot=0;
end
if ~isfield(options,'plot')
    options.plot=0;
end

offset2=zeros(size(comp,2),1);
for ii=1:size(comp,2)
    offset2(ii)=calc_auto_cor(comp(:,ii));
end
%% optional plots
if options.plot~=0
    figure; plot(offset2);
    ylim([0 15]);
    title('Plot of coherence lengths of the PCs (Fig 2 d)');
    xlabel('PC number')
    ylabel('Coherence length (R(l)>0)')
end

%% now calculating the same, but for directionally sorted data

if isfield(options,'directions')
    offset3=zeros(size(comp,2),1);
    [~, reshuffle]=sort(options.directions);
    comp=comp(reshuffle,:);
    for ii=1:size(comp,2)
        offset3(ii)=calc_auto_cor(comp(:,ii));
    end
end


%% optional plots
if options.plot~=0 && exist('offset3','var')
    figure; plot(offset3);
    ylim([0 15]);
    title('Plot of coherence lengths of the PCs for directional sorted PCs');
    xlabel('PC number')
    ylabel('Coherence length (R(l)>0)')
end

%% calculate the power of the PCs and fitting a polynomial to estimate the error
power_PC=mean(abs(score));
a1=polyfit(round(size(power_PC,2)/3):size(power_PC,2),power_PC(round(size(power_PC,2)/3):end),2);
dd=1:size(power_PC,2);
if options.plot~=0
    figure; plot(power_PC); hold on; plot(a1(3)+dd*a1(2)+a1(1)*dd.^2);
    title('Plot of the power on the PCs and fitted error contribution estimation (Fig 2a)');
    xlabel('PC number')
    ylabel('Power')
end

info_integ=zeros(size(dd));
info=power_PC-(a1(3)+dd*a1(2)+a1(1)*dd.^2);

%% numerical integral of the power
info_integ(1)=info(1);
for aa=dd(2:end)
    info_integ(aa)=info_integ(aa-1)+info(aa);
end

if options.plot~=0
    figure;plot(info_integ/info_integ(end));
    title('Plot of the information fraction of the PCs (Fig 2b right axis)');
    xlabel('PC number')
    ylabel('Power')
end

cutoff4=find(info_integ/info_integ(end)>0.97);
cutoff4=cutoff4(1);

if exist('options')==1
    if isfield(options,'directions')
        offset2=max(offset3,offset2);
        %% optional plots
        if options.plot~=0 && exist('offset3','var')
            figure; plot(offset2);
            ylim([0 15]);
            title('Plot of max coherence lengths (maxed over directional and b-value sorting)');
            xlabel('PC number')
            ylabel('Coherence length (R(l)>0)')
        end
    end
end

uz2=find(offset2(cutoff4+1:end)<4)+cutoff4-1;

PCAcutoff=uz2(1);
end

function offset=calc_auto_cor(S)
%% calculating the auto-correlation function and selecting the first l for which R(l)<0
if size(S,1)>15
    s=15;
else
    s=size(S,1)-1;
end

%% autocorrelation (R(l) function based upon implementation of ACF by Calvin Price v1.0.0.0 in 2011 on Matlab File exchange:
ta = zeros(s,1) ;
N = max(size(S,1)) ;
Su = mean(S);
for l = 1:s
    cross_sum = zeros(N-l,1) ;
    for n = (l+1):N
        cross_sum(n) = (S(n)-Su)*(S(n-l)-Su) ;
    end
    yvar = (S-Su)'*(S-Su) ;
    
    ta(l) = sum(cross_sum) / yvar ;
end
R=ta./(size(S,1)-(1:s))';

%% find first entry for which autocorrelation<0
digit=find(R<0);
if size(digit,1)>0
    offset=digit(1);
else
    offset=15;
end

end