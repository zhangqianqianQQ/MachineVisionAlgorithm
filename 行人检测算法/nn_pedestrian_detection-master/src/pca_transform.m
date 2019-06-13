function H = pca_transform(X, th)
    %% Check if dataset file already exists and only execute script if not
    if exist('cache/pca.mat', 'file') == 2
        display('Cache file found, loading precomputed data ...')
        tic
        
        load('cache/pca')
        
        display(['   ... Completed in ' num2str(toc) ' seconds.'])
        return
    end
    
    %% Calculate projection
    display('Executing PCA ...')
    tic
    
    Sigma = cov(X);
    [V, D] = eig(Sigma);
    
    V = V(end:-1:1, :);
    D = D(end:-1:1, end:-1:1);
    
    eigen = sqrt(max(diag(D), 0));
    H = V(cumsum(eigen) <= th * sum(eigen), :);
    
    %% Save result
    save('cache/pca', 'H')
    
    %% Plot results
    threshold_list = [0:0.01:1]';
    featurenum_list = zeros(size(threshold_list));
    for i = 1:size(threshold_list, 1)
        featurenum_list(i) = sum(cumsum(eigen) <= threshold_list(i) * sum(eigen));
    end
    
    figure(1)
    clf
    hold on
    grid on
    plot(threshold_list * 100, featurenum_list)
    plot(threshold_list * 100, ones(size(threshold_list)) * sum(cumsum(eigen) <= 0.99 * sum(eigen)), 'k--')
    plot(threshold_list * 100, ones(size(threshold_list)) * sum(cumsum(eigen) <= 0.95 * sum(eigen)), 'k-.')
    xlabel('Descrição dos datos [%]')
    ylabel('Número de características [-]')
    legend('Número de catacterísticas necessárias', '99% de descição', '95% de descrição')
    
    set(gcf, 'paperunits', 'centimeters', 'paperposition', [0 0 10 10])
    print -dpng -r300 results/pca.png
    
    display(['   ... ' num2str(size(eigen,1) - sum(cumsum(eigen) <= 0.999 * sum(eigen))) ' features represent 0.1%'])
    display(['   ... ' num2str(size(eigen,1) - sum(cumsum(eigen) <= 0.99 * sum(eigen))) ' features represent 1%'])
    display(['   ... Completed in ' num2str(toc) ' seconds.'])
end