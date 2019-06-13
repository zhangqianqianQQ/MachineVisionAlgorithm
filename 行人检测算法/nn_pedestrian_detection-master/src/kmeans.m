function [ centroid, variance, nfinal ] = kmeans(data, n)

    %% Check if dataset file already exists and only execute script if not
    if exist('cache/kmeans.mat', 'file') == 2
        display('Cache file found, loading precomputed data ...')
        tic
        
        load('cache/kmeans')
        
        display(['   ... Completed in ' num2str(toc) ' seconds.'])
        return
    end
    
    %% Initialize centroids
    display('Calculating k-Means ...')
    total_time = tic;
    
    centroid = data(1:n, :);
    assignment = zeros(size(data,1), 1);

    %% Iterate k-means algorithms
    epoch = 0;
    error_hist = NaN * ones(200,2);
    
    while true
        display(['   ... Executing epoch ' num2str(epoch + 1)])
        tic;
        
        last_assignment = assignment;

        distances = zeros(size(data,1), n);
        for i = 1:n
            distances(:, i) = ...
                sum((data - ones(size(data,1), 1) * centroid(i,:)) .^ 2, 2);
        end

        [~, assignment] = min(distances, [], 2);
        for i = 1:n
            if size(data(assignment == i, :), 1) ~= 0
                centroid(i, :) = mean(data(assignment == i, :));
            else
                centroid(i, :) = Inf;
            end
        end
        
        epoch = epoch + 1;
        error = sum(last_assignment ~= assignment);
        error_hist(epoch) = error;
        
        display(['       Error: ' num2str(error), ' execution time: ' num2str(toc)])
        if error == 0
            break
        end
    end
    
    %% Filter empty centroids
    mask = all(centroid ~= Inf, 2);
    centroid = centroid(mask, :);
    nfinal = size(centroid, 1);

    %% Calculate variance
    variance = zeros(n, size(data,2));
    for i = 1:n
        variance(i, :) = var(data(assignment == i, :));
    end
    variance = variance(mask, :);

    display(['   ... Completed in ' num2str(epoch) ' epochs and ' num2str(toc(total_time)) ' seconds.'])
    
    %% Plot error convergence
    figure(1)
    clf
    semilogy(error_hist / size(data, 1))
    hold on
    grid on
    xlabel('Número de épocas')
    ylabel('Variação de associação')
    legend('Treinamento')
    drawnow()
    set(gcf, 'paperunits', 'centimeters', 'paperposition', [0 0 10 10])
    print -dpng -r300 results/kmeans_train.png
    
    %% Save results
    save('cache/kmeans', 'centroid', 'variance');
end